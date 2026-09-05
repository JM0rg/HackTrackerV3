import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/presentation/screens/log_personal_game_screen.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester) async {
    // Tall enough that the Start button stays on screen with every field shown.
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LogPersonalGameScreen()),
        GoRoute(
          path: '/games/:id/play',
          builder: (_, s) => Scaffold(body: Text('PLAY ${s.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  /// Unmount before the database closes, so Drift's stream timers are gone.
  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('the two modes come first, and only team scores asks home or away',
      (tester) async {
    await pump(tester);

    expect(find.text('My At-Bats Only'), findsOneWidget);
    expect(find.text('My At-Bats and Team Scores'), findsOneWidget);
    expect(find.byKey(const Key('home-away')), findsNothing);

    await tester.tap(find.byKey(const Key('scope-game')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-away')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Away'), findsOneWidget);

    await tester.tap(find.byKey(const Key('scope-bat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-away')), findsNothing);
    await finish(tester);
  });

  testWidgets('starting with nothing filled in makes a dated at-bats game',
      (tester) async {
    await pump(tester);

    await tester.tap(find.text('Start scoring'));
    await settle(tester);

    final games = await db.select(db.games).get();
    expect(games.single.opponentName, isNull);
    expect(games.single.playedForName, isNull);
    expect(games.single.scope, GameScope.bat);
    expect(find.textContaining('PLAY '), findsOneWidget);
    await finish(tester);
  });

  testWidgets('Pick team saves a new team, fills the name and tags the game',
      (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('pick-team')));
    await settle(tester);
    expect(find.text('Playing with'), findsOneWidget);
    expect(
      find.text('Save the teams you play with to fill this in next time.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('add-team')));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('new-team-name')), 'Tuesday Crew');
    await tester.tap(find.text('Save team'));
    await settle(tester);

    // The name is filled in and the game is tagged.
    expect(
      tester.widget<TextField>(
        find.widgetWithText(TextField, 'Playing with (optional)'),
      ).controller?.text,
      'Tuesday Crew',
    );
    expect(find.byKey(const Key('tagged')), findsOneWidget);

    await tester.tap(find.text('Start scoring'));
    await settle(tester);

    final game = (await db.select(db.games).get()).single;
    final team = (await db.select(db.personalTeams).get()).single;
    expect(game.playedForName, 'Tuesday Crew');
    expect(game.playedForTeamId, team.id);
    await finish(tester);
  });

  testWidgets('a saved team can be picked again next time', (tester) async {
    await db.into(db.people).insert(
          PeopleCompanion.insert(
            id: 'p1',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db.into(db.personalTeams).insert(
          PersonalTeamsCompanion.insert(
            id: 't1',
            personId: 'p1',
            name: 'Alley Cats',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await pump(tester);

    await tester.tap(find.byKey(const Key('pick-team')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('pick-t1')));
    await settle(tester);

    expect(find.byKey(const Key('tagged')), findsOneWidget);
    await tester.tap(find.text('Start scoring'));
    await settle(tester);

    final game = (await db.select(db.games).get()).single;
    expect(game.playedForName, 'Alley Cats');
    expect(game.playedForTeamId, 't1');
    await finish(tester);
  });

  testWidgets('typing over a picked team drops the tag', (tester) async {
    await db.into(db.people).insert(
          PeopleCompanion.insert(
            id: 'p1',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await db.into(db.personalTeams).insert(
          PersonalTeamsCompanion.insert(
            id: 't1',
            personId: 'p1',
            name: 'Alley Cats',
            createdAt: DateTime.now().toUtc(),
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    await pump(tester);

    await tester.tap(find.byKey(const Key('pick-team')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('pick-t1')));
    await settle(tester);
    expect(find.byKey(const Key('tagged')), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Playing with (optional)'),
      'Some other squad',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tagged')), findsNothing);

    await tester.tap(find.text('Start scoring'));
    await settle(tester);
    final game = (await db.select(db.games).get()).single;
    expect(game.playedForName, 'Some other squad');
    expect(game.playedForTeamId, isNull);
    await finish(tester);
  });

  testWidgets('team scores with away carries through', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(const Key('scope-game')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Away'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Opponent (optional)'), 'Reds');
    await tester.tap(find.text('Start scoring'));
    await settle(tester);

    final game = (await db.select(db.games).get()).single;
    expect(game.scope, GameScope.game);
    expect(game.homeAway, 'away');
    expect(game.opponentName, 'Reds');
    await finish(tester);
  });
}
