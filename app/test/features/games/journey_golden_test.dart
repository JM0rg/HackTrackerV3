@Tags(['golden'])
library;
import 'package:hacktracker/features/premium/data/plan_provider.dart';


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
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/me/presentation/screens/you_screen.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/connectivity_mock.dart';
import '../../helpers/test_fonts.dart';

void main() {
  late AppDatabase db;
  late TrackerRepository tracker;
  late MeRepository me;
  late ScoringRepository scoring;

  setUpAll(() async {
    mockConnectivity();
    await loadTestFonts();
  });

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    const uuid = Uuid();
    tracker = TrackerRepository(db, uuid);
    me = MeRepository(db, uuid);
    scoring = ScoringRepository(db, uuid);
  });

  tearDown(() => db.close());

  GoRouter router(String start) {
    return GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const YouScreen()),
        GoRoute(
          path: '/games/:id',
          builder: (_, s) => GameScreen(gameId: s.pathParameters['id']!),
        ),
      ],
    );
  }

  Future<void> pump(WidgetTester tester, String start) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), locationTrackingProvider.overrideWithValue(false)],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(fontFamily: 'Roboto'),
          routerConfig: router(start),
        ),
      ),
    );
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<Game> game(String id) async => (await tracker.game(id))!;

  Future<void> seed() async {
    await me.updateMe(firstName: 'Jordan', lastName: 'Reyes');
    final crew = await me.createPersonalTeam('Tuesday Crew');
    final a = await me.createPersonalGame(
      opponentName: 'Alley Cats',
      playedForName: crew!.name,
      playedForTeamId: crew.id,
    );
    for (final r in [PaResult.single, PaResult.out, PaResult.homer, PaResult.single, PaResult.walk]) {
      await scoring.recordPa(game: await game(a), result: r);
    }
    await scoring.finalizeGame(await game(a));
    final b = await me.createPersonalGame(
      opponentName: 'Rockets',
      playedForName: crew.name,
      playedForTeamId: crew.id,
      scope: GameScope.game,
      homeAway: 'home',
    );
    await scoring.bumpTheirHalfRuns(game: await game(b), delta: 1);
    await scoring.endTheirHalf(await game(b));
    await scoring.recordPa(game: await game(b), result: PaResult.double);
    await scoring.bumpOurHalfRuns(game: await game(b), delta: 2);
    await scoring.endOurHalf(await game(b));
    await scoring.bumpTheirHalfRuns(game: await game(b), delta: 2);
    await scoring.endTheirHalf(await game(b));
    await scoring.recordPa(game: await game(b), result: PaResult.single);
    final pas = await scoring.plateAppearances(b);
    await scoring.setRunsOnPlay(game: await game(b), paId: pas.last.id, runs: 1);
    await scoring.recordPa(game: await game(b), result: PaResult.out);
  }

  testWidgets('golden: cold start', (tester) async {
    await me.ensureMe();
    await pump(tester, '/');
    await expectLater(find.byType(YouScreen), matchesGoldenFile('goldens/you_empty.png'));
    await finish(tester);
  });

  testWidgets('golden: the You tab with a live game', (tester) async {
    await seed();
    await pump(tester, '/');
    await expectLater(find.byType(YouScreen), matchesGoldenFile('goldens/you_tab.png'));
    await finish(tester);
  });

  testWidgets('golden: the start sheet', (tester) async {
    await seed();
    await pump(tester, '/');
    await tester.tap(find.byKey(const Key('start-game')));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('goldens/start_sheet.png'));
    await finish(tester);
  });

  testWidgets('golden: the wrap', (tester) async {
    await seed();
    final games = await db.select(db.games).get();
    final live = games.firstWhere((g) => g.status == 'live');
    await scoring.bumpOurHalfRuns(game: live, delta: 1);
    await scoring.finalizeGame(await game(live.id));
    await pump(tester, '/games/${live.id}');
    await expectLater(find.byType(GameScreen), matchesGoldenFile('goldens/wrap.png'));
    await finish(tester);
  });
}
