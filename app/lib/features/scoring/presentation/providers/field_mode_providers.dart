import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

/// Everything Field Mode draws, replayed from the log on every change.
class FieldModeState {
  const FieldModeState({
    required this.game,
    required this.slots,
    required this.roster,
    required this.events,
    required this.settings,
    required this.replay,
  });

  final Game game;
  final List<LineupSlot> slots;
  final List<Player> roster;

  /// Log entries that are not plate appearances, so undo knows what is newest.
  final List<GameEvent> events;
  final TeamSettings settings;
  final ReplayedGame replay;

  bool get personal => game.kind == GameKind.personal;
  bool get isFinal => game.status == 'final';

  /// A team game always keeps score. A personal game only if it was set up to.
  bool get tracksScore => !personal || game.scope == GameScope.game;
  bool get weBat => !tracksScore || replay.weBat;
  bool get hasLineup => slots.isNotEmpty;

  Player? playerById(String? id) {
    if (id == null) return null;
    for (final player in roster) {
      if (player.id == id) return player;
    }
    return null;
  }

  int get batterIndex {
    if (slots.isEmpty) return 0;
    return game.currentBatterIndex % slots.length;
  }

  Player? get batter {
    if (slots.isEmpty) return null;
    return playerById(slots[batterIndex].playerId);
  }

  Player? get onDeck {
    if (slots.length < 2) return null;
    return playerById(slots[(batterIndex + 1) % slots.length].playerId);
  }

  /// The play the adjust strip acts on: always the newest one.
  ReplayedPa? get lastPa => replay.lastPa;

  bool get hasLog => replay.pas.isNotEmpty || events.isNotEmpty;

  /// True when the newest log entry is a finished opponent half.
  bool get newestIsTheirHalf {
    if (events.isEmpty) return false;
    final pa = replay.lastPa;
    if (pa == null) return true;
    return events.last.sequence > pa.sequence;
  }

  /// Today's line for one batter, straight off the replayed plays.
  ({int hits, int atBats, List<String> results}) lineFor(String playerId) {
    var hits = 0;
    var atBats = 0;
    final results = <String>[];
    for (final pa in replay.pas) {
      if (pa.playerId != playerId) continue;
      if (!pa.effective.isNonAtBat) atBats += 1;
      if (pa.effective.isHit) {
        hits += 1;
        results.add(pa.effective.label);
      }
    }
    return (hits: hits, atBats: atBats, results: results);
  }
}

final gameTeamProvider = Provider.family<Team?, String?>((ref, teamId) {
  if (teamId == null) return null;
  final teams = ref.watch(teamsStreamProvider).valueOrNull ?? const <Team>[];
  for (final team in teams) {
    if (team.id == teamId) return team;
  }
  return null;
});

final fieldModeProvider =
    Provider.family<AsyncValue<FieldModeState?>, String>((ref, gameId) {
  final gameAsync = ref.watch(gameStreamProvider(gameId));
  final slotsAsync = ref.watch(lineupStreamProvider(gameId));
  final rosterAsync = ref.watch(gamePlayersStreamProvider(gameId));
  final pasAsync = ref.watch(paStreamProvider(gameId));
  final eventsAsync = ref.watch(gameEventsStreamProvider(gameId));

  final error = [gameAsync, slotsAsync, rosterAsync, pasAsync, eventsAsync]
      .where((a) => a.hasError)
      .firstOrNull;
  if (error != null) {
    return AsyncValue.error(error.error!, error.stackTrace ?? StackTrace.empty);
  }

  final game = gameAsync.valueOrNull;
  final slots = slotsAsync.valueOrNull;
  final roster = rosterAsync.valueOrNull;
  final pas = pasAsync.valueOrNull;
  final events = eventsAsync.valueOrNull;
  if (game == null || slots == null || roster == null || pas == null || events == null) {
    if (gameAsync.hasValue && gameAsync.valueOrNull == null) {
      return const AsyncValue.data(null);
    }
    return const AsyncValue.loading();
  }

  final team = ref.watch(gameTeamProvider(game.teamId));
  final settings = TeamSettings.fromJson(team?.settings);
  final genders = {for (final player in roster) player.id: player.gender};

  final replay = const GameReplay().run(
    events: ScoringRepository.inputsFrom(
      pas: pas,
      events: events,
      genderByPlayerId: genders,
    ),
    personal: game.kind == GameKind.personal,
    tracksScore: game.scope == GameScope.game,
    weAreHome: game.homeAway == 'home',
    lineupPlayerIds: [for (final slot in slots) slot.playerId],
    rules: settings.rules,
    ourHalfRuns: game.ourHalfRuns,
    theirHalfRuns: game.theirHalfRuns,
  );

  return AsyncValue.data(
    FieldModeState(
      game: game,
      slots: slots,
      roster: roster,
      events: events,
      settings: settings,
      replay: replay,
    ),
  );
});
