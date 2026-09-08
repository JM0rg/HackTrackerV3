import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/database/app_database.dart';

final competitionProvider = StreamProvider.family<Competition?, String>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.competitions,
  )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).watchSingleOrNull();
});
final competitionGamesProvider = StreamProvider.family<List<Game>, String>((
  ref,
  id,
) {
  final db = ref.watch(databaseProvider);
  return db
      .customSelect(
        '''SELECT g.* FROM games g WHERE g.deleted_at IS NULL AND EXISTS (
    SELECT 1 FROM game_competitions gc WHERE gc.game_id = g.id AND gc.competition_id = ? AND gc.deleted_at IS NULL
  ) ORDER BY g.starts_at DESC, g.created_at DESC''',
        variables: [Variable.withString(id)],
        readsFrom: {db.games, db.gameCompetitions},
      )
      .watch()
      .map((rows) => [for (final row in rows) db.games.map(row.data)]);
});
