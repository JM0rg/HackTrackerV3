import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/screens/game_screen.dart';
import 'package:hacktracker/features/games/presentation/widgets/start_sheet.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/me/presentation/screens/you_screen.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/connectivity_mock.dart';

/// The whole journey: You tab, start sheet, Field Mode, wrap, and back.
void main() {
  late AppDatabase db;
  late TrackerRepository tracker;
  late MeRepository me;
  late ScoringRepository scoring;

  setUpAll(mockConnectivity);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    const uuid = Uuid();
    tracker = TrackerRepository(db, uuid);
    me = MeRepository(db, uuid);
    scoring = ScoringRepository(db, uuid);
  });

  tearDown(() => db.close());

  GoRouter router({String start = '/'}) {
    return GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const YouScreen()),
        GoRoute(path: '/team', builder: (_, _) => const Scaffold(body: Text('TEAM TAB'))),
        GoRoute(
          path: '/games/:id',
          builder: (_, s) => GameScreen(gameId: s.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'box',
              builder: (_, _) => const Scaffold(body: Text('BOX')),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> pump(WidgetTester tester, GoRouter r) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: r),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Database writes are not driven by the fake clock on their own. The short
  /// settle timeout turns a runaway animation into a failure with a stack,
  /// instead of a ten-minute hang.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 5),
    );
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<Game> game(String id) async => (await tracker.game(id))!;

  group('start sheet', () {
    testWidgets('first time: at-bats only, nothing filled, two taps to a game',
        (tester) async {
      await me.ensureMe();
      await pump(tester, router());

      await tap(tester, find.text('Start a game'));
      expect(find.text('New game'), findsOneWidget);
      expect(find.byKey(const Key('row-team')), findsOneWidget);
      expect(find.byKey(const Key('row-opponent')), findsOneWidget);
      // Home or away only matters when the game keeps score.
      expect(find.byKey(const Key('home-away')), findsNothing);

      await tap(tester, find.byKey(const Key('start')));

      final games = await db.select(db.games).get();
      expect(games.single.scope, GameScope.bat);
      expect(games.single.opponentName, isNull);
      // Straight into Field Mode.
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);
      await finish(tester);
    });

    testWidgets('team scores shows home or away; the sheet remembers next time',
        (tester) async {
      await me.ensureMe();
      final crew = await me.createPersonalTeam('Tuesday Crew');
      await me.createPersonalGame(
        playedForName: crew!.name,
        playedForTeamId: crew.id,
        scope: GameScope.game,
        homeAway: 'away',
      );
      await pump(tester, router());

      await tap(tester, find.byKey(const Key('start-game')));

      expect(find.text('Tuesday Crew'), findsOneWidget);
      expect(find.byKey(const Key('home-away')), findsOneWidget);
      await tap(tester, find.text('Home'));

      await tap(tester, find.byKey(const Key('start')));
      final games = await db.select(db.games).get();
      final newest = games.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
      expect(newest.scope, GameScope.game);
      expect(newest.homeAway, 'home');
      expect(newest.playedForTeamId, crew.id);
      await finish(tester);
    });

    testWidgets('the opponent chip offers recent names before a keyboard',
        (tester) async {
      await me.ensureMe();
      await me.createPersonalGame(opponentName: 'Rockets');
      await pump(tester, router());

      await tap(tester, find.byKey(const Key('start-game')));
      await tap(tester, find.byKey(const Key('row-opponent')));
      expect(find.byKey(const Key('recent-Rockets')), findsOneWidget);
      await tap(tester, find.byKey(const Key('recent-Rockets')));
      expect(
        find.descendant(
          of: find.byKey(const Key('row-opponent')),
          matching: find.text('Rockets'),
        ),
        findsOneWidget,
      );

      await tap(tester, find.byKey(const Key('start')));
      final games = await db.select(db.games).get();
      expect(games.where((g) => g.opponentName == 'Rockets').length, 2);
      await finish(tester);
    });

    testWidgets('a team game starts from the same sheet', (tester) async {
      final team = await tracker.createTeam(name: 'Club');
      await tracker.upsertOpponent(teamId: team.id, name: 'Rockets');
      String? started;
      await pump(
        tester,
        GoRouter(routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async =>
                      started = await showStartSheet(context, teamId: team.id),
                  child: const Text('OPEN'),
                ),
              ),
            ),
          ),
        ]),
      );

      await tap(tester, find.text('OPEN'));
      expect(find.byKey(const Key('row-lineup')), findsOneWidget);
      await tap(tester, find.byKey(const Key('row-opponent')));
      await tap(tester, find.byKey(const Key('recent-Rockets')));
      await tap(tester, find.text('Away'));
      await tap(tester, find.byKey(const Key('start')));

      final g = await game(started!);
      expect(g.teamId, team.id);
      expect(g.opponentId, isNotNull);
      expect(g.homeAway, 'away');
      await finish(tester);
    });
  });

  group('the game route', () {
    testWidgets('live is Field Mode, final is the wrap, and reopen goes back',
        (tester) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(id), result: PaResult.double);
      await pump(tester, router(start: '/games/$id'));
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);

      await scoring.finalizeGame(await game(id));
      await settle(tester);
      expect(find.byKey(const Key('wrap-line')), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('wrap-line'))).data, '1 for 1');
      // Share is the icon in the corner; the card renders off-screen for it.
      expect(find.byKey(const Key('wrap-share')), findsOneWidget);
      expect(find.byKey(const Key('batter-chip')), findsNothing);

      await tap(tester, find.byKey(const Key('wrap-menu')));
      await tap(tester, find.text('Reopen game'));
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);
      await finish(tester);
    });

    testWidgets('done on the wrap goes home; close in Field Mode goes home',
        (tester) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.finalizeGame(await game(id));
      await pump(tester, router(start: '/games/$id'));

      await tap(tester, find.byKey(const Key('wrap-done')));
      expect(find.byKey(const Key('start-game')), findsOneWidget);

      await scoring.reopenGame(await game(id));
      await settle(tester);
      // The You tab now shows it as live.
      expect(find.byKey(const Key('live-card')), findsOneWidget);
      await tap(tester, find.byKey(const Key('live-card')));
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);

      await tap(tester, find.byKey(const Key('field-close')));
      expect(find.byKey(const Key('start-game')), findsOneWidget);
      expect((await game(id)).status, 'live');
      await finish(tester);
    });

    testWidgets('pull the score down and let go to end the game',
        (tester) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(
        opponentName: 'Reds',
        scope: GameScope.game,
        homeAway: 'away',
      );
      await pump(tester, router(start: '/games/$id'));
      expect(find.byKey(const Key('hero-pull')), findsOneWidget);

      // A short pull does nothing.
      await tester.drag(find.byKey(const Key('hero-pull')), const Offset(0, 40));
      await settle(tester);
      expect((await game(id)).status, isNot('final'));

      await tester.drag(find.byKey(const Key('hero-pull')), const Offset(0, 140));
      await settle(tester);
      expect((await game(id)).status, 'final');
      expect(find.byKey(const Key('wrap-done')), findsOneWidget);
      await finish(tester);
    });
  });

  group('you tab', () {
    testWidgets('cold start is one invitation, not three empty messages',
        (tester) async {
      await me.ensureMe();
      await pump(tester, router());

      expect(find.text('Your first at-bat'), findsOneWidget);
      expect(find.byKey(const Key('start-game')), findsNothing);
      expect(find.text('Start a game'), findsOneWidget);

      // No header over an empty list, no filter, no stat row of zeros.
      expect(find.text('Games'), findsNothing);
      expect(find.text('All'), findsNothing);
      expect(find.text('Average'), findsNothing);
      expect(find.text('Nothing yet. Start a game below.'), findsNothing);

      // An untouched name is a prompt, not an identity.
      expect(tester.widget<Text>(find.byKey(const Key('you-name'))).data,
          'Set your name');
      expect(find.textContaining('0 games'), findsNothing);
      await finish(tester);
    });

    testWidgets('one game brings back the stats, the header and the list',
        (tester) async {
      await me.ensureMe();
      await me.updateMe(firstName: 'Jordan');
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(id), result: PaResult.single);
      await scoring.finalizeGame(await game(id));
      await pump(tester, router());

      expect(find.text('Your first at-bat'), findsNothing);
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Average'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const Key('you-name'))).data, 'Jordan');
      expect(find.textContaining('1 game'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('rows carry your line, and a live game is pinned on top',
        (tester) async {
      await me.ensureMe();
      final done = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(done), result: PaResult.single);
      await scoring.recordPa(game: await game(done), result: PaResult.out);
      await scoring.finalizeGame(await game(done));
      final live = await me.createPersonalGame(opponentName: 'Rockets');
      await scoring.recordPa(game: await game(live), result: PaResult.homer);

      await pump(tester, router());
      expect(find.byKey(const Key('live-card')), findsOneWidget);
      expect(find.text('1 for 1'), findsOneWidget);
      expect(find.byKey(Key('game-$done')), findsOneWidget);
      expect(find.byKey(Key('game-$live')), findsNothing);
      expect(find.text('1 for 2'), findsOneWidget);
      await finish(tester);
    });
  });
}
