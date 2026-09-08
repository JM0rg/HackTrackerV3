import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/stats/data/team_stats_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  test(
    'competition stats isolate teams, ignore deleted records and do not duplicate linked games',
    () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final tracker = TrackerRepository(db, const Uuid());
      final scoring = ScoringRepository(db, const Uuid());
      final stats = TeamStatsRepository(db);
      final team = await tracker.createTeam(name: 'Crew');
      final other = await tracker.createTeam(name: 'Other');
      for (final t in [team, other]) {
        await tracker.upsertPlayer(teamId: t.id, firstName: 'Player');
      }
      await tracker.upsertCompetition(
        id: 'season',
        teamId: team.id,
        type: 'season',
        name: 'Fall',
      );
      Future<String> game(String teamId, List<String> competitions) async {
        final id = await tracker.createGame(
          teamId: teamId,
          homeAway: 'away',
          competitionIds: competitions,
        );
        await tracker.setLineup(
          teamId: teamId,
          gameId: id,
          playerIds: [(await tracker.players(teamId)).first.id],
        );
        await scoring.recordPa(
          game: (await tracker.game(id))!,
          result: PaResult.single,
        );
        return id;
      }

      final selected = await game(team.id, ['season', 'season']);
      final outside = await game(team.id, []);
      await game(other.id, []);
      expect((await stats.watch(team.id).first).length, 2);
      expect(
        (await stats.watch(team.id, competitionId: 'season').first)
            .single
            .gameId,
        selected,
      );
      await (db.update(db.games)..where((g) => g.id.equals(outside))).write(
        GamesCompanion(deletedAt: Value(DateTime.now())),
      );
      expect((await stats.watch(team.id).first).length, 1);
      await (db.update(db.plateAppearances)
            ..where((p) => p.gameId.equals(selected)))
          .write(PlateAppearancesCompanion(deletedAt: Value(DateTime.now())));
      expect(
        await stats.watch(team.id, competitionId: 'season').first,
        isEmpty,
      );
    },
  );
}
