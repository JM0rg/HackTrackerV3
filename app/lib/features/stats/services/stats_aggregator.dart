import 'package:hacktracker/core/domain/pa_result.dart';

class PlayerLine {
  const PlayerLine({
    required this.playerId,
    required this.plateAppearances,
    required this.atBats,
    required this.hits,
    required this.singles,
    required this.doubles,
    required this.triples,
    required this.homeRuns,
    required this.walks,
    required this.strikeouts,
    required this.runs,
    required this.rbi,
    required this.sacFlies,
  });

  final String playerId;
  final int plateAppearances;
  final int atBats;
  final int hits;
  final int singles;
  final int doubles;
  final int triples;
  final int homeRuns;
  final int walks;
  final int strikeouts;
  final int runs;
  final int rbi;
  final int sacFlies;

  double get avg => atBats == 0 ? 0 : hits / atBats;
  double get obp {
    final denom = atBats + walks + sacFlies;
    return denom == 0 ? 0 : (hits + walks) / denom;
  }

  double get slg {
    if (atBats == 0) return 0;
    return (singles + 2 * doubles + 3 * triples + 4 * homeRuns) / atBats;
  }

  double get ops => obp + slg;
}

class PaInput {
  const PaInput({
    required this.playerId,
    required this.result,
    required this.rbi,
    required this.runsScored,
  });

  final String playerId;
  final PaResult result;
  final int rbi;
  final int runsScored;
}

class StatsAggregator {
  const StatsAggregator();

  Map<String, PlayerLine> rollup(Iterable<PaInput> pas) {
    final map = <String, _Acc>{};
    for (final pa in pas) {
      final acc = map.putIfAbsent(pa.playerId, _Acc.new);
      acc.pa += 1;
      acc.rbi += pa.rbi;
      acc.runs += pa.runsScored;
      if (!pa.result.isNonAtBat) acc.ab += 1;
      switch (pa.result) {
        case PaResult.single:
          acc.hits += 1;
          acc.singles += 1;
        case PaResult.double:
          acc.hits += 1;
          acc.doubles += 1;
        case PaResult.triple:
          acc.hits += 1;
          acc.triples += 1;
        case PaResult.homer:
          acc.hits += 1;
          acc.homeRuns += 1;
        case PaResult.walk:
          acc.walks += 1;
        case PaResult.strikeout:
          acc.ks += 1;
        case PaResult.sacFly:
          acc.sf += 1;
        case PaResult.out:
        case PaResult.fieldersChoice:
        case PaResult.reachOnError:
          break;
      }
    }
    return {
      for (final e in map.entries)
        e.key: PlayerLine(
          playerId: e.key,
          plateAppearances: e.value.pa,
          atBats: e.value.ab,
          hits: e.value.hits,
          singles: e.value.singles,
          doubles: e.value.doubles,
          triples: e.value.triples,
          homeRuns: e.value.homeRuns,
          walks: e.value.walks,
          strikeouts: e.value.ks,
          runs: e.value.runs,
          rbi: e.value.rbi,
          sacFlies: e.value.sf,
        ),
    };
  }
}

class _Acc {
  int pa = 0;
  int ab = 0;
  int hits = 0;
  int singles = 0;
  int doubles = 0;
  int triples = 0;
  int homeRuns = 0;
  int walks = 0;
  int ks = 0;
  int runs = 0;
  int rbi = 0;
  int sf = 0;
}
