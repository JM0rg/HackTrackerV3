import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/scoring/services/scoring_engine.dart';

void main() {
  const engine = ScoringEngine();

  PlayOutcome apply(
    BaseState before,
    PaResult result, {
    String batter = 'B',
    int outs = 0,
    TeamRules rules = TeamRules.defaults,
    bool male = false,
    int homeRuns = 0,
    int? runs,
  }) {
    return engine.apply(
      before: before,
      result: result,
      batterId: batter,
      outsBefore: outs,
      rules: rules,
      batterIsMale: male,
      teamHomeRunsSoFar: homeRuns,
      runsOverride: runs,
    );
  }

  group('advancement', () {
    test('empty-bases single puts batter on first', () {
      final r = apply(BaseState.empty, PaResult.single);
      expect(r.bases, const BaseState(first: 'B'));
      expect(r.outsAdded, 0);
      expect(r.inningEnded, isFalse);
    });

    test('single scores runner from third; second goes to third not home', () {
      final r = apply(
        const BaseState(first: 'A', second: 'C', third: 'D'),
        PaResult.single,
      );
      expect(r.bases, const BaseState(first: 'B', second: 'A', third: 'C'));
      expect(r.scoredPlayerIds, ['D']);
      expect(r.rbi, 1);
    });

    test('double scores second and third; first to third', () {
      final r = apply(
        const BaseState(first: 'A', second: 'C', third: 'D'),
        PaResult.double,
      );
      expect(r.bases, const BaseState(second: 'B', third: 'A'));
      expect(r.scoredPlayerIds, ['D', 'C']);
    });

    test('triple: all score, batter to third', () {
      final r = apply(
        const BaseState(first: 'A', second: 'C', third: 'D'),
        PaResult.triple,
      );
      expect(r.bases, const BaseState(third: 'B'));
      expect(r.scoredPlayerIds, ['D', 'C', 'A']);
    });

    test('homer clears the bases and scores the batter', () {
      final r = apply(
        const BaseState(first: '1', second: '2', third: '3'),
        PaResult.homer,
      );
      expect(r.rbi, 4);
      expect(r.bases.isEmpty, isTrue);
      expect(r.batterScored, isTrue);
      expect(r.scoredPlayerIds, ['3', '2', '1', 'B']);
    });

    test('walk forces only', () {
      final r = apply(const BaseState(first: '1'), PaResult.walk);
      expect(r.bases, const BaseState(first: 'B', second: '1'));
      expect(r.rbi, 0);
    });

    test('walk does not move an unforced runner on second', () {
      final r = apply(const BaseState(second: 'C'), PaResult.walk);
      expect(r.bases, const BaseState(first: 'B', second: 'C'));
    });

    test('bases-loaded walk forces in a run', () {
      final r = apply(
        const BaseState(first: 'A', second: 'C', third: 'D'),
        PaResult.walk,
      );
      expect(r.scoredPlayerIds, ['D']);
      expect(r.rbi, 1);
    });

    test('third out ends the inning', () {
      final r = apply(const BaseState(first: '1'), PaResult.out, outs: 2);
      expect(r.inningEnded, isTrue);
      expect(r.outsAdded, 1);
    });

    test('sac fly scores third and records an out', () {
      final r = apply(const BaseState(first: 'A', third: '3'), PaResult.sacFly);
      expect(r.outsAdded, 1);
      expect(r.scoredPlayerIds, ['3']);
      expect(r.bases, const BaseState(first: 'A'));
    });

    test('fielders choice: lead runner out, batter to first', () {
      final r = apply(
        const BaseState(first: 'A', second: 'C'),
        PaResult.fieldersChoice,
      );
      expect(r.outsAdded, 1);
      expect(r.bases, const BaseState(first: 'B', second: 'A'));
    });

    test('reach on error matches single bases but is not an RBI', () {
      const before = BaseState(second: 'C', third: 'D');
      final roe = apply(before, PaResult.reachOnError);
      final single = apply(before, PaResult.single);
      expect(roe.bases, single.bases);
      expect(roe.scoredPlayerIds, single.scoredPlayerIds);
      expect(roe.rbi, 0);
    });
  });

  group('runs on the play', () {
    test('a runner from first can be waved home on a double', () {
      const before = BaseState(first: 'A');
      final natural = apply(before, PaResult.double);
      expect(natural.runs, 0);
      // The runner, and the batter on an overthrow.
      expect(natural.maxRuns, 2);

      final waved = apply(before, PaResult.double, runs: 1);
      expect(waved.runs, 1);
      expect(waved.rbi, 1);
      expect(waved.scoredPlayerIds, ['A']);
      expect(waved.bases, const BaseState(second: 'B'));
    });

    test('a groundout can drive in the runner from third', () {
      final r = apply(const BaseState(third: 'D'), PaResult.out, runs: 1);
      expect(r.runs, 1);
      expect(r.rbi, 1);
      expect(r.outsAdded, 1);
      expect(r.bases.isEmpty, isTrue);
    });

    test('a run on a strikeout is not an RBI', () {
      final r = apply(const BaseState(third: 'D'), PaResult.strikeout, runs: 1);
      expect(r.runs, 1);
      expect(r.rbi, 0);
    });

    test('a runner on third can be held on a single', () {
      const before = BaseState(third: 'D');
      final natural = apply(before, PaResult.single);
      expect(natural.runs, 1);
      expect(natural.minRuns, 0);

      final held = apply(before, PaResult.single, runs: 0);
      expect(held.runs, 0);
      expect(held.bases, const BaseState(first: 'B', third: 'D'));
    });

    test('forced runs on a home run cannot be taken back', () {
      final r = apply(const BaseState(third: 'D'), PaResult.homer, runs: 0);
      expect(r.minRuns, 2);
      expect(r.runs, 2);
    });

    test('an override beyond what is possible clamps to the runners', () {
      final r = apply(const BaseState(first: 'A'), PaResult.single, runs: 9);
      expect(r.maxRuns, 2);
      expect(r.runs, 2);
      expect(r.bases.isEmpty, isTrue);
    });

    test('the batter coming around on his own hit is not an RBI', () {
      final r = apply(BaseState.empty, PaResult.triple, runs: 1);
      expect(r.runs, 1);
      expect(r.batterScored, isTrue);
      expect(r.rbi, 0);
    });
  });

  group('team rules', () {
    test('a home run past the limit is an out by default', () {
      const rules = TeamRules(hrLimit: 2);
      final r = apply(
        const BaseState(first: 'A'),
        PaResult.homer,
        rules: rules,
        homeRuns: 2,
      );
      expect(r.effectiveResult, PaResult.out);
      expect(r.outsAdded, 1);
      expect(r.runs, 0);
      expect(r.bases, const BaseState(first: 'A'));
    });

    test('a home run past the limit can be scored as a single instead', () {
      const rules = TeamRules(hrLimit: 1, hrLimitExcess: HrLimitExcess.single);
      final r = apply(
        const BaseState(third: 'D'),
        PaResult.homer,
        rules: rules,
        homeRuns: 1,
      );
      expect(r.effectiveResult, PaResult.single);
      expect(r.scoredPlayerIds, ['D']);
      expect(r.bases, const BaseState(first: 'B'));
    });

    test('under the limit a home run is still a home run', () {
      const rules = TeamRules(hrLimit: 3);
      final r = apply(BaseState.empty, PaResult.homer, rules: rules, homeRuns: 2);
      expect(r.effectiveResult, PaResult.homer);
      expect(r.rbi, 1);
    });

    test('coed: a walked male batter takes two bases', () {
      const rules = TeamRules(coedMaleWalkTwoBases: true);
      final r = apply(
        const BaseState(first: 'A'),
        PaResult.walk,
        rules: rules,
        male: true,
      );
      expect(r.bases, const BaseState(second: 'B', third: 'A'));
    });

    test('coed: bases loaded, a two-base walk forces in two', () {
      const rules = TeamRules(coedMaleWalkTwoBases: true);
      final r = apply(
        const BaseState(first: 'A', second: 'C', third: 'D'),
        PaResult.walk,
        rules: rules,
        male: true,
      );
      expect(r.scoredPlayerIds, ['D', 'C']);
      expect(r.rbi, 2);
      expect(r.bases, const BaseState(second: 'B', third: 'A'));
    });

    test('coed two-base walk does not apply to a female batter', () {
      const rules = TeamRules(coedMaleWalkTwoBases: true);
      final r = apply(const BaseState(first: 'A'), PaResult.walk, rules: rules);
      expect(r.bases, const BaseState(first: 'B', second: 'A'));
    });
  });
}
