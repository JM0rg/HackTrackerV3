import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/models/team_settings.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/features/scoring/services/scoring_engine.dart';

/// One entry in a game's log. Plate appearances and finished halves share a
/// single sequence space so undo and replay have one ordering.
sealed class GameEventInput {
  const GameEventInput({required this.sequence});

  final int sequence;
}

class PaEventInput extends GameEventInput {
  const PaEventInput({
    required super.sequence,
    required this.paId,
    required this.playerId,
    required this.result,
    this.runsOverride,
    this.batterScoredOverride,
    this.batterIsMale = false,
    this.hitLocation,
    this.qualityOfContact,
    this.outKind,
  });

  final String paId;
  final String playerId;
  final PaResult result;

  /// Scorer's correction to runs on the play (team) or RBI (personal).
  final int? runsOverride;

  /// Personal games: the batter came around to score later in the inning.
  final bool? batterScoredOverride;
  final bool batterIsMale;

  /// Optional detail a team captures. Carried through untouched.
  final String? hitLocation;
  final String? qualityOfContact;
  final OutKind? outKind;
}

/// The opponent's half is over; this many crossed.
class TheirHalfEventInput extends GameEventInput {
  const TheirHalfEventInput({
    required super.sequence,
    required this.eventId,
    required this.runs,
  });

  final String eventId;
  final int runs;
}

/// Our half is over, ended by hand, with this many teammate runs. Only a
/// personal game keeping score writes these.
class OurHalfEventInput extends GameEventInput {
  const OurHalfEventInput({
    required super.sequence,
    required this.eventId,
    required this.runs,
  });

  final String eventId;
  final int runs;
}

/// A plate appearance after replay: what it produced in the game it sits in.
class ReplayedPa {
  const ReplayedPa({
    required this.paId,
    required this.playerId,
    required this.sequence,
    required this.inning,
    required this.half,
    required this.requested,
    required this.effective,
    required this.runs,
    required this.rbi,
    required this.runsScored,
    required this.outsRecorded,
    required this.minRuns,
    required this.maxRuns,
    required this.batterScored,
    this.hitLocation,
    this.qualityOfContact,
    this.outKind,
  });

  final String paId;
  final String playerId;
  final int sequence;
  final int inning;
  final String half;

  /// What the scorer tapped.
  final PaResult requested;

  /// What it counted as after team rules (a home run past the limit).
  final PaResult effective;

  final int runs;
  final int rbi;

  /// 1 when this batter's own run crossed.
  final int runsScored;
  final int outsRecorded;
  final int minRuns;
  final int maxRuns;
  final bool batterScored;
  final String? hitLocation;
  final String? qualityOfContact;
  final OutKind? outKind;

  bool get canAdjustRuns => maxRuns > minRuns;
  bool get ruleApplied => effective != requested;
}

class InningLine {
  const InningLine({required this.inning, required this.ourRuns, required this.theirRuns});

  final int inning;
  final int ourRuns;
  final int theirRuns;
}

class ReplayedGame {
  const ReplayedGame({
    required this.inning,
    required this.weBat,
    required this.half,
    required this.outs,
    required this.bases,
    required this.ourRuns,
    required this.theirRuns,
    required this.nextBatterIndex,
    required this.pas,
    required this.innings,
    required this.homeRuns,
  });

  final int inning;

  /// True when it is our turn. A personal game that keeps no score is always
  /// true.
  final bool weBat;
  final String half;
  final int outs;
  final BaseState bases;
  final int ourRuns;
  final int theirRuns;
  final int nextBatterIndex;
  final List<ReplayedPa> pas;
  final List<InningLine> innings;

  /// Our home runs so far, for the team's home run limit.
  final int homeRuns;

  int get plateAppearanceCount => pas.length;
  ReplayedPa? get lastPa => pas.isEmpty ? null : pas.last;
}

/// Rebuilds live game state from the event log. Pure: same log, same state.
class GameReplay {
  const GameReplay();

  static const _engine = ScoringEngine();

  ReplayedGame run({
    required List<GameEventInput> events,
    required bool personal,
    required bool weAreHome,
    required List<String> lineupPlayerIds,
    bool tracksScore = true,
    TeamRules rules = TeamRules.defaults,
    int ourHalfRuns = 0,
    int theirHalfRuns = 0,
  }) {
    final ordered = [...events]..sort((a, b) => a.sequence.compareTo(b.sequence));
    if (personal && !tracksScore) return _personalBat(ordered);
    if (personal) {
      return _personalGame(
        ordered,
        weAreHome: weAreHome,
        ourHalfRuns: ourHalfRuns,
        theirHalfRuns: theirHalfRuns,
      );
    }
    return _team(
      ordered,
      weAreHome: weAreHome,
      lineupPlayerIds: lineupPlayerIds,
      rules: rules,
      theirHalfRuns: theirHalfRuns,
    );
  }

  // ------------------------------------------------------------------- team

  ReplayedGame _team(
    List<GameEventInput> events, {
    required bool weAreHome,
    required List<String> lineupPlayerIds,
    required TeamRules rules,
    required int theirHalfRuns,
  }) {
    final innings = _Innings(weAreHome: weAreHome);
    var outs = 0;
    var bases = BaseState.empty;
    var homeRuns = 0;
    var nextBatterIndex = 0;
    final pas = <ReplayedPa>[];

    for (final event in events) {
      switch (event) {
        case TheirHalfEventInput(:final runs):
          innings.theirs(runs);
          innings.endTheirHalf();
        case OurHalfEventInput():
          // A team game ends our half on outs; ignore a stray one.
          break;
        case PaEventInput():
          // A plate appearance logged while they were up means their half was
          // never closed. Close it with no runs rather than dropping the play.
          if (!innings.weBat) innings.endTheirHalf();
          final outcome = _engine.apply(
            before: bases,
            result: event.result,
            batterId: event.playerId,
            outsBefore: outs,
            rules: rules,
            batterIsMale: event.batterIsMale,
            teamHomeRunsSoFar: homeRuns,
            runsOverride: event.runsOverride,
          );
          pas.add(
            ReplayedPa(
              paId: event.paId,
              playerId: event.playerId,
              sequence: event.sequence,
              inning: innings.inning,
              half: innings.half,
              requested: event.result,
              effective: outcome.effectiveResult,
              runs: outcome.runs,
              rbi: outcome.rbi,
              runsScored: outcome.batterScored ? 1 : 0,
              outsRecorded: outcome.outsAdded,
              minRuns: outcome.minRuns,
              maxRuns: outcome.maxRuns,
              batterScored: outcome.batterScored,
              hitLocation: event.hitLocation,
              qualityOfContact: event.qualityOfContact,
              outKind: event.outKind,
            ),
          );
          if (outcome.effectiveResult == PaResult.homer) homeRuns += 1;
          innings.ours(outcome.runs);
          outs += outcome.outsAdded;
          bases = outcome.bases;
          nextBatterIndex = _nextIndex(lineupPlayerIds, event.playerId, nextBatterIndex);
          if (outcome.inningEnded) {
            outs = 0;
            bases = BaseState.empty;
            innings.endOurHalf();
          }
      }
    }

    if (!innings.weBat && theirHalfRuns > 0) innings.theirs(theirHalfRuns);

    return ReplayedGame(
      inning: innings.inning,
      weBat: innings.weBat,
      half: innings.half,
      outs: outs,
      bases: bases,
      ourRuns: innings.ourRuns,
      theirRuns: innings.theirRuns,
      nextBatterIndex:
          lineupPlayerIds.isEmpty ? 0 : nextBatterIndex % lineupPlayerIds.length,
      pas: pas,
      innings: innings.lines(),
      homeRuns: homeRuns,
    );
  }

  // --------------------------------------------------------- personal, score

  /// Your at-bats plus both teams' scores. No lineup, so halves end by hand.
  ReplayedGame _personalGame(
    List<GameEventInput> events, {
    required bool weAreHome,
    required int ourHalfRuns,
    required int theirHalfRuns,
  }) {
    final innings = _Innings(weAreHome: weAreHome);
    final pas = <ReplayedPa>[];
    var homeRuns = 0;

    for (final event in events) {
      switch (event) {
        case TheirHalfEventInput(:final runs):
          innings.theirs(runs);
          innings.endTheirHalf();
        case OurHalfEventInput(:final runs):
          if (!innings.weBat) innings.endTheirHalf();
          innings.ours(runs);
          innings.endOurHalf();
        case PaEventInput():
          if (!innings.weBat) innings.endTheirHalf();
          final pa = _personalPa(event, innings.inning, innings.half);
          pas.add(pa);
          if (pa.effective == PaResult.homer) homeRuns += 1;
          innings.ours(_personalRunsFor(pa));
      }
    }

    if (innings.weBat) {
      innings.ours(ourHalfRuns);
    } else {
      innings.theirs(theirHalfRuns);
    }

    return ReplayedGame(
      inning: innings.inning,
      weBat: innings.weBat,
      half: innings.half,
      outs: 0,
      bases: BaseState.empty,
      ourRuns: innings.ourRuns,
      theirRuns: innings.theirRuns,
      nextBatterIndex: 0,
      pas: pas,
      innings: innings.lines(),
      homeRuns: homeRuns,
    );
  }

  // ------------------------------------------------------ personal, at-bats

  /// Just your at-bats. No innings, no score to keep.
  ReplayedGame _personalBat(List<GameEventInput> events) {
    final pas = <ReplayedPa>[];
    var ourRuns = 0;
    var homeRuns = 0;

    for (final event in events) {
      if (event is! PaEventInput) continue;
      final pa = _personalPa(event, 1, 'bottom');
      pas.add(pa);
      if (pa.effective == PaResult.homer) homeRuns += 1;
      ourRuns += _personalRunsFor(pa);
    }

    return ReplayedGame(
      inning: 1,
      weBat: true,
      half: 'bottom',
      outs: 0,
      bases: BaseState.empty,
      ourRuns: ourRuns,
      theirRuns: 0,
      nextBatterIndex: 0,
      pas: pas,
      innings: const [],
      homeRuns: homeRuns,
    );
  }

  ReplayedPa _personalPa(PaEventInput event, int inning, String half) {
    final result = event.result;
    final min = personalMinRbi(result);
    final rbi = result.earnsRbi
        ? (event.runsOverride ?? min).clamp(min, personalMaxRbi)
        : 0;
    final scored = result == PaResult.homer ||
        (result.reachesBase && (event.batterScoredOverride ?? false));
    return ReplayedPa(
      paId: event.paId,
      playerId: event.playerId,
      sequence: event.sequence,
      inning: inning,
      half: half,
      requested: result,
      effective: result,
      runs: rbi,
      rbi: rbi,
      runsScored: scored ? 1 : 0,
      outsRecorded: 0,
      minRuns: min,
      maxRuns: result.earnsRbi ? personalMaxRbi : 0,
      batterScored: scored,
      hitLocation: event.hitLocation,
      qualityOfContact: event.qualityOfContact,
      outKind: event.outKind,
    );
  }

  /// A home run's own run is already inside its RBI.
  int _personalRunsFor(ReplayedPa pa) {
    return pa.rbi + (pa.batterScored && pa.effective != PaResult.homer ? 1 : 0);
  }

  static const personalMaxRbi = 4;

  /// A home run and a sac fly always drive in at least one.
  static int personalMinRbi(PaResult result) {
    if (result == PaResult.homer || result == PaResult.sacFly) return 1;
    return 0;
  }

  int _nextIndex(List<String> lineup, String playerId, int fallback) {
    if (lineup.isEmpty) return 0;
    final index = lineup.indexOf(playerId);
    if (index < 0) return (fallback + 1) % lineup.length;
    return (index + 1) % lineup.length;
  }
}

/// Inning bookkeeping shared by every game that keeps score. The visiting side
/// bats first; the home side bats last, so its half closes the inning.
class _Innings {
  _Innings({required this.weAreHome}) : weBat = !weAreHome;

  final bool weAreHome;
  int inning = 1;
  bool weBat;
  int ourRuns = 0;
  int theirRuns = 0;
  final _ours = <int, int>{};
  final _theirs = <int, int>{};

  String get half => weBat == weAreHome ? 'bottom' : 'top';

  void ours(int runs) {
    if (runs == 0) return;
    ourRuns += runs;
    _ours[inning] = (_ours[inning] ?? 0) + runs;
  }

  void theirs(int runs) {
    if (runs == 0) return;
    theirRuns += runs;
    _theirs[inning] = (_theirs[inning] ?? 0) + runs;
  }

  void endOurHalf() {
    weBat = false;
    if (weAreHome) inning += 1;
  }

  void endTheirHalf() {
    weBat = true;
    if (!weAreHome) inning += 1;
  }

  List<InningLine> lines() {
    final numbers = <int>{..._ours.keys, ..._theirs.keys}.toList()..sort();
    return [
      for (final n in numbers)
        InningLine(inning: n, ourRuns: _ours[n] ?? 0, theirRuns: _theirs[n] ?? 0),
    ];
  }
}
