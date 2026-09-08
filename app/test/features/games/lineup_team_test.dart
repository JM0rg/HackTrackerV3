import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/screens/lineup_screen.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  testWidgets('lineup belongs to the opened game, not the last selected team', (
    t,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TrackerRepository(db, const Uuid());
    final first = await repo.createTeam(name: 'First');
    final second = await repo.createTeam(name: 'Second');
    await repo.upsertPlayer(teamId: first.id, firstName: 'Correct roster');
    await repo.upsertPlayer(teamId: second.id, firstName: 'Wrong roster');
    final game = await repo.createGame(teamId: first.id);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => LineupScreen(gameId: game),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    container.read(currentTeamIdProvider.notifier).state = second.id;
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );
    await t.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 20));
    }
    expect(find.text('Correct roster'), findsOneWidget);
    expect(find.text('Wrong roster'), findsNothing);
    await t.tap(find.byType(CheckboxListTile));
    await t.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 20));
    }
    final slot = (await ScoringRepository(
      db,
      const Uuid(),
    ).lineup(game)).single;
    expect(slot.teamId, first.id);
    await t.pumpWidget(const SizedBox.shrink());
    await t.pumpAndSettle();
    router.dispose();
    container.dispose();
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
  });
}
