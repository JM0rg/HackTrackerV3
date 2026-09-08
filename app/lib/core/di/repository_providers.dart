import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';

final trackerRepositoryProvider = Provider<TrackerRepository>((ref) {
  return TrackerRepository(ref.watch(databaseProvider), ref.watch(uuidProvider));
});

final meRepositoryProvider = Provider<MeRepository>((ref) {
  return MeRepository(ref.watch(databaseProvider), ref.watch(uuidProvider));
});

final scoringRepositoryProvider = Provider<ScoringRepository>((ref) {
  return ScoringRepository(ref.watch(databaseProvider), ref.watch(uuidProvider));
});

final teamsStreamProvider = StreamProvider<List<Team>>((ref) {
  return ref.watch(trackerRepositoryProvider).watchTeams();
});

final playersStreamProvider =
    StreamProvider.family<List<Player>, String>((ref, teamId) {
  return ref.watch(trackerRepositoryProvider).watchPlayers(teamId);
});

final gamePlayersStreamProvider =
    StreamProvider.family<List<Player>, String>((ref, gameId) {
  return ref.watch(trackerRepositoryProvider).watchPlayersForGame(gameId);
});

final opponentsStreamProvider =
    StreamProvider.family<List<Opponent>, String>((ref, teamId) {
  return ref.watch(trackerRepositoryProvider).watchOpponents(teamId);
});

final competitionsStreamProvider =
    StreamProvider.family<List<Competition>, String>((ref, teamId) {
  return ref.watch(trackerRepositoryProvider).watchCompetitions(teamId);
});

final gamesStreamProvider =
    StreamProvider.family<List<Game>, String>((ref, teamId) {
  return ref.watch(trackerRepositoryProvider).watchGames(teamId);
});

final gameStreamProvider = StreamProvider.family<Game?, String>((ref, id) {
  return ref.watch(trackerRepositoryProvider).watchGame(id);
});

final lineupStreamProvider =
    StreamProvider.family<List<LineupSlot>, String>((ref, gameId) {
  return ref.watch(trackerRepositoryProvider).watchLineup(gameId);
});

final paStreamProvider =
    StreamProvider.family<List<PlateAppearance>, String>((ref, gameId) {
  return ref.watch(scoringRepositoryProvider).watchPlateAppearances(gameId);
});

final gameEventsStreamProvider =
    StreamProvider.family<List<GameEvent>, String>((ref, gameId) {
  return ref.watch(scoringRepositoryProvider).watchGameEvents(gameId);
});

final gameInningsStreamProvider =
    StreamProvider.family<List<GameInning>, String>((ref, gameId) {
  return ref.watch(scoringRepositoryProvider).watchInnings(gameId);
});

final meStreamProvider = StreamProvider<Person?>((ref) {
  return ref.watch(meRepositoryProvider).watchMe();
});

final myGamesStreamProvider = StreamProvider<List<Game>>((ref) {
  return ref.watch(meRepositoryProvider).watchMyGames();
});

final myTeamsStreamProvider = StreamProvider<List<Team>>((ref) {
  return ref.watch(meRepositoryProvider).watchTeamsIPlayOn();
});

final personalTeamsStreamProvider = StreamProvider<List<PersonalTeam>>((ref) {
  return ref.watch(meRepositoryProvider).watchPersonalTeams();
});

final myPaRowsStreamProvider = StreamProvider<List<YouPaRow>>((ref) {
  return ref.watch(meRepositoryProvider).watchMyPaRows();
});

/// The newest personal game still in progress, for the live strip.
final liveGameProvider = Provider<Game?>((ref) {
  final games = ref.watch(myGamesStreamProvider).valueOrNull ?? const <Game>[];
  for (final game in games) {
    if (game.status == 'live') return game;
  }
  return null;
});

/// The newest team game still in progress.
final teamLiveGameProvider = Provider.family<Game?, String>((ref, teamId) {
  final games = ref.watch(gamesStreamProvider(teamId)).valueOrNull ?? const <Game>[];
  for (final game in games) {
    if (game.status == 'live') return game;
  }
  return null;
});

/// Your line in every game, by game id.
final myGameLinesProvider = Provider<Map<String, GameLine>>((ref) {
  final me = ref.watch(meStreamProvider).valueOrNull;
  if (me == null) return const {};
  final rows = ref.watch(myPaRowsStreamProvider).valueOrNull ?? const <YouPaRow>[];
  return gameLines(rows, me.id);
});

final youFilterProvider = StateProvider<YouFilter>((ref) {
  return const YouFilter.all();
});

final ensureMeProvider = FutureProvider<Person>((ref) {
  return ref.watch(meRepositoryProvider).ensureMe();
});
