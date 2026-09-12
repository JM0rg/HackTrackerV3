import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

void main() {
  const agg = StatsAggregator();

  test('walk is a PA but not an AB', () {
    final line = agg.rollup([
      const PaInput(
        playerId: 'p',
        result: PaResult.walk,
        rbi: 0,
        runsScored: 0,
      ),
      const PaInput(
        playerId: 'p',
        result: PaResult.single,
        rbi: 1,
        runsScored: 0,
      ),
    ])['p']!;
    expect(line.plateAppearances, 2);
    expect(line.atBats, 1);
    expect(line.hits, 1);
    expect(line.walks, 1);
    expect(line.avg, 1);
    expect(line.obp, 1);
  });

  test('sac fly is a PA not an AB', () {
    final sf = agg.rollup([
      const PaInput(
        playerId: 'p',
        result: PaResult.sacFly,
        rbi: 1,
        runsScored: 0,
      ),
    ])['p']!;
    expect(sf.atBats, 0);
    expect(sf.plateAppearances, 1);
    expect(sf.sacFlies, 1);
  });

  test('slowpitch has no sacrifice bunt', () {
    expect(PaResult.values.map((r) => r.wire), isNot(contains('sacrifice')));
  });

  test('ROE, FC, K, out are AB not hits', () {
    for (final result in [
      PaResult.reachOnError,
      PaResult.fieldersChoice,
      PaResult.strikeout,
      PaResult.out,
    ]) {
      final line = agg.rollup([
        PaInput(playerId: 'p', result: result, rbi: 0, runsScored: 0),
      ])['p']!;
      expect(line.atBats, 1, reason: '$result');
      expect(line.hits, 0, reason: '$result');
    }
  });

  test('homer counts as a hit and four total bases', () {
    final line = agg.rollup([
      const PaInput(
        playerId: 'p',
        result: PaResult.homer,
        rbi: 1,
        runsScored: 1,
      ),
    ])['p']!;
    expect(line.homeRuns, 1);
    expect(line.hits, 1);
    expect(line.slg, 4);
    expect(line.runs, 1);
  });
}
