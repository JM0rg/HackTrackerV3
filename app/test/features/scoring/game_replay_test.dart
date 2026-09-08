import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

void main() {
  const replay = GameReplay();
  const lineup = ['p1', 'p2', 'p3'];

  var sequence = 0;
  PaEventInput pa(
    String playerId,
    PaResult result, {
    int? runs,
    bool? scored,
    bool male = false,
  }) {
    return PaEventInput(
      sequence: sequence++,
      paId: 'pa$sequence',
      playerId: playerId,
      result: result,
      runsOverride: runs,
      batterScoredOverride: scored,
      batterIsMale: male,
    );
  }

  TheirHalfEventInput theirs(int runs) {
    return TheirHalfEventInput(
      sequence: sequence++,
      eventId: 'ev$sequence',
      runs: runs,
    );
  }

  OurHalfEventInput ours(int runs) {
    return OurHalfEventInput(
      sequence: sequence++,
      eventId: 'ev$sequence',
      runs: runs,
    );
  }

  ReplayedGame run(
    List<GameEventInput> events, {
    bool personal = false,
    bool score = false,
    bool home = true,
    TeamRules rules = TeamRules.defaults,
    int ourTally = 0,
    int openTally = 0,
  }) {
    return replay.run(
      events: events,
      personal: personal,
      tracksScore: personal ? score : true,
      weAreHome: home,
      lineupPlayerIds: personal ? const ['me'] : lineup,
      rules: rules,
      ourHalfRuns: ourTally,
      theirHalfRuns: openTally,
    );
  }

  setUp(() => sequence = 0);

  group('innings, home team', () {
    test('opens in the top of the first with the opponent batting', () {
      final state = run(const []);
      expect(state.inning, 1);
      expect(state.weBat, isFalse);
      expect(state.half, 'top');
    });

    test('their half hands us the bottom of the same inning', () {
      final state = run([theirs(2)]);
      expect(state.inning, 1);
      expect(state.weBat, isTrue);
      expect(state.half, 'bottom');
      expect(state.theirRuns, 2);
    });

    test('our third out moves to the next inning', () {
      final state = run([
        theirs(0),
        pa('p1', PaResult.out),
        pa('p2', PaResult.out),
        pa('p3', PaResult.out),
      ]);
      expect(state.inning, 2);
      expect(state.weBat, isFalse);
      expect(state.half, 'top');
      expect(state.outs, 0);
      expect(state.bases.isEmpty, isTrue);
    });

    test('a full inning each way lands in the top of the second', () {
      final state = run([
        theirs(1),
        pa('p1', PaResult.single),
        pa('p2', PaResult.out),
        pa('p3', PaResult.out),
        pa('p1', PaResult.out),
      ]);
      expect(state.inning, 2);
      expect(state.half, 'top');
      expect(state.innings.length, 1);
      expect(state.innings.first.theirRuns, 1);
    });

    test(
      'an open opponent tally shows in the score before it is committed',
      () {
        final state = run([theirs(1), pa('p1', PaResult.out)], openTally: 3);
        expect(state.weBat, isTrue);
        // We are still batting, so the open tally is not counted yet.
        expect(state.theirRuns, 1);

        final theirTurn = run([theirs(1)], openTally: 0);
        expect(theirTurn.theirRuns, 1);
      },
    );
  });

  group('innings, away team', () {
    test('we lead off the top of the first', () {
      final state = run(const [], home: false);
      expect(state.weBat, isTrue);
      expect(state.half, 'top');
      expect(state.inning, 1);
    });

    test('our third out gives them the bottom of the same inning', () {
      final state = run([
        pa('p1', PaResult.out),
        pa('p2', PaResult.out),
        pa('p3', PaResult.out),
      ], home: false);
      expect(state.inning, 1);
      expect(state.weBat, isFalse);
      expect(state.half, 'bottom');
    });

    test('their half closes the inning', () {
      final state = run([
        pa('p1', PaResult.out),
        pa('p2', PaResult.out),
        pa('p3', PaResult.out),
        theirs(2),
      ], home: false);
      expect(state.inning, 2);
      expect(state.weBat, isTrue);
      expect(state.half, 'top');
    });
  });

  test('scoreless completed innings remain in the line score', () {
    final state = run([
      theirs(0),
      pa('p1', PaResult.out),
      pa('p2', PaResult.out),
      pa('p3', PaResult.out),
    ]);
    expect(state.innings.length, 1);
    expect(state.innings.single.ourRuns, 0);
    expect(state.innings.single.theirRuns, 0);
  });

  test('run credits follow each trip around the bases', () {
    final state = run([
      theirs(0),
      pa('p1', PaResult.single),
      pa('p2', PaResult.homer),
      pa('p1', PaResult.single),
    ]);
    expect(state.pas.map((p) => p.runsScored), [1, 1, 0]);
    expect(state.ourRuns, 2);
  });

  group('plays', () {
    test('runs and RBI accumulate across an inning', () {
      final state = run([
        theirs(0),
        pa('p1', PaResult.single),
        pa('p2', PaResult.double, runs: 1),
        pa('p3', PaResult.homer),
      ]);
      expect(state.ourRuns, 3);
      expect(state.pas.map((p) => p.rbi).toList(), [0, 1, 2]);
      expect(state.homeRuns, 1);
    });

    test('the batting order picks up from the last play', () {
      final state = run([theirs(0), pa('p2', PaResult.single)]);
      expect(state.nextBatterIndex, 2);
    });

    test(
      'a play logged while they bat closes their half rather than dropping',
      () {
        final state = run([pa('p1', PaResult.single)]);
        expect(state.weBat, isTrue);
        expect(state.inning, 1);
        expect(state.pas.single.inning, 1);
        expect(state.pas.single.half, 'bottom');
      },
    );

    test('the home run limit turns extra home runs into outs', () {
      const rules = TeamRules(hrLimit: 1);
      final state = run([
        theirs(0),
        pa('p1', PaResult.homer),
        pa('p2', PaResult.homer),
      ], rules: rules);
      expect(state.pas.first.effective, PaResult.homer);
      expect(state.pas.last.effective, PaResult.out);
      expect(state.pas.last.ruleApplied, isTrue);
      expect(state.ourRuns, 1);
      expect(state.outs, 1);
    });
  });

  group('personal games keeping score', () {
    test('home means they bat first; away means we do', () {
      final home = run(const [], personal: true, score: true, home: true);
      expect(home.weBat, isFalse);
      expect(home.half, 'top');
      final away = run(const [], personal: true, score: true, home: false);
      expect(away.weBat, isTrue);
      expect(away.half, 'top');
    });

    test('our half total is independent of personal RBI', () {
      final state = run(
        [pa('me', PaResult.double, runs: 1), ours(3)],
        personal: true,
        score: true,
        home: false,
      );
      expect(state.ourRuns, 3);
      expect(state.weBat, isFalse);
      expect(state.inning, 1);
      expect(state.innings.single.ourRuns, 3);
    });

    test('a full inning each way, with a line score', () {
      final state = run(
        [
          pa('me', PaResult.homer, runs: 2),
          ours(3),
          theirs(4),
          pa('me', PaResult.out),
        ],
        personal: true,
        score: true,
        home: false,
      );
      expect(state.inning, 2);
      expect(state.weBat, isTrue);
      expect(state.ourRuns, 3);
      expect(state.theirRuns, 4);
      expect(state.innings.first.inning, 1);
      expect(state.innings.first.ourRuns, 3);
      expect(state.innings.first.theirRuns, 4);
      expect(state.pas.last.inning, 2);
    });

    test('open tallies count for whoever is batting', () {
      final us = run(
        const [],
        personal: true,
        score: true,
        home: false,
        ourTally: 2,
        openTally: 9,
      );
      expect(us.ourRuns, 2);
      expect(us.theirRuns, 0);
      final them = run(
        const [],
        personal: true,
        score: true,
        home: true,
        ourTally: 9,
        openTally: 3,
      );
      expect(them.theirRuns, 3);
      expect(them.ourRuns, 0);
    });

    test('an at-bat logged while they bat closes their half', () {
      final state = run(
        [pa('me', PaResult.single)],
        personal: true,
        score: true,
        home: true,
      );
      expect(state.weBat, isTrue);
      expect(state.pas.single.inning, 1);
      expect(state.pas.single.half, 'bottom');
    });

    test('a stray our-half event in a team game is ignored', () {
      final state = run([theirs(0), ours(5), pa('p1', PaResult.single)]);
      expect(state.ourRuns, 0);
      expect(state.inning, 1);
    });
  });

  group('personal games', () {
    test('outs never end an inning', () {
      final state = run([
        pa('me', PaResult.out),
        pa('me', PaResult.strikeout),
        pa('me', PaResult.out),
        pa('me', PaResult.out),
      ], personal: true);
      expect(state.inning, 1);
      expect(state.outs, 0);
      expect(state.plateAppearanceCount, 4);
    });

    test('RBI comes from the tap, and a home run drives in at least one', () {
      final state = run([
        pa('me', PaResult.homer, runs: 3),
        pa('me', PaResult.single, runs: 1),
      ], personal: true);
      expect(state.pas.first.rbi, 3);
      expect(state.pas.last.rbi, 1);
      expect(state.ourRuns, 4);
    });

    test('a home run with no override still counts one run', () {
      final state = run([pa('me', PaResult.homer)], personal: true);
      expect(state.pas.single.rbi, 1);
      expect(state.ourRuns, 1);
    });

    test('coming around to score after reaching adds a run', () {
      final state = run([
        pa('me', PaResult.walk, scored: true),
      ], personal: true);
      expect(state.pas.single.rbi, 0);
      expect(state.pas.single.runsScored, 1);
      expect(state.ourRuns, 1);
    });

    test('a home run does not count its own run twice', () {
      final state = run([pa('me', PaResult.homer, runs: 2)], personal: true);
      expect(state.pas.single.runsScored, 1);
      expect(state.ourRuns, 2);
    });

    test('with no score kept, halves are ignored and they never score', () {
      final state = run([
        pa('me', PaResult.single, runs: 1),
        ours(3),
        theirs(4),
        pa('me', PaResult.double),
      ], personal: true);
      expect(state.ourRuns, 1);
      expect(state.theirRuns, 0);
      expect(state.inning, 1);
      expect(state.innings, isEmpty);
    });

    test('a strikeout can never be given an RBI', () {
      final state = run([
        pa('me', PaResult.strikeout, runs: 2),
      ], personal: true);
      expect(state.pas.single.rbi, 0);
      expect(state.ourRuns, 0);
    });
  });
}
