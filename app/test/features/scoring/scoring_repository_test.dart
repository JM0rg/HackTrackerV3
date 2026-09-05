import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/models/player_gender.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
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

  Future<(String teamId, String gameId, List<Player> roster)> teamGame({
    String homeAway = 'home',
    int players = 3,
  }) async {
    final team = await tracker.createTeam(name: 'Club');
    for (var i = 0; i < players; i++) {
      await tracker.upsertPlayer(
        teamId: team.id,
        firstName: 'P$i',
        jerseyNumber: '$i',
      );
    }
    final roster = await tracker.players(team.id);
    final gameId = await tracker.createGame(teamId: team.id, homeAway: homeAway);
    await tracker.setLineup(
      teamId: team.id,
      gameId: gameId,
      playerIds: [for (final p in roster) p.id],
    );
    return (team.id, gameId, roster);
  }

  Future<Game> reload(String gameId) async => (await tracker.game(gameId))!;

  test('a home game opens with the opponent batting in the top of the first',
      () async {
    final (_, gameId, _) = await teamGame();
    await scoring.enterFieldMode(await reload(gameId));
    final game = await reload(gameId);
    expect(game.currentInning, 1);
    expect(game.currentHalf, 'top');
    expect(game.status, 'live');
  });

  test('an away game opens with us batting', () async {
    final (_, gameId, _) = await teamGame(homeAway: 'away');
    await scoring.enterFieldMode(await reload(gameId));
    expect((await reload(gameId)).currentHalf, 'top');
    final state = await scoring.replay(gameId);
    expect(state.weBat, isTrue);
  });

  test('a single puts the batter on first and moves the order along', () async {
    final (_, gameId, roster) = await teamGame();
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    final game = await reload(gameId);
    expect(game.firstBaseId, roster.first.id);
    expect(game.currentBatterIndex, 1);
    expect(game.ourRuns, 0);
  });

  test('undo takes back the last play and the bases with it', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    await scoring.undoLast(await reload(gameId));
    final game = await reload(gameId);
    expect(game.firstBaseId, isNull);
    expect(game.currentBatterIndex, 0);
    expect(await scoring.plateAppearances(gameId), isEmpty);
  });

  test('the opponent half tallies, commits, and hands the bats back', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.enterFieldMode(await reload(gameId));
    for (var i = 0; i < 3; i++) {
      await scoring.bumpTheirHalfRuns(game: await reload(gameId), delta: 1);
    }
    expect((await reload(gameId)).theirRuns, 3);

    await scoring.endTheirHalf(await reload(gameId));
    final game = await reload(gameId);
    expect(game.theirHalfRuns, 0);
    expect(game.theirRuns, 3);
    expect(game.currentHalf, 'bottom');
    expect((await scoring.gameEvents(gameId)).single.runs, 3);
  });

  test('undo after ending their half reopens the tally', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.bumpTheirHalfRuns(game: await reload(gameId), delta: 2);
    await scoring.endTheirHalf(await reload(gameId));
    await scoring.undoLast(await reload(gameId));
    final game = await reload(gameId);
    expect(game.theirHalfRuns, 2);
    expect(game.theirRuns, 2);
    expect(game.currentHalf, 'top');
    expect(await scoring.gameEvents(gameId), isEmpty);
  });

  test('the tally cannot go below zero', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.bumpTheirHalfRuns(game: await reload(gameId), delta: -1);
    expect((await reload(gameId)).theirHalfRuns, 0);
  });

  test('runs on the play can be corrected after the fact', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    await scoring.recordPa(game: await reload(gameId), result: PaResult.double);
    expect((await reload(gameId)).ourRuns, 0);

    final pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(
      game: await reload(gameId),
      paId: pas.last.id,
      runs: 1,
    );
    final game = await reload(gameId);
    expect(game.ourRuns, 1);
    final updated = await scoring.plateAppearances(gameId);
    expect(updated.last.rbi, 1);
  });

  test('changing a play three batters back replays everything after it',
      () async {
    final (_, gameId, _) = await teamGame();
    for (final result in [PaResult.out, PaResult.single, PaResult.single]) {
      await scoring.recordPa(game: await reload(gameId), result: result);
    }
    expect((await reload(gameId)).ourRuns, 0);

    final pas = await scoring.plateAppearances(gameId);
    await scoring.changePaResult(
      game: await reload(gameId),
      paId: pas.first.id,
      result: PaResult.homer,
    );
    final game = await reload(gameId);
    expect(game.ourRuns, 1);
    expect(game.outs, 0);
    expect(game.secondBaseId, isNotNull);
  });

  test('deleting a play from the middle keeps the rest in order', () async {
    final (_, gameId, _) = await teamGame();
    for (final result in [PaResult.single, PaResult.out, PaResult.single]) {
      await scoring.recordPa(game: await reload(gameId), result: result);
    }
    final pas = await scoring.plateAppearances(gameId);
    await scoring.deletePa(game: await reload(gameId), paId: pas[1].id);
    final left = await scoring.plateAppearances(gameId);
    expect(left.length, 2);
    expect((await reload(gameId)).outs, 0);
  });

  test('an override is dropped when the result changes under it', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    final pas = await scoring.plateAppearances(gameId);
    await scoring.setRunsOnPlay(
      game: await reload(gameId),
      paId: pas.last.id,
      runs: 1,
    );
    expect((await reload(gameId)).ourRuns, 1);

    await scoring.changePaResult(
      game: await reload(gameId),
      paId: pas.last.id,
      result: PaResult.strikeout,
    );
    final after = await scoring.plateAppearances(gameId);
    expect(after.last.runsOnPlay, isNull);
    expect((await reload(gameId)).ourRuns, 0);
  });

  test('jumping the order records the batter you picked', () async {
    final (_, gameId, roster) = await teamGame();
    await scoring.jumpToBatter(game: await reload(gameId), index: 2);
    await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
    final pas = await scoring.plateAppearances(gameId);
    expect(pas.single.playerId, roster[2].id);
    expect((await reload(gameId)).currentBatterIndex, 0);
  });

  test('plays and opponent halves share one sequence', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
    await scoring.endTheirHalf(await reload(gameId));
    await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
    final pas = await scoring.plateAppearances(gameId);
    final events = await scoring.gameEvents(gameId);
    expect(pas.map((p) => p.sequence).toList(), [0, 2]);
    expect(events.single.sequence, 1);
  });

  test('the inning line is rebuilt from the log', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.bumpTheirHalfRuns(game: await reload(gameId), delta: 2);
    await scoring.endTheirHalf(await reload(gameId));
    await scoring.recordPa(game: await reload(gameId), result: PaResult.homer);
    final innings = await scoring.watchInnings(gameId).first;
    expect(innings.single.inning, 1);
    expect(innings.single.theirRuns, 2);
    expect(innings.single.ourRuns, 1);
  });

  test('an inning line is revived, never duplicated, after an undo', () async {
    final (_, gameId, _) = await teamGame();
    await scoring.endTheirHalf(await reload(gameId));
    await scoring.recordPa(game: await reload(gameId), result: PaResult.homer);
    expect((await scoring.watchInnings(gameId).first).single.ourRuns, 1);

    await scoring.undoLast(await reload(gameId));
    await scoring.undoLast(await reload(gameId));
    expect(await scoring.watchInnings(gameId).first, isEmpty);

    await scoring.endTheirHalf(await reload(gameId));
    await scoring.recordPa(game: await reload(gameId), result: PaResult.homer);
    final live = await scoring.watchInnings(gameId).first;
    expect(live.single.ourRuns, 1);

    final all = await db.select(db.gameInnings).get();
    expect(all.where((r) => r.gameId == gameId).length, 1);
  });

  test('team rules reach the engine: the home run limit applies', () async {
    final (teamId, gameId, _) = await teamGame();
    await tracker.updateTeamSettings(teamId, {
      'modules': <String, dynamic>{},
      'rules': {'hrLimit': 1},
    });
    await scoring.recordPa(game: await reload(gameId), result: PaResult.homer);
    await scoring.recordPa(game: await reload(gameId), result: PaResult.homer);
    final game = await reload(gameId);
    expect(game.ourRuns, 1);
    expect(game.outs, 1);
  });

  test('coed two-base walk reaches the engine through player gender', () async {
    final team = await tracker.createTeam(name: 'Coed', type: 'coed');
    await tracker.updateTeamSettings(team.id, {
      'modules': <String, dynamic>{},
      'rules': {'coedMaleWalkTwoBases': true},
    });
    await tracker.upsertPlayer(
      teamId: team.id,
      firstName: 'Max',
      gender: PlayerGender.male,
    );
    final roster = await tracker.players(team.id);
    final gameId = await tracker.createGame(teamId: team.id);
    await tracker.setLineup(
      teamId: team.id,
      gameId: gameId,
      playerIds: [for (final p in roster) p.id],
    );
    final male = roster.firstWhere((p) => p.gender == PlayerGender.male);
    await scoring.jumpToBatter(
      game: await reload(gameId),
      index: roster.indexOf(male),
    );
    await scoring.recordPa(game: await reload(gameId), result: PaResult.walk);
    final game = await reload(gameId);
    expect(game.secondBaseId, male.id);
    expect(game.firstBaseId, isNull);
  });

  group('how an out was made', () {
    test('a kind is stored and a plain out stays a plain out', () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).single;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.fly);
      final after = (await scoring.plateAppearances(gameId)).single;
      expect(after.result, 'out');
      expect(after.outKind, 'fly');
    });

    test('K is its own result, and picking a kind turns it back into an out',
        () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).single;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: null);
      expect((await scoring.plateAppearances(gameId)).single.result, 'strikeout');
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.ground);
      final after = (await scoring.plateAppearances(gameId)).single;
      expect(after.result, 'out');
      expect(after.outKind, 'ground');
    });

    test('a run on a fly out is a sacrifice fly', () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.triple);
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).last;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.fly);
      await scoring.setRunScoredOnOut(game: await reload(gameId), paId: pa.id, scored: true);
      final after = (await scoring.plateAppearances(gameId)).last;
      expect(after.result, 'sac_fly');
      expect(after.rbi, 1);
      expect((await reload(gameId)).ourRuns, 1);
    });

    test('a run on a groundout is an RBI groundout, and the at-bat counts',
        () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.triple);
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).last;
      await scoring.setRunScoredOnOut(game: await reload(gameId), paId: pa.id, scored: true);
      expect((await scoring.plateAppearances(gameId)).last.result, 'sac_fly');

      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.ground);
      final after = (await scoring.plateAppearances(gameId)).last;
      expect(after.result, 'out');
      expect(after.runsOnPlay, 1);
      expect(after.rbi, 1);
      expect((await reload(gameId)).ourRuns, 1);
    });

    test('waving a runner home on a fly out makes it a sac fly', () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.triple);
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).last;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.fly);
      await scoring.setRunsOnPlay(game: await reload(gameId), paId: pa.id, runs: 1);
      expect((await scoring.plateAppearances(gameId)).last.result, 'sac_fly');

      await scoring.setRunsOnPlay(game: await reload(gameId), paId: pa.id, runs: 0);
      final after = (await scoring.plateAppearances(gameId)).last;
      expect(after.result, 'out');
      expect(after.outKind, 'fly');
      expect((await reload(gameId)).ourRuns, 0);
    });

    test('changing the result outright forgets the kind', () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.out);
      final pa = (await scoring.plateAppearances(gameId)).single;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.line);
      await scoring.changePaResult(game: await reload(gameId), paId: pa.id, result: PaResult.single);
      expect((await scoring.plateAppearances(gameId)).single.outKind, isNull);
    });

    test('a kind is ignored on anything that is not an out', () async {
      final (_, gameId, _) = await teamGame();
      await scoring.recordPa(game: await reload(gameId), result: PaResult.single);
      final pa = (await scoring.plateAppearances(gameId)).single;
      await scoring.setOutKind(game: await reload(gameId), paId: pa.id, kind: OutKind.fly);
      final after = (await scoring.plateAppearances(gameId)).single;
      expect(after.result, 'single');
      expect(after.outKind, isNull);
    });
  });

  group('personal games keeping score', () {
    Future<String> scored({String homeAway = 'away'}) async {
      await me.ensureMe();
      return me.createPersonalGame(
        opponentName: 'Reds',
        scope: GameScope.game,
        homeAway: homeAway,
      );
    }

    test('away means we bat first; home means they do', () async {
      final away = await reload(await scored(homeAway: 'away'));
      final home = await reload(await scored(homeAway: 'home'));
      expect((await scoring.replay(away.id)).weBat, isTrue);
      expect((await scoring.replay(home.id)).weBat, isFalse);
    });

    test('teammate runs tally, then our half ends by hand', () async {
      final id = await scored();
      await scoring.recordPa(game: await reload(id), result: PaResult.double);
      final pa = (await scoring.plateAppearances(id)).single;
      await scoring.setRunsOnPlay(game: await reload(id), paId: pa.id, runs: 1);
      await scoring.bumpOurHalfRuns(game: await reload(id), delta: 1);
      await scoring.bumpOurHalfRuns(game: await reload(id), delta: 1);
      expect((await reload(id)).ourRuns, 3);

      await scoring.endOurHalf(await reload(id));
      final game = await reload(id);
      expect(game.ourHalfRuns, 0);
      expect(game.ourRuns, 3);
      expect(game.currentHalf, 'bottom');
      final events = await scoring.gameEvents(id);
      expect(events.single.kind, GameEventKind.ourHalf);
      expect(events.single.runs, 2);
    });

    test('undo after ending our half reopens the tally', () async {
      final id = await scored();
      await scoring.bumpOurHalfRuns(game: await reload(id), delta: 2);
      await scoring.endOurHalf(await reload(id));
      await scoring.undoLast(await reload(id));
      final game = await reload(id);
      expect(game.ourHalfRuns, 2);
      expect(game.currentHalf, 'top');
      expect(await scoring.gameEvents(id), isEmpty);
    });

    test('their half works like a team game and the line score is kept',
        () async {
      final id = await scored();
      await scoring.bumpOurHalfRuns(game: await reload(id), delta: 1);
      await scoring.endOurHalf(await reload(id));
      await scoring.bumpTheirHalfRuns(game: await reload(id), delta: 3);
      await scoring.endTheirHalf(await reload(id));
      final game = await reload(id);
      expect(game.currentInning, 2);
      expect(game.currentHalf, 'top');
      expect(game.theirRuns, 3);
      final innings = await scoring.watchInnings(id).first;
      expect(innings.single.ourRuns, 1);
      expect(innings.single.theirRuns, 3);
    });

    test('switching scope keeps every at-bat', () async {
      final id = await scored();
      await scoring.recordPa(game: await reload(id), result: PaResult.single);
      await scoring.setGameScope(game: await reload(id), scope: GameScope.bat);
      expect((await reload(id)).scope, GameScope.bat);
      expect((await scoring.plateAppearances(id)).single.result, 'single');
      await scoring.setGameScope(game: await reload(id), scope: GameScope.game);
      expect((await reload(id)).scope, GameScope.game);
    });
  });

  group('personal games', () {
    test('outs never advance an inning', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      for (var i = 0; i < 4; i++) {
        await scoring.recordPa(game: await reload(id), result: PaResult.out);
      }
      final game = await reload(id);
      expect(game.currentInning, 1);
      expect(game.outs, 0);
    });

    test('RBI is set on the strip, not in a dialog', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await reload(id), result: PaResult.single);
      expect((await reload(id)).ourRuns, 0);

      final pa = (await scoring.plateAppearances(id)).single;
      await scoring.setRunsOnPlay(game: await reload(id), paId: pa.id, runs: 2);
      expect((await reload(id)).ourRuns, 2);
      expect((await scoring.plateAppearances(id)).single.rbi, 2);
    });

    test('scoring after you reach adds your own run', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await reload(id), result: PaResult.walk);
      final pa = (await scoring.plateAppearances(id)).single;
      await scoring.setBatterScored(
        game: await reload(id),
        paId: pa.id,
        scored: true,
      );
      expect((await reload(id)).ourRuns, 1);
      expect((await scoring.plateAppearances(id)).single.runsScored, 1);
    });

    test('opponent and playing-with are optional', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: '  ', playedForName: '');
      final game = await reload(id);
      expect(game.opponentName, isNull);
      expect(game.playedForName, isNull);
      expect(game.scope, GameScope.bat);
    });

    test('a home run counts one run with no extra tap', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(opponentName: 'Reds');
      await scoring.recordPa(game: await reload(id), result: PaResult.homer);
      final game = await reload(id);
      expect(game.ourRuns, 1);
      expect((await scoring.plateAppearances(id)).single.rbi, 1);
    });
  });
}
