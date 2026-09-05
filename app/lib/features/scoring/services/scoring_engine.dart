import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/core/domain/pa_result.dart';

/// Who is standing where. Ids are `Player.id`.
class BaseState {
  const BaseState({this.first, this.second, this.third});

  final String? first;
  final String? second;
  final String? third;

  static const empty = BaseState();

  bool get isEmpty => first == null && second == null && third == null;

  int get runnerCount =>
      (first == null ? 0 : 1) + (second == null ? 0 : 1) + (third == null ? 0 : 1);

  String? at(int base) {
    return switch (base) {
      1 => first,
      2 => second,
      3 => third,
      _ => null,
    };
  }

  BaseState withBase(int base, String? playerId) {
    return switch (base) {
      1 => BaseState(first: playerId, second: second, third: third),
      2 => BaseState(first: first, second: playerId, third: third),
      3 => BaseState(first: first, second: second, third: playerId),
      _ => this,
    };
  }

  @override
  bool operator ==(Object other) {
    return other is BaseState &&
        other.first == first &&
        other.second == second &&
        other.third == third;
  }

  @override
  int get hashCode => Object.hash(first, second, third);

  @override
  String toString() => 'BaseState(1:$first, 2:$second, 3:$third)';
}

/// A runner who crossed the plate, and the base they started the play on.
/// Base 0 is the batter.
class ScoredRunner {
  const ScoredRunner(this.playerId, this.fromBase);

  final String playerId;
  final int fromBase;
}

class PlayOutcome {
  const PlayOutcome({
    required this.bases,
    required this.outsAdded,
    required this.runs,
    required this.rbi,
    required this.scoredPlayerIds,
    required this.batterScored,
    required this.effectiveResult,
    required this.naturalRuns,
    required this.minRuns,
    required this.maxRuns,
    required this.inningEnded,
  });

  final BaseState bases;
  final int outsAdded;

  /// Runs that crossed on this play, after any scorer override.
  final int runs;
  final int rbi;
  final List<String> scoredPlayerIds;
  final bool batterScored;

  /// What the play became after team rules were applied (home run limit).
  final PaResult effectiveResult;

  /// Runs the engine assigns with no override.
  final int naturalRuns;

  /// Bounds the scorer can pick between. Forced runs cannot be taken back.
  final int minRuns;
  final int maxRuns;

  final bool inningEnded;

  bool get canAdjustRuns => maxRuns > minRuns;
}

/// Pure slowpitch scoring. No I/O, no Flutter.
class ScoringEngine {
  const ScoringEngine();

  PlayOutcome apply({
    required BaseState before,
    required PaResult result,
    required String batterId,
    required int outsBefore,
    TeamRules rules = TeamRules.defaults,
    bool batterIsMale = false,
    int teamHomeRunsSoFar = 0,
    int? runsOverride,
  }) {
    final effective = _effectiveResult(result, rules, teamHomeRunsSoFar);
    final play = _play(before, effective, batterId, rules, batterIsMale);

    final naturalRuns = play.scored.length;
    // Forced runs (walks, home runs) can never be held up.
    final canHold =
        effective != PaResult.homer && effective != PaResult.walk;
    final minRuns = canHold ? _minRuns(play) : naturalRuns;
    final maxRuns = naturalRuns + play.bases.runnerCount;

    final target = runsOverride == null
        ? naturalRuns
        : runsOverride.clamp(minRuns, maxRuns);

    final adjusted = _adjust(play, target);
    final scoredIds = [for (final r in adjusted.scored) r.playerId];
    // Identify the batter by id: waving him home from a base rewrites the
    // origin the run was credited from.
    final batterScored = adjusted.scored.any((r) => r.playerId == batterId);

    var rbi = 0;
    if (effective.earnsRbi) {
      rbi = adjusted.scored.length;
      // A batter who comes around on his own hit only drives himself in on a
      // home run.
      if (batterScored && effective != PaResult.homer) rbi -= 1;
      if (rbi < 0) rbi = 0;
    }

    return PlayOutcome(
      bases: adjusted.bases,
      outsAdded: adjusted.outsAdded,
      runs: adjusted.scored.length,
      rbi: rbi,
      scoredPlayerIds: scoredIds,
      batterScored: batterScored,
      effectiveResult: effective,
      naturalRuns: naturalRuns,
      minRuns: minRuns,
      maxRuns: maxRuns,
      inningEnded: outsBefore + adjusted.outsAdded >= 3,
    );
  }

  PaResult _effectiveResult(PaResult result, TeamRules rules, int hrSoFar) {
    final limit = rules.hrLimit;
    if (result != PaResult.homer || limit == null || hrSoFar < limit) {
      return result;
    }
    return rules.hrLimitExcess == HrLimitExcess.single
        ? PaResult.single
        : PaResult.out;
  }

  _Play _play(
    BaseState before,
    PaResult result,
    String batterId,
    TeamRules rules,
    bool batterIsMale,
  ) {
    switch (result) {
      case PaResult.single:
      case PaResult.double:
      case PaResult.triple:
      case PaResult.homer:
      case PaResult.reachOnError:
        return _hit(before, batterId, result.basesTaken);
      case PaResult.walk:
        final twoBases = rules.coedMaleWalkTwoBases && batterIsMale;
        return _walk(before, batterId, twoBases);
      case PaResult.strikeout:
      case PaResult.out:
        return _Play(bases: before, outsAdded: 1);
      case PaResult.sacFly:
        return _sacFly(before);
      case PaResult.fieldersChoice:
        return _fieldersChoice(before, batterId);
    }
  }

  /// Everyone advances the same number of bases.
  _Play _hit(BaseState before, String batterId, int basesTaken) {
    final scored = <ScoredRunner>[];
    var bases = BaseState.empty;

    for (var from = 3; from >= 1; from--) {
      final runner = before.at(from);
      if (runner == null) continue;
      final dest = from + basesTaken;
      if (dest >= 4) {
        scored.add(ScoredRunner(runner, from));
      } else {
        bases = bases.withBase(dest, runner);
      }
    }

    if (basesTaken >= 4) {
      scored.add(ScoredRunner(batterId, 0));
    } else {
      bases = bases.withBase(basesTaken, batterId);
    }

    return _Play(bases: bases, scored: scored);
  }

  /// Forced advance only. A coed two-base award pushes the chain twice.
  _Play _walk(BaseState before, String batterId, bool twoBases) {
    final scored = <ScoredRunner>[];
    var bases = _bump(before, 1, batterId, 0, scored);
    if (twoBases) {
      bases = bases.withBase(1, null);
      bases = _bump(bases, 2, batterId, 0, scored);
    }
    return _Play(bases: bases, scored: scored);
  }

  _Play _sacFly(BaseState before) {
    final scored = <ScoredRunner>[];
    var bases = before;
    final third = before.third;
    if (third != null) {
      scored.add(ScoredRunner(third, 3));
      bases = bases.withBase(3, null);
    }
    return _Play(bases: bases, outsAdded: 1, scored: scored);
  }

  /// Lead runner is retired, batter reaches first, the rest are forced along.
  _Play _fieldersChoice(BaseState before, String batterId) {
    var bases = before;
    for (var base = 3; base >= 1; base--) {
      if (bases.at(base) != null) {
        bases = bases.withBase(base, null);
        break;
      }
    }
    final scored = <ScoredRunner>[];
    bases = _bump(bases, 1, batterId, 0, scored);
    return _Play(bases: bases, outsAdded: 1, scored: scored);
  }

  /// Place [playerId] on [base], pushing whoever is there up one. Past third
  /// is a run.
  BaseState _bump(
    BaseState bases,
    int base,
    String playerId,
    int fromBase,
    List<ScoredRunner> scored,
  ) {
    if (base >= 4) {
      scored.add(ScoredRunner(playerId, fromBase));
      return bases;
    }
    final occupant = bases.at(base);
    var next = bases;
    if (occupant != null) {
      next = _bump(next, base + 1, occupant, base, scored);
    }
    return next.withBase(base, playerId);
  }

  /// How few runs this play can be talked down to: hold trailing runners at the
  /// highest base they could have stopped on.
  int _minRuns(_Play play) {
    var bases = play.bases;
    final scored = [...play.scored];
    while (scored.isNotEmpty) {
      final runner = scored.last;
      final base = _holdBase(bases, runner.fromBase);
      if (base == null) break;
      bases = bases.withBase(base, runner.playerId);
      scored.removeLast();
    }
    return scored.length;
  }

  /// Highest free base a runner starting on [fromBase] could stop at. Never
  /// behind where they started, and the batter (base 0) is never held up.
  int? _holdBase(BaseState bases, int fromBase) {
    if (fromBase == 0) return null;
    for (var base = 3; base >= fromBase; base--) {
      if (bases.at(base) == null) return base;
    }
    return null;
  }

  _Play _adjust(_Play play, int target) {
    var bases = play.bases;
    final scored = [...play.scored];

    while (scored.length > target) {
      final runner = scored.last;
      final base = _holdBase(bases, runner.fromBase);
      if (base == null) break;
      bases = bases.withBase(base, runner.playerId);
      scored.removeLast();
    }

    while (scored.length < target) {
      var waved = false;
      for (var base = 3; base >= 1; base--) {
        final runner = bases.at(base);
        if (runner == null) continue;
        bases = bases.withBase(base, null);
        scored.add(ScoredRunner(runner, base));
        waved = true;
        break;
      }
      if (!waved) break;
    }

    return _Play(bases: bases, outsAdded: play.outsAdded, scored: scored);
  }
}

class _Play {
  _Play({required this.bases, this.outsAdded = 0, List<ScoredRunner>? scored})
      : scored = scored ?? const [];

  final BaseState bases;
  final int outsAdded;
  final List<ScoredRunner> scored;
}
