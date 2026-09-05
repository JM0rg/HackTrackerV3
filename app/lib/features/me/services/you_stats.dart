import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class YouPaRow {
  const YouPaRow({
    required this.personId,
    required this.gameKind,
    required this.teamId,
    required this.result,
    required this.rbi,
    required this.runsScored,
  });

  final String personId;
  final String gameKind;
  final String? teamId;
  final PaResult result;
  final int rbi;
  final int runsScored;
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
