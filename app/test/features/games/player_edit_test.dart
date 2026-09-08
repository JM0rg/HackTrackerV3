import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/players/presentation/screens/players_screen.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  testWidgets('editing a player name preserves handedness and coed gender', (
    t,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = TrackerRepository(db, const Uuid());
    final team = await repo.createTeam(name: 'Coed', type: 'coed');
    await repo.upsertPlayer(
      teamId: team.id,
      firstName: 'Casey',
      lastName: 'Original',
      bats: 'left',
      throws: 'left',
      gender: 'female',
    );
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const PlayersScreen())],
    );
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    container.read(currentTeamIdProvider.notifier).state = team.id;
    await t.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Casey Original'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(1), 'Updated');
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await t.pump(const Duration(milliseconds: 20));
    }
    final player = (await repo.players(team.id)).single;
    expect(player.lastName, 'Updated');
    expect(player.bats, 'left');
    expect(player.throws_, 'left');
    expect(player.gender, 'female');
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox.shrink());
    await t.pumpAndSettle();
    router.dispose();
    container.dispose();
    await t.pump(const Duration(seconds: 1));
    await t.pumpAndSettle();
  });
}
