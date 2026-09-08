import 'package:drift/drift.dart';
import 'package:hacktracker/database/app_database.dart';

class ContactChartRepository {
  const ContactChartRepository(this.db);
  final AppDatabase db;
  Stream<List<PlateAppearance>> watch({
    String? teamId,
    String? personId,
    String? gameId,
    String? competitionId,
  }) {
    final conditions = <String>[
      'pa.deleted_at IS NULL',
      'g.deleted_at IS NULL',
    ];
    final variables = <Variable>[];
    if (teamId != null) {
      conditions.add('g.team_id = ?');
      variables.add(Variable.withString(teamId));
    }
    if (personId != null) {
      conditions.add('pa.person_id = ?');
      variables.add(Variable.withString(personId));
    }
    if (gameId != null) {
      conditions.add('g.id = ?');
      variables.add(Variable.withString(gameId));
    }
    if (competitionId != null) {
      conditions.add(
        'EXISTS (SELECT 1 FROM game_competitions gc WHERE gc.game_id=g.id AND gc.competition_id=? AND gc.deleted_at IS NULL)',
      );
      variables.add(Variable.withString(competitionId));
    }
    if (teamId == null && personId == null && gameId == null) {
      return Stream.value([]);
    }
    return db
        .customSelect(
          'SELECT pa.* FROM plate_appearances pa JOIN games g ON g.id=pa.game_id WHERE ${conditions.join(' AND ')} ORDER BY g.created_at,pa.sequence',
          variables: variables,
          readsFrom: {db.games, db.plateAppearances, db.gameCompetitions},
        )
        .watch()
        .map(
          (rows) => [for (final row in rows) db.plateAppearances.map(row.data)],
        );
  }
}
