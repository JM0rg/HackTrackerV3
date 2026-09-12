import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'contact_field.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_glass.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_surface.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// Where a drag can end up.
enum DiamondZone { first, second, third, homeRun, out }

/// A finished play: the result plus whatever the follow-through asked for.
class LoggedPlay {
  const LoggedPlay({
    required this.result,
    this.outKind,
    this.rbi,
    this.hitLocation,
    this.qualityOfContact,
  });

  final PaResult result;
  final OutKind? outKind;
  final String? hitLocation, qualityOfContact;

  /// Personal games only: runs driven in on the play.
  final int? rbi;
}

/// What the row under the diamond is still asking. One at a time, in order.
enum _Question { location, how, reach, rbi }

/// A play that has been filed and is now being shown. While one of these is
/// live the field renders the situation as it was *before* the play, and
/// walks it forward: the ball leaves the bat, the runners go, and only when
/// they arrive does the field agree with the data again.
class _Replay {
  _Replay({
    this.preview = false,
    required this.batterId,
    required this.batterName,
    required this.jersey,
    required this.to,
    required this.kind,
    required this.ball,
    required this.before,
    required this.after,
  });

  /// Shown before the play was written rather than after. Only a personal
  /// game does this, and only because it keeps no runners: where the hitter
  /// finishes is the whole of the play, and the drop already said it.
  final bool preview;

  /// Who hit it. Held here because by now the app is on the next batter.
  final String? batterId;
  final String batterName;
  final String? jersey;

  /// Where the batter finished. Null means they never left the plate.
  final int? to;

  /// How the ball came off the bat, and where it came down. Either being
  /// null means there is no ball to show — a walk, a strikeout, or a play
  /// whose location was never given.
  final OutKind? kind;
  final ContactLocation? ball;

  final Map<String, int> before;
  final Map<String, int> after;

  /// Everyone who moves, and the bases they move between. Base 0 is the
  /// plate; base 4 is home with a run in.
  Iterable<({String id, int from, int to})> get runners sync* {
    for (final id in {...before.keys, ...after.keys, ?batterId}) {
      final a = id == batterId ? 0 : (before[id] ?? 0);
      // Gone from the bases after a play that scored: they came home. An
      // out on the bases is rare enough to look like a run from up here.
      final b = after[id] ?? (id == batterId ? (to ?? 0) : 4);
      if (a != b) yield (id: id, from: a, to: b);
    }
  }

  /// True once the batter is off the field: over the fence, or retired.
  bool leaves(String id) => !after.containsKey(id);
}

/// How a batted ball travels, seen from above. Launch angle cannot be drawn
/// on a plan view, so height is carried by the ball swelling and its shadow
/// dropping away beneath it, and the three kinds are told apart by how fast
/// they cover the ground.
class _Flight {
  const _Flight({
    required this.ms,
    required this.travel,
    required this.lift,
    required this.skips,
  });

  /// How long the ball is in the air, in its own right. A fly hangs whether
  /// the hitter stopped at first or ran it out.
  final int ms;

  /// Easing across the ground.
  final Curve travel;

  /// How high it gets, as a multiple of the ball's own size.
  final double lift;

  /// Bounces on the way, for a ball that never left the dirt.
  final int skips;

  static const _ground = _Flight(
    ms: 1600,
    travel: Curves.easeOutCubic,
    lift: 1.5,
    skips: 4,
  );
  static const _line = _Flight(
    ms: 1200,
    travel: Curves.easeOutQuad,
    lift: .35,
    skips: 0,
  );
  static const _fly = _Flight(
    ms: 2500,
    travel: Curves.linear,
    lift: 2.6,
    skips: 0,
  );

  static _Flight of(OutKind kind) => switch (kind) {
    OutKind.ground => _ground,
    OutKind.line => _line,
    OutKind.fly => _fly,
  };

  /// Height above the ground at [u], 0 at the bat and 0 where it lands.
  double heightAt(double u) {
    if (skips > 0) {
      // Hops, each shorter than the last, the way a grounder dies.
      final hop = math.sin(u * math.pi * skips).abs();
      return hop * lift * (1 - u) * (1 - u);
    }
    return math.sin(u * math.pi) * lift;
  }
}

class _Pending {
  _Pending({required this.result, required this.questions});

  PaResult result;
  OutKind? outKind;
  int? rbi;
  final List<_Question> questions;

  _Question get asking => questions.first;

  /// A walk or a strikeout put no ball in play, so any location answered
  /// before the result was known is thrown away.
  bool get batted => result != PaResult.walk && result != PaResult.strikeout;
}

/// The whole input surface. The batter's chip sits on the plate; drag it to a
/// base, past the fence, or flick it down. A play is not filed until the row
/// underneath has its answer, so nothing lands half-said.
class OneCardDiamond extends StatefulWidget {
  /// The question bar's footprint at the bottom, at a text scale of one. It is
  /// a constant, so no answer can move the field out from under a thumb.
  static const barSpace = 108.0;

  const OneCardDiamond({
    super.key,
    required this.state,
    required this.geometry,
    required this.enabled,
    required this.showHint,
    required this.onCommit,
    required this.onWave,
    required this.onPendingChanged,
    this.onDraftChanged,
    this.trackLocation = false,
  });

  final FieldModeState state;
  final FieldGeometry geometry;
  final bool enabled;
  final bool showHint;
  final bool trackLocation;

  /// Called once, when every question has an answer.
  final FutureOr<void> Function(LoggedPlay) onCommit;
  final FutureOr<void> Function(String) onWave;

  /// True while a play is waiting on the row, so the rest of the screen can
  /// hold still.
  final ValueChanged<bool> onPendingChanged;
  final Future<void> Function(String?)? onDraftChanged;

  /// Takes back the play just filed. Replaces the old Cancel button: nothing
  /// is held hostage before it is written, so the way out is afterwards.
  @override
  State<OneCardDiamond> createState() => _OneCardDiamondState();
}

class _OneCardDiamondState extends State<OneCardDiamond>
    with SingleTickerProviderStateMixin {
  /// Drives a filed play being shown back. Nothing moves on the drop any
  /// more: the field waits until it knows what the play was.
  late final AnimationController _replay;

  /// The play on screen, if one is being shown.
  _Replay? _live;

  /// The share of the replay spent moving. The rest is a hold on the result,
  /// so a play does not snap back to the plate the instant it lands.
  double _motion = 1;

  /// Where the hold gives way to the fade. The hitter and the ball leave
  /// together, and the plate is clear again by the time the fade is done.
  double _fadeAt = 1;

  /// The ball's and the runners' shares of the moving part. Whichever takes
  /// longer sets the length of the play; the other finishes early and waits.
  double _ballSpan = 1;
  double _runSpan = 1;

  /// Bumped whenever a play finishes showing, so the next hitter fades in at
  /// the plate rather than appearing there.
  int _chipEpoch = 0;

  /// True once this play has been shown, so writing it does not show it again.
  bool _previewed = false;

  /// The bar is asking whether to throw the at-bat away.
  bool _confirming = false;

  /// Bases as the field is drawing them. Equal to the data except while a
  /// play is being shown, when it trails behind by one play.
  Map<String, int> _shown = const {};

  /// Set when a play is committed and consumed when the new state lands, so
  /// the before and after can be walked between.
  ({
    Map<String, int> before,
    String? batterId,
    String name,
    String? jersey,
    int to,
  })?
  _landing;

  DiamondZone? _destination;
  ContactLocation? _location;
  String? _error;

  /// The play just filed, held briefly so the row can confirm it and offer
  /// undo before it folds back into the last-play line above the diamond.
  LoggedPlay? _justFiled;
  Timer? _filedTimer;
  Offset? _drag;
  DiamondZone? _zone;

  /// A play that has been dragged but not yet answered.
  _Pending? _pending;

  /// Where the chip rests after a release, before it returns to the plate.

  /// Set on commit, cleared on the next drag: lets the row point at a runner
  /// the engine held up.
  bool _justCommitted = false;

  /// Runners who just reached base appear there rather than running the path
  /// the batter's chip already ran.
  Map<String, int> _baseOf = const {};
  Set<String> _justArrived = const {};

  FieldGeometry get _geo => widget.geometry;

  @override
  void initState() {
    super.initState();
    _replay =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1800),
          )
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _settleReplay();
          });
    _baseOf = _basesOf(widget.state);
    _shown = _baseOf;
    _justArrived = _baseOf.keys.toSet();
    _restoreDraft();
  }

  Future<void> _draftWrites = Future.value();

  int get _lastSequence => [
    0,
    ...widget.state.events.map((e) => e.sequence),
    ...widget.state.replay.pas.map((p) => p.sequence),
  ].reduce((a, b) => a > b ? a : b);

  Future<void> _persistDraft({LoggedPlay? ready, bool clear = false}) {
    final writer = widget.onDraftChanged;
    if (writer == null) return Future.value();
    final pending = _pending;
    final encoded = clear
        ? null
        : jsonEncode({
            'version': 1,
            'destination': _destination?.name,
            'location': _location?.encode(),
            'batterId': widget.state.batter?.id,
            'sequence': _lastSequence,
            'result': (ready?.result ?? pending?.result)?.wire,
            'outKind': (ready?.outKind ?? pending?.outKind)?.wire,
            'rbi': ready?.rbi ?? pending?.rbi,
            'questions':
                pending?.questions.map((q) => q.name).toList() ?? <String>[],
          });
    // Preserve input ordering, including cancel and retry after a failed write.
    _draftWrites = _draftWrites
        .catchError((Object _) {})
        .then((_) => writer(encoded));
    return _draftWrites;
  }

  void _restoreDraft() {
    final source = widget.state.game.scoringDraft;
    if (source == null) return;
    try {
      final raw = jsonDecode(source) as Map<String, dynamic>;
      if (raw['version'] != 1 ||
          raw['batterId'] != widget.state.batter?.id ||
          raw['sequence'] != _lastSequence) {
        return;
      }
      final result = PaResult.fromWire(raw['result'] as String);
      final kind = OutKind.fromWire(raw['outKind'] as String?);
      final questions = (raw['questions'] as List)
          .map((q) => _Question.values.byName(q as String))
          .toList();
      final destination = raw['destination'] as String?;
      if (destination != null) {
        _destination = DiamondZone.values.byName(destination);
      }
      _location = ContactLocation.parse(raw['location'] as String?);
      if (questions.isEmpty) {
        _failedPlay = LoggedPlay(
          result: result,
          outKind: kind,
          rbi: raw['rbi'] as int?,
        );
      } else {
        _pending = _Pending(result: result, questions: questions)
          ..outKind = kind
          ..rbi = raw['rbi'] as int?;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onPendingChanged(true);
      });
    } catch (_) {
      // Leave an unreadable draft in storage; never turn it into a scored out.
    }
  }

  @override
  void didUpdateWidget(OneCardDiamond old) {
    super.didUpdateWidget(old);
    final next = _basesOf(widget.state);
    _justArrived = {
      for (final id in next.keys)
        if ((_baseOf[id] ?? 0) == 0) id,
    };
    _baseOf = next;

    final landing = _landing;
    final landed =
        landing != null &&
        widget.state.replay.pas.length != old.state.replay.pas.length;
    if (!landed) {
      // No play in flight, so the field says what the data says.
      if (_live == null) _shown = next;
      return;
    }
    _landing = null;
    final pa = widget.state.replay.lastPa;
    final show = _Replay(
      batterId: landing.batterId,
      batterName: landing.name,
      jersey: landing.jersey,
      to: landing.to,
      kind: pa?.outKind,
      ball: ContactLocation.parse(pa?.hitLocation),
      before: landing.before,
      after: next,
    );
    _show(show);
  }

  void _show(_Replay show) {
    _shown = show.before;
    _live = show;
    if (MediaQuery.disableAnimationsOf(context)) {
      _settleReplay();
    } else {
      // Ball and runners are timed separately, and the play lasts as long as
      // the slower of the two: a fly hangs while the hitter is still running,
      // and a triple is still running long after a grounder has stopped.
      final legs = show.to ?? 0;
      final ballMs = show.ball?.hasPoint == true && show.kind != null
          ? _Flight.of(show.kind!).ms
          : 0;
      final runMs = legs == 0 ? 0 : 900 + 700 * legs;
      final moving = math.max(1000, math.max(ballMs, runMs));
      const holding = 900;
      const fading = 340;
      final total = moving + holding;
      _replay.duration = Duration(milliseconds: total);
      _motion = moving / total;
      _ballSpan = ballMs == 0 ? 1 : ballMs / moving;
      _runSpan = runMs == 0 ? 1 : runMs / moving;
      _fadeAt = (total - fading) / total;
      _replay.forward(from: 0);
    }
  }

  Map<String, int> _basesOf(FieldModeState state) {
    final b = state.replay.bases;
    return {
      if (b.first != null) b.first!: 1,
      if (b.second != null) b.second!: 2,
      if (b.third != null) b.third!: 3,
    };
  }

  @override
  void dispose() {
    _filedTimer?.cancel();
    _replay.dispose();
    super.dispose();
  }

  /// Show the play as soon as it has been described, so the runs are counted
  /// after watching them come in rather than before. Only reached when the
  /// count is all that is left, which only a personal game asks.
  void _preview() {
    final pending = _pending;
    if (_previewed || pending == null) return;
    if (pending.questions.length != 1 ||
        pending.questions.first != _Question.rbi) {
      return;
    }
    final batter = widget.state.batter;
    final to = switch (_destination) {
      DiamondZone.first => 1,
      DiamondZone.second => 2,
      DiamondZone.third => 3,
      DiamondZone.homeRun => 4,
      _ => 0,
    };
    _previewed = true;
    _show(
      _Replay(
        preview: true,
        batterId: batter?.id,
        batterName: widget.state.personal ? 'You' : (batter?.firstName ?? ''),
        jersey: widget.state.personal ? null : batter?.jerseyNumber,
        to: to,
        kind: pending.batted ? pending.outKind : null,
        ball: pending.batted ? _location : null,
        before: _shown,
        after: {if (batter != null && to > 0 && to < 4) batter.id: to},
      ),
    );
  }

  /// Put the field back in step with the data, whether the play finished
  /// showing or something interrupted it.
  void _settleReplay() {
    if (_live == null) return;
    _replay.stop();
    if (!mounted) {
      _live = null;
      return;
    }
    setState(() {
      // A preview guessed at the bases; the book is the authority.
      _shown = _live!.preview ? _basesOf(widget.state) : _live!.after;
      _live = null;
      _chipEpoch += 1;
    });
  }

  // --------------------------------------------------------------- gestures

  DiamondZone? _zoneAt(Offset p) {
    final g = _geo;
    if (p.dy > g.outY) return DiamondZone.out;
    if ((p - g.home).distance < g.deadZone) return null;
    // The fence is an arc, so clearing it is a distance, not a height.
    if ((p - g.home).distance > g.fenceRadius) return DiamondZone.homeRun;
    // Anywhere else inside the fence, the nearest base wins. The outfield is
    // most of the field now, and a drag that overshoots second still means
    // second. Letting go back at the plate is what cancels.
    DiamondZone? best;
    var bestDistance = double.infinity;
    for (final (zone, at) in [
      (DiamondZone.first, g.first),
      (DiamondZone.second, g.second),
      (DiamondZone.third, g.third),
    ]) {
      final d = (p - at).distance;
      if (d < bestDistance) {
        bestDistance = d;
        best = zone;
      }
    }
    return best;
  }

  bool _saving = false;
  LoggedPlay? _failedPlay;

  bool get _locked => _pending != null || _saving || _failedPlay != null;

  void _onPanStart(DragStartDetails d) {
    // Impatience is the way out: starting the next play ends the last one's
    // replay rather than making anyone tap through it.
    _settleReplay();
    if (!widget.enabled || _locked) return;
    // Only a drag that begins on the chip is a play.
    if ((d.localPosition - _geo.home).distance > 40 * _geo.scale) return;
    setState(() {
      _drag = d.localPosition;
      _zone = null;
      _justCommitted = false;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_drag == null) return;
    final zone = _zoneAt(d.localPosition);
    setState(() {
      _drag = d.localPosition;
      if (zone != _zone) {
        _zone = zone;
        if (zone != null) unawaited(HapticFeedback.selectionClick());
      }
    });
  }

  void _onPanEnd() {
    if (_drag == null) return;
    final zone = _zone;
    setState(() {
      _drag = null;
      _zone = null;
    });
    if (zone == null) return;
    _start(zone);
  }

  /// Parks the chip where it was dropped and works out what still has to be
  /// said before the play can be filed.
  void _start(DiamondZone zone) {
    _settleReplay();
    if (!widget.enabled || _locked) return;
    final personal = widget.state.personal;

    final result = switch (zone) {
      DiamondZone.first => PaResult.single,
      DiamondZone.second => PaResult.double,
      DiamondZone.third => PaResult.triple,
      DiamondZone.homeRun => PaResult.homer,
      DiamondZone.out => PaResult.out,
    };

    final questions = <_Question>[
      // Where the ball went is a tap on the grass, so it goes first.
      if (widget.trackLocation) _Question.location,
      // Reaching first might have been a walk, and a walk puts no ball in
      // play, so what happened comes before how it happened.
      if (zone == DiamondZone.first) _Question.reach,
      // An out is always classified, because K is one of the answers. A hit
      // is described only where ball detail is already switched on, so the
      // plain fast path stays one drag.
      if (zone == DiamondZone.out || widget.trackLocation) _Question.how,
      // Only the scorer's own game counts runs here; an out can still drive
      // one in, so the question survives the trip to the dugout.
      if (personal) _Question.rbi,
    ];

    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _destination = zone;
      _location = null;
      _error = null;
      _justFiled = null;
      _previewed = false;
      _confirming = false;
      _pending = _Pending(result: result, questions: questions)
        ..rbi = personal ? (result == PaResult.homer ? 1 : 0) : null;
    });
    widget.onPendingChanged(true);
    unawaited(_persistDraft().catchError(_draftFailed));
    // Nothing left to say: the drag was the whole play.
    if (questions.isEmpty) {
      unawaited(_file(LoggedPlay(result: result)));
    } else {
      _preview();
    }
  }

  void _draftFailed(Object _) {
    if (!mounted) return;
    setState(() => _error = 'Draft not saved. Keep this screen open.');
  }

  void _answer(
    _Question question, {
    OutKind? kind,
    PaResult? result,
    int? rbi,
    ContactLocation? location,
  }) {
    final pending = _pending;
    if (pending == null ||
        pending.questions.isEmpty ||
        pending.asking != question) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    switch (question) {
      case _Question.location:
        _location = location;
      case _Question.how:
        // On an out the answer decides the result; on a hit it only
        // describes the ball.
        if (pending.result == PaResult.out ||
            pending.result == PaResult.strikeout) {
          pending.result = kind == null ? PaResult.strikeout : PaResult.out;
          // Nobody scores on a strikeout.
          if (kind == null) pending.questions.remove(_Question.rbi);
        }
        pending.outKind = kind;
      case _Question.reach:
        pending.result = result ?? pending.result;
        // A walk put nothing in play, so there is nothing to describe.
        if (pending.result == PaResult.walk) {
          pending.questions.remove(_Question.how);
        }
      case _Question.rbi:
        pending.rbi = rbi;
    }
    pending.questions.removeAt(0);
    if (pending.questions.isNotEmpty) {
      unawaited(_persistDraft().catchError(_draftFailed));
      setState(() {});
      _preview();
      return;
    }
    unawaited(
      _file(
        LoggedPlay(
          result: pending.result,
          outKind: pending.outKind,
          rbi: pending.rbi,
          hitLocation: pending.batted ? _location?.encode() : null,
        ),
      ),
    );
  }

  /// Where the ball went. The first one answers the question; any after it
  /// move the ball without disturbing the questions that followed.
  void _place(ContactLocation location) {
    final pending = _pending;
    if (pending == null) return;
    if (pending.questions.firstOrNull == _Question.location) {
      _answer(_Question.location, location: location);
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    setState(() => _location = location);
    unawaited(_persistDraft().catchError(_draftFailed));
  }

  /// Throwing the at-bat away is the one thing here that cannot be undone —
  /// nothing has been written, so there is nothing to take back afterwards.
  /// The ask takes over the bar it was made from rather than opening a box
  /// over the field.
  void _cancel() {
    if (_saving) return;
    setState(() => _confirming = true);
  }

  Future<void> _discard() async {
    if (_saving) return;
    setState(() {
      _confirming = false;
      _saving = true;
    });
    try {
      await _persistDraft(clear: true);
      if (!mounted) return;
      _settleReplay();
      if (!mounted) return;
      setState(() {
        _pending = null;
        _location = null;
        _failedPlay = null;
        _error = null;
        _previewed = false;
      });
      widget.onPendingChanged(false);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not cancel. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _sendRunner(String id) async {
    if (_locked) return;
    setState(() => _saving = true);
    widget.onPendingChanged(true);
    try {
      await widget.onWave(id);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Runner not changed: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
        widget.onPendingChanged(false);
      }
    }
  }

  Future<void> _file(LoggedPlay play) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failedPlay = null;
    });
    widget.onPendingChanged(true);
    // Snapshot the field as it stands, so the play can be walked forward from
    // here once the data catches up.
    final batter = widget.state.batter;
    _landing = _previewed
        ? null
        : (
            before: _shown,
            batterId: batter?.id,
            name: widget.state.personal ? 'You' : (batter?.firstName ?? ''),
            jersey: widget.state.personal ? null : batter?.jerseyNumber,
            // Where the hitter finishes comes from the play, not from the bases: a
            // personal game keeps no runners at all.
            to: switch (_destination) {
              DiamondZone.first => 1,
              DiamondZone.second => 2,
              DiamondZone.third => 3,
              DiamondZone.homeRun => 4,
              _ => 0,
            },
          );
    try {
      await _persistDraft(ready: play);
      await widget.onCommit(play);
      if (!mounted) return;
      setState(() {
        _pending = null;
        _location = null;
        _justCommitted = true;
        _justFiled = play;
        _saving = false;
      });
      widget.onPendingChanged(false);
      _filedTimer?.cancel();
      _filedTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _justFiled = null);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _failedPlay = play;
        _landing = null;
      });
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final g = _geo;

    return LayoutBuilder(
      builder: (context, room) {
        // The field hangs from the bar's footprint, so the plate sits as low
        // as the thumb's own controls allow, and the footprint is a constant,
        // so no answer can ever shift the field mid-drag. Whatever room is
        // left over goes above the wall, between the readings and the field.
        final reserve = MediaQuery.textScalerOf(
          context,
        ).scale(OneCardDiamond.barSpace);
        final top = math.max(0.0, room.maxHeight - reserve - g.height);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: (room.maxWidth - g.width) / 2,
              top: top,
              width: g.width,
              height: g.height,
              child: _field(context),
            ),
            Positioned(left: 12, right: 12, bottom: 12, child: _bar(context)),
          ],
        );
      },
    );
  }

  /// The floating question bar. Everything the play still needs to be told,
  /// over the ground below the plate.
  Widget _bar(BuildContext context) {
    final field = context.colors.field;
    if (_failedPlay != null) {
      return FieldGlass(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Play not saved.',
                style: context.text.bodySmall?.copyWith(color: field.on),
              ),
            ),
            TextButton(
              onPressed: () => _file(_failedPlay!),
              child: const Text('Retry'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _failedPlay = null;
                });
                widget.onPendingChanged(false);
                unawaited(_persistDraft(clear: true).catchError((Object _) {}));
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
    final error = _error;
    final say = _followThrough(context);
    // Nothing to ask and nothing to report: no bar at all, rather than an
    // empty pane of glass sitting on the grass.
    if (error == null && say is SizedBox) return const SizedBox.shrink();
    return FieldGlass(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          say,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error,
                key: const Key('draft-error'),
                textAlign: TextAlign.center,
                style: context.text.bodySmall?.copyWith(color: field.onOut),
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(BuildContext context) {
    final field = context.colors.field;
    final g = _geo;
    final state = widget.state;
    final batter = state.batter;
    final dragging = _drag != null;
    final tapsAllowed = widget.enabled && !dragging && !_locked;
    final live = _live;
    // Dropped but not yet shown: the hitter stands on the bag they were
    // dragged to. The replay takes them back to the plate and runs it.
    final parked = switch (_destination) {
      DiamondZone.first => g.first,
      DiamondZone.second => g.second,
      DiamondZone.third => g.third,
      _ => g.home,
    };
    final chipPos = live != null
        ? _along(0, live.to ?? 0, _runnerAt)
        : (_drag ?? (_pending != null ? parked : g.home));
    // The field is the answer to "where did it go", so it takes the taps —
    // but only once the hitter is standing on the bag, never mid-stride. It
    // keeps taking them for the rest of the play, so the ball can be moved
    // while the later questions are still open.
    final pendingFlight = _pending;
    final capture =
        widget.trackLocation && pendingFlight != null && pendingFlight.batted;
    // The flight stays on the grass through the confirmation too, where it is
    // a receipt rather than a control.
    final flight = pendingFlight != null
        ? (pendingFlight.batted ? _location : null)
        : ContactLocation.parse(_justFiled?.hitLocation);
    final showFlight = live == null && (capture || (flight?.hasPoint ?? false));
    // The out's three answers sit beside the ball they are about.
    // Not while a finger is on the glass: the ball is still being placed, and
    // the answers would open under the hand placing it.
    final askHow =
        pendingFlight?.questions.firstOrNull == _Question.how &&
        _located &&
        _pointers == 0;
    final chipLabel = state.personal ? 'You' : (batter?.firstName ?? '');

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: (_) => _onPanEnd(),
      onPanCancel: () => setState(() {
        _drag = null;
        _zone = null;
      }),
      child: SizedBox(
        key: const Key('diamond'),
        width: g.width,
        height: g.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _LinesPainter(
                  geometry: g,
                  palette: field,
                  fenceHot: _zone == DiamondZone.homeRun,
                ),
              ),
            ),
            // Over the fence: tap to file a home run.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              // Exactly the ground beyond the wall, no grass.
              height: g.fenceY,
              child: GestureDetector(
                key: const Key('zone-homeRun'),
                behavior: HitTestBehavior.translucent,
                onTap: tapsAllowed ? () => _start(DiamondZone.homeRun) : null,
              ),
            ),
            for (final (zone, number) in const [
              (DiamondZone.first, 1),
              (DiamondZone.second, 2),
              (DiamondZone.third, 3),
            ])
              _BaseMarker(
                key: Key('zone-${zone.name}'),
                at: g.base(number),
                scale: g.scale,
                touch: g.baseTouch,
                hot: _zone == zone,
                occupied: state.replay.bases.at(number) != null,
                label: const [
                  'Single or reach first',
                  'Double',
                  'Triple',
                ][number - 1],
                onTap: tapsAllowed ? () => _start(zone) : null,
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: Text(
                  'OUT',
                  style: context.text.labelSmall?.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 2.2,
                    color: _zone == DiamondZone.out
                        ? field.onOut
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
            if (!state.personal)
              for (final slot in state.slots)
                if (slot.playerId != live?.batterId)
                  _RunnerChip(
                    key: Key('runner-${slot.playerId}'),
                    name: state.playerById(slot.playerId)?.firstName ?? '',
                    at: _runnerPos(slot.playerId),
                    on: (_shown[slot.playerId] ?? 0) > 0,
                    instant:
                        live != null || _justArrived.contains(slot.playerId),
                    onTap: tapsAllowed
                        ? () => _sendRunner(slot.playerId)
                        : null,
                  ),
            if (showFlight)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: !capture,
                  // Raw pointers, so this holds whatever the gesture arena
                  // decides and however the touch happens to end.
                  child: Listener(
                    onPointerDown: (_) => setState(() => _pointers += 1),
                    onPointerUp: (_) =>
                        setState(() => _pointers = math.max(0, _pointers - 1)),
                    onPointerCancel: (_) =>
                        setState(() => _pointers = math.max(0, _pointers - 1)),
                    child: ContactField(
                      geometry: ContactFieldGeometry(
                        Size(g.width, g.height),
                        origin: g.home,
                        fieldRadius: g.fenceRadius,
                      ),
                      drawSurface: false,
                      showLabels: false,
                      fieldMode: true,
                      location: flight,
                      onLocation: _saving || !capture ? null : _place,
                    ),
                  ),
                ),
              ),
            if (live?.ball?.hasPoint == true && live?.kind != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _BallPainter(
                      geometry: g,
                      palette: field,
                      flight: _Flight.of(live!.kind!),
                      to: live.ball!,
                      t: (_replay.value / (_motion * _ballSpan)).clamp(
                        0.0,
                        1.0,
                      ),
                      fade: _replayFade,
                    ),
                  ),
                ),
              ),
            AnimatedPositioned(
              key: const Key('batter-chip'),
              duration:
                  _pending != null ||
                      dragging ||
                      live != null ||
                      MediaQuery.disableAnimationsOf(context)
                  // The replay puts the chip on the basepath frame by frame.
                  // Tweening on top of that rounds off every corner, which is
                  // how a triple ends up cutting under second.
                  ? Duration.zero
                  : const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              left: chipPos.dx,
              top: chipPos.dy,
              child: IgnorePointer(
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey('chip-$_chipEpoch'),
                    tween: Tween(begin: 0, end: 1),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 280),
                    builder: (context, fade, child) =>
                        Opacity(opacity: fade * _replayFade, child: child),
                    child: _BatterChip(
                      label: chipLabel,
                      jersey: state.personal ? null : batter?.jerseyNumber,
                      dragging: dragging,
                      enabled: widget.enabled,
                    ),
                  ),
                ),
              ),
            ),
            // Last, so the live control is never behind a runner.
            if (askHow)
              _HowCluster(
                at: _ballAt,
                box: Size(g.width, g.height),
                avoid: chipPos,
                tone: _howTone(context),
                onPick: (kind) => _answer(_Question.how, kind: kind),
              ),
          ],
        ),
      ),
    );
  }

  Widget _followThrough(BuildContext context) {
    final field = context.colors.field;
    final zone = _zone;
    if (zone != null) {
      final text = switch (zone) {
        DiamondZone.first => 'First base',
        DiamondZone.second => 'Double',
        DiamondZone.third => 'Triple',
        DiamondZone.homeRun => 'Home run',
        DiamondZone.out => 'Out',
      };
      return Text(
        text,
        key: const Key('pending'),
        style: context.text.titleMedium?.copyWith(
          color: zone == DiamondZone.out ? field.onOut : field.on,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    if (_drag != null) {
      return Text(
        'let go here to cancel',
        style: context.text.bodySmall?.copyWith(color: field.muted),
      );
    }

    final pending = _pending;
    if (pending != null && _confirming) {
      return _PillRow(
        key: const Key('ask-discard'),
        question: 'Discard this at-bat?',
        onCancel: () => setState(() => _confirming = false),
        pills: [
          _Pill(
            key: const Key('discard-keep'),
            label: 'Keep',
            tone: field.muted,
            quiet: true,
            onTap: () => setState(() => _confirming = false),
          ),
          _Pill(
            key: const Key('discard-confirm'),
            label: 'Discard',
            tone: field.onOut,
            onTap: () => unawaited(_discard()),
          ),
        ],
      );
    }
    if (pending != null && pending.questions.isNotEmpty) {
      return switch (pending.asking) {
        _Question.location => _PillRow(
          key: const Key('ask-location'),
          question: 'Where did it go?',
          hint: 'tap the field',
          onCancel: _cancel,
          skip: () => _answer(_Question.location),
          pills: const [],
        ),
        // A ball that was placed on the field was in play, so it cannot have
        // been a strikeout — and the three answers that are left belong
        // beside the ball, not down here.
        _Question.how => _PillRow(
          key: const Key('ask-how'),
          question: _outPending ? 'How was the out?' : 'How was it hit?',
          onCancel: _cancel,
          pills: _located
              ? const []
              : [
                  for (final kind in OutKind.values)
                    _Pill(
                      key: Key('how-${kind.wire}'),
                      label: kind.label,
                      tone: _howTone(context),
                      onTap: () => _answer(_Question.how, kind: kind),
                    ),
                  if (_outPending)
                    _Pill(
                      key: const Key('how-k'),
                      label: 'K',
                      tone: field.onOut,
                      quiet: true,
                      onTap: () => _answer(_Question.how),
                    ),
                ],
        ),
        _Question.reach => _PillRow(
          key: const Key('ask-reach'),
          question: 'How did they reach?',
          onCancel: _cancel,
          pills: [
            for (final (result, quiet) in const [
              (PaResult.single, false),
              (PaResult.walk, false),
              (PaResult.reachOnError, true),
              (PaResult.fieldersChoice, true),
            ])
              _Pill(
                key: Key('reach-${result.wire}'),
                label: result.label,
                tone: field.accent,
                quiet: quiet,
                onTap: () => _answer(_Question.reach, result: result),
              ),
          ],
        ),
        _Question.rbi => _PillRow(
          key: const Key('ask-rbi'),
          question: 'How many scored?',
          onCancel: _cancel,
          pills: [
            for (var n = _minRbi(pending.result); n <= 4; n++)
              _Pill(
                key: Key('rbi-$n'),
                label: '$n',
                tone: field.accent,
                onTap: () => _answer(_Question.rbi, rbi: n),
              ),
          ],
        ),
      };
    }

    // Runs come off the diamond in a team game, so the one thing left to say
    // after a play is that somebody kept running. What the play was, and the
    // way to take it back, are in the log at the top of the page.
    final last = widget.state.lastPa;
    final wave =
        _justCommitted &&
        !widget.state.personal &&
        last != null &&
        last.runs < last.maxRuns &&
        !widget.state.replay.bases.isEmpty;

    if (wave) {
      return Text(
        'tap a runner to send them home',
        key: const Key('wave-hint'),
        style: context.text.bodySmall?.copyWith(color: field.muted),
      );
    }
    if (widget.showHint && widget.enabled) {
      // The chip is the batter, and in a personal game the batter is you.
      final name = widget.state.personal
          ? 'yourself'
          : (widget.state.batter?.firstName ?? 'the batter');
      return Text(
        'drag $name to a base  ·  flick down for an out',
        key: const Key('hint'),
        style: context.text.bodySmall?.copyWith(color: field.muted),
      );
    }
    return const SizedBox.shrink();
  }

  int _minRbi(PaResult result) => result == PaResult.homer ? 1 : 0;

  /// Pointers currently down on the field. Nothing that would land under a
  /// finger is shown while one is.
  int _pointers = 0;

  /// Where a runner is drawn: on their bag, or part-way to the next one
  /// while the play is being shown.
  Offset _runnerPos(String id) {
    final live = _live;
    final base = _shown[id] ?? 0;
    if (live == null) return base > 0 ? _geo.base(base) : _geo.home;
    final to = live.after[id] ?? (base > 0 ? 4 : 0);
    return _along(base, to, _runnerAt);
  }

  /// The play leaving the field at the end of its hold: one for most of the
  /// replay, nothing by the time it is over.
  double get _replayFade => _live == null
      ? 1
      : (1 - (_replay.value - _fadeAt) / (1 - _fadeAt)).clamp(0.0, 1.0);

  /// How far through the running the replay is, ignoring the hold on the end.
  double get _runnerAt => Curves.easeInOutSine.transform(
    (_replay.value / (_motion * _runSpan)).clamp(0.0, 1.0),
  );

  /// A point on the basepaths, [from] to [to], at [t]. Base 0 is the plate
  /// and base 4 is home with a run in, so the path never doubles back.
  Offset _along(int from, int to, double t) {
    final g = _geo;
    final path = [g.home, g.first, g.second, g.third, g.home];
    if (to <= from) return path[from.clamp(0, 4)];
    final travelled = from + (to - from) * t.clamp(0.0, 1.0);
    final leg = travelled.floor().clamp(0, 3);
    return Offset.lerp(path[leg], path[leg + 1], travelled - leg)!;
  }

  /// True once the ball has a spot on the grass.
  bool get _located => _location?.hasPoint == true;

  /// True while the play on the table is still an out. A hit answers the same
  /// question, but the answer only describes the ball.
  bool get _outPending {
    final r = _pending?.result;
    return r == PaResult.out || r == PaResult.strikeout;
  }

  Color _howTone(BuildContext context) =>
      _outPending ? context.colors.field.onOut : context.colors.field.accent;

  /// Where the ball is drawn, in the field box's own coordinates.
  Offset get _ballAt {
    final g = _geo;
    final at = _location!;
    return g.home + Offset(at.x! * g.fenceRadius, -at.y! * g.fenceRadius);
  }
}

/// The batted ball, mid-flight. A plan view cannot show launch angle, so
/// height is carried by the ball swelling while its shadow drops away
/// beneath it, and the three kinds are told apart by how they cover ground.
class _BallPainter extends CustomPainter {
  _BallPainter({
    required this.geometry,
    required this.palette,
    required this.flight,
    required this.to,
    required this.t,
    required this.fade,
  });

  final FieldGeometry geometry;
  final FieldPalette palette;
  final _Flight flight;
  final ContactLocation to;
  final double t;

  /// The whole play going out together at the end of the hold.
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final target =
        g.home + Offset(to.x! * g.fenceRadius, -to.y! * g.fenceRadius);
    final u = t.clamp(0.0, 1.0);
    final r = math.max(2.5, g.fenceRadius * .016);

    /// Where the ball is over the ground at [s].
    Offset ground(double s) =>
        Offset.lerp(g.home, target, flight.travel.transform(s))!;

    /// And where it is drawn, which is that lifted by its height.
    Offset ball(double s) =>
        ground(s) + Offset(0, -flight.heightAt(s) * r * 3.4);

    // The trail is the path the ball has actually taken, so it arcs with a
    // fly, scallops with a grounder, and stays flat on a liner. Drawing it
    // along the ground instead leaves the ball flying off its own line.
    const steps = 32;
    final path = Path()..moveTo(g.home.dx, g.home.dy);
    for (var i = 1; i <= steps; i++) {
      final s = i / steps;
      if (s >= u) break;
      final p = ball(s);
      path.lineTo(p.dx, p.dy);
    }
    final tip = ball(u);
    path.lineTo(tip.dx, tip.dy);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, g.fenceRadius * .008)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = palette.spray.withValues(alpha: .85 * fade),
    );

    // Its shadow stays on the grass, flattened the way a shadow is, and the
    // gap between the two is the only place the height can live.
    final h = flight.heightAt(u);
    final squash = (1 - (h * .10)).clamp(0.60, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: ground(u),
        width: r * 2 * squash,
        height: r * 1.3 * squash,
      ),
      // Constant weight: a shadow that faded as the ball climbed would take
      // the height cue away exactly when it is needed most.
      Paint()..color = const Color(0xFF07110B).withValues(alpha: .55 * fade),
    );
    canvas.drawCircle(
      tip,
      r * (1 + h * .34),
      Paint()..color = palette.bag.withValues(alpha: fade),
    );
    if (u >= 1) {
      // Landed: a mark where it came down.
      canvas.drawCircle(
        target,
        r * 1.9,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, g.fenceRadius * .005)
          ..color = palette.spray.withValues(alpha: .55 * fade),
      );
    }
  }

  @override
  bool shouldRepaint(_BallPainter old) =>
      old.t != t ||
      old.fade != fade ||
      old.to != to ||
      old.geometry.width != geometry.width;
}

/// How the ball was hit, stacked beside it on the grass. It takes the
/// side of the field with more room, and never leaves the box.
class _HowCluster extends StatelessWidget {
  const _HowCluster({
    required this.at,
    required this.box,
    required this.avoid,
    required this.tone,
    required this.onPick,
  });

  final Offset at;
  final Size box;

  /// The hitter, standing on the bag they were dropped on. The answers take
  /// the side of the ball that keeps clear of them.
  final Offset avoid;

  final Color tone;
  final ValueChanged<OutKind> onPick;

  static const _w = 78.0;
  static const _row = 32.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final n = OutKind.values.length;
    final tall = n * _row + (n - 1) * _gap;
    final double top = (at.dy - tall / 2).clamp(
      6.0,
      math.max(6.0, box.height - tall - 6),
    );
    double place(double x) =>
        x.clamp(6.0, math.max(6.0, box.width - _w - 6)).toDouble();
    // Whichever side of the ball leaves the hitter alone; failing that,
    // whichever side has the room.
    double clearance(double x) {
      final rect = Rect.fromLTWH(x, top, _w, tall);
      final dx = math.max(rect.left - avoid.dx, avoid.dx - rect.right);
      final dy = math.max(rect.top - avoid.dy, avoid.dy - rect.bottom);
      return math.max(math.max(dx, dy), 0);
    }

    final roomy = place(at.dx > box.width / 2 ? at.dx - 18 - _w : at.dx + 18);
    final other = place(at.dx > box.width / 2 ? at.dx + 18 : at.dx - 18 - _w);
    final left = clearance(roomy) >= 26 || clearance(other) <= clearance(roomy)
        ? roomy
        : other;
    return Positioned(
      left: left,
      top: top,
      width: _w,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final kind in OutKind.values) ...[
              if (kind != OutKind.values.first) const SizedBox(height: _gap),
              Semantics(
                button: true,
                child: InkWell(
                  key: Key('how-${kind.wire}'),
                  onTap: () => onPick(kind),
                  borderRadius: BorderRadius.circular(_row / 2),
                  child: Container(
                    height: _row,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: field.bg.withValues(alpha: .82),
                      borderRadius: BorderRadius.circular(_row / 2),
                      border: Border.all(color: tone, width: 1.5),
                    ),
                    child: Text(
                      kind.label,
                      style: context.text.labelMedium?.copyWith(
                        color: tone,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The row under the diamond. One question, one tap, plus a way out.
class _PillRow extends StatelessWidget {
  const _PillRow({
    super.key,
    required this.pills,
    required this.onCancel,
    this.question,
    this.hint,
    this.skip,
  });

  final List<Widget> pills;

  /// Throws the whole play away.
  final VoidCallback onCancel;

  /// Leaves this one answer blank and moves on. A different thing entirely
  /// from [onCancel], so it sits in a different corner.
  final VoidCallback? skip;

  /// The one thing being asked, in words.
  final String? question;

  /// Where the rest of the answer lives, when it is not on a pill.
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 200),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 6),
          child: child,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Full width, so the two controls below land in the bar's corners
          // rather than beside the question.
          SizedBox(
            width: double.infinity,
            child: Padding(
              // Room for those corners, so a long question never runs under
              // them.
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (question != null)
                    Text(
                      question!,
                      textAlign: TextAlign.center,
                      style: context.text.titleMedium?.copyWith(
                        color: field.on,
                      ),
                    ),
                  if (pills.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: pills,
                        ),
                      ),
                    ),
                  if (hint != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        hint!,
                        style: context.text.bodySmall?.copyWith(
                          color: field.muted,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -4,
            right: -6,
            child: Semantics(
              button: true,
              label: 'Cancel this play',
              excludeSemantics: true,
              child: InkWell(
                key: const Key('ask-cancel'),
                onTap: onCancel,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 34,
                  height: 32,
                  child: Icon(Icons.close, size: 16, color: field.muted),
                ),
              ),
            ),
          ),
          if (skip != null)
            Positioned(
              bottom: -6,
              left: -8,
              child: TextButton(
                key: const Key('location-skip'),
                onPressed: skip,
                style: TextButton.styleFrom(
                  foregroundColor: field.muted,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  textStyle: context.text.bodySmall,
                ),
                child: const Text('Skip'),
              ),
            ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.tone,
    required this.onTap,
    this.quiet = false,
  });

  final String label;
  final Color tone;
  final VoidCallback onTap;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 30,
            constraints: const BoxConstraints(minWidth: 42),
            padding: const EdgeInsets.symmetric(horizontal: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: quiet ? field.lineStrong : tone,
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: context.text.labelMedium?.copyWith(
                color: quiet ? field.muted : tone,
                fontWeight: FontWeight.w700,
                fontFeatures: tabularFigures,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The field under the diamond: the shared surface, plus the wall lighting up
/// when a drag clears it.
class _LinesPainter extends CustomPainter {
  _LinesPainter({
    required this.geometry,
    required this.palette,
    required this.fenceHot,
  });

  final FieldGeometry geometry;
  final FieldPalette palette;
  final bool fenceHot;

  @override
  void paint(Canvas canvas, Size size) {
    FieldSurface.paint(canvas, geometry, palette);
    if (fenceHot) FieldSurface.lightTheWall(canvas, geometry, palette);
  }

  @override
  bool shouldRepaint(_LinesPainter old) {
    return old.fenceHot != fenceHot ||
        old.geometry.width != geometry.width ||
        old.palette != palette;
  }
}

class _BaseMarker extends StatelessWidget {
  const _BaseMarker({
    super.key,
    required this.at,
    required this.scale,
    required this.touch,
    required this.hot,
    required this.occupied,
    required this.label,
    required this.onTap,
  });

  final Offset at;
  final double scale;
  final double touch;
  final bool hot;
  final bool occupied;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final hit = touch;
    return Positioned(
      left: at.dx - hit / 2,
      top: at.dy - hit / 2,
      width: hit,
      height: hit,
      child: Semantics(
        label: label,
        button: true,
        enabled: onTap != null,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 150),
              width: 15 * scale,
              height: 15 * scale,
              transform: Matrix4.identity()
                ..translateByDouble(7.5 * scale, 7.5 * scale, 0, 1)
                ..rotateZ(0.7853981633974483)
                ..scaleByDouble(hot ? 1.25 : 1.0, hot ? 1.25 : 1.0, 1, 1)
                ..translateByDouble(-7.5 * scale, -7.5 * scale, 0, 1),
              // A base is a white canvas bag. An occupied one picks up the
              // accent, which is what the accent is for.
              decoration: BoxDecoration(
                color: hot ? field.accent : field.bag,
                borderRadius: BorderRadius.circular(2),
                boxShadow: hot || occupied
                    ? [
                        BoxShadow(
                          color: field.accent.withValues(
                            alpha: hot ? 0.55 : 0.40,
                          ),
                          blurRadius: hot ? 18 : 11,
                          spreadRadius: hot ? 3 : 1,
                        ),
                      ]
                    : const [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunnerChip extends StatelessWidget {
  const _RunnerChip({
    super.key,
    required this.name,
    required this.at,
    required this.on,
    required this.instant,
    required this.onTap,
  });

  final String name;
  final Offset at;

  /// Drawn at all: a runner neither on base nor running is nowhere.
  final bool on;
  final bool instant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return AnimatedPositioned(
      duration: instant || MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 440),
      curve: Curves.easeOutCubic,
      left: at.dx,
      top: at.dy,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: IgnorePointer(
          ignoring: !on,
          child: AnimatedOpacity(
            duration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            opacity: on ? 1 : 0,
            child: Semantics(
              button: on,
              label: on ? '$name on base, tap to score' : null,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: on ? onTap : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 13,
                    horizontal: 8,
                  ),
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: field.surfaceHigh,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: field.accent, width: 1.5),
                    ),
                    child: Text(
                      name,
                      style: context.text.labelSmall?.copyWith(
                        color: field.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BatterChip extends StatelessWidget {
  const _BatterChip({
    required this.label,
    required this.jersey,
    required this.dragging,
    required this.enabled,
  });

  final String label;
  final String? jersey;
  final bool dragging;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final background = enabled ? field.accent : field.surfaceHigh;
    final foreground = enabled ? field.onAccent : field.muted;
    return AnimatedScale(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 120),
      scale: dragging ? 1.12 : 1,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: field.accent.withValues(
                      alpha: dragging ? 0.45 : 0.35,
                    ),
                    blurRadius: dragging ? 30 : 22,
                    offset: Offset(0, dragging ? 14 : 8),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            if (jersey != null && jersey!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                jersey!,
                style: context.text.labelSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.75),
                  fontSize: 10,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
