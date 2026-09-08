import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';
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

  test(
    'linking a different account cannot adopt an existing scorebook',
    () async {
      await me.linkToUser('account-a');
      await expectLater(me.linkToUser('account-b'), throwsStateError);
      expect((await me.ensureMe()).linkedUserId, 'account-a');
    },
  );

  test(
    'personal PAs copy personId and stay off the team leaderboard',
    () async {
      final person = await me.ensureMe();
      final team = await tracker.createTeam(name: 'Club');
      await me.attachMeToNewTeam(team.id);

      final personalId = await me.createPersonalGame(opponentName: 'Reds');
      final personalGame = (await tracker.game(personalId))!;
      await scoring.recordPa(game: personalGame, result: PaResult.single);

      final teamGameId = await tracker.createGame(teamId: team.id);
      final lineup = await (db.select(
        db.players,
      )..where((t) => t.teamId.equals(team.id))).get();
      await tracker.setLineup(
        teamId: team.id,
        gameId: teamGameId,
        playerIds: [lineup.first.id],
      );
      final teamGame = (await tracker.game(teamGameId))!;
      await scoring.recordPa(game: teamGame, result: PaResult.homer);

      final personalPas = await scoring.plateAppearances(personalId);
      expect(personalPas.single.personId, person.id);
      expect(personalPas.single.teamId, isNull);

      final teamPas = await scoring.plateAppearances(teamGameId);
      expect(teamPas.single.personId, person.id);
      expect(teamPas.single.teamId, team.id);

      final youRows = [
        YouPaRow(
          personId: personalPas.single.personId!,
          gameId: 'g',
          gameKind: GameKind.personal,
          teamId: personalPas.single.teamId,
          result: PaResult.fromWire(personalPas.single.result),
          rbi: personalPas.single.rbi,
          runsScored: personalPas.single.runsScored,
        ),
        YouPaRow(
          personId: teamPas.single.personId!,
          gameId: 'g',
          gameKind: GameKind.team,
          teamId: teamPas.single.teamId,
          result: PaResult.fromWire(teamPas.single.result),
          rbi: teamPas.single.rbi,
          runsScored: teamPas.single.runsScored,
        ),
      ];
      expect(youPaInputs(youRows, const YouFilter.all(), person.id).length, 2);
      expect(
        youPaInputs(youRows, const YouFilter.personal(), person.id).length,
        1,
      );
      expect(
        youPaInputs(youRows, YouFilter.team(team.id), person.id).length,
        1,
      );

      final club = const StatsAggregator().rollup([
        PaInput(
          playerId: teamPas.single.playerId,
          result: PaResult.fromWire(teamPas.single.result),
          rbi: teamPas.single.rbi,
          runsScored: teamPas.single.runsScored,
        ),
      ]);
      expect(club.length, 1);
    },
  );

  group('personal teams', () {
    test('saving, listing and forgetting', () async {
      await me.ensureMe();
      expect(await me.personalTeams(), isEmpty);

      final crew = await me.createPersonalTeam('  Tuesday Crew  ');
      expect(crew!.name, 'Tuesday Crew');
      await me.createPersonalTeam('Alley Cats');
      expect((await me.personalTeams()).map((t) => t.name), [
        'Alley Cats',
        'Tuesday Crew',
      ]);

      await me.deletePersonalTeam(crew.id);
      expect((await me.personalTeams()).single.name, 'Alley Cats');
    });

    test('an empty name saves nothing', () async {
      await me.ensureMe();
      expect(await me.createPersonalTeam('   '), isNull);
      expect(await me.personalTeams(), isEmpty);
    });

    test('the same name comes back instead of piling up', () async {
      await me.ensureMe();
      final first = await me.createPersonalTeam('Alley Cats');
      final again = await me.createPersonalTeam('alley cats');
      expect(again!.id, first!.id);
      expect(await me.personalTeams(), hasLength(1));
    });

    test(
      'a game tagged to a saved team keeps both the tag and the name',
      () async {
        await me.ensureMe();
        final crew = await me.createPersonalTeam('Tuesday Crew');
        final id = await me.createPersonalGame(
          playedForName: crew!.name,
          playedForTeamId: crew.id,
        );
        final game = (await tracker.game(id))!;
        expect(game.playedForName, 'Tuesday Crew');
        expect(game.playedForTeamId, crew.id);

        // Forgetting the team leaves the game's own name alone.
        await me.deletePersonalTeam(crew.id);
        expect((await tracker.game(id))!.playedForName, 'Tuesday Crew');
      },
    );

    test('a typed name is not tagged to anything', () async {
      await me.ensureMe();
      final id = await me.createPersonalGame(playedForName: 'One off squad');
      final game = (await tracker.game(id))!;
      expect(game.playedForName, 'One off squad');
      expect(game.playedForTeamId, isNull);
    });
  });

  test("That's me is one roster slot per team", () async {
    final person = await me.ensureMe();
    final team = await tracker.createTeam(name: 'Club');
    await me.attachMeToNewTeam(team.id);
    await tracker.upsertPlayer(teamId: team.id, firstName: 'Sam');
    final roster = await tracker.players(team.id);
    expect(roster.where((p) => p.personId == person.id).length, 1);

    final other = roster.firstWhere((p) => p.personId != person.id);
    await me.setRosterSlotAsMe(teamId: team.id, playerId: other.id);
    final after = await tracker.players(team.id);
    expect(after.where((p) => p.personId == person.id).length, 1);
    expect(after.firstWhere((p) => p.id == other.id).personId, person.id);
  });

  test(
    'undo after a single restores empty bases and the same batter',
    () async {
      final team = await tracker.createTeam(name: 'Club');
      await tracker.upsertPlayer(teamId: team.id, firstName: 'Ada');
      await tracker.upsertPlayer(teamId: team.id, firstName: 'Sam');
      final roster = await tracker.players(team.id);
      final gameId = await tracker.createGame(teamId: team.id);
      await tracker.setLineup(
        teamId: team.id,
        gameId: gameId,
        playerIds: [roster[0].id, roster[1].id],
      );
      var game = (await tracker.game(gameId))!;
      await scoring.recordPa(game: game, result: PaResult.single);
      game = (await tracker.game(gameId))!;
      expect(game.firstBaseId, roster[0].id);
      expect(game.currentBatterIndex, 1);
      expect(game.ourRuns, 0);

      await scoring.undoLast(game);
      game = (await tracker.game(gameId))!;
      expect(game.firstBaseId, isNull);
      expect(game.currentBatterIndex, 0);
      expect(game.ourRuns, 0);
      expect(await scoring.plateAppearances(gameId), isEmpty);
    },
  );

  test('personal HR takes its RBI from the adjust strip', () async {
    await me.ensureMe();
    final id = await me.createPersonalGame(opponentName: 'Reds');
    var game = (await tracker.game(id))!;
    await scoring.recordPa(game: game, result: PaResult.homer);
    game = (await tracker.game(id))!;
    expect(game.ourRuns, 1);

    final pa = (await scoring.plateAppearances(id)).single;
    await scoring.setRunsOnPlay(game: game, paId: pa.id, runs: 3);
    game = (await tracker.game(id))!;
    expect(game.ourRuns, 3);
    expect((await scoring.plateAppearances(id)).single.rbi, 3);

    await scoring.undoLast(game);
    game = (await tracker.game(id))!;
    expect(game.ourRuns, 0);
    expect(await scoring.plateAppearances(id), isEmpty);
  });
}
