import 'package:drift/drift.dart';
import 'package:hacktracker/database/app_database.dart';

class TeamStatsRepository {
  TeamStatsRepository(this.db);
  final AppDatabase db;

  /// One reactive local query replaces a separate database read for every game.
  Stream<List<PlateAppearance>> watch(String teamId, {String? competitionId}) {
    return db
        .customSelect(
          '''
      SELECT pa.* FROM plate_appearances pa
      JOIN games g ON g.id = pa.game_id
      WHERE g.team_id = ? AND g.kind = 'team'
        AND g.deleted_at IS NULL AND pa.deleted_at IS NULL
        ${competitionId == null ? '' : '''AND EXISTS (
          SELECT 1 FROM game_competitions gc WHERE gc.game_id = g.id
            AND gc.competition_id = ? AND gc.deleted_at IS NULL
        )'''}
      ORDER BY g.created_at, pa.sequence
    ''',
          variables: [
            Variable.withString(teamId),
            if (competitionId != null) Variable.withString(competitionId),
          ],
          readsFrom: {db.plateAppearances, db.games, db.gameCompetitions},
        )
        .watch()
        .map(
          (rows) => [for (final row in rows) db.plateAppearances.map(row.data)],
        );
  }
}
