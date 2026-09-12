import 'dart:convert';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/features/scoring/services/scoring_engine.dart';
import 'package:hacktracker/core/domain/models/play_resolution.dart';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/models/player_gender.dart';
import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';
import 'package:uuid/uuid.dart';

/// Everything that writes to a live game. Every mutation ends by replaying the
/// log, so the cached columns on `games` can never drift from the plays.
class ScoringRepository {
  ScoringRepository(this._db, this._uuid);

  final AppDatabase _db;
  final Uuid _uuid;
  static const _replay = GameReplay();

  DateTime _now() => DateTime.now().toUtc();

  // ---------------------------------------------------------------- queries

  Future<Game?> game(String id) {
    return (_db.select(
      _db.games,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<PlateAppearance>> plateAppearances(String gameId) {
    return (_db.select(_db.plateAppearances)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  Stream<List<PlateAppearance>> watchPlateAppearances(String gameId) {
    return (_db.select(_db.plateAppearances)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .watch();
  }

  Future<List<GameEvent>> gameEvents(String gameId) {
    return (_db.select(_db.gameEvents)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .get();
  }

  Stream<List<GameEvent>> watchGameEvents(String gameId) {
    return (_db.select(_db.gameEvents)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.sequence)]))
        .watch();
  }

  Stream<List<GameInning>> watchInnings(String gameId) {
    return (_db.select(_db.gameInnings)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.inning)]))
        .watch();
  }

  Future<List<LineupSlot>> lineup(String gameId) {
    return (_db.select(_db.lineupSlots)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.battingOrder)]))
        .get();
  }

  Future<TeamSettings> teamSettings(String? teamId) async {
    if (teamId == null) return TeamSettings.defaults;
    final team = await (_db.select(
      _db.teams,
    )..where((t) => t.id.equals(teamId))).getSingleOrNull();
    return TeamSettings.fromJson(team?.settings);
  }

  // --------------------------------------------------------------- mutations

  Future<void> enterFieldMode(Game game, {String? userId}) async {
    return _db.transaction(() async {
      await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
        GamesCompanion(
          status: const Value('live'),
          scorerUserId: userId == null ? const Value.absent() : Value(userId),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
      await rebuild(game.id);
    });
  }

  Future<void> setContactMode(Game target, bool enabled) async {
    await _db.transaction(() async {
      final current = await game(target.id);
      if (current == null) throw StateError('Game not found');
      if (current.scoringDraft != null) {
        throw StateError(
          'Finish or cancel the current play before changing scoring mode.',
        );
      }
      final team = current.teamId == null
          ? null
          : await (_db.select(
              _db.teams,
            )..where((t) => t.id.equals(current.teamId!))).getSingleOrNull();
      final map =
          jsonDecode(
                current.settingsSnapshot ??
                    team?.settings ??
                    defaultTeamSettings,
              )
              as Map<String, dynamic>;
      final modules = Map<String, dynamic>.from(map['modules'] as Map? ?? {});
      modules['spray'] = enabled;
      map['modules'] = modules;
      await (_db.update(_db.games)..where((g) => g.id.equals(target.id))).write(
        GamesCompanion(
          settingsSnapshot: Value(jsonEncode(map)),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
    });
  }

  /// Files one play, detail and all, in a single write. The screen asks its
  /// questions before calling this, so a play never lands half-answered.
  Future<void> recordPa({
    required Game game,
    required PaResult result,
    OutKind? outKind,
    int? runsOnPlay,
    String? hitLocation,
    String? qualityOfContact,
    String? fielderPlayerId,
    PlayResolution? resolution,
  }) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final slots = await lineup(live.id);
      if (slots.isEmpty) return;
      final slot = slots[live.currentBatterIndex % slots.length];
      final batter = await _player(slot.playerId);
      if (hitLocation != null && ContactLocation.parse(hitLocation) == null) {
        throw const FormatException('Invalid ball location');
      }
      if (result == PaResult.walk || result == PaResult.strikeout) {
        hitLocation = null;
      } else if (hitLocation != null) {
        final detail = ContactLocation.parse(hitLocation)!;
        hitLocation = detail
            .withDetails(
              bats:
                  detail.bats ??
                  (['left', 'right'].contains(batter?.bats)
                      ? batter?.bats
                      : null),
            )
            .encode();
      }
      // An out that drives in a run is a sacrifice unless it was a grounder.
      // One rule decides that, whether the runs arrive now or in a correction.
      final out = result == PaResult.out
          ? _resolveOut(
              kind: outKind,
              runScored: (runsOnPlay ?? 0) > 0,
              runsOnPlay: runsOnPlay,
            )
          : null;
      final now = _now();
      await _db
          .into(_db.plateAppearances)
          .insert(
            PlateAppearancesCompanion.insert(
              id: _uuid.v4(),
              teamId: Value(live.teamId),
              gameId: live.id,
              playerId: slot.playerId,
              personId: Value(batter?.personId),
              batterWasMale: Value(batter?.gender == PlayerGender.male),
              resolution: Value(resolution?.encode()),
              sequence: await _nextSequence(live.id),
              inning: live.currentInning,
              inningHalf: live.currentHalf,
              result: out?.result.value ?? result.wire,
              outKind: Value(out != null ? out.outKind.value : outKind?.wire),
              runsOnPlay: Value(
                out != null ? out.runsOnPlay.value : runsOnPlay,
              ),
              hitLocation: Value(hitLocation),
              qualityOfContact: Value(qualityOfContact),
              fielderPlayerId: Value(fielderPlayerId),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await saveDraft(live.id, null);
      await rebuild(live.id);
    });
  }

  /// Scorer's correction to runs on the play (team) or RBI (personal). On an
  /// out, a run scoring also decides whether it was a sacrifice fly.
  Future<void> setRunsOnPlay({
    required Game game,
    required String paId,
    required int? runs,
  }) async {
    return _db.transaction(() async {
      final row = await _pa(paId);
      if (row == null) return;
      final result = PaResult.fromWire(row.result);
      if (result == PaResult.out || result == PaResult.sacFly) {
        await _writePa(
          paId,
          _resolveOut(
            kind: OutKind.fromWire(row.outKind),
            runScored: (runs ?? 0) > 0,
            runsOnPlay: runs,
          ),
        );
      } else {
        await _writePa(
          paId,
          PlateAppearancesCompanion(runsOnPlay: Value(runs)),
        );
      }
      await rebuild(game.id);
    });
  }

  /// How an out was made. Null means a strikeout, which is its own result.
  Future<void> setOutKind({
    required Game game,
    required String paId,
    required OutKind? kind,
  }) async {
    return _db.transaction(() async {
      final row = await _pa(paId);
      if (row == null) return;
      final result = PaResult.fromWire(row.result);
      if (!result.recordsOut || result == PaResult.fieldersChoice) return;
      if (kind == null) {
        await _writePa(
          paId,
          PlateAppearancesCompanion(
            result: Value(PaResult.strikeout.wire),
            hitLocation: const Value(null),
            outKind: const Value(null),
          ),
        );
      } else {
        final runScored =
            result == PaResult.sacFly || (row.runsOnPlay ?? 0) > 0;
        await _writePa(
          paId,
          _resolveOut(
            kind: kind,
            runScored: runScored,
            runsOnPlay: row.runsOnPlay,
          ),
        );
      }
      await rebuild(game.id);
    });
  }

  /// A run crossed on an out. Whether that makes it a sacrifice fly depends on
  /// how the out was made.
  Future<void> setRunScoredOnOut({
    required Game game,
    required String paId,
    required bool scored,
  }) async {
    return _db.transaction(() async {
      final row = await _pa(paId);
      if (row == null) return;
      final result = PaResult.fromWire(row.result);
      if (result != PaResult.out && result != PaResult.sacFly) return;
      await _writePa(
        paId,
        _resolveOut(
          kind: OutKind.fromWire(row.outKind),
          runScored: scored,
          runsOnPlay: scored ? row.runsOnPlay : null,
        ),
      );
      await rebuild(game.id);
    });
  }

  /// One rule for every out-family write, so the stored result never
  /// disagrees with the kind and the runs.
  PlateAppearancesCompanion _resolveOut({
    required OutKind? kind,
    required bool runScored,
    required int? runsOnPlay,
  }) {
    if (!runScored) {
      return PlateAppearancesCompanion(
        result: Value(PaResult.out.wire),
        runsOnPlay: const Value(null),
        outKind: Value(kind?.wire),
      );
    }
    if (kind == OutKind.ground) {
      return PlateAppearancesCompanion(
        result: Value(PaResult.out.wire),
        runsOnPlay: Value(math.max(runsOnPlay ?? 1, 1)),
        outKind: Value(kind?.wire),
      );
    }
    return PlateAppearancesCompanion(
      result: Value(PaResult.sacFly.wire),
      runsOnPlay: Value(runsOnPlay),
      outKind: Value(kind?.wire),
    );
  }

  Future<void> setBatterScored({
    required Game game,
    required String paId,
    required bool scored,
  }) async {
    return _db.transaction(() async {
      await _writePa(
        paId,
        PlateAppearancesCompanion(batterScored: Value(scored)),
      );
      await rebuild(game.id);
    });
  }

  /// Change a play already in the log. Overrides are dropped because they were
  /// chosen for the old result.
  Future<void> changePaResult({
    required Game game,
    required String paId,
    required PaResult result,
  }) async {
    return _db.transaction(() async {
      await _writePa(
        paId,
        PlateAppearancesCompanion(
          result: Value(result.wire),
          hitLocation: result == PaResult.walk || result == PaResult.strikeout
              ? const Value(null)
              : const Value.absent(),
          resolution: const Value(null),
          runsOnPlay: const Value(null),
          batterScored: const Value(null),
          outKind: const Value(null),
        ),
      );
      await rebuild(game.id);
    });
  }

  Future<void> setPaDetail({
    required Game game,
    required String paId,
    String? hitLocation,
    String? qualityOfContact,
    String? fielderPlayerId,
  }) async {
    return _db.transaction(() async {
      if (hitLocation != null && ContactLocation.parse(hitLocation) == null) {
        throw const FormatException('Invalid ball location');
      }
      final row = await _pa(paId);
      if (row == null || row.gameId != game.id) {
        throw StateError('Play not in this game');
      }
      if (row.result == PaResult.walk.wire ||
          row.result == PaResult.strikeout.wire) {
        hitLocation = null;
      }
      await _writePa(
        paId,
        PlateAppearancesCompanion(
          hitLocation: Value(hitLocation),
          qualityOfContact: Value(qualityOfContact),
          fielderPlayerId: fielderPlayerId == null
              ? const Value.absent()
              : Value(fielderPlayerId),
        ),
      );
      await rebuild(game.id);
    });
  }

  Future<void> deletePa({required Game game, required String paId}) async {
    return _db.transaction(() async {
      final now = _now();
      await _writePa(paId, PlateAppearancesCompanion(deletedAt: Value(now)));
      await rebuild(game.id);
    });
  }

  /// Removes the newest log entry, whichever kind it is. An opponent half comes
  /// back as an open tally so the runs are not lost.
  Future<void> undoLast(Game game) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final pas = await plateAppearances(live.id);
      final events = await gameEvents(live.id);
      final lastPa = pas.isEmpty ? null : pas.last;
      final lastEvent = events.isEmpty ? null : events.last;
      if (lastPa == null && lastEvent == null) return;

      final now = _now();
      final newestIsEvent =
          lastEvent != null &&
          (lastPa == null || lastEvent.sequence > lastPa.sequence);

      if (newestIsEvent) {
        await (_db.update(
          _db.gameEvents,
        )..where((t) => t.id.equals(lastEvent.id))).write(
          GameEventsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            syncState: const Value(1),
          ),
        );
        // Put the runs back on the open tally so nothing is lost.
        final ours = lastEvent.kind == GameEventKind.ourHalf;
        await (_db.update(_db.games)..where((t) => t.id.equals(live.id))).write(
          GamesCompanion(
            ourHalfRuns: ours ? Value(lastEvent.runs) : const Value.absent(),
            theirHalfRuns: ours ? const Value.absent() : Value(lastEvent.runs),
            updatedAt: Value(now),
            syncState: const Value(1),
          ),
        );
      } else if (lastPa != null) {
        await _writePa(
          lastPa.id,
          PlateAppearancesCompanion(deletedAt: Value(now)),
        );
      }
      await rebuild(live.id);
    });
  }

  Future<void> bumpTheirHalfRuns({
    required Game game,
    required int delta,
  }) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final next = (live.theirHalfRuns + delta).clamp(0, 99);
      await (_db.update(_db.games)..where((t) => t.id.equals(live.id))).write(
        GamesCompanion(
          theirHalfRuns: Value(next),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
      await rebuild(live.id);
    });
  }

  /// Commits the open opponent tally to the log and hands the bats back.
  Future<void> endTheirHalf(Game game) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final now = _now();
      await _db
          .into(_db.gameEvents)
          .insert(
            GameEventsCompanion.insert(
              id: _uuid.v4(),
              teamId: Value(live.teamId),
              gameId: live.id,
              sequence: await _nextSequence(live.id),
              kind: GameEventKind.theirHalf,
              runs: Value(live.theirHalfRuns),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await (_db.update(_db.games)..where((t) => t.id.equals(live.id))).write(
        GamesCompanion(
          theirHalfRuns: const Value(0),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await rebuild(live.id);
    });
  }

  /// A personal game's independent team tally, including every run this half.
  /// Player RBI and runs never change the scoreboard.
  Future<void> bumpOurHalfRuns({required Game game, required int delta}) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final next = (live.ourHalfRuns + delta).clamp(0, 99);
      await (_db.update(_db.games)..where((t) => t.id.equals(live.id))).write(
        GamesCompanion(
          ourHalfRuns: Value(next),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
      await rebuild(live.id);
    });
  }

  /// Ends our half by hand. A team game ends it on the third out and never
  /// needs this.
  Future<void> endOurHalf(Game game) async {
    return _db.transaction(() async {
      final live = await this.game(game.id) ?? game;
      final now = _now();
      await _db
          .into(_db.gameEvents)
          .insert(
            GameEventsCompanion.insert(
              id: _uuid.v4(),
              teamId: Value(live.teamId),
              gameId: live.id,
              sequence: await _nextSequence(live.id),
              kind: GameEventKind.ourHalf,
              runs: Value(live.ourHalfRuns),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await (_db.update(_db.games)..where((t) => t.id.equals(live.id))).write(
        GamesCompanion(
          ourHalfRuns: const Value(0),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await rebuild(live.id);
    });
  }

  /// Switch a personal game between just-my-at-bats and keeping team scores.
  /// Nothing is lost either way; the replay just reads more or less of the log.
  Future<void> setGameScope({required Game game, required String scope}) async {
    return _db.transaction(() async {
      await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
        GamesCompanion(
          scope: Value(scope),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
      await rebuild(game.id);
    });
  }

  /// Jump the order — subs, or a batter who was missed. Deliberately does not
  /// replay: the next play records this batter and the order picks up there.
  Future<void> jumpToBatter({required Game game, required int index}) async {
    return _db.transaction(() async {
      await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
        GamesCompanion(
          currentBatterIndex: Value(index),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
    });
  }

  Future<void> finalizeGame(Game game) async {
    return _db.transaction(() async {
      await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
        GamesCompanion(
          status: const Value('final'),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
    });
  }

  Future<void> reopenGame(Game game) async {
    return _db.transaction(() async {
      await (_db.update(_db.games)..where((t) => t.id.equals(game.id))).write(
        GamesCompanion(
          status: const Value('live'),
          updatedAt: Value(_now()),
          syncState: const Value(1),
        ),
      );
    });
  }

  /// Throws the whole game away: the game and everything recorded against it.
  /// Soft, like every other delete here, so it syncs; and every list and every
  /// stat already reads past a deleted game, so it leaves no trace in either.
  Future<void> discardGame(Game game) async {
    return _db.transaction(() async {
      final now = _now();
      final id = game.id;
      await (_db.update(
        _db.plateAppearances,
      )..where((t) => t.gameId.equals(id) & t.deletedAt.isNull())).write(
        PlateAppearancesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await (_db.update(
        _db.gameEvents,
      )..where((t) => t.gameId.equals(id) & t.deletedAt.isNull())).write(
        GameEventsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await (_db.update(
        _db.gameInnings,
      )..where((t) => t.gameId.equals(id) & t.deletedAt.isNull())).write(
        GameInningsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await (_db.update(
        _db.lineupSlots,
      )..where((t) => t.gameId.equals(id) & t.deletedAt.isNull())).write(
        LineupSlotsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await (_db.update(
        _db.gameCompetitions,
      )..where((t) => t.gameId.equals(id) & t.deletedAt.isNull())).write(
        GameCompetitionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
      await (_db.update(_db.games)..where((t) => t.id.equals(id))).write(
        GamesCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          scoringDraft: const Value(null),
          syncState: const Value(1),
        ),
      );
    });
  }

  /// Seeds a correction from the original state, retaining runner identities.
  Future<({ReplayedGame before, PlayResolution resolution})> resolutionFor(
    String gameId,
    String paId,
  ) async {
    final pa = await _pa(paId);
    final game = await this.game(gameId);
    if (pa == null || game == null || pa.gameId != gameId) {
      throw StateError('Play not found.');
    }
    final before = await replay(gameId, beforeSequence: pa.sequence);
    final saved = PlayResolution.decode(pa.resolution);
    if (saved != null) return (before: before, resolution: saved);
    final settings = game.settingsSnapshot == null
        ? await teamSettings(game.teamId)
        : TeamSettings.fromJson(game.settingsSnapshot);
    final result = PaResult.fromWire(pa.result);
    final outcome = const ScoringEngine().apply(
      before: before.bases,
      result: result,
      batterId: pa.playerId,
      outsBefore: 0,
      rules: settings.rules,
      teamHomeRunsSoFar: before.homeRuns,
      batterIsMale: pa.batterWasMale ?? false,
      runsOverride: pa.runsOnPlay,
    );
    final runners = <RunnerDecision>[];
    for (final id in [
      pa.playerId,
      before.bases.first,
      before.bases.second,
      before.bases.third,
    ].whereType<String>()) {
      var destination = 0;
      for (var base = 1; base <= 3; base++) {
        if (outcome.bases.at(base) == id) destination = base;
      }
      if (outcome.scoredPlayerIds.contains(id)) destination = 4;
      // An inning-ending result clears the diamond, but doesn't retire everyone.
      if (outcome.inningEnded &&
          id != pa.playerId &&
          result != PaResult.fieldersChoice) {
        for (var base = 1; base <= 3; base++) {
          if (before.bases.at(base) == id) destination = base;
        }
      }
      runners.add(
        RunnerDecision(
          playerId: id,
          destination: destination,
          rbi:
              destination == 4 &&
              result.earnsRbi &&
              (id != pa.playerId || result == PaResult.homer),
        ),
      );
    }
    return (before: before, resolution: PlayResolution(runners: runners));
  }

  Future<void> scoreRunner({
    required Game game,
    required String paId,
    required String playerId,
  }) => _db.transaction(() async {
    final context = await resolutionFor(game.id, paId);
    final runner = context.resolution.runners
        .where((r) => r.playerId == playerId)
        .firstOrNull;
    if (runner == null || runner.destination < 1 || runner.destination > 3) {
      throw StateError('This runner is no longer on base.');
    }
    final pa = await _pa(paId);
    final result = PaResult.fromWire(pa!.result);
    await setResolution(
      game: game,
      paId: paId,
      resolution: PlayResolution(
        runners: [
          for (final r in context.resolution.runners)
            r.playerId == playerId
                ? RunnerDecision(
                    playerId: playerId,
                    destination: 4,
                    rbi: result.earnsRbi && playerId != pa.playerId,
                  )
                : r,
        ],
        thirdOutNegatesRuns: context.resolution.thirdOutNegatesRuns,
      ),
    );
  });

  Future<void> setResolution({
    required Game game,
    required String paId,
    required PlayResolution resolution,
  }) => _db.transaction(() async {
    final pa = await _pa(paId);
    if (pa == null || pa.gameId != game.id) {
      throw StateError('Play not in this game.');
    }
    final before = await replay(game.id, beforeSequence: pa.sequence);
    final fly = OutKind.fromWire(pa.outKind)?.scoresAsSacFly ?? false;
    final becomesSac =
        pa.result == PaResult.out.wire &&
        fly &&
        before.outs < 2 &&
        resolution.runners.any((r) => r.destination == 4 && r.rbi);
    await _writePa(
      paId,
      PlateAppearancesCompanion(
        resolution: Value(resolution.encode()),
        result: becomesSac ? Value(PaResult.sacFly.wire) : const Value.absent(),
      ),
    );
    await rebuild(game.id);
  });

  Future<void> changeBatter({
    required Game game,
    required String paId,
    required String playerId,
  }) => _db.transaction(() async {
    final pa = await _pa(paId);
    final player = await _player(playerId);
    if (pa == null ||
        pa.gameId != game.id ||
        player == null ||
        player.teamId != game.teamId) {
      throw StateError('Choose a player from this team.');
    }
    final contact = ContactLocation.parse(pa.hitLocation);
    await _writePa(
      paId,
      PlateAppearancesCompanion(
        hitLocation: contact == null
            ? const Value.absent()
            : Value(
                ContactLocation(
                  x: contact.x,
                  y: contact.y,
                  region: contact.region,
                  flight: contact.flight,
                  bats: ['left', 'right'].contains(player.bats)
                      ? player.bats
                      : null,
                ).encode(),
              ),
        playerId: Value(playerId),
        personId: Value(player.personId),
        resolution: const Value(null),
        batterWasMale: Value(player.gender == PlayerGender.male),
      ),
    );
    await rebuild(game.id);
  });

  Future<void> saveDraft(String gameId, String? draft) =>
      (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
        GamesCompanion(scoringDraft: Value(draft)),
      );

  // ------------------------------------------------------------------ replay

  /// Turns stored rows into replay input. Shared with the UI so the screen and
  /// the database always agree.
  static List<GameEventInput> inputsFrom({
    required List<PlateAppearance> pas,
    required List<GameEvent> events,
    Map<String, String> genderByPlayerId = const {},
  }) {
    return [
      for (final pa in pas)
        PaEventInput(
          sequence: pa.sequence,
          paId: pa.id,
          playerId: pa.playerId,
          result: PaResult.fromWire(pa.result),
          runsOverride: pa.runsOnPlay,
          batterScoredOverride: pa.batterScored,
          batterIsMale:
              pa.batterWasMale ??
              (genderByPlayerId[pa.playerId] == PlayerGender.male),
          resolution: PlayResolution.decode(pa.resolution),
          hitLocation: pa.hitLocation,
          qualityOfContact: pa.qualityOfContact,
          outKind: OutKind.fromWire(pa.outKind),
        ),
      for (final event in events)
        if (event.kind == GameEventKind.theirHalf)
          TheirHalfEventInput(
            sequence: event.sequence,
            eventId: event.id,
            runs: event.runs,
          )
        else if (event.kind == GameEventKind.ourHalf)
          OurHalfEventInput(
            sequence: event.sequence,
            eventId: event.id,
            runs: event.runs,
          ),
    ];
  }

  Future<ReplayedGame> replay(String gameId, {int? beforeSequence}) async {
    final game = await this.game(gameId);
    if (game == null) {
      return _replay.run(
        events: const [],
        personal: true,
        weAreHome: true,
        lineupPlayerIds: const [],
      );
    }
    final slots = await lineup(gameId);
    final pas = await plateAppearances(gameId);
    final events = await gameEvents(gameId);
    final settings = game.settingsSnapshot == null
        ? await teamSettings(game.teamId)
        : TeamSettings.fromJson(game.settingsSnapshot);
    final genders = await _genders(slots.map((s) => s.playerId).toList());
    return _replay.run(
      events: inputsFrom(pas: pas, events: events, genderByPlayerId: genders)
          .where((e) => beforeSequence == null || e.sequence < beforeSequence)
          .toList(),
      personal: game.kind == GameKind.personal,
      tracksScore: game.scope == GameScope.game,
      weAreHome: game.homeAway == 'home',
      lineupPlayerIds: [for (final s in slots) s.playerId],
      rules: settings.rules,
      ourHalfRuns: game.ourHalfRuns,
      theirHalfRuns: game.theirHalfRuns,
    );
  }

  /// Replays the log and writes the derived values back: the score line on the
  /// game, the per-play numbers stats read, and the inning-by-inning line.
  Future<void> rebuild(String gameId) async {
    return _db.transaction(() async {
      final game = await this.game(gameId);
      if (game == null) return;
      final state = await replay(gameId);
      final pas = await plateAppearances(gameId);
      final byId = {for (final pa in pas) pa.id: pa};
      final now = _now();

      for (final played in state.pas) {
        final row = byId[played.paId];
        if (row == null) continue;
        final unchanged =
            row.effectiveResult == played.effective.wire &&
            row.rbi == played.rbi &&
            row.runsScored == played.runsScored &&
            row.outsRecorded == played.outsRecorded &&
            row.inning == played.inning &&
            row.inningHalf == played.half;
        if (unchanged) continue;
        await _writePa(
          played.paId,
          PlateAppearancesCompanion(
            effectiveResult: Value(played.effective.wire),
            rbi: Value(played.rbi),
            runsScored: Value(played.runsScored),
            outsRecorded: Value(played.outsRecorded),
            inning: Value(played.inning),
            inningHalf: Value(played.half),
          ),
        );
      }

      await _writeInnings(game, state);

      await (_db.update(_db.games)..where((t) => t.id.equals(gameId))).write(
        GamesCompanion(
          ourRuns: Value(state.ourRuns.clamp(0, 999)),
          theirRuns: Value(state.theirRuns.clamp(0, 999)),
          outs: Value(state.outs),
          currentInning: Value(state.inning),
          currentHalf: Value(state.half),
          firstBaseId: Value(state.bases.first),
          secondBaseId: Value(state.bases.second),
          thirdBaseId: Value(state.bases.third),
          currentBatterIndex: Value(state.nextBatterIndex),
          status: Value(
            game.status == 'scheduled' && state.pas.isNotEmpty
                ? 'live'
                : game.status,
          ),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
    });
  }

  /// One row per inning for the life of the game. Soft-deleted rows are revived
  /// rather than replaced, because the server keys them by game and inning.
  Future<void> _writeInnings(Game game, ReplayedGame state) async {
    final existing = await (_db.select(
      _db.gameInnings,
    )..where((t) => t.gameId.equals(game.id))).get();
    final byInning = {for (final row in existing) row.inning: row};
    final now = _now();
    final keep = <int>{};

    for (final line in state.innings) {
      keep.add(line.inning);
      final row = byInning[line.inning];
      if (row == null) {
        await _db
            .into(_db.gameInnings)
            .insert(
              GameInningsCompanion.insert(
                id: _uuid.v4(),
                teamId: Value(game.teamId),
                gameId: game.id,
                inning: line.inning,
                ourRuns: Value(line.ourRuns),
                theirRuns: Value(line.theirRuns),
                createdAt: now,
                updatedAt: now,
              ),
            );
        continue;
      }
      final unchanged =
          row.ourRuns == line.ourRuns &&
          row.theirRuns == line.theirRuns &&
          row.deletedAt == null;
      if (unchanged) continue;
      await (_db.update(
        _db.gameInnings,
      )..where((t) => t.id.equals(row.id))).write(
        GameInningsCompanion(
          ourRuns: Value(line.ourRuns),
          theirRuns: Value(line.theirRuns),
          deletedAt: const Value(null),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
    }

    for (final row in existing) {
      if (keep.contains(row.inning) || row.deletedAt != null) continue;
      await (_db.update(
        _db.gameInnings,
      )..where((t) => t.id.equals(row.id))).write(
        GameInningsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
    }
  }

  // ------------------------------------------------------------------ private

  Future<PlateAppearance?> _pa(String id) {
    return (_db.select(
      _db.plateAppearances,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Player?> _player(String id) {
    return (_db.select(
      _db.players,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<Map<String, String>> _genders(List<String> playerIds) async {
    if (playerIds.isEmpty) return const {};
    final rows = await (_db.select(
      _db.players,
    )..where((t) => t.id.isIn(playerIds))).get();
    return {for (final row in rows) row.id: row.gender};
  }

  /// One counter across plate appearances and events, including soft-deleted
  /// rows, so a sequence is never handed out twice.
  Future<int> _nextSequence(String gameId) async {
    final pas =
        await (_db.select(_db.plateAppearances)
              ..where((t) => t.gameId.equals(gameId))
              ..orderBy([(t) => OrderingTerm.desc(t.sequence)])
              ..limit(1))
            .getSingleOrNull();
    final events =
        await (_db.select(_db.gameEvents)
              ..where((t) => t.gameId.equals(gameId))
              ..orderBy([(t) => OrderingTerm.desc(t.sequence)])
              ..limit(1))
            .getSingleOrNull();
    final highest = [
      if (pas != null) pas.sequence,
      if (events != null) events.sequence,
    ];
    if (highest.isEmpty) return 0;
    return highest.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<void> _writePa(String paId, PlateAppearancesCompanion values) {
    return (_db.update(
      _db.plateAppearances,
    )..where((t) => t.id.equals(paId))).write(
      values.copyWith(updatedAt: Value(_now()), syncState: const Value(1)),
    );
  }
}
