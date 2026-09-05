import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

void main() {
  const me = 'me';
  const teamA = 'team-a';
  const teamB = 'team-b';

  YouPaRow pa({
    required String kind,
    String? teamId,
    PaResult result = PaResult.single,
    String personId = me,
  }) {
    return YouPaRow(
      personId: personId,
      gameKind: kind,
      teamId: teamId,
      result: result,
      rbi: 0,
      runsScored: 0,
    );
  }

  final rows = [
    pa(kind: GameKind.personal),
    pa(kind: GameKind.personal, result: PaResult.walk),
    pa(kind: GameKind.team, teamId: teamA, result: PaResult.homer),
    pa(kind: GameKind.team, teamId: teamB, result: PaResult.double),
    pa(kind: GameKind.team, teamId: teamA, personId: 'teammate'),
  ];

  test('You stats roll up by personId across two teams and pickup', () {
    final inputs = youPaInputs(rows, const YouFilter.all(), me);
    final line = const StatsAggregator().rollup(inputs)[me]!;
    expect(line.plateAppearances, 4);
    expect(line.hits, 3);
    expect(line.homeRuns, 1);
    expect(line.walks, 1);
  });

  test('Free agent filter keeps only personal games', () {
    final inputs = youPaInputs(rows, const YouFilter.personal(), me);
    final line = const StatsAggregator().rollup(inputs)[me]!;
    expect(line.plateAppearances, 2);
    expect(line.walks, 1);
    expect(line.homeRuns, 0);
  });

  test('Team filter is isolated and does not include the other roster slot', () {
    final a = youPaInputs(rows, const YouFilter.team(teamA), me);
    expect(const StatsAggregator().rollup(a)[me]!.homeRuns, 1);
    expect(const StatsAggregator().rollup(a)[me]!.plateAppearances, 1);

    final b = youPaInputs(rows, const YouFilter.team(teamB), me);
    expect(const StatsAggregator().rollup(b)[me]!.doubles, 1);
    expect(const StatsAggregator().rollup(b)[me]!.homeRuns, 0);
  });

  test('teammate PAs never enter the You line', () {
    final inputs = youPaInputs(rows, const YouFilter.all(), me);
    expect(inputs.every((p) => p.playerId == me), isTrue);
    expect(inputs.length, 4);
  });
}
