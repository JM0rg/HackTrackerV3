@Tags(['golden'])
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
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
  }) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(430 * 2, 932 * 2);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
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
