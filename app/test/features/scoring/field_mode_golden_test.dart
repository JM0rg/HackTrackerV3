@Tags(['golden'])
library;

import 'package:hacktracker/features/premium/data/plan_provider.dart';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/contact_field.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

import '../../helpers/test_fonts.dart';

void main() {
  late AppDatabase db;
  late TrackerRepository tracker;
  late MeRepository me;
  late ScoringRepository scoring;

  setUpAll(loadTestFonts);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    const uuid = Uuid();
    tracker = TrackerRepository(db, uuid);
    me = MeRepository(db, uuid);
    scoring = ScoringRepository(db, uuid);
  });

  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester,
    String gameId, {
    bool outdoor = false,
    bool premium = false,
    double scale = 1,
  }) async {
    // Unmount even when the test fails. Drift keeps a timer for every live
    // stream, and a test that throws before its own finish() would otherwise
    // leave one pending and hang teardown instead of reporting.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locationTrackingProvider.overrideWithValue(premium),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: outdoor
              ? AppTheme.dark(fontFamily: 'Roboto').copyWith(
                  extensions: [
                    ...AppTheme.dark().extensions.values.where(
                      (e) => e is! AppColors,
                    ),
                    AppColors.dark.copyWith(
                      field: FieldPalette.outdoor,
                      fieldBg: FieldPalette.outdoor.bg,
                      fieldOn: FieldPalette.outdoor.on,
                    ),
                  ],
                )
              : AppTheme.dark(fontFamily: 'Roboto'),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: FieldModeScreen(gameId: gameId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<String> teamGame() async {
    final team = await tracker.createTeam(name: 'Club');
    const roster = [
      ('Mike', 'Delgado', '12'),
      ('Jess', 'Kaur', '7'),
      ('Sam', 'Rivera', '23'),
      ('Tay', 'Mendez', '4'),
      ('Drew', 'Park', '31'),
    ];
    for (final (first, last, jersey) in roster) {
      await tracker.upsertPlayer(
        teamId: team.id,
        firstName: first,
        lastName: last,
        jerseyNumber: jersey,
      );
    }
    final players = await tracker.players(team.id);
    final gameId = await tracker.createGame(teamId: team.id, homeAway: 'away');
    await tracker.setLineup(
      teamId: team.id,
      gameId: gameId,
      playerIds: [for (final p in players) p.id],
    );
    return gameId;
  }

  testWidgets('golden: premium asks where it went, at two text sizes', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      final id = await me.createPersonalGame();
      await pump(tester, id, premium: true, scale: scale);
      final target = find.byKey(const Key('zone-second'));
      await tester.ensureVisible(target);
      await tester.pumpAndSettle();
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(find.text('Where did it go?'), findsOneWidget);
      await expectLater(
        find.byType(FieldModeScreen),
        matchesGoldenFile('goldens/ask_location_${scale.toInt()}.png'),
      );

      final field = find.byKey(const Key('contact-field'));
      final g =
          (tester.widget<ContactField>(find.byType(ContactField)).geometry ??
          ContactFieldGeometry(tester.getSize(field)));
      await tester.tapAt(tester.getTopLeft(field) + g.point(.3, .7));
      await tester.pumpAndSettle();
      // A hit is described beside the ball, the same as an out.
      expect(find.text('How was it hit?'), findsOneWidget);
      await expectLater(
        find.byType(FieldModeScreen),
        matchesGoldenFile('goldens/ask_hit_how_${scale.toInt()}.png'),
      );

      await tester.tap(find.byKey(const Key('how-line')));
      await tester.pumpAndSettle();
      expect(find.text('How many scored?'), findsOneWidget);
      await expectLater(
        find.byType(FieldModeScreen),
        matchesGoldenFile('goldens/ask_rbi_${scale.toInt()}.png'),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byKey(const Key('rbi-1')));
      await tester.pumpAndSettle();
      expect((await scoring.plateAppearances(id)).length, 1);
      await finish(tester);
    }
  });

  testWidgets('golden: the ball shows under the finger before release', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await tester.tap(find.byKey(const Key('zone-second')));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('contact-field'));
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    // Held, not released: the flight is drawn and the question still stands.
    final touch = await tester.startGesture(
      tester.getTopLeft(field) + g.point(-.45, .45),
    );
    await tester.pump();
    expect(find.text('Where did it go?'), findsOneWidget);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/ask_location_held.png'),
    );
    await touch.up();
    await tester.pumpAndSettle();
    await finish(tester);
  });

  testWidgets('golden: the log fills the room and offers the rest', (
    tester,
  ) async {
    final gameId = await teamGame();
    Future<Game> live() async => (await tracker.game(gameId))!;
    for (final r in [
      PaResult.single,
      PaResult.out,
      PaResult.double,
      PaResult.walk,
      PaResult.homer,
      PaResult.single,
      PaResult.out,
      PaResult.triple,
    ]) {
      await scoring.recordPa(game: await live(), result: r);
    }
    await pump(tester, gameId);
    expect(find.byKey(const Key('view-all')), findsOneWidget);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_log_full.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: an out is described beside the ball', (tester) async {
    final id = await me.createPersonalGame(opponentName: 'Rockets');
    await pump(tester, id, premium: true);
    final diamond = find.byKey(const Key('diamond'));
    final g = FieldGeometry(tester.getSize(diamond).width);
    await tester.dragFrom(
      tester.getTopLeft(diamond) + g.home,
      Offset(0, g.outY - g.home.dy + 22),
    );
    await tester.pumpAndSettle();

    final fieldFinder = find.byKey(const Key('contact-field'));
    final cg =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(fieldFinder));
    await tester.tapAt(tester.getTopLeft(fieldFinder) + cg.point(-.34, .46));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('how-k')), findsNothing);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/ask_how_beside_ball.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: the ball in flight, three ways', (tester) async {
    // Answering how it was hit is what shows the play, so the tap has to be
    // raw: settling would run the whole thing before it can be seen.
    for (final (kind, at) in const [
      ('ground', 380),
      ('line', 480),
      ('fly', 1250),
    ]) {
      final id = await me.createPersonalGame(opponentName: 'Rockets');
      await pump(tester, id, premium: true);
      await tester.tap(find.byKey(const Key('zone-second')));
      await tester.pumpAndSettle();

      final fieldFinder = find.byKey(const Key('contact-field'));
      final cg =
          tester.widget<ContactField>(find.byType(ContactField)).geometry ??
          ContactFieldGeometry(tester.getSize(fieldFinder));
      await tester.tapAt(tester.getTopLeft(fieldFinder) + cg.point(.42, .62));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(Key('how-$kind')));
      await tester.pump();
      await tester.pump(Duration(milliseconds: at));
      await expectLater(
        find.byType(FieldModeScreen),
        matchesGoldenFile('goldens/flight_$kind.png'),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('rbi-0')));
      await tester.pumpAndSettle();
      await finish(tester);
    }
  });

  testWidgets('golden: backing out asks in the same bar', (tester) async {
    final id = await me.createPersonalGame(opponentName: 'Rockets');
    await pump(tester, id, premium: true);
    await tester.tap(find.byKey(const Key('zone-second')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('location-skip')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('how-line')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('ask-cancel')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/ask_discard.png'),
    );
    await tester.tap(find.byKey(const Key('discard-keep')));
    await tester.pumpAndSettle();
    await finish(tester);
  });

  testWidgets('golden: discarding a game asks in the menu', (tester) async {
    final id = await me.createPersonalGame(opponentName: 'Rockets');
    Future<Game> live() async => (await tracker.game(id))!;
    await scoring.recordPa(game: await live(), result: PaResult.double);
    await scoring.recordPa(game: await live(), result: PaResult.out);
    await pump(tester, id);
    await tester.tap(find.byTooltip('Game menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu-discard')));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/menu_discard.png'),
    );
    await tester.tap(find.byKey(const Key('menu-discard-keep')));
    await tester.pumpAndSettle();
    await finish(tester);
  });

  testWidgets('golden: outdoor field contrast', (tester) async {
    final gameId = await teamGame();
    await scoring.recordPa(
      game: (await tracker.game(gameId))!,
      result: PaResult.single,
    );
    await pump(tester, gameId, outdoor: true);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_outdoor.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: mid inning, runners on', (tester) async {
    final gameId = await teamGame();
    Future<Game> live() async => (await tracker.game(gameId))!;
    await scoring.recordPa(game: await live(), result: PaResult.single);
    await scoring.recordPa(game: await live(), result: PaResult.out);
    await scoring.recordPa(game: await live(), result: PaResult.double);
    final pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(game: await live(), paId: pas.last.id, runs: 1);
    await scoring.recordPa(game: await live(), result: PaResult.walk);

    await pump(tester, gameId);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_team.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: a flick asks how', (tester) async {
    final gameId = await teamGame();
    Future<Game> live() async => (await tracker.game(gameId))!;
    await scoring.recordPa(game: await live(), result: PaResult.single);
    await scoring.recordPa(game: await live(), result: PaResult.double);

    await pump(tester, gameId);
    final diamond = find.byKey(const Key('diamond'));
    final width = tester.getSize(diamond).width;
    final home = tester.getTopLeft(diamond) + FieldGeometry(width).home;
    await tester.dragFrom(home, const Offset(0, 70));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_ask_how.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: first base asks how they reached', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(
      opponentName: 'Rockets',
      scope: GameScope.game,
      homeAway: 'home',
    );
    Future<Game> live() async => (await tracker.game(gameId))!;
    await scoring.bumpTheirHalfRuns(game: await live(), delta: 5);
    await scoring.endTheirHalf(await live());
    await scoring.recordPa(game: await live(), result: PaResult.single);

    await pump(tester, gameId);
    final diamond = find.byKey(const Key('diamond'));
    final width = tester.getSize(diamond).width;
    final g = FieldGeometry(width);
    final home = tester.getTopLeft(diamond) + g.home;
    await tester.dragFrom(home, g.first - g.home);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_ask_reach.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: their half', (tester) async {
    final gameId = await teamGame();
    Future<Game> live() async => (await tracker.game(gameId))!;
    for (var i = 0; i < 3; i++) {
      await scoring.recordPa(game: await live(), result: PaResult.out);
    }
    await scoring.bumpTheirHalfRuns(game: await live(), delta: 2);

    await pump(tester, gameId);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_their_half.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: my at-bats only', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Rockets');
    Future<Game> live() async => (await tracker.game(gameId))!;
    await scoring.recordPa(game: await live(), result: PaResult.single);
    var pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(game: await live(), paId: pas.last.id, runs: 1);
    await scoring.recordPa(game: await live(), result: PaResult.out);
    await scoring.recordPa(game: await live(), result: PaResult.homer);
    pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(game: await live(), paId: pas.last.id, runs: 2);

    await pump(tester, gameId);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_personal_bat.png'),
    );
    await finish(tester);
  });

  testWidgets('golden: my at-bats and team scores', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(
      opponentName: 'Rockets',
      scope: GameScope.game,
      homeAway: 'home',
    );
    Future<Game> live() async => (await tracker.game(gameId))!;
    await scoring.bumpTheirHalfRuns(game: await live(), delta: 5);
    await scoring.endTheirHalf(await live());
    await scoring.recordPa(game: await live(), result: PaResult.single);
    var pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(game: await live(), paId: pas.last.id, runs: 1);
    await scoring.bumpOurHalfRuns(game: await live(), delta: 1);
    await scoring.recordPa(game: await live(), result: PaResult.out);
    await scoring.recordPa(game: await live(), result: PaResult.homer);
    pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(game: await live(), paId: pas.last.id, runs: 2);

    await pump(tester, gameId);
    await expectLater(
      find.byType(FieldModeScreen),
      matchesGoldenFile('goldens/field_mode_personal_game.png'),
    );
    await finish(tester);
  });
}
