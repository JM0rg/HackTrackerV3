import 'dart:convert';
import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:hacktracker/features/backup/data/local_backup.dart';
import 'dart:math' as math;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/contact_field.dart';
import 'package:hacktracker/features/stats/presentation/screens/spray_chart_screen.dart';
import 'package:uuid/uuid.dart';
import '../../helpers/test_fonts.dart';
import '../../helpers/connectivity_mock.dart';

void main() {
  setUpAll(() async {
    mockConnectivity();
    await loadTestFonts();
  });
  test('normalized points, legacy regions and malformed locations', () {
    final p = ContactLocation.parse(
      const ContactLocation(
        x: .3,
        y: .7,
        flight: 'line',
        bats: 'left',
      ).encode(),
    )!;
    expect(p.x, .3);
    expect(p.bats, 'left');
    expect(p.direction, 'Right');
    expect(ContactLocation.parse('SS')!.hasPoint, false);
    for (final bad in [
      'garbage',
      '{"v":2}',
      '{"v":1,"x":0}',
      '{"v":1,"x":null,"y":null}',
      '{"v":1,"x":2,"y":0}',
      '{"v":1,"bats":"switch"}',
    ]) {
      expect(ContactLocation.parse(bad), isNull, reason: bad);
    }
  });
  test('field proportions are real distances, independent of display size', () {
    for (final w in [320.0, 390.0, 700.0]) {
      final g = ContactFieldGeometry(Size(w, w * .68 + 44));
      expect((g.first - g.home).distance / g.radius, closeTo(65 / 300, 1e-10));
      expect(
        (g.second - g.home).distance / g.radius,
        closeTo(65 * math.sqrt2 / 300, 1e-10),
      );
      final p = g.locate(g.point(.25, .65))!;
      expect(p.x, closeTo(.25, 1e-10));
      expect(p.y, closeTo(.65, 1e-10));
    }
  });
  late AppDatabase db;
  late MeRepository me;
  late ScoringRepository scoring;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    me = MeRepository(db, const Uuid());
    scoring = ScoringRepository(db, const Uuid());
  });
  tearDown(() => db.close());
  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    double scale = 1,
    bool light = false,
    bool premium = true,
  }) async {
    if (screen is FieldModeScreen) {
      final game = (await scoring.game(screen.gameId))!;
      if (game.scoringDraft == null) {
        final slots = await scoring.lineup(game.id);
        final pas = await scoring.plateAppearances(game.id);
        final events = await scoring.gameEvents(game.id);
        await scoring.saveDraft(
          game.id,
          jsonEncode({
            'version': 2,
            'batterId': slots[game.currentBatterIndex % slots.length].playerId,
            'sequence': [
              0,
              ...pas.map((p) => p.sequence),
              ...events.map((e) => e.sequence),
            ].reduce(math.max),
            'phase': 'location',
          }),
        );
      }
    }
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locationTrackingProvider.overrideWithValue(premium),
        ],
        child: MaterialApp(
          theme: light
              ? AppTheme.light(fontFamily: 'Roboto')
              : AppTheme.dark(fontFamily: 'Roboto'),
          builder: (c, w) => MediaQuery(
            data: MediaQuery.of(
              c,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: w!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, Finder f) async {
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> point(WidgetTester t) async {
    final f = find.byKey(const Key('contact-field'));
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    final g = ContactFieldGeometry(t.getSize(f));
    await t.tapAt(t.getTopLeft(f) + g.point(.3, .7));
    await t.pumpAndSettle();
  }

  Future<void> finish(WidgetTester t) async {
    await t.pumpWidget(const SizedBox.shrink());
    await t.pumpAndSettle();
  }

  testWidgets(
    'location waits for result and RBI; draft survives screen recreation',
    (t) async {
      final id = await me.createPersonalGame(trackContact: true);
      await pump(t, FieldModeScreen(gameId: id));
      await point(t);
      expect(await scoring.plateAppearances(id), isEmpty);
      final draft = (await scoring.game(id))!.scoringDraft;
      expect(draft, contains('"version":2'));
      await finish(t);
      await pump(t, FieldModeScreen(gameId: id));
      await tap(t, find.byKey(const Key('contact-double')));
      expect(await scoring.plateAppearances(id), isEmpty);
      await tap(t, find.byKey(const Key('contact-rbi-1')));
      final pa = (await scoring.plateAppearances(id)).single;
      expect(pa.result, 'double');
      expect(pa.rbi, 1);
      expect(ContactLocation.parse(pa.hitLocation)!.x, closeTo(.3, .001));
      expect((await scoring.game(id))!.scoringDraft, isNull);
      await finish(t);
    },
  );
  testWidgets('team contact supports occupied bases and large text', (t) async {
    final tracker = TrackerRepository(db, const Uuid());
    final team = await tracker.createTeam(name: 'Tuesday Crew');
    await tracker.upsertPlayer(
      teamId: team.id,
      firstName: 'Jordan',
      lastName: 'Reyes',
    );
    await tracker.upsertPlayer(
      teamId: team.id,
      firstName: 'Alex',
      lastName: 'Rivera',
    );
    final id = await tracker.createGame(
      teamId: team.id,
      homeAway: 'away',
      trackContact: true,
    );
    await tracker.setLineup(
      teamId: team.id,
      gameId: id,
      playerIds: [for (final p in await tracker.players(team.id)) p.id],
    );
    await scoring.recordPa(
      game: (await scoring.game(id))!,
      result: PaResult.single,
    );
    for (final scale in [1.0, 2.0]) {
      await pump(t, FieldModeScreen(gameId: id), scale: scale);
      expect(t.takeException(), isNull);
      if (scale == 1) {
        await expectLater(
          find.byType(FieldModeScreen),
          matchesGoldenFile('goldens/team_contact.png'),
        );
      }
      await point(t);
      expect(t.takeException(), isNull);
      await tap(t, find.byKey(const Key('contact-cancel')));
      await finish(t);
    }
  });
  testWidgets('failed contact save restores and retries exactly once', (
    t,
  ) async {
    final id = await me.createPersonalGame(trackContact: true);
    await pump(t, FieldModeScreen(gameId: id));
    await point(t);
    await tap(t, find.byKey(const Key('contact-double')));
    await db.customStatement(
      "CREATE TRIGGER reject_contact BEFORE INSERT ON plate_appearances BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await tap(t, find.byKey(const Key('contact-rbi-0')));
    expect(await scoring.plateAppearances(id), isEmpty);
    expect(find.byKey(const Key('contact-retry')), findsOneWidget);
    await finish(t);
    await db.customStatement('DROP TRIGGER reject_contact');
    await pump(t, FieldModeScreen(gameId: id));
    await tap(t, find.byKey(const Key('contact-retry')));
    final pa = (await scoring.plateAppearances(id)).single;
    expect(ContactLocation.parse(pa.hitLocation)!.x, closeTo(.3, .001));
    expect((await scoring.game(id))!.scoringDraft, isNull);
    await finish(t);
  });
  testWidgets('down shortcut records an out without inventing a location', (
    t,
  ) async {
    final id = await me.createPersonalGame(trackContact: true);
    await pump(t, FieldModeScreen(gameId: id));
    final f = find.byKey(const Key('contact-field'));
    await t.ensureVisible(f);
    await t.pumpAndSettle();
    final g = ContactFieldGeometry(t.getSize(f));
    await t.tapAt(t.getTopLeft(f) + g.home + const Offset(0, 38));
    await t.pumpAndSettle();
    await tap(t, find.text('Fly'));
    await tap(t, find.byKey(const Key('contact-rbi-0')));
    final pa = (await scoring.plateAppearances(id)).single;
    expect(pa.result, PaResult.out.wire);
    expect(ContactLocation.parse(pa.hitLocation)!.located, false);
    await finish(t);
  });
  testWidgets(
    'chart includes located outs and coverage excludes walks and strikeouts',
    (t) async {
      final id = await me.createPersonalGame(trackContact: true);
      for (final r in [
        PaResult.single,
        PaResult.out,
        PaResult.walk,
        PaResult.strikeout,
      ]) {
        await scoring.recordPa(
          game: (await scoring.game(id))!,
          result: r,
          hitLocation: r == PaResult.single
              ? 'LF'
              : r == PaResult.out
              ? const ContactLocation(x: .3, y: .6).encode()
              : null,
        );
      }
      await pump(t, SprayChartScreen(gameId: id));
      expect(find.text('2 of 2 batted balls located'), findsOneWidget);
      expect(find.text('1 pins · 1 area-only observations'), findsOneWidget);
      expect(t.takeException(), isNull);
      await expectLater(
        find.byType(SprayChartScreen),
        matchesGoldenFile('goldens/chart_dark.png'),
      );
      await finish(t);
      await pump(t, SprayChartScreen(gameId: id), light: true);
      await expectLater(
        find.byType(SprayChartScreen),
        matchesGoldenFile('goldens/chart_light.png'),
      );
      await finish(t);
      await pump(t, SprayChartScreen(gameId: id), light: true, scale: 2);
      expect(t.takeException(), isNull);
      await finish(t);
    },
  );
  testWidgets('contact field normal and double text layouts', (t) async {
    final id = await me.createPersonalGame(trackContact: true);
    for (final scale in [1.0, 2.0]) {
      await pump(t, FieldModeScreen(gameId: id), scale: scale);
      await point(t);
      expect(t.takeException(), isNull);
      if (scale == 1) {
        await expectLater(
          find.byType(FieldModeScreen),
          matchesGoldenFile('goldens/contact_scoring.png'),
        );
      }
      await tap(t, find.byKey(const Key('contact-cancel')));
      await finish(t);
    }
  });

  test(
    'portable backup preserves precise locations and pending location drafts',
    () async {
      final id = await me.createPersonalGame(trackContact: true);
      final detail = const ContactLocation(
        x: -.3,
        y: .6,
        flight: 'line',
        bats: 'right',
      ).encode();
      await scoring.recordPa(
        game: (await scoring.game(id))!,
        result: PaResult.single,
        hitLocation: detail,
      );
      await scoring.saveDraft(id, '{"version":2,"location":"LF"}');
      final backup = await LocalBackup(db).export();
      final other = AppDatabase(NativeDatabase.memory());
      try {
        await LocalBackup(other).restore(backup);
        final pa = (await other.select(other.plateAppearances).get()).single;
        expect(ContactLocation.parse(pa.hitLocation)!.x, -.3);
        expect(
          (await other.select(other.games).get()).single.scoringDraft,
          contains('"version":2'),
        );
      } finally {
        await other.close();
      }
    },
  );
  test('enabling contact on legacy games retains team rules', () async {
    final tracker = TrackerRepository(db, const Uuid());
    final team = await tracker.createTeam(name: 'Legacy');
    await tracker.updateTeamSettings(team.id, {
      'rules': {'hrLimit': 1, 'innings': 9},
    });
    final id = await tracker.createGame(teamId: team.id);
    await (db.update(db.games)..where((g) => g.id.equals(id))).write(
      const GamesCompanion(settingsSnapshot: Value(null)),
    );
    await scoring.setContactMode((await scoring.game(id))!, true);
    final snapshot = (await scoring.game(id))!.settingsSnapshot!;
    expect(snapshot, contains('"hrLimit":1'));
    expect(snapshot, contains('"innings":9'));
    expect(snapshot, contains('"spray":true'));
  });
  test(
    'mode cannot change across an unfinished play; detail edits preserve score',
    () async {
      final id = await me.createPersonalGame(trackContact: true);
      final game = (await scoring.game(id))!;
      await scoring.saveDraft(id, 'pending');
      await expectLater(scoring.setContactMode(game, false), throwsStateError);
      await scoring.saveDraft(id, null);
      await scoring.recordPa(
        game: game,
        result: PaResult.single,
        hitLocation: 'LF',
      );
      final pa = (await scoring.plateAppearances(id)).single;
      await scoring.setPaDetail(
        game: game,
        paId: pa.id,
        hitLocation: const ContactLocation(x: .2, y: .6).encode(),
      );
      final after = (await scoring.plateAppearances(id)).single;
      expect(after.result, pa.result);
      expect(after.rbi, pa.rbi);
      await scoring.recordPa(
        game: (await scoring.game(id))!,
        result: PaResult.walk,
        hitLocation: 'RF',
      );
      expect((await scoring.plateAppearances(id)).last.hitLocation, isNull);
    },
  );
}
