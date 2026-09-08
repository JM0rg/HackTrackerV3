import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
// Runs real Flutter rendering and SQLite on iOS/Android with isolated test data.
// No Supabase initialization or production writes. Use a disposable device:
// Flutter's test runner uninstalls the app and deletes its sandbox after testing.
import 'dart:io';
import 'package:hacktracker/features/scoring/presentation/widgets/one_card_diamond.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/contact_field.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hacktracker/app.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/routing/app_router.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/backup/data/local_backup.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Native roster, opponents, competitions, lineup, stats and disk backup',
    (t) async {
      // A separate file tests native persistence without touching the user's DB.
      debugPrint('QA: native temp directory');
      final dir = await getTemporaryDirectory();
      debugPrint('QA: database and preferences');
      final file = File(
        '${dir.path}/hacktracker-emulator-${const Uuid().v4()}.sqlite',
      );
      var db = AppDatabase(NativeDatabase(file));
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      debugPrint('QA: boot app');
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      final router = container.read(routerProvider);
      Future<void> settle() async {
        await t.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 12),
        );
        await t.pump(const Duration(milliseconds: 150));
        await t.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 12),
        );
        expect(t.takeException(), isNull);
      }

      Future<void> tap(Finder finder) async {
        await t.ensureVisible(finder);
        await t.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 12),
        );
        await t.tap(finder);
        await settle();
      }

      Future<void> go(String route) async {
        debugPrint('QA: route $route');
        router.go(route);
        await settle();
      }

      Future<void> fill(String label, String value) async {
        debugPrint('QA: fill $label');
        final field = find.byWidgetPredicate(
          (w) => w is TextField && w.decoration?.labelText == label,
        );
        await t.ensureVisible(field);
        await t.enterText(field, value);
        await settle();
      }

      Future<void> drag(Offset start, Offset end) async {
        final gesture = await t.startGesture(start);
        for (var i = 1; i <= 10; i++) {
          await gesture.moveTo(Offset.lerp(start, end, i / 10)!);
          await t.pump(const Duration(milliseconds: 20));
        }
        await gesture.up();
        await settle();
      }

      Future<void> dragBase(int base) async {
        debugPrint('QA: drag to base $base');
        await t.ensureVisible(find.byKey(const Key('batter-chip')));
        await t.pumpAndSettle();
        final g = t
            .widget<OneCardDiamond>(find.byType(OneCardDiamond))
            .geometry;
        final origin = t.getTopLeft(find.byKey(const Key('diamond')));
        await drag(
          origin + g.home,
          origin + (base == 0 ? g.home + const Offset(0, 60) : g.base(base)),
        );
        expect(find.byKey(const Key('save-play')), findsOneWidget);
      }

      await t.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const HackTrackerApp(),
        ),
      );
      await settle();
      final repo = container.read(trackerRepositoryProvider);
      await tap(find.byKey(const Key('you-name')));
      await fill('First name', 'Emulator');
      await fill('Last name', 'Player');
      await tap(find.text('Save'));
      expect(find.text('Emulator'), findsOneWidget);
      debugPrint('PASS: profile keyboard save and live name refresh');
      await go('/team/edit');
      expect(
        t.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      await fill('Team name', 'Emulator Rockets');
      await tap(find.text('Save'));
      final team = (await repo.teams()).single;
      expect(team.name, 'Emulator Rockets');
      await go('/players');
      await tap(find.byType(FloatingActionButton));
      await fill('First name', 'Casey');
      await fill('Last name', 'Tester');
      await fill('Number', '27');
      await tap(find.text('Save'));
      expect(
        (await repo.players(team.id)).any((p) => p.firstName == 'Casey'),
        isTrue,
      );
      await go('/opponents');
      await tap(find.byType(FloatingActionButton));
      await fill('Opponent name', 'Emulator Visitors');
      await tap(find.text('Save'));
      expect((await repo.opponents(team.id)).single.name, 'Emulator Visitors');
      await go('/competitions');
      for (final type in ['Season', 'Tournament']) {
        await tap(find.byType(FloatingActionButton));
        await tap(find.text(type));
        await fill('Name', 'Emulator $type');
        await fill('League (optional)', 'QA League');
        await tap(find.text('Save'));
      }
      final competitions = await repo.watchCompetitions(team.id).first;
      expect(competitions.length, 2);
      final id = await repo.createGame(
        teamId: team.id,
        homeAway: 'away',
        competitionIds: competitions.map((c) => c.id).toList(),
      );
      await go('/games/$id/lineup');
      final checkboxes = find.byType(CheckboxListTile);
      expect(checkboxes, findsNWidgets(2));
      await tap(checkboxes.at(0));
      await tap(checkboxes.at(1));
      expect(
        (await container.read(scoringRepositoryProvider).lineup(id)).length,
        2,
      );
      await tap(find.text('Done'));
      await go('/games/$id');
      await dragBase(2);
      await tap(find.byKey(const Key('save-play')));
      final scorer = container.read(scoringRepositoryProvider);
      expect((await scorer.plateAppearances(id)).single.result, 'double');
      expect((await scorer.game(id))!.currentBatterIndex, 1);
      await tap(find.byKey(const Key('undo')));
      expect(await scorer.plateAppearances(id), isEmpty);
      await dragBase(2);
      await tap(find.byKey(const Key('cancel-play')));
      expect(await scorer.plateAppearances(id), isEmpty);
      debugPrint('PASS: free drag, explicit save, undo and cancel');
      await go('/more');
      await tap(find.text('Player Plus'));
      await tap(find.text('Light'));
      await tap(find.text('Outdoor contrast'));
      await tap(find.text('Reduce motion'));
      await go('/games/$id');
      await dragBase(2);
      final field = find.byKey(const Key('contact-field'));
      for (final point in [const Offset(-.2, .6), const Offset(.3, .7)]) {
        await t.ensureVisible(field);
        await t.pumpAndSettle();
        final geometry = ContactFieldGeometry(t.getSize(field));
        await t.tapAt(t.getTopLeft(field) + geometry.point(point.dx, point.dy));
        await settle();
      }
      expect(await scorer.plateAppearances(id), isEmpty);
      final draft = (await scorer.game(id))!.scoringDraft;
      expect(draft, contains('"version":3'));
      await go('/games');
      await go('/games/$id');
      expect(
        t.widget<ContactField>(find.byType(ContactField)).location!.x,
        closeTo(.3, .001),
      );
      await tap(find.byKey(const Key('save-play')));
      expect(
        ContactLocation.parse(
          (await scorer.plateAppearances(id)).single.hitLocation,
        )!.x,
        closeTo(.3, .001),
      );
      debugPrint('PASS: premium location repositioning and draft recovery');
      await dragBase(1);
      await tap(find.byKey(const Key('result-walk')));
      expect(find.byKey(const Key('contact-field')), findsNothing);
      await tap(find.byKey(const Key('save-play')));
      expect((await scorer.plateAppearances(id)).last.hitLocation, isNull);
      await tap(find.byKey(const Key('undo')));
      // Failed write must keep the complete draft and retry exactly once.
      await dragBase(1);
      await db.customStatement(
        "CREATE TRIGGER reject_qa BEFORE INSERT ON plate_appearances BEGIN SELECT RAISE(ABORT, 'QA failure'); END",
      );
      await tap(find.byKey(const Key('save-play')));
      expect((await scorer.plateAppearances(id)).length, 1);
      expect(find.text('Play not saved. Try Save play again.'), findsOneWidget);
      await db.customStatement('DROP TRIGGER reject_qa');
      await tap(find.byKey(const Key('save-play')));
      expect((await scorer.plateAppearances(id)).length, 2);
      await tap(find.byKey(const Key('undo')));
      debugPrint('PASS: walks, failure recovery and duplicate prevention');
      await tap(find.byTooltip('Game menu'));
      await tap(find.text('End game'));
      await tap(find.text('Confirm'));
      expect((await scorer.game(id))!.status, 'final');
      expect(find.byKey(const Key('wrap-done')), findsOneWidget);
      await tap(find.byKey(const Key('wrap-menu')));
      await tap(find.text('Reopen game'));
      expect((await scorer.game(id))!.status, 'live');
      debugPrint('PASS: finish game and reopen');
      for (final kind in ['ground', 'fly', 'strikeout']) {
        await dragBase(0);
        await tap(
          find.byKey(
            Key(kind == 'strikeout' ? 'result-strikeout' : 'how-$kind'),
          ),
        );
        await tap(find.byKey(const Key('save-play')));
      }
      expect(find.text('RUNS THIS HALF'), findsOneWidget);
      await tap(find.byKey(const Key('their-half')));
      await tap(find.byKey(const Key('their-half')));
      final halfCenter = t.getCenter(find.byKey(const Key('their-half')));
      await drag(halfCenter, halfCenter - const Offset(0, 140));
      expect((await scorer.game(id))!.theirRuns, 2);
      expect((await scorer.game(id))!.currentInning, 2);
      debugPrint('PASS: three outs, opponent tally and inning transition');
      await go('/more');
      await tap(find.text('Free'));
      await go('/');
      await tap(find.byKey(const Key('start-game')));
      await tap(find.byKey(const Key('start')));
      final personalId =
          t.widget<FieldModeScreen>(find.byType(FieldModeScreen)).gameId;
      await dragBase(2);
      expect(find.byKey(const Key('contact-field')), findsNothing);
      await tap(find.byKey(const Key('rbi-2')));
      expect(await scorer.plateAppearances(personalId), isEmpty);
      await tap(find.byKey(const Key('save-play')));
      expect((await scorer.plateAppearances(personalId)).single.rbi, 2);
      await go('/');
      await tap(find.byKey(const Key('start-game')));
      await tap(find.byType(Switch));
      await tap(find.text('Away'));
      await tap(find.byKey(const Key('start')));
      final tallyId = t.widget<FieldModeScreen>(find.byType(FieldModeScreen)).gameId;
      await tap(find.byKey(const Key('us-runs')));
      await dragBase(2);
      await tap(find.byKey(const Key('rbi-2')));
      await tap(find.byKey(const Key('save-play')));
      expect((await scorer.game(tallyId))!.ourRuns, 1);
      debugPrint(
        'PASS: personal RBI scoring, free access and independent team totals',
      );

      for (final route in [
        '/games/$id/box',
        '/team/stats',
        '/competitions/${competitions.first.id}',
        '/spray?team=${team.id}',
        '/games',
        '/team/settings',
        '/more',
      ]) {
        await go(route);
        expect(find.byType(ErrorWidget), findsNothing);
      }
      // Switching the selected team must not change an older game's roster.
      final second = await repo.createTeam(name: 'Other team');
      await repo.upsertPlayer(teamId: second.id, firstName: 'Wrong roster');
      container.read(currentTeamIdProvider.notifier).state = second.id;
      await go('/games/$id/lineup');
      expect(find.textContaining('Casey'), findsOneWidget);
      expect(find.textContaining('Wrong roster'), findsNothing);

      final expectedPaCount = (await scorer.plateAppearances(id)).length;
      final backup = await LocalBackup(db).export();
      await t.pumpWidget(const SizedBox.shrink());
      await t.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 12),
      );
      router.dispose();
      container.dispose();
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      expect(
        (await ScoringRepository(db, const Uuid()).plateAppearances(id)).length,
        expectedPaCount,
      );
      final restored = AppDatabase(NativeDatabase.memory());
      await LocalBackup(restored).restore(backup);
      expect(
        (await TrackerRepository(
          restored,
          const Uuid(),
        ).watchCompetitions(team.id).first).length,
        2,
      );
      expect(
        (await ScoringRepository(
          restored,
          const Uuid(),
        ).plateAppearances(id)).first.result,
        'double',
      );
      expect(
        (await ScoringRepository(
          restored,
          const Uuid(),
        ).plateAppearances(id)).length,
        expectedPaCount,
      );
      debugPrint('PASS: disk reopen and portable restore');
      await restored.close();
      await db.close();
      await file.delete();
    },
  );
}
