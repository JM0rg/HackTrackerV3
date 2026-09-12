import 'dart:math' as math;
import 'package:hacktracker/features/scoring/presentation/widgets/one_card_diamond.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/contact_field.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
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
  Future<void> pump(
    WidgetTester tester,
    String gameId, {
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
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locationTrackingProvider.overrideWithValue(premium),
        ],
        child: MaterialApp(
          theme: AppTheme.dark(),
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

  /// Database writes are not driven by the fake clock on their own.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 20));
    }
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await settle(tester);
  }

  /// Answer the one question the row is asking. Answering the last one files
  /// the play; there is no separate save.
  Future<void> answer(WidgetTester tester, String key) =>
      tap(tester, find.byKey(Key(key)));

  /// Read the diamond's real size back, so drags land wherever it was laid out.
  FieldGeometry geo(WidgetTester tester) =>
      FieldGeometry(tester.getSize(find.byKey(const Key('diamond'))).width);
  Offset home(WidgetTester tester) =>
      tester.getTopLeft(find.byKey(const Key('diamond'))) + geo(tester).home;

  Future<void> dragChip(WidgetTester tester, Offset by) async {
    // Native safe-area insets can put the plate below the initial viewport.
    await tester.ensureVisible(find.byKey(const Key('batter-chip')));
    await tester.pumpAndSettle();
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

  /// The newest row of the log names the batter and says what they did.
  void expectLastPlay(String name, String verb) {
    final row = find.byKey(const Key('last-play'));
    expect(row, findsOneWidget);
    expect(find.descendant(of: row, matching: find.text(name)), findsOneWidget);
    expect(
      find.descendant(of: row, matching: find.textContaining(verb)),
      findsOneWidget,
    );
  }

  testWidgets('the hitter parks on the bag, then runs it when filed', (
    tester,
  ) async {
    final id = await teamGame();
    await pump(tester, id, premium: true);
    final diamondRect = tester.getRect(find.byKey(const Key('diamond')));
    final diamondElement = tester.element(find.byKey(const Key('diamond')));
    final g = tester
        .widget<OneCardDiamond>(find.byType(OneCardDiamond))
        .geometry;

    await tester.tap(find.byKey(const Key('zone-second')));
    await tester.pumpAndSettle();

    Offset chipAt() {
      final chip = tester.widget<AnimatedPositioned>(
        find.byKey(const Key('batter-chip')),
      );
      return Offset(chip.left!, chip.top!);
    }

    // Dropped on second, and standing there while the play is described.
    expect(chipAt(), g.second);
    expect(await scoring.plateAppearances(id), isEmpty);
    // The field is asked about first, and it never moves under the answer.
    expect(find.byKey(const Key('ask-location')), findsOneWidget);
    expect(find.byKey(const Key('contact-field')), findsOneWidget);
    expect(
      tester.element(find.byKey(const Key('diamond'))),
      same(diamondElement),
    );
    expect(tester.getRect(find.byKey(const Key('diamond'))), diamondRect);

    // Answer it all out, and only then does the hitter run.
    await tap(tester, find.byKey(const Key('location-skip')));
    await settle(tester);
    expect(chipAt(), g.second);
    // A raw tap: settling here would run the whole replay before it can be
    // watched.
    await tester.tap(find.byKey(const Key('how-line')));
    double distanceToLeg(Offset p, Offset a, Offset b) {
      final leg = b - a;
      final offset = p - a;
      final progress =
          ((offset.dx * leg.dx + offset.dy * leg.dy) / leg.distanceSquared)
              .clamp(0.0, 1.0);
      return (p - (a + leg * progress)).distance;
    }

    // Watch the whole thing. The write has to land before the run can start,
    // so step rather than jump, and run past the end of the replay.
    double chipOpacity() => tester
        .widgetList<Opacity>(
          find.descendant(
            of: find.byKey(const Key('batter-chip')),
            matching: find.byType(Opacity),
          ),
        )
        .fold<double>(1, (a, o) => a * o.opacity);

    var furthest = 0.0;
    var atSecond = 0;
    var fadedOnSecond = 0;
    for (var i = 0; i < 120; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      final p = chipAt();
      furthest = math.max(furthest, (p - g.home).distance);
      // Always on the basepaths, never cutting across the diamond.
      expect(
        [
          distanceToLeg(p, g.home, g.first),
          distanceToLeg(p, g.first, g.second),
          distanceToLeg(p, g.second, g.third),
          distanceToLeg(p, g.third, g.home),
        ].any((d) => d < 1),
        isTrue,
        reason: 'off the basepaths at $p',
      );
      if (p == g.second) {
        atSecond += 1;
        if (chipOpacity() < 0.9) fadedOnSecond += 1;
      }
    }
    expect(furthest, greaterThan(20));
    // It holds on the result rather than snapping back the instant it lands,
    // and the hitter leaves by fading rather than vanishing.
    expect(atSecond, greaterThan(8), reason: 'no pause on the result');
    expect(fadedOnSecond, greaterThan(1), reason: 'the hitter never faded');

    await tester.pumpAndSettle();
    expect(chipAt(), g.home);
    expect((await scoring.plateAppearances(id)).single.result, 'double');
    await finish(tester);
  });

  testWidgets('discarding a shown play asks, and clears the field', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));
    await tap(tester, find.byKey(const Key('location-skip')));
    await tap(tester, find.byKey(const Key('how-line')));
    await settle(tester);
    expect(find.text('How many scored?'), findsOneWidget);

    // The ask takes over the same bar, in the same shape, rather than opening
    // a box over the field.
    final bar = tester.getRect(find.byKey(const Key('ask-rbi')));
    await tap(tester, find.byKey(const Key('ask-cancel')));
    expect(find.text('Discard this at-bat?'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.getRect(find.byKey(const Key('ask-discard'))), bar);

    await tap(tester, find.byKey(const Key('discard-confirm')));
    await settle(tester);

    expect(await scoring.plateAppearances(id), isEmpty);
    expect(find.text('How many scored?'), findsNothing);
    // The hitter is back at the plate, ready for another go.
    final g = tester
        .widget<OneCardDiamond>(find.byType(OneCardDiamond))
        .geometry;
    final chip = tester.widget<AnimatedPositioned>(
      find.byKey(const Key('batter-chip')),
    );
    expect(Offset(chip.left!, chip.top!), g.home);

    await dragChip(tester, toFirst(tester));
    await tap(tester, find.byKey(const Key('location-skip')));
    await tap(tester, find.byKey(const Key('reach-single')));
    await tap(tester, find.byKey(const Key('how-ground')));
    await answer(tester, 'rbi-0');
    expect((await scoring.plateAppearances(id)).single.result, 'single');
    await finish(tester);
  });

  testWidgets('the play is shown before the runs are counted', (tester) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toThird(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final cg =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    await tester.tapAt(tester.getTopLeft(field) + cg.point(.36, .58));
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);

    final g = tester
        .widget<OneCardDiamond>(find.byType(OneCardDiamond))
        .geometry;
    Offset chipAt() {
      final chip = tester.widget<AnimatedPositioned>(
        find.byKey(const Key('batter-chip')),
      );
      return Offset(chip.left!, chip.top!);
    }

    // Parked on third, nothing has run yet.
    expect(chipAt(), g.third);

    // Say how it was hit, raw so the replay can be watched.
    await tester.tap(find.byKey(const Key('how-fly')));
    var ran = false;
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      final p = chipAt();
      if (p != g.third && p != g.home) ran = true;
    }
    // The play is shown, and nothing has been written yet.
    expect(ran, isTrue, reason: 'the play was never shown');
    expect(await scoring.plateAppearances(id), isEmpty);
    // The count is still waiting to be answered, after the watching.
    expect(find.text('How many scored?'), findsOneWidget);

    await tester.pumpAndSettle();
    await answer(tester, 'rbi-2');
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.result, 'triple');
    expect(pa.outKind, 'fly');
    expect(pa.rbi, 2);
    // Written once, and not shown a second time for being written.
    expect(chipAt(), g.home);
    await finish(tester);
  });

  testWidgets('the runners on base move with the hitter', (tester) async {
    final id = await teamGame();
    await pump(tester, id);

    // Put a runner on first, and let the replay finish.
    await dragChip(tester, toFirst(tester));
    await answer(tester, 'reach-single');
    await settle(tester);
    final players = await tracker.players((await game(id)).teamId!);
    final ada = players.first;
    final g = tester
        .widget<OneCardDiamond>(find.byType(OneCardDiamond))
        .geometry;
    Offset runnerAt(String pid) {
      final w = tester.widget<AnimatedPositioned>(
        find.descendant(
          of: find.byKey(Key('runner-$pid')),
          matching: find.byType(AnimatedPositioned),
        ),
      );
      return Offset(w.left!, w.top!);
    }

    expect(runnerAt(ada.id), g.first);

    // The next hitter doubles. Ada has to go too. Drag raw: settling here
    // would run the whole replay before it can be watched.
    await tester.dragFrom(home(tester), toSecond(tester));
    var moved = 0;
    var everOffBase = false;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 40));
      final at = runnerAt(ada.id);
      if (at != g.first && at != g.third && at != g.home) everOffBase = true;
      if (at != g.first) moved += 1;
    }
    expect(everOffBase, isTrue, reason: 'the runner never left first');
    expect(moved, greaterThan(0));

    await tester.pumpAndSettle();
    // Two on, and the field agrees with the book again.
    expect(runnerAt(ada.id), g.third);
    await finish(tester);
  });

  testWidgets('the next drag cuts the replay short', (tester) async {
    final id = await teamGame();
    await pump(tester, id);

    await dragChip(tester, toSecond(tester));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    // Mid-replay, and impatient: the next play starts without a skip tap.
    await dragChip(tester, toFirst(tester));
    await settle(tester);
    await answer(tester, 'reach-single');
    await settle(tester);

    final pas = await scoring.plateAppearances(id);
    expect(pas.length, 2);
    expect(pas.first.result, 'double');
    expect(pas.last.result, 'single');
    await finish(tester);
  });

  testWidgets(
    'premium asks where it went, then how many scored, and survives a restart',
    (tester) async {
      final id = await me.createPersonalGame();
      await pump(tester, id, premium: true);
      expect(find.byKey(const Key('contact-field')), findsNothing);
      await dragChip(tester, toSecond(tester));

      // One question at a time: the field first, because that is the answer.
      expect(find.text('Where did it go?'), findsOneWidget);
      expect(find.text('How many scored?'), findsNothing);
      expect(await scoring.plateAppearances(id), isEmpty);

      final field = find.byKey(const Key('contact-field'));
      Future<void> locate(double x, double y) async {
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        final g =
            (tester.widget<ContactField>(find.byType(ContactField)).geometry ??
            ContactFieldGeometry(tester.getSize(field)));
        await tester.tapAt(tester.getTopLeft(field) + g.point(x, y));
        await settle(tester);
      }

      await locate(.3, .7);
      // A hit is described the same way an out is, and beside the ball.
      expect(find.text('How was it hit?'), findsOneWidget);
      expect(find.byKey(const Key('how-k')), findsNothing);
      // The field keeps taking taps: the ball can still be moved while the
      // later questions are open.
      expect(find.byKey(const Key('contact-field')), findsOneWidget);
      expect(
        tester.widget<ContactField>(find.byType(ContactField)).onLocation,
        isNotNull,
      );
      expect(await scoring.plateAppearances(id), isEmpty);

      // Moving it does not disturb the question that followed.
      await locate(-.2, .5);
      expect(find.text('How was it hit?'), findsOneWidget);
      expect(await scoring.plateAppearances(id), isEmpty);

      await tester.tap(find.byKey(const Key('how-line')));
      await settle(tester);
      expect(find.text('How many scored?'), findsOneWidget);

      // The half-answered play survives the app going away.
      final draft = (await scoring.game(id))!.scoringDraft;
      expect(draft, contains('"version":1'));
      await finish(tester);
      await pump(tester, id, premium: true);
      expect(find.text('How many scored?'), findsOneWidget);

      await answer(tester, 'rbi-2');
      final pa = (await scoring.plateAppearances(id)).single;
      expect(pa.result, 'double');
      expect(pa.outKind, 'line');
      expect(pa.rbi, 2);
      expect(ContactLocation.parse(pa.hitLocation)!.x, closeTo(-.2, .001));
      expect((await scoring.game(id))!.scoringDraft, isNull);
      expect(find.byKey(const Key('diamond')), findsOneWidget);
      await finish(tester);
    },
  );

  testWidgets('the ball cannot be placed off the field', (tester) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    final origin = tester.getTopLeft(field);

    // Drag it well past the wall and out over the left field line.
    final touch = await tester.startGesture(origin + g.point(0, .4));
    await tester.pump();
    await touch.moveTo(origin + g.point(-1.4, .5));
    await tester.pump();
    await touch.up();
    await settle(tester);

    await tester.tap(find.byKey(const Key('how-ground')));
    await settle(tester);
    await answer(tester, 'rbi-0');
    final at = ContactLocation.parse(
      (await scoring.plateAppearances(id)).single.hitLocation,
    )!;
    // Inside the fence, and no further foul than the line itself.
    final reach = math.sqrt(at.x! * at.x! + at.y! * at.y!);
    expect(reach, lessThanOrEqualTo(1.0001));
    expect(at.y, greaterThan(0));
    expect(at.x! / at.y!, closeTo(-1, .0001));
    await finish(tester);
  });

  testWidgets('a located out is described beside the ball, never as a K', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, const Offset(0, 70));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    final ball = tester.getTopLeft(field) + g.point(.25, .35);
    await tester.tapAt(ball);
    await settle(tester);

    // The out is still being described, and the ball can still be moved.
    expect(find.text('How was the out?'), findsOneWidget);
    expect(
      tester.widget<ContactField>(find.byType(ContactField)).onLocation,
      isNotNull,
    );

    // A ball on the grass was in play, so it cannot have been a strikeout.
    expect(find.byKey(const Key('how-k')), findsNothing);

    // The three that are left stand beside the ball, not under the field, so
    // the eye never leaves the mark it just placed.
    final cluster = tester.getCenter(find.byKey(const Key('how-line')));
    expect((cluster.dy - ball.dy).abs(), lessThan(90));
    expect((cluster.dx - ball.dx).abs(), lessThan(140));

    // Answering it moves the play on to the runs, down in the bar.
    await tester.tap(find.byKey(const Key('how-line')));
    await settle(tester);
    expect(find.text('How many scored?'), findsOneWidget);
    expect(await scoring.plateAppearances(id), isEmpty);

    await answer(tester, 'rbi-1');
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.result, 'sac_fly');
    expect(pa.outKind, 'line');
    expect(pa.hitLocation, isNotNull);
    await finish(tester);
  });

  testWidgets('skipping the location leaves K on the table', (tester) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, const Offset(0, 70));

    // No ball was placed, so a strikeout is still one of the ways out.
    await tap(tester, find.byKey(const Key('location-skip')));
    await settle(tester);
    expect(find.byKey(const Key('how-k')), findsOneWidget);

    await answer(tester, 'how-k');
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.result, 'strikeout');
    expect(pa.hitLocation, isNull);
    await finish(tester);
  });

  testWidgets('a half-answered play comes back ready to finish', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    await tester.tapAt(tester.getTopLeft(field) + g.point(-.3, .55));
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);

    // Away and back with the question still open.
    await finish(tester);
    await pump(tester, id, premium: true);

    expect(find.text('How was it hit?'), findsOneWidget);
    // The answers are reachable, not stranded beside a ball that never ran.
    expect(find.byKey(const Key('how-line')), findsOneWidget);
    // Still standing on the bag it was dropped on, waiting to be described.
    final geo = FieldGeometry(
      tester.getSize(find.byKey(const Key('diamond'))).width,
    );
    final chip = tester.widget<AnimatedPositioned>(
      find.byKey(const Key('batter-chip')),
    );
    expect(Offset(chip.left!, chip.top!), geo.second);

    await tester.tap(find.byKey(const Key('how-line')));
    await settle(tester);
    await answer(tester, 'rbi-0');
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.result, 'double');
    expect(pa.outKind, 'line');
    expect(pa.hitLocation, isNotNull);
    await finish(tester);
  });

  testWidgets('coming back mid-placement, the field still takes taps', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));
    expect(find.text('Where did it go?'), findsOneWidget);

    await finish(tester);
    await pump(tester, id, premium: true);
    expect(find.text('Where did it go?'), findsOneWidget);

    final field = find.byKey(const Key('contact-field'));
    expect(
      tester.widget<ContactField>(find.byType(ContactField)).onLocation,
      isNotNull,
    );
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    await tester.tapAt(tester.getTopLeft(field) + g.point(.35, .5));
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('the answers keep clear of the hitter standing on the bag', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    // Dropped on second, so the hitter is parked right where a ball to
    // left-centre would otherwise put the answers.
    await dragChip(tester, toSecond(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final cg =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    await tester.tapAt(tester.getTopLeft(field) + cg.point(-.30, .62));
    await settle(tester);

    final chip = tester.getRect(find.byKey(const Key('batter-chip')));
    for (final kind in const ['fly', 'ground', 'line']) {
      final pill = tester.getRect(find.byKey(Key('how-$kind')));
      expect(
        pill.overlaps(chip.deflate(4)),
        isFalse,
        reason: '$kind sits on the hitter',
      );
      // And reachable: a tap has to land on the pill, not on a runner.
      expect(
        find.byKey(Key('how-$kind')).hitTestable(),
        findsOneWidget,
        reason: '$kind is not hittable',
      );
    }
    await finish(tester);
  });

  testWidgets('nothing is filed while the finger is still down', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    final origin = tester.getTopLeft(field);

    final touch = await tester.startGesture(origin + g.point(0, .5));
    await tester.pump();
    expect(find.text('Where did it go?'), findsOneWidget);

    // Out past the left field line and back again, finger never lifted.
    for (final at in const [
      Offset(-.9, .35),
      Offset(-1.3, .2),
      Offset(-.5, .6),
    ]) {
      await touch.moveTo(origin + g.point(at.dx, at.dy));
      await tester.pump();
      expect(find.text('Where did it go?'), findsOneWidget);
      expect(find.byKey(const Key('how-line')), findsNothing);
      expect(await scoring.plateAppearances(id), isEmpty);
    }

    // Only letting go asks how it was hit.
    await touch.up();
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);
    expect(find.byKey(const Key('how-line')), findsOneWidget);

    // And with the ball already placed, putting a finger back down takes the
    // answers away again rather than leaving them under the hand.
    final again = await tester.startGesture(origin + g.point(.2, .6));
    await tester.pump();
    expect(find.byKey(const Key('how-line')), findsNothing);
    await again.moveTo(origin + g.point(.45, .45));
    await tester.pump();
    expect(find.byKey(const Key('how-line')), findsNothing);
    await again.up();
    await settle(tester);
    expect(find.byKey(const Key('how-line')), findsOneWidget);

    await tester.tap(find.byKey(const Key('how-line')));
    await settle(tester);
    await answer(tester, 'rbi-0');
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.outKind, 'line');
    expect(ContactLocation.parse(pa.hitLocation)!.x, closeTo(.45, .001));
    await finish(tester);
  });

  testWidgets('a hit is described but a walk is not', (tester) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toFirst(tester));

    // Where it went, then what it was, then how it was hit: a walk could
    // still be the answer, so nothing is described until it is not.
    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    await tester.tapAt(tester.getTopLeft(field) + g.point(.1, .3));
    await settle(tester);
    expect(find.text('How did they reach?'), findsOneWidget);
    expect(find.byKey(const Key('ask-how')), findsNothing);

    // A walk put nothing in play, so the question never comes.
    await tap(tester, find.byKey(const Key('reach-walk')));
    await settle(tester);
    expect(find.byKey(const Key('ask-how')), findsNothing);
    expect(find.text('How many scored?'), findsOneWidget);
    await answer(tester, 'rbi-0');
    final walk = (await scoring.plateAppearances(id)).single;
    expect(walk.result, 'walk');
    expect(walk.outKind, isNull);
    expect(walk.hitLocation, isNull);

    // A single did, so it is described beside the ball.
    await dragChip(tester, toFirst(tester));
    await tester.tapAt(tester.getTopLeft(field) + g.point(-.3, .5));
    await settle(tester);
    await tap(tester, find.byKey(const Key('reach-single')));
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('how-ground')));
    await settle(tester);
    await answer(tester, 'rbi-0');
    final hit = (await scoring.plateAppearances(id)).last;
    expect(hit.result, 'single');
    expect(hit.outKind, 'ground');
    await finish(tester);
  });

  testWidgets('without ball detail a hit is still one drag', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    // No location module, so nothing is asked about the ball on a hit.
    await dragChip(tester, toSecond(tester));
    await settle(tester);
    expect(find.byKey(const Key('ask-how')), findsNothing);
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'double');
    expect(pa.outKind, isNull);
    await finish(tester);
  });

  testWidgets('a personal game claims nothing about the batting order', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);

    // Only your own trips to the plate are logged, so the app cannot know
    // that your first one is the game's first.
    expect(find.text('First batter of the game'), findsNothing);
    await finish(tester);
  });

  testWidgets('the ball is dragged into place and lands on release', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    await pump(tester, id, premium: true);
    await dragChip(tester, toSecond(tester));

    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.pumpAndSettle();
    final g =
        tester.widget<ContactField>(find.byType(ContactField)).geometry ??
        ContactFieldGeometry(tester.getSize(field));
    final origin = tester.getTopLeft(field);

    // Touching down shows the ball without answering anything.
    final touch = await tester.startGesture(origin + g.point(-.4, .4));
    await tester.pump();
    expect(find.text('Where did it go?'), findsOneWidget);
    expect(find.text('How many scored?'), findsNothing);

    // It follows the finger, still uncommitted.
    await touch.moveTo(origin + g.point(.5, .6));
    await tester.pump();
    expect(find.text('Where did it go?'), findsOneWidget);

    // Letting go places it, where it was last seen and not where it started.
    await touch.up();
    await settle(tester);
    expect(find.text('How was it hit?'), findsOneWidget);

    await tester.tap(find.byKey(const Key('how-fly')));
    await settle(tester);
    await answer(tester, 'rbi-0');
    final pa = (await scoring.plateAppearances(id)).single;
    final at = ContactLocation.parse(pa.hitLocation)!;
    expect(at.x, closeTo(.5, .001));
    // The ball rides above the finger while it is dragged, so it may be
    // placed no shallower than where the finger let go.
    expect(at.y, greaterThan(.6));
    await finish(tester);
  });

  testWidgets(
    'a walk keeps no location, a cancel keeps no play, free asks no location',
    (tester) async {
      final id = await me.createPersonalGame();
      await pump(tester, id, premium: true);
      await dragChip(tester, toFirst(tester));
      final field = find.byKey(const Key('contact-field'));
      await tester.ensureVisible(field);
      await tester.tapAt(
        tester.getTopLeft(field) +
            (tester.widget<ContactField>(find.byType(ContactField)).geometry ??
                    ContactFieldGeometry(tester.getSize(field)))
                .point(.2, .6),
      );
      await settle(tester);

      await tap(tester, find.byKey(const Key('reach-walk')));
      expect(find.byKey(const Key('contact-field')), findsNothing);
      expect(await scoring.plateAppearances(id), isEmpty);
      await answer(tester, 'rbi-0');
      expect((await scoring.plateAppearances(id)).single.hitLocation, isNull);

      await dragChip(tester, toSecond(tester));
      // Throwing an at-bat away is asked about first.
      await tap(tester, find.byKey(const Key('ask-cancel')));
      await tap(tester, find.byKey(const Key('discard-confirm')));
      expect((await scoring.plateAppearances(id)).length, 1);
      expect((await scoring.game(id))!.scoringDraft, isNull);
      await finish(tester);

      // Without the module there is no location to ask about.
      await pump(tester, id, premium: false);
      await dragChip(tester, toSecond(tester));
      expect(find.byKey(const Key('contact-field')), findsNothing);
      expect(find.text('Where did it go?'), findsNothing);
      await answer(tester, 'rbi-0');
      expect((await scoring.plateAppearances(id)).length, 2);
      await finish(tester);
    },
  );

  testWidgets('a failed write keeps the answered play and retries once', (
    tester,
  ) async {
    final id = await teamGame();
    await pump(tester, id, premium: true);
    await db.customStatement(
      "CREATE TRIGGER reject_pa BEFORE INSERT ON plate_appearances BEGIN SELECT RAISE(ABORT, 'test'); END",
    );
    await dragChip(tester, toSecond(tester));
    final field = find.byKey(const Key('contact-field'));
    await tester.ensureVisible(field);
    await tester.tapAt(
      tester.getTopLeft(field) +
          (tester.widget<ContactField>(find.byType(ContactField)).geometry ??
                  ContactFieldGeometry(tester.getSize(field)))
              .point(.2, .6),
    );
    await settle(tester);
    await tester.tap(find.byKey(const Key('how-line')));
    await settle(tester);

    expect(await scoring.plateAppearances(id), isEmpty);
    expect(find.text('Play not saved.'), findsOneWidget);
    await db.customStatement('DROP TRIGGER reject_pa');
    await tap(tester, find.text('Retry'));
    expect((await scoring.plateAppearances(id)).single.hitLocation, isNotNull);
    await finish(tester);
  });

  testWidgets('handoff keeps scoring available and hides the game menu', (
    tester,
  ) async {
    final id = await teamGame();
    await pump(tester, id);
    // Handing off is a once-a-game action, so it lives in the menu.
    await tap(tester, find.byTooltip('Game menu'));
    await tap(tester, find.text('Hand off the phone'));
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
    // A team game is scored in order, so the app knows who leads off.
    expect(find.text('First batter of the game'), findsOneWidget);
    // Who follows, named in the dugout.
    expect(tester.widget<Text>(find.byKey(const Key('next-up'))).data, 'Sam');
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
    expect(find.byKey(const Key('reach-single')), findsOneWidget);

    await answer(tester, 'reach-single');

    expect((await scoring.plateAppearances(gameId)).single.result, 'single');
    expectLastPlay('Ada', 'singled');
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

    // Explicit submission commits the selected double.
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
    expect(find.byKey(const Key('how-ground')), findsNothing);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('how-ground')), findsOneWidget);
    for (final label in ['Fly', 'Ground', 'Line', 'K']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'how-fly');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'out');
    expect(pa.outKind, 'fly');
    expectLastPlay('Ada', 'flied out');
    await finish(tester);
  });

  testWidgets('K is one of the ways out', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'how-k');

    expect((await scoring.plateAppearances(gameId)).single.result, 'strikeout');
    expectLastPlay('Ada', 'struck out');
    await finish(tester);
  });

  testWidgets('an unanswered play blocks the next drag until it is settled', (
    tester,
  ) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('how-ground')), findsOneWidget);

    // An unanswered out is not filed, and the next batter is not active.
    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('how-ground')), findsOneWidget);

    await answer(tester, 'how-line');
    expect((await scoring.plateAppearances(gameId)).single.outKind, 'line');
    await finish(tester);
  });

  testWidgets('a misfire can be cancelled instead of answered', (tester) async {
    final gameId = await teamGame();
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));

    // Backing out asks first, and backing out of the ask changes nothing.
    await tap(tester, find.byKey(const Key('ask-cancel')));
    await tap(tester, find.byKey(const Key('discard-keep')));
    expect(find.byKey(const Key('how-ground')), findsOneWidget);

    await tap(tester, find.byKey(const Key('ask-cancel')));
    await tap(tester, find.byKey(const Key('discard-confirm')));

    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('how-ground')), findsNothing);

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
    expectLastPlay('Ada', 'walked');
    await finish(tester);
  });

  testWidgets('error and fielders choice remain selectable before saving', (
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
    expectLastPlay('Ada', 'singled');
    await finish(tester);
  });

  testWidgets('my at-bats only: no score, your day is the hero', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    expect(find.byKey(const Key('us-runs')), findsNothing);
    // Your day stands where the score would: beyond the wall, no label.
    expect(find.byKey(const Key('your-day')), findsOneWidget);
    expect(find.textContaining('Reds'), findsOneWidget);
    expect(find.text('YOUR DAY'), findsNothing);
    await finish(tester);
  });

  testWidgets('no opponent, no problem', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame();
    await pump(tester, gameId);
    // Nothing to say about the opponent, so nothing is said.
    expect(find.byKey(const Key('your-day')), findsOneWidget);
    expect(find.text('PERSONAL GAME'), findsNothing);
    expect(tester.takeException(), isNull);
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

  testWidgets('a personal hit reviews result and RBI before saving', (
    tester,
  ) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    expect(find.byKey(const Key('your-day')), findsOneWidget);
    expect(find.textContaining('Reds'), findsOneWidget);
    expect(find.textContaining('PA '), findsNothing);

    await dragChip(tester, toFirst(tester));
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const Key('reach-single')), findsOneWidget);
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'reach-single');
    expect(find.byKey(const Key('rbi-0')), findsOneWidget);
    expect(find.text('How many scored?'), findsOneWidget);
    for (var n = 0; n <= 4; n++) {
      expect(find.byKey(Key('rbi-$n')), findsOneWidget);
    }
    // Still nothing filed: choosing an input is not submission.
    expect(await scoring.plateAppearances(gameId), isEmpty);

    await answer(tester, 'rbi-2');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'single');
    expect(pa.rbi, 2);
    expect((await game(gameId)).ourRuns, 2);
    expect(find.text('1 for 1'), findsOneWidget);
    expect(find.textContaining('2 RBI  ·  0 runs'), findsOneWidget);
    expect(find.textContaining('Single · 2 RBI'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a personal double allows RBI review', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    await dragChip(tester, toSecond(tester));
    expect(find.byKey(const Key('rbi-0')), findsOneWidget);
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

  testWidgets('a personal out still asks who it drove in', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    expect(find.byKey(const Key('how-ground')), findsOneWidget);
    expect(find.byKey(const Key('rbi-0')), findsNothing);

    // The out is not filed until the RBI question is answered too.
    await answer(tester, 'how-ground');
    expect(await scoring.plateAppearances(gameId), isEmpty);
    expect(find.byKey(const Key('rbi-1')), findsOneWidget);

    await answer(tester, 'rbi-1');
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'out');
    expect(pa.outKind, 'ground');
    expect(pa.runsOnPlay, 1);
    await finish(tester);
  });

  testWidgets('a strikeout skips the RBI question', (tester) async {
    await me.ensureMe();
    final gameId = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, gameId);

    await dragChip(tester, const Offset(0, 70));
    await answer(tester, 'how-k');
    expect(find.byKey(const Key('ask-rbi')), findsNothing);
    final pa = (await scoring.plateAppearances(gameId)).single;
    expect(pa.result, 'strikeout');
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

    // Runs come off the diamond, so there is nothing to type, and the play
    // itself is reported in the log rather than under the field.
    expect(find.byKey(const Key('rbi-0')), findsNothing);
    expect(find.byKey(const Key('wave-hint')), findsOneWidget);
    expect(find.text('filed'), findsNothing);
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
    expect(find.byKey(const Key('reach-single')), findsNothing);
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
