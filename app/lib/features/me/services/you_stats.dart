import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class YouPaRow {
  const YouPaRow({
    required this.personId,
    required this.gameId,
    required this.gameKind,
    required this.teamId,
    required this.result,
    required this.rbi,
    required this.runsScored,
  });

  final String personId;
  final String gameId;
  final String gameKind;
  final String? teamId;
  final PaResult result;
  final int rbi;
  final int runsScored;
}

/// One game's line for one person: "2 for 4, 2B, 1 RBI".
class GameLine {
  const GameLine({
    required this.hits,
    required this.atBats,
    required this.rbi,
    required this.runs,
    required this.results,
  });

  final int hits;
  final int atBats;
  final int rbi;
  final int runs;

  /// Hit labels in the order they happened.
  final List<String> results;

  String get summary => '$hits for $atBats';
}

/// Lines by game id, for the rows on the You tab.
Map<String, GameLine> gameLines(Iterable<YouPaRow> rows, String meId) {
  final acc = <String, ({int h, int ab, int rbi, int r, List<String> res})>{};
  for (final row in rows) {
    if (row.personId != meId) continue;
    final a = acc.putIfAbsent(
      row.gameId,
      () => (h: 0, ab: 0, rbi: 0, r: 0, res: <String>[]),
    );
    final isAb = !row.result.isNonAtBat;
    final isHit = row.result.isHit;
    if (isHit) a.res.add(row.result.label);
    acc[row.gameId] = (
      h: a.h + (isHit ? 1 : 0),
      ab: a.ab + (isAb ? 1 : 0),
      rbi: a.rbi + row.rbi,
      r: a.r + row.runsScored,
      res: a.res,
    );
  }
  return {
    for (final e in acc.entries)
      e.key: GameLine(
        hits: e.value.h,
        atBats: e.value.ab,
        rbi: e.value.rbi,
        runs: e.value.r,
        results: e.value.res,
      ),
  };
}

bool matchesYouFilter(YouPaRow row, YouFilter filter) {
  return switch (filter.kind) {
    YouFilterKind.all => true,
    YouFilterKind.personal =>
      row.gameKind == GameKind.personal || row.teamId == null,
    YouFilterKind.team =>
      row.gameKind == GameKind.team && row.teamId == filter.teamId,
  };
}

List<PaInput> youPaInputs(
  Iterable<YouPaRow> rows,
  YouFilter filter,
  String meId,
) {
  return [
    for (final row in rows)
      if (row.personId == meId && matchesYouFilter(row, filter))
        PaInput(
          playerId: meId,
          result: row.result,
          rbi: row.rbi,
          runsScored: row.runsScored,
        ),
  ];
}
