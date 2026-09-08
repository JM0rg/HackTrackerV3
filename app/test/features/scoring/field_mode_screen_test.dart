import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/batter_card.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

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

  /// iPhone-sized, so the diamond lands at its full 300pt width.
  Future<void> pump(WidgetTester tester, String gameId) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db), locationTrackingProvider.overrideWithValue(false)],
        child: MaterialApp(
          theme: AppTheme.dark(),
          home: FieldModeScreen(gameId: gameId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// Database writes are not driven by the fake clock on their own.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  /// Answer the row under the diamond.
  Future<void> answer(WidgetTester tester, String key) =>
      tap(tester, find.byKey(Key(key)));

  /// Read the diamond's real size back, so drags land wherever it was laid out.
  FieldGeometry geo(WidgetTester tester) =>
      FieldGeometry(tester.getSize(find.byKey(const Key('diamond'))).width);
  Offset home(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(const Key('diamond'))) + geo(tester).home;

  Future<void> dragChip(WidgetTester tester, Offset by) async {
    await tester.dragFrom(home(tester), by);
    await settle(tester);
  }

  Offset toFirst(WidgetTester t) => geo(t).first - geo(t).home;
  Offset toSecond(WidgetTester t) => geo(t).second - geo(t).home;
  Offset toThird(WidgetTester t) => geo(t).third - geo(t).home;

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  Future<String> teamGame({String homeAway = 'away'}) async {
    final team = await tracker.createTeam(name: 'Club');
    for (final (first, last) in const [
      ('Ada', 'A'),
      ('Sam', 'B'),
      ('Kai', 'C'),
    ]) {
      await tracker.upsertPlayer(
        teamId: team.id,
        firstName: first,
        lastName: last,
      );
    }
    final roster = await tracker.players(team.id);
    final gameId = await tracker.createGame(
      teamId: team.id,
      homeAway: homeAway,
    );
    await tracker.setLineup(
      teamId: team.id,
      gameId: gameId,
      playerIds: [for (final p in roster) p.id],
    );
    return gameId;
  }

  Future<Game> game(String id) async => (await tracker.game(id))!;

  testWidgets('an unanswered play survives leaving and reopening field mode', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);
    await dragChip(tester, toFirst(tester));
    expect((await tracker.game(gameId))!.scoringDraft, isNotNull);
    await finish(tester);
    await pump(tester, gameId);
    expect(find.byKey(const Key('reach-single')), findsOneWidget);
    await answer(tester, 'reach-single');
    expect((await scoring.plateAppearances(gameId)).length, 1);
    expect((await tracker.game(gameId))!.scoringDraft, isNull);
    await finish(tester);
  });

  testWidgets('handoff keeps scoring available and hides the game menu', (
    tester,
  ) async {
    final id = await teamGame();
    await pump(tester, id);
    await tap(tester, find.byKey(const Key('field-handoff')));
    expect(find.text('Done'), findsOneWidget);
    expect(find.byTooltip('Game menu'), findsNothing);
    await tap(tester, find.byKey(const Key('zone-second')));
    expect((await scoring.plateAppearances(id)).length, 1);
    await tap(tester, find.byKey(const Key('field-handoff')));
    expect(find.byTooltip('Game menu'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('failed save retains the play for retry without duplication', (
    tester,
  ) async {
    final id = await teamGame();
    await pump(tester, id);
    await db.customStatement(
      "CREATE TRIGGER reject_save BEFORE UPDATE ON games BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await tap(tester, find.byKey(const Key('zone-second')));
    expect(find.text('Play not saved.'), findsOneWidget);
    expect(await scoring.plateAppearances(id), isEmpty);
    await db.customStatement('DROP TRIGGER reject_save');
    await tap(tester, find.text('Retry'));
    expect(find.text('Play not saved.'), findsNothing);
    expect((await scoring.plateAppearances(id)).length, 1);
    await finish(tester);
  });

  testWidgets('the card shows the batter, the diamond and one line of score', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    expect(find.byKey(const Key('us-runs')), findsOneWidget);
    expect(find.byKey(const Key('them-runs')), findsOneWidget);
    expect(find.byKey(const Key('situation')), findsOneWidget);
    expect(find.textContaining('Top 1'), findsOneWidget);
    expect(find.textContaining('0 out'), findsOneWidget);
    expect(find.byKey(const Key('card-first')), findsOneWidget);
    expect(find.text('Ada A'), findsOneWidget);
    expect(find.text('0 for 0'), findsOneWidget);
    expect(find.byKey(const Key('batter-chip')), findsOneWidget);
    expect(find.byKey(const Key('hint')), findsOneWidget);
    expect(find.text('First batter of the game'), findsOneWidget);
    expect(find.text('Sam'), findsOneWidget);
    // No result pad anywhere.
    expect(find.text('1B'), findsNothing);
    expect(find.text('OUT'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('dragging the chip to first files a single', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    // Nothing is filed until the row is answered.
    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('ask-reach')), findsOneWidget);

    await answer(tester, 'reach-single');

    expect((await scoring.plateAppearances(gameId)).single.result, 'single');
    expect(find.textContaining('Ada singled'), findsOneWidget);
    final ada = (await tracker.players((await game(gameId)).teamId!)).first;
    expect(find.byKey(Key('runner-${ada.id}')), findsOneWidget);
    // Next batter's card is in.
    expect(find.text('Sam'), findsWidgets);
    await finish(tester);
  });

  testWidgets('tapping a base works too', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await tap(tester, find.byKey(const Key('zone-second')));

    // Second base is unambiguous in a team game, so it files at once.
    expect((await scoring.plateAppearances(gameId)).single.result, 'double');
    await finish(tester);
  });

  testWidgets('flicking the chip down is an out', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'how-ground');

    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'out');
    expect(pa.outKind, 'ground');
    expect((await game(gameId)).outs, 1);
    await finish(tester);
  });

  testWidgets('a flick asks how before it files anything', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);
    expect(find.byKey(const Key('ask-how')), findsNothing);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('ask-how')), findsOneWidget);
    for (final label in ['Fly', 'Ground', 'Line', 'K']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'how-fly');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'out');
    expect(pa.outKind, 'fly');
    expect(find.textContaining('Ada flied out'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('K is one of the ways out', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'how-k');

    expect((await scoring.plateAppearances(gameId)).single.result, 'strikeout');
    expect(find.textContaining('Ada struck out'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('an unanswered play blocks the next drag until it is settled', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('ask-how')), findsOneWidget);

    // The chip will not move again while the question stands.
    await dragChip(tester, toFirst(tester));
    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('ask-how')), findsOneWidget);

    await answer(tester, 'how-line');
    expect((await scoring.plateAppearances(gameId)).single.outKind, 'line');
    await finish(tester);
  });

  testWidgets('a misfire can be cancelled instead of answered', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'ask-cancel');

    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('ask-how')), findsNothing);

    // And the chip is free again.
    await dragChip(tester, toSecond(tester));
    expect((await scoring.plateAppearances(gameId)).single.result, 'double');
    await finish(tester);
  });

  testWidgets('first base asks how they got there, walk included', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    for (final label in ['1B', 'BB', 'ROE', 'FC']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    await answer(tester, 'reach-walk');
    expect((await scoring.plateAppearances(gameId)).single.result, 'walk');
    expect(find.textContaining('Ada walked'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('reaching on an error and a fielders choice are one tap each', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-reach_on_error');
    expect(
      (await scoring.plateAppearances(gameId)).single.result,
      'reach_on_error',
    );

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-fielders_choice');
    final pas = await scoring.plateAppearances(gameId);
    expect(pas.last.result, 'fielders_choice');
    expect((await game(gameId)).outs, 1);
    await finish(tester);
  });

  testWidgets('a fly out with a runner sent home is a sac fly', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toThird(tester));
    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'how-fly');
    await tester.tapAt(
      tester.getTopLeft(find.byKey(const Key('diamond'))) + geo(tester).third,
    );
    await settle(tester);

    final pas = await scoring.plateAppearances(gameId);
    expect(pas.last.result, 'sac_fly');
    expect(pas.last.rbi, 1);
    expect((await game(gameId)).ourRuns, 1);
    await finish(tester);
  });

  testWidgets('past the fence is a home run', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    final g = geo(tester);
    await dragChip(tester, Offset(0, -(g.home.dy - g.fenceY + 12)));

    expect((await scoring.plateAppearances(gameId)).single.result, 'homer');
    expect((await game(gameId)).ourRuns, 1);
    await finish(tester);
  });

  testWidgets('letting go near the plate cancels', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(20, -10));

    expect(await scoring.plateAppearances(gameId), isEmpty);
    await finish(tester);
  });

  testWidgets('tapping a runner sends them home', (tester) async {
    final gameId = await teamGame();
    final roster = await tracker.players((await game(gameId)).teamId!);
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');
    await dragChip(tester, toSecond(tester));
    expect((await game(gameId)).ourRuns, 0);

    // Ada went first to third on the double; her chip sits on the bag.
    expect(find.byKey(Key('runner-${roster.first.id}')), findsOneWidget);
    await tester.tapAt(
      tester.getTopLeft(find.byKey(const Key('diamond'))) + geo(tester).third,
    );
    await settle(tester);

    expect((await game(gameId)).ourRuns, 1);
    expect(find.textContaining('1 run'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('three outs flip to the opponent card; tap and swipe run it', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    for (var i = 0; i < 3; i++) {
      await dragChip(tester, const Offset(0, 70));
      await answer(tester, 'how-ground');
    }
    expect(find.text('RUNS THIS HALF'), findsOneWidget);

    await tap(tester, find.byKey(const Key('their-half')));
    await tap(tester, find.byKey(const Key('their-half')));
    expect(tester.widget<Text>(find.byKey(const Key('their-tally'))).data, '2');
    expect((await game(gameId)).theirRuns, 2);

    await tester.drag(
      find.byKey(const Key('their-half')),
      const Offset(0, -140),
    );
    await settle(tester);

    expect(find.text('RUNS THIS HALF'), findsNothing);
    expect(find.textContaining('Top 2'), findsOneWidget);
    expect((await game(gameId)).theirRuns, 2);
    await finish(tester);
  });

  testWidgets('swiping the name down undoes; sideways moves the order', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');
    expect((await scoring.plateAppearances(gameId)).length, 1);

    await tester.drag(find.byType(BatterCard), const Offset(0, 120));
    await settle(tester);
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await tester.drag(find.byType(BatterCard), const Offset(-120, 0));
    await settle(tester);
    expect((await game(gameId)).currentBatterIndex, 1);
    await finish(tester);
  });

  testWidgets('the last line opens a fix sheet in plain words', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');
    await tap(tester, find.byKey(const Key('last-play')));
    expect(find.text('On an error'), findsOneWidget);

    await tap(tester, find.byKey(const Key('fix-error')));
    expect(
      (await scoring.plateAppearances(gameId)).single.result,
      'reach_on_error',
    );

    await tap(tester, find.text('Done'));
    expect(find.textContaining('on an error'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('an out with a run scored becomes a sac fly', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toThird(tester));
    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'how-fly');
    await tap(tester, find.byKey(const Key('last-play')));
    expect(find.text('HOW'), findsOneWidget);
    await tap(tester, find.byKey(const Key('fix-runScored')));

    var pas = await scoring.plateAppearances(gameId);
    expect(pas.last.result, 'sac_fly');
    expect(pas.last.rbi, 1);

    // Say it was on the ground and it becomes an RBI groundout instead.
    await tap(tester, find.byKey(const Key('fix-kind-ground')));
    pas = await scoring.plateAppearances(gameId);
    expect(pas.last.result, 'out');
    expect(pas.last.rbi, 1);
    await finish(tester);
  });

  testWidgets('the score line opens the log', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);
    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');

    // The situation line is what opens the log now.
    await tap(tester, find.byKey(const Key('situation')));
    expect(find.text('This game'), findsOneWidget);
    expect(find.textContaining('1 plate appearance'), findsOneWidget);
    expect(find.textContaining('Ada singled'), findsWidgets);
    await finish(tester);
  });

  testWidgets('my at-bats only: no score, your day is the hero', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    expect(find.byKey(const Key('us-runs')), findsNothing);
    expect(find.byKey(const Key('your-day')), findsOneWidget);
    expect(find.byKey(const Key('opponent-pill')), findsOneWidget);
    expect(find.text('VS REDS'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('no opponent, no problem', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame();
    await pump(tester, gameId);
    expect(find.text('PERSONAL GAME'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('team scores stay independent of RBI and halves end by hand', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(
      opponentName: 'Reds',
      scope: GameScope.game,
      homeAway: 'away',
    );
    await pump(tester, gameId);

    expect(find.byKey(const Key('us-runs')), findsOneWidget);
    // No lineup, so no outs in the line: just the half and inning.
    expect(find.textContaining('Top 1'), findsOneWidget);

    // Tapping our score adds one team run. RBI does not add it again.
    await tap(tester, find.byKey(const Key('us-runs')));
    expect((await game(gameId)).ourRuns, 1);

    await dragChip(tester, toSecond(tester));
    await answer(tester, 'rbi-2');
    expect((await game(gameId)).ourRuns, 1);

    // Swiping the situation line ends our half.
    await tester.fling(
      find.byKey(const Key('situation')),
      const Offset(-120, 0),
      600,
    );
    await settle(tester);
    expect(find.text('RUNS THIS HALF'), findsOneWidget);

    await tap(tester, find.byKey(const Key('their-half')));
    expect((await game(gameId)).theirRuns, 1);
    await tester.drag(
      find.byKey(const Key('their-half')),
      const Offset(0, -140),
    );
    await settle(tester);
    expect(find.textContaining('Top 2'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('team scores: home means they bat first', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(
      opponentName: 'Reds',
      scope: GameScope.game,
      homeAway: 'home',
    );
    await pump(tester, gameId);
    expect(find.text('RUNS THIS HALF'), findsOneWidget);
    expect(find.textContaining('they bat'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a personal hit asks how, then RBI, before it files', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    expect(find.byKey(const Key('your-day')), findsOneWidget);
    expect(find.text('VS REDS'), findsOneWidget);
    expect(find.textContaining('PA '), findsNothing);

    await dragChip(tester, toFirst(tester));
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const Key('ask-reach')), findsOneWidget);
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'reach-single');
    expect(find.byKey(const Key('ask-rbi')), findsOneWidget);
    expect(find.text('RBI'), findsOneWidget);
    for (var n = 0; n <= 4; n++) {
      expect(find.byKey(Key('rbi-$n')), findsOneWidget);
    }
    // Still nothing filed: RBI is not assumed to be zero.
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'rbi-2');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'single');
    expect(pa.rbi, 2);
    expect((await game(gameId)).ourRuns, 2);
    expect(find.text('1 for 1'), findsOneWidget);
    expect(find.text('2 RBI  ·  0 runs'), findsOneWidget);
    expect(find.textContaining('Single · 2 RBI'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a personal double asks only for RBI', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    await dragChip(tester, toSecond(tester));
    expect(find.byKey(const Key('ask-rbi')), findsOneWidget);
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'rbi-0');
    expect((await scoring.plateAppearances(gameId)).single.result, 'double');
    expect((await game(gameId)).ourRuns, 0);
    await finish(tester);
  });

  testWidgets('a personal home run starts at one RBI, never zero', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    final g = geo(tester);
    await dragChip(tester, Offset(0, -(g.home.dy - g.fenceY + 12)));

    expect(find.byKey(const Key('rbi-0')), findsNothing);
    expect(find.byKey(const Key('rbi-1')), findsOneWidget);

    await answer(tester, 'rbi-3');
    expect((await scoring.plateAppearances(gameId)).single.rbi, 3);
    expect((await game(gameId)).ourRuns, 3);
    await finish(tester);
  });

  testWidgets('a personal out asks how, not for RBI', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('ask-how')), findsOneWidget);
    expect(find.byKey(const Key('ask-rbi')), findsNothing);

    await answer(tester, 'how-ground');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'out');
    expect(pa.outKind, 'ground');
    await finish(tester);
  });

  testWidgets('a team hit points at the runner instead of asking for RBI', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');
    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');

    // Runs come off the diamond, so there is nothing to type.
    expect(find.byKey(const Key('ask-rbi')), findsNothing);
    expect(find.byKey(const Key('wave-hint')), findsOneWidget);
    await finish(tester);
  });

  testWidgets('no lineup: the chip is parked and the card says so', (
    tester,
  ) async {
    final team = await tracker.createTeam(name: 'Club');
    final gameId = await tracker.createGame(teamId: team.id, homeAway: 'away');
    await pump(tester, gameId);

    expect(find.text('Pick a batting order to start'), findsWidgets);
    await dragChip(tester, toFirst(tester));
    expect(find.byKey(const Key('ask-reach')), findsNothing);
    expect(await scoring.plateAppearances(gameId), isEmpty);
    await finish(tester);
  });

  testWidgets('a finished game shows the final', (tester) async {
    final gameId = await teamGame();
    await scoring.finalizeGame(await game(gameId));
    await pump(tester, gameId);

    expect(find.text('FINAL'), findsOneWidget);
    expect(find.text('Reopen game'), findsOneWidget);
    await finish(tester);
  });
}
