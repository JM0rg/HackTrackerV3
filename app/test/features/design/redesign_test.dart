import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/team/presentation/screens/team_home_screen.dart';
import 'package:hacktracker/features/players/presentation/screens/players_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/games_screen.dart';
import 'package:hacktracker/features/stats/presentation/screens/team_stats_screen.dart';
import 'package:hacktracker/features/competitions/presentation/screens/competition_detail_screen.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
import 'package:uuid/uuid.dart';
import '../../helpers/test_fonts.dart';
import '../../helpers/connectivity_mock.dart';

void main() {
  setUpAll(() async {
    mockConnectivity();
    await loadTestFonts();
  });
  for (final large in [false, true]) {
    for (final light in [false, true]) {
      testWidgets('scorebook layouts light=$light large=$large', (
        tester,
      ) async {
        final db = AppDatabase(NativeDatabase.memory());
        addTearDown(db.close);
        final tracker = TrackerRepository(db, const Uuid());
        final scoring = ScoringRepository(db, const Uuid());
        final team = await tracker.createTeam(name: 'Tuesday Crew');
        await tracker.upsertPlayer(
          teamId: team.id,
          firstName: 'Jordan',
          lastName: 'Reyes',
          jerseyNumber: '12',
        );
        await tracker.upsertCompetition(
          id: 'season',
          teamId: team.id,
          type: 'season',
          name: 'Fall League',
          leagueName: 'Tuesday nights',
        );
        final gameId = await tracker.createGame(
          teamId: team.id,
          homeAway: 'away',
          competitionIds: ['season'],
            startsAt: DateTime.utc(2026, 9, 8, 18),
        );
        await tracker.setLineup(
          teamId: team.id,
          gameId: gameId,
          playerIds: [(await tracker.players(team.id)).first.id],
        );
        await scoring.recordPa(
          game: (await tracker.game(gameId))!,
          result: PaResult.double,
        );
        final container = ProviderContainer(
          overrides: [databaseProvider.overrideWithValue(db), locationTrackingProvider.overrideWithValue(false)],
        );
        container.read(currentTeamIdProvider.notifier).state = team.id;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.reset);
        final screens = <String, Widget>{
          'team': const TeamHomeScreen(),
          'roster': const PlayersScreen(),
          'games': const GamesScreen(),
          'stats': const TeamStatsScreen(initialCompetitionId: 'season'),
          'competition': const CompetitionDetailScreen(competitionId: 'season'),
          'field': FieldModeScreen(gameId: gameId),
        };
        for (final entry in screens.entries) {
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: light
                    ? AppTheme.light(fontFamily: 'Roboto')
                    : AppTheme.dark(fontFamily: 'Roboto'),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(large ? 2 : 1)),
                  child: child!,
                ),
                home: entry.value,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: entry.key);
          if (!large) {
            await expectLater(
              find.byType(MaterialApp),
              matchesGoldenFile(
                'goldens/${entry.key}_${light ? 'light' : 'dark'}.png',
              ),
            );
          }
        }
        await tester.pumpWidget(const SizedBox.shrink());
        container.dispose();
        await tester.pumpAndSettle();
      });
    }
  }
}
