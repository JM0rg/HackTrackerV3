import 'package:drift/drift.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';
import 'package:uuid/uuid.dart';

class MeRepository {
  MeRepository(this._db, this._uuid);

  final AppDatabase _db;
  final Uuid _uuid;

  DateTime _now() => DateTime.now().toUtc();

  Future<Person> ensureMe() async {
    final existing =
        await (_db.select(_db.people)
              ..where((t) => t.deletedAt.isNull())
              ..limit(1))
            .get();
    if (existing.isNotEmpty) {
      await _ensurePersonalPlayer(existing.first);
      return existing.first;
    }
    final now = _now();
    final id = _uuid.v4();
    await _db
        .into(_db.people)
        .insert(PeopleCompanion.insert(id: id, createdAt: now, updatedAt: now));
    final me = await (_db.select(
      _db.people,
    )..where((t) => t.id.equals(id))).getSingle();
    await _ensurePersonalPlayer(me);
    return me;
  }

  Stream<Person?> watchMe() {
    return (_db.select(_db.people)
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .watch()
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  Future<void> updateMe({
    required String firstName,
    String lastName = '',
  }) async {
    final me = await ensureMe();
    final now = _now();
    final display = lastName.trim().isEmpty
        ? firstName.trim()
        : '${firstName.trim()} ${lastName.trim()}';
    await (_db.update(_db.people)..where((t) => t.id.equals(me.id))).write(
      PeopleCompanion(
        firstName: Value(firstName.trim().isEmpty ? 'Me' : firstName.trim()),
        lastName: Value(lastName.trim()),
        displayName: Value(display.isEmpty ? 'Me' : display),
        updatedAt: Value(now),
        syncState: const Value(1),
      ),
    );
    final personal = await _personalPlayer(me.id);
    if (personal != null) {
      await (_db.update(
        _db.players,
      )..where((t) => t.id.equals(personal.id))).write(
        PlayersCompanion(
          firstName: Value(firstName.trim().isEmpty ? 'Me' : firstName.trim()),
          lastName: Value(lastName.trim()),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
    }
  }

  Future<void> linkToUser(String userId) async {
    final me = await ensureMe();
    if (me.linkedUserId != null && me.linkedUserId != userId) {
      throw StateError(
        'These local games belong to a different account. Sign in with that account to keep its scorebook separate.',
      );
    }
    await (_db.update(_db.people)..where((t) => t.id.equals(me.id))).write(
      PeopleCompanion(
        linkedUserId: Value(userId),
        updatedAt: Value(_now()),
        syncState: const Value(1),
      ),
    );
  }

  Future<void> attachMeToNewTeam(String teamId) async {
    final me = await ensureMe();
    final already =
        await (_db.select(_db.players)..where(
              (t) =>
                  t.teamId.equals(teamId) &
                  t.personId.equals(me.id) &
                  t.deletedAt.isNull(),
            ))
            .get();
    if (already.isNotEmpty) return;
    final now = _now();
    await _db
        .into(_db.players)
        .insert(
          PlayersCompanion.insert(
            id: _uuid.v4(),
            teamId: Value(teamId),
            personId: Value(me.id),
            firstName: me.firstName,
            lastName: Value(me.lastName),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> setRosterSlotAsMe({
    required String teamId,
    required String playerId,
  }) async {
    final me = await ensureMe();
    final now = _now();
    await _db.transaction(() async {
      final current =
          await (_db.select(_db.players)..where(
                (t) =>
                    t.teamId.equals(teamId) &
                    t.personId.equals(me.id) &
                    t.deletedAt.isNull(),
              ))
              .get();
      for (final row in current) {
        if (row.id == playerId) continue;
        await (_db.update(
          _db.players,
        )..where((t) => t.id.equals(row.id))).write(
          PlayersCompanion(
            personId: const Value(null),
            updatedAt: Value(now),
            syncState: const Value(1),
          ),
        );
      }
      await (_db.update(
        _db.players,
      )..where((t) => t.id.equals(playerId))).write(
        PlayersCompanion(
          personId: Value(me.id),
          updatedAt: Value(now),
          syncState: const Value(1),
        ),
      );
    });
  }

  /// Opponent and who you played with are both optional; a game with neither
  /// is just dated. [scope] decides whether the game keeps team scores, and
  /// [homeAway] only matters when it does.
  /// The newest personal game, which is where the start sheet's defaults
  /// come from.
  Future<Game?> lastPersonalGame() async {
    final games = await watchMyGames().first;
    for (final game in games) {
      if (game.kind == GameKind.personal) return game;
    }
    return null;
  }

  /// Opponents you have typed before, newest first, no repeats.
  Future<List<String>> recentOpponents({int limit = 5}) async {
    final games = await watchMyGames().first;
    final seen = <String>{};
    final out = <String>[];
    for (final game in games) {
      final name = game.opponentName?.trim();
      if (name == null || name.isEmpty) continue;
      if (!seen.add(name.toLowerCase())) continue;
      out.add(name);
      if (out.length >= limit) break;
    }
    return out;
  }

  // ------------------------------------------------------- personal teams

  /// Teams you play with, newest name first. Metadata only.
  Stream<List<PersonalTeam>> watchPersonalTeams() {
    return watchMe().asyncExpand((me) {
      if (me == null) return Stream.value(const <PersonalTeam>[]);
      return (_db.select(_db.personalTeams)
            ..where((t) => t.personId.equals(me.id) & t.deletedAt.isNull())
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();
    });
  }

  Future<List<PersonalTeam>> personalTeams() async {
    final me = await ensureMe();
    return (_db.select(_db.personalTeams)
          ..where((t) => t.personId.equals(me.id) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  /// Saves a team to reuse. A name that already exists comes back as-is
  /// rather than piling up duplicates.
  Future<PersonalTeam?> createPersonalTeam(String name) async {
    final clean = name.trim();
    if (clean.isEmpty) return null;
    final me = await ensureMe();
    final existing = await personalTeams();
    for (final team in existing) {
      if (team.name.toLowerCase() == clean.toLowerCase()) return team;
    }
    final now = _now();
    final id = _uuid.v4();
    await _db
        .into(_db.personalTeams)
        .insert(
          PersonalTeamsCompanion.insert(
            id: id,
            personId: me.id,
            name: clean,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(
      _db.personalTeams,
    )..where((t) => t.id.equals(id))).getSingle();
  }

  /// Forgets a saved team. Games already tagged with it keep their name.
  Future<void> deletePersonalTeam(String id) async {
    final now = _now();
    await (_db.update(_db.personalTeams)..where((t) => t.id.equals(id))).write(
      PersonalTeamsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: const Value(1),
      ),
    );
  }

  // -------------------------------------------------------- personal games

  Future<String> createPersonalGame({
    String? opponentName,
    String? playedForName,
    String? playedForTeamId,
    String scope = GameScope.bat,
    String homeAway = 'home',
  }) async {
    final me = await ensureMe();
    final batter = await _ensurePersonalPlayer(me);
    final now = _now();
    final id = _uuid.v4();
    String? clean(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    await _db
        .into(_db.games)
        .insert(
          GamesCompanion.insert(
            id: id,
            kind: const Value(GameKind.personal),
            scope: Value(scope),
            opponentName: Value(clean(opponentName)),
            playedForName: Value(clean(playedForName)),
            playedForTeamId: Value(playedForTeamId),
            startsAt: Value(now),
            homeAway: Value(homeAway),
            currentHalf: Value(homeAway == 'home' ? 'top' : 'top'),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _db
        .into(_db.lineupSlots)
        .insert(
          LineupSlotsCompanion.insert(
            id: _uuid.v4(),
            gameId: id,
            playerId: batter.id,
            battingOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Stream<List<Game>> watchMyGames() {
    return watchMe().asyncExpand((me) {
      if (me == null) return Stream.value(const <Game>[]);
      final query =
          _db.select(_db.games).join([
              innerJoin(
                _db.lineupSlots,
                _db.lineupSlots.gameId.equalsExp(_db.games.id),
              ),
              innerJoin(
                _db.players,
                _db.players.id.equalsExp(_db.lineupSlots.playerId),
              ),
            ])
            ..where(
              _db.players.personId.equals(me.id) &
                  _db.games.deletedAt.isNull() &
                  _db.lineupSlots.deletedAt.isNull() &
                  _db.players.deletedAt.isNull(),
            )
            ..orderBy([OrderingTerm.desc(_db.games.startsAt)]);
      return query.watch().map((rows) {
        final seen = <String>{};
        final games = <Game>[];
        for (final row in rows) {
          final game = row.readTable(_db.games);
          if (seen.add(game.id)) games.add(game);
        }
        return games;
      });
    });
  }

  Stream<List<Team>> watchTeamsIPlayOn() {
    return watchMe().asyncExpand((me) {
      if (me == null) return Stream.value(const <Team>[]);
      final query =
          _db.select(_db.teams).join([
            innerJoin(_db.players, _db.players.teamId.equalsExp(_db.teams.id)),
          ])..where(
            _db.players.personId.equals(me.id) &
                _db.teams.deletedAt.isNull() &
                _db.players.deletedAt.isNull(),
          );
      return query.watch().map((rows) {
        final seen = <String>{};
        final teams = <Team>[];
        for (final row in rows) {
          final team = row.readTable(_db.teams);
          if (seen.add(team.id)) teams.add(team);
        }
        return teams;
      });
    });
  }

  Stream<List<YouPaRow>> watchMyPaRows() {
    return watchMe().asyncExpand((me) {
      if (me == null) return Stream.value(const <YouPaRow>[]);
      final query =
          _db.select(_db.plateAppearances).join([
            innerJoin(
              _db.games,
              _db.games.id.equalsExp(_db.plateAppearances.gameId),
            ),
          ])..where(
            _db.plateAppearances.personId.equals(me.id) &
                _db.plateAppearances.deletedAt.isNull() &
                _db.games.deletedAt.isNull(),
          );
      return query.watch().map((rows) {
        return [
          for (final row in rows)
            YouPaRow(
              personId: me.id,
              gameId: row.readTable(_db.plateAppearances).gameId,
              gameKind: row.readTable(_db.games).kind,
              teamId: row.readTable(_db.plateAppearances).teamId,
              result: PaResult.fromWire(
                row.readTable(_db.plateAppearances).effectiveResult ??
                    row.readTable(_db.plateAppearances).result,
              ),
              rbi: row.readTable(_db.plateAppearances).rbi,
              runsScored: row.readTable(_db.plateAppearances).runsScored,
            ),
        ];
      });
    });
  }

  PlayerLine? careerLine(List<YouPaRow> rows, YouFilter filter, String meId) {
    final inputs = youPaInputs(rows, filter, meId);
    if (inputs.isEmpty) return null;
    return const StatsAggregator().rollup(inputs)[meId];
  }

  Future<Player?> _personalPlayer(String personId) {
    return (_db.select(_db.players)
          ..where(
            (t) =>
                t.personId.equals(personId) &
                t.teamId.isNull() &
                t.deletedAt.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Player> _ensurePersonalPlayer(Person me) async {
    final existing = await _personalPlayer(me.id);
    if (existing != null) return existing;
    final now = _now();
    final id = _uuid.v4();
    await _db
        .into(_db.players)
        .insert(
          PlayersCompanion.insert(
            id: id,
            personId: Value(me.id),
            firstName: me.firstName,
            lastName: Value(me.lastName),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(_db.players)..where((t) => t.id.equals(id))).getSingle();
  }
}
