import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
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

/// The whole journey: You tab, start sheet, Field Mode, wrap, and back.
void main() {
  late AppDatabase db;
  late TrackerRepository tracker;
  late MeRepository me;
  late ScoringRepository scoring;

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
        GoRoute(
          path: '/team',
          builder: (_, _) => const Scaffold(body: Text('TEAM TAB')),
        ),
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
    // Unmount even when the test fails. Drift keeps a timer for every live
    // stream, and a test that throws before its own finish() would otherwise
    // leave one pending and hang teardown instead of reporting.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locationTrackingProvider.overrideWithValue(false),
        ],
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
    testWidgets(
      'profile save keeps controllers alive through keyboard and sheet dismissal',
      (tester) async {
        final r = router();
        await pump(tester, r);
        await tester.tap(find.byKey(const Key('you-name')));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).at(0), 'QA');
        await tester.enterText(find.byType(TextField).at(1), 'Softball');
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpAndSettle();
        await settle(tester);
        expect(tester.takeException(), isNull);
        expect(find.text('QA'), findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        r.dispose();
      },
    );

    testWidgets('a start time and a location go on the game when given', (
      tester,
    ) async {
      await me.ensureMe();
      await pump(tester, router());
      await tap(tester, find.text('Start a game'));

      // Where.
      await tap(tester, find.byKey(const Key('row-park')));
      await tester.enterText(find.byType(TextField), '  Riverside Park  ');
      await tap(tester, find.text('Done'));
      expect(
        find.descendant(
          of: find.byKey(const Key('row-park')),
          matching: find.text('Riverside Park'),
        ),
        findsOneWidget,
      );

      // When: an hour ago, on the wheel, and back to now is one tap away.
      await tap(tester, find.byKey(const Key('row-starts')));
      expect(find.byKey(const Key('start-wheel')), findsOneWidget);
      await tap(tester, find.byKey(const Key('start-now')));
      expect(
        find.descendant(
          of: find.byKey(const Key('row-starts')),
          matching: find.text('Now'),
        ),
        findsOneWidget,
      );
      await tap(tester, find.byKey(const Key('row-starts')));
      final wheel = tester.widget<CupertinoDatePicker>(
        find.byKey(const Key('start-wheel')),
      );
      final earlier = DateTime.now().subtract(const Duration(hours: 1));
      wheel.onDateTimeChanged(earlier);
      await tap(tester, find.byKey(const Key('start-set')));
      expect(
        find.descendant(
          of: find.byKey(const Key('row-starts')),
          matching: find.textContaining('Today, '),
        ),
        findsOneWidget,
      );

      await tap(tester, find.byKey(const Key('start')));
      final game = (await db.select(db.games).get()).single;
      expect(game.park, 'Riverside Park');
      expect(
        game.startsAt!.difference(earlier.toUtc()).inSeconds.abs(),
        lessThan(2),
      );
      await finish(tester);
    });

    testWidgets(
      'first time: at-bats only, nothing filled, two taps to a game',
      (tester) async {
        await me.ensureMe();
        await pump(tester, router());

        await tap(tester, find.text('Start a game'));
        expect(find.text('New game'), findsOneWidget);
        expect(find.byKey(const Key('row-team')), findsOneWidget);
        expect(find.byKey(const Key('row-opponent')), findsOneWidget);
        // Home or away only matters when the game keeps score.
        expect(find.byKey(const Key('home-away')), findsNothing);

        // Both optional, and saying nothing means "now, wherever".
        expect(
          find.descendant(
            of: find.byKey(const Key('row-starts')),
            matching: find.text('Now'),
          ),
          findsOneWidget,
        );
        expect(find.byKey(const Key('row-park')), findsOneWidget);

        final before = DateTime.now().toUtc();
        await tap(tester, find.byKey(const Key('start')));

        final games = await db.select(db.games).get();
        expect(games.single.scope, GameScope.bat);
        expect(games.single.opponentName, isNull);
        expect(games.single.park, isNull);
        expect(
          games.single.startsAt!.difference(before).inSeconds.abs(),
          lessThan(5),
        );
        // Straight into Field Mode.
        expect(find.byKey(const Key('batter-chip')), findsOneWidget);
        await finish(tester);
      },
    );

    testWidgets(
      'team scores shows home or away; the sheet remembers next time',
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
        final newest = games.reduce(
          (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
        );
        expect(newest.scope, GameScope.game);
        expect(newest.homeAway, 'home');
        expect(newest.playedForTeamId, crew.id);
        await finish(tester);
      },
    );

    testWidgets('the opponent chip offers recent names before a keyboard', (
      tester,
    ) async {
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
        GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () async => started = await showStartSheet(
                      context,
                      teamId: team.id,
                    ),
                    child: const Text('OPEN'),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    testWidgets('live is Field Mode, final is the wrap, and reopen goes back', (
      tester,
    ) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(id), result: PaResult.double);
      await pump(tester, router(start: '/games/$id'));
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);

      await scoring.finalizeGame(await game(id));
      await settle(tester);
      expect(find.byKey(const Key('wrap-line')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('wrap-line'))).data,
        '1 for 1',
      );
      // Share is the icon in the corner; the card renders off-screen for it.
      expect(find.byKey(const Key('wrap-share')), findsOneWidget);
      expect(find.byKey(const Key('batter-chip')), findsNothing);

      await tap(tester, find.byKey(const Key('wrap-menu')));
      await tap(tester, find.text('Reopen game'));
      expect(find.byKey(const Key('batter-chip')), findsOneWidget);
      await finish(tester);
    });

    testWidgets('done on the wrap goes home; close in Field Mode goes home', (
      tester,
    ) async {
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

    testWidgets('discarding a game asks in the menu, then it is gone', (
      tester,
    ) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(id), result: PaResult.double);
      await pump(tester, router());
      expect(find.byKey(const Key('live-card')), findsOneWidget);
      await tap(tester, find.byKey(const Key('live-card')));

      // Ending a game is reversible, so it sits beside a discard that is not.
      await tap(tester, find.byTooltip('Game menu'));
      expect(find.text('End game'), findsOneWidget);
      // Turning the menu into the question moves nothing: the sheet is the
      // same box on every frame of the change, not just before and after.
      final sheet = find.byType(BottomSheet);
      final shape = tester.getRect(sheet);
      await tester.tap(find.byKey(const Key('menu-discard')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getRect(sheet), shape, reason: 'the sheet moved');
      }
      await tester.pumpAndSettle();
      expect(tester.getRect(sheet), shape);

      // The same sheet turns into the question; no second box opens on top.
      expect(find.text('Discard this game?'), findsOneWidget);
      expect(find.textContaining('1 at-bat go with it'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Backing out of the ask changes nothing, and moves nothing either.
      await tester.tap(find.byKey(const Key('menu-discard-keep')));
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.getRect(sheet), shape, reason: 'the sheet moved');
      }
      await tester.pumpAndSettle();
      expect(find.text('Game'), findsOneWidget);
      expect(find.text('Discard this game?'), findsNothing);
      expect((await game(id)).deletedAt, isNull);

      await tap(tester, find.byKey(const Key('menu-discard')));
      await tap(tester, find.byKey(const Key('menu-discard-confirm')));
      // Home, with nothing left of it: it was the only game, so the tab is
      // back to how it looked before there were any.
      expect(find.byType(YouScreen), findsOneWidget);
      expect(find.text('Your first at-bat'), findsOneWidget);
      expect(find.byKey(const Key('live-card')), findsNothing);
      expect(find.byKey(Key('game-$id')), findsNothing);
      expect((await game(id)).deletedAt, isNotNull);
      await finish(tester);
    });

    testWidgets('pull the score down and let go to end the game', (
      tester,
    ) async {
      await me.ensureMe();
      final id = await me.createPersonalGame(
        opponentName: 'Reds',
        scope: GameScope.game,
        homeAway: 'away',
      );
      await pump(tester, router(start: '/games/$id'));
      expect(find.byKey(const Key('hero-pull')), findsOneWidget);

      // A short pull does nothing.
      await tester.drag(
        find.byKey(const Key('hero-pull')),
        const Offset(0, 40),
      );
      await settle(tester);
      expect((await game(id)).status, isNot('final'));

      await tester.drag(
        find.byKey(const Key('hero-pull')),
        const Offset(0, 140),
      );
      await settle(tester);
      expect((await game(id)).status, 'final');
      expect(find.byKey(const Key('wrap-done')), findsOneWidget);
      await finish(tester);
    });
  });

  group('you tab', () {
    testWidgets('cold start is one invitation, not three empty messages', (
      tester,
    ) async {
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
      expect(
        tester.widget<Text>(find.byKey(const Key('you-name'))).data,
        'Set your name',
      );
      expect(find.textContaining('0 games'), findsNothing);
      await finish(tester);
    });

    testWidgets('one game brings back the stats, the header and the list', (
      tester,
    ) async {
      await me.ensureMe();
      await me.updateMe(firstName: 'Jordan');
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(id), result: PaResult.single);
      await scoring.finalizeGame(await game(id));
      await pump(tester, router());

      expect(find.text('Your first at-bat'), findsNothing);
      expect(find.text('Games'), findsOneWidget);
      expect(find.text('Average'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('you-name'))).data,
        'Jordan',
      );
      expect(find.textContaining('1 game'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('rows carry your line, and a live game is pinned on top', (
      tester,
    ) async {
      await me.ensureMe();
      final done = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await game(done), result: PaResult.single);
      await scoring.recordPa(game: await game(done), result: PaResult.out);
      await scoring.finalizeGame(await game(done));
      final live = await me.createPersonalGame(opponentName: 'Rockets');
      await scoring.recordPa(game: await game(live), result: PaResult.homer);

      await pump(tester, router());
      final card = find.byKey(const Key('live-card'));
      expect(card, findsOneWidget);
      // The card says which game first, then how it is going.
      expect(
        find.descendant(of: card, matching: find.text('vs Rockets')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.textContaining('1 for 1')),
        findsOneWidget,
      );
      expect(find.byKey(Key('game-$done')), findsOneWidget);
      expect(find.byKey(Key('game-$live')), findsNothing);
      expect(find.text('1 for 2'), findsOneWidget);
      await finish(tester);
    });
  });
}
