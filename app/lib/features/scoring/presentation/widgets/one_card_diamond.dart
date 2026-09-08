import 'dart:async';
import 'dart:convert';
import 'contact_field.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hacktracker/core/domain/models/out_kind.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
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

/// What the row under the diamond is still asking.
enum _Question { how, reach, rbi }

class _Pending {
  _Pending({
    required this.result,
    required this.target,
    required this.hidden,
    required this.questions,
  });

  PaResult result;
  OutKind? outKind;
  int? rbi;
  final Offset target;

  /// The chip is gone from the field: an out, or over the fence.
  final bool hidden;
  final List<_Question> questions;

  _Question get asking => questions.first;
}

/// The whole input surface. The batter's chip sits on the plate; drag it to a
/// base, past the fence, or flick it down. A play is not filed until the row
/// underneath has its answer, so nothing lands half-said.
class OneCardDiamond extends StatefulWidget {
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
    this.reviewHeight = 600,
  });

  final FieldModeState state;
  final FieldGeometry geometry;
  final bool enabled;
  final bool showHint;
  final bool trackLocation;
  final double reviewHeight;

  /// Called once, when every question has an answer.
  final FutureOr<void> Function(LoggedPlay) onCommit;
  final FutureOr<void> Function(String) onWave;

  /// True while a play is waiting on the row, so the rest of the screen can
  /// hold still.
  final ValueChanged<bool> onPendingChanged;
  final Future<void> Function(String?)? onDraftChanged;

  @override
  State<OneCardDiamond> createState() => _OneCardDiamondState();
}

class _OneCardDiamondState extends State<OneCardDiamond>
    with SingleTickerProviderStateMixin {
  late final AnimationController _run;
  DiamondZone? _destination;
  ContactLocation? _location;
  String? _quality;
  bool _review = false;
  String? _error;
  Offset? _drag;
  DiamondZone? _zone;

  /// A play that has been dragged but not yet answered.
  _Pending? _pending;

  /// Where the chip rests after a release, before it returns to the plate.
  Offset? _settleTarget;
  bool _settleHidden = false;
  Timer? _settle;
  int _chipEpoch = 0;

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
    _run =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 480),
        )..addListener(() {
          if (mounted) setState(() {});
        });
    _baseOf = _basesOf(widget.state);
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
            'version': _review ? 3 : 1,
            'destination': _destination?.name,
            'location': _location?.encode(),
            'quality': _quality,
            'batterId': widget.state.batter?.id,
            'sequence': _lastSequence,
            'result': (ready?.result ?? pending?.result)?.wire,
            'outKind': (ready?.outKind ?? pending?.outKind)?.wire,
            'rbi': ready?.rbi ?? pending?.rbi,
            'questions':
                pending?.questions.map((q) => q.name).toList() ?? <String>[],
            'targetX': (_settleTarget?.dx ?? _geo.home.dx) / _geo.width,
            'targetY': (_settleTarget?.dy ?? _geo.home.dy) / _geo.height,
            'hidden': _settleHidden,
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
      if (![1, 3].contains(raw['version']) ||
          raw['batterId'] != widget.state.batter?.id ||
          raw['sequence'] != _lastSequence) {
        return;
      }
      final result = PaResult.fromWire(raw['result'] as String);
      final kind = OutKind.fromWire(raw['outKind'] as String?);
      final questions = (raw['questions'] as List)
          .map((q) => _Question.values.byName(q as String))
          .toList();
      _settleTarget = Offset(
        (raw['targetX'] as num).toDouble() * _geo.width,
        (raw['targetY'] as num).toDouble() * _geo.height,
      );
      _settleHidden = raw['hidden'] == true;
      if (raw['version'] == 3) {
        _review = true;
        _destination = DiamondZone.values.byName(raw['destination'] as String);
        _location = ContactLocation.parse(raw['location'] as String?);
        _quality = raw['quality'] as String?;
        _run.value = 1;
        _pending =
            _Pending(
                result: result,
                target: _settleTarget!,
                hidden: _settleHidden,
                questions: [],
              )
              ..outKind = kind
              ..rbi = raw['rbi'] as int?;
      } else if (questions.isEmpty) {
        _failedPlay = LoggedPlay(
          result: result,
          outKind: kind,
          rbi: raw['rbi'] as int?,
        );
      } else {
        _pending =
            _Pending(
                result: result,
                target: _settleTarget!,
                hidden: _settleHidden,
                questions: questions,
              )
              ..outKind = kind
              ..rbi = raw['rbi'] as int?;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onPendingChanged(true);
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
    _settle?.cancel();
    _run.dispose();
    super.dispose();
  }

  // --------------------------------------------------------------- gestures

  DiamondZone? _zoneAt(Offset p) {
    final g = _geo;
    if (p.dy > g.outY) return DiamondZone.out;
    if ((p - g.home).distance < g.deadZone) return null;
    if (p.dy < g.fenceY) return DiamondZone.homeRun;
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
    return bestDistance <= g.snap ? best : null;
  }

  bool _saving = false;
  LoggedPlay? _failedPlay;

  bool get _locked => _pending != null || _saving || _failedPlay != null;

  void _onPanStart(DragStartDetails d) {
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
    if (!widget.enabled || _locked) return;
    final g = _geo;
    final personal = widget.state.personal;

    final (result, target, hidden) = switch (zone) {
      DiamondZone.first => (PaResult.single, g.first, false),
      DiamondZone.second => (PaResult.double, g.second, false),
      DiamondZone.third => (PaResult.triple, g.third, false),
      DiamondZone.homeRun => (
        PaResult.homer,
        Offset(g.home.dx, -30 * g.scale),
        true,
      ),
      DiamondZone.out => (
        PaResult.out,
        Offset(g.home.dx, g.outY + 12 * g.scale),
        true,
      ),
    };

    unawaited(HapticFeedback.mediumImpact());
    setState(() {
      _review = true;
      _destination = zone;
      _location = null;
      _quality = null;
      _error = null;
      _settleTarget = target;
      _settleHidden = false;
      _pending = _Pending(
        result: result,
        target: target,
        hidden: hidden,
        questions: [],
      )..rbi = personal ? (result == PaResult.homer ? 1 : 0) : null;
    });
    widget.onPendingChanged(true);
    unawaited(
      _persistDraft().catchError((Object _) {
        if (mounted) {
          setState(
            () => _error =
                'Draft not saved. Keep this screen open and try Save play.',
          );
        }
      }),
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      _run.value = 1;
    } else {
      _run.forward(from: 0);
    }
  }

  void _answer(
    _Question question, {
    OutKind? kind,
    PaResult? result,
    int? rbi,
  }) {
    final pending = _pending;
    if (pending == null ||
        pending.questions.isEmpty ||
        pending.asking != question) {
      return;
    }
    unawaited(HapticFeedback.selectionClick());
    switch (question) {
      case _Question.how:
        pending.result = kind == null ? PaResult.strikeout : PaResult.out;
        pending.outKind = kind;
      case _Question.reach:
        pending.result = result ?? pending.result;
      case _Question.rbi:
        pending.rbi = rbi;
    }
    pending.questions.removeAt(0);
    if (pending.questions.isNotEmpty) {
      unawaited(
        _persistDraft().catchError((Object _) {
          if (mounted) {
            setState(
              () => _error =
                  'Draft not saved. Keep this screen open and try Save play.',
            );
          }
        }),
      );
      setState(() {});
      return;
    }
    final play = LoggedPlay(
      result: pending.result,
      outKind: pending.outKind,
      rbi: pending.rbi,
    );
    setState(() {
      _review = true;
      _destination = switch (play.result) {
        PaResult.double => DiamondZone.second,
        PaResult.triple => DiamondZone.third,
        PaResult.homer => DiamondZone.homeRun,
        PaResult.out || PaResult.strikeout => DiamondZone.out,
        _ => DiamondZone.first,
      };
      _run.value = 1;
    });
    unawaited(
      _persistDraft().catchError((Object _) {
        if (mounted) {
          setState(
            () => _error =
                'Draft not saved. Keep this screen open and try Save play.',
          );
        }
      }),
    );
  }

  Future<void> _cancel() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _persistDraft(clear: true);
      if (!mounted) return;
      setState(() {
        _pending = null;
        _review = false;
        _location = null;
        _failedPlay = null;
        _settleTarget = null;
        _settleHidden = false;
        _error = null;
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
    try {
      await _persistDraft(ready: play);
      await widget.onCommit(play);
      if (!mounted) return;
      setState(() {
        _pending = null;
        _review = false;
        _location = null;
        _justCommitted = true;
        _saving = false;
      });
      widget.onPendingChanged(false);
      _settle?.cancel();
      _settle = Timer(
        MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        () {
          if (!mounted) return;
          setState(() {
            _settleTarget = null;
            _settleHidden = false;
            _chipEpoch += 1;
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        if (_review) {
          _error = 'Play not saved. Try Save play again.';
        } else {
          _failedPlay = play;
        }
      });
    }
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final g = _geo;
    final state = widget.state;
    final batter = state.batter;
    final dragging = _drag != null;
    final tapsAllowed =
        widget.enabled && !dragging && !_locked && _settleTarget == null;

    final path = [g.home, g.first, g.second, g.third, g.home];
    final legs = switch (_destination) {
      DiamondZone.first => 1,
      DiamondZone.second => 2,
      DiamondZone.third => 3,
      DiamondZone.homeRun => 4,
      _ => 0,
    };
    final progress = _run.value * legs;
    final leg = progress.floor().clamp(0, legs > 0 ? legs - 1 : 0);
    final running = legs == 0
        ? g.home
        : Offset.lerp(path[leg], path[leg + 1], progress - leg)!;
    final chipPos = _review ? running : (_drag ?? _settleTarget ?? g.home);
    final reviewing = _review && _run.isCompleted;
    final capture =
        reviewing &&
        widget.trackLocation &&
        _pending!.result != PaResult.walk &&
        _pending!.result != PaResult.strikeout;
    final chipLabel = state.personal ? 'You' : (batter?.firstName ?? '');

    return SizedBox(
      width: double.infinity,
      height: widget.reviewHeight.clamp(g.height + 220, double.infinity),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_failedPlay != null)
            Row(
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
                      _settleTarget = null;
                      _settleHidden = false;
                    });
                    widget.onPendingChanged(false);
                    unawaited(
                      _persistDraft(clear: true).catchError((Object _) {}),
                    );
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          GestureDetector(
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
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: Center(
                      child: Text(
                        'FENCE',
                        style: context.text.labelSmall?.copyWith(
                          fontSize: 9.5,
                          letterSpacing: 2.2,
                          color: _zone == DiamondZone.homeRun
                              ? field.accent
                              : field.lineStrong,
                        ),
                      ),
                    ),
                  ),
                  // Over the fence: tap to file a home run.
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 46 * g.scale,
                    child: GestureDetector(
                      key: const Key('zone-homeRun'),
                      behavior: HitTestBehavior.translucent,
                      onTap: tapsAllowed
                          ? () => _start(DiamondZone.homeRun)
                          : null,
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
                      hot: _zone == zone,
                      occupied: state.replay.bases.at(number) != null,
                      label: const [
                        'Single or reach first',
                        'Double',
                        'Triple',
                      ][number - 1],
                      onTap: tapsAllowed ? () => _start(zone) : null,
                    ),
                  _Plate(at: g.home, scale: g.scale),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: -6 * g.scale,
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
                      _RunnerChip(
                        key: Key('runner-${slot.playerId}'),
                        name: state.playerById(slot.playerId)?.firstName ?? '',
                        base: _baseOf[slot.playerId] ?? 0,
                        instant: _justArrived.contains(slot.playerId),
                        geometry: g,
                        onTap: tapsAllowed
                            ? () => _sendRunner(slot.playerId)
                            : null,
                      ),
                  if (capture)
                    Positioned.fill(
                      child: ContactField(
                        geometry: ContactFieldGeometry(
                          Size(g.width, g.height),
                          origin: g.home,
                          fieldRadius: g.home.dy - 14 * g.scale,
                        ),
                        drawSurface: false,
                        showLabels: false,
                        fieldMode: true,
                        location: _location,
                        onLocation: _saving
                            ? null
                            : (v) => _edit(
                                () => _location = v.withDetails(
                                  flight: _location?.flight,
                                  bats: _location?.bats,
                                ),
                              ),
                      ),
                    ),
                  AnimatedPositioned(
                    key: const Key('batter-chip'),
                    duration:
                        _review ||
                            dragging ||
                            MediaQuery.disableAnimationsOf(context)
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
                          builder: (context, fade, child) => Opacity(
                            opacity: _settleHidden ? 0 : fade,
                            child: child,
                          ),
                          child: _BatterChip(
                            label: chipLabel,
                            jersey: state.personal
                                ? null
                                : batter?.jerseyNumber,
                            dragging: dragging,
                            enabled: widget.enabled,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: Center(
              child: capture
                  ? Text(
                      'Tap the field to place or move the hit',
                      style: context.text.bodySmall?.copyWith(
                        color: field.accent,
                      ),
                    )
                  : reviewing
                  ? const SizedBox.shrink()
                  : _followThrough(context),
            ),
          ),
          if (reviewing)
            Expanded(
              child: TweenAnimationBuilder<double>(
                key: const Key('review-reveal'),
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 220),
                builder: (context, value, child) =>
                    Opacity(opacity: value, child: child),
                child: _reviewPanel(context),
              ),
            ),
        ],
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
    if (_review) {
      return Text(
        'Hitter → $_destinationLabel',
        style: context.text.titleMedium?.copyWith(color: field.on),
      );
    }
    if (pending != null) {
      return switch (pending.asking) {
        _Question.how => _PillRow(
          key: const Key('ask-how'),
          onCancel: _cancel,
          pills: [
            for (final kind in OutKind.values)
              _Pill(
                key: Key('how-${kind.wire}'),
                label: kind.label,
                tone: field.onOut,
                onTap: () => _answer(_Question.how, kind: kind),
              ),
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
          label: 'RBI',
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

    // Runs come off the diamond in a team game; the only thing left to say is
    // that somebody kept running.
    final last = widget.state.lastPa;
    if (_justCommitted &&
        !widget.state.personal &&
        last != null &&
        last.runs < last.maxRuns &&
        !widget.state.replay.bases.isEmpty) {
      return Text(
        'tap a runner to send them home',
        key: const Key('wave-hint'),
        style: context.text.bodySmall?.copyWith(color: field.muted),
      );
    }
    if (widget.showHint && widget.enabled) {
      final name = widget.state.batter?.firstName ?? 'the batter';
      return Text(
        'drag $name to a base  ·  flick down for an out',
        key: const Key('hint'),
        style: context.text.bodySmall?.copyWith(color: field.muted),
      );
    }
    return const SizedBox.shrink();
  }

  String get _destinationLabel => switch (_destination) {
    DiamondZone.first => '1st base',
    DiamondZone.second => '2nd base',
    DiamondZone.third => '3rd base',
    DiamondZone.homeRun => 'Home',
    _ => 'Out',
  };

  void _edit(VoidCallback change) {
    if (_saving) return;
    setState(() {
      change();
      _error = null;
    });
    unawaited(
      _persistDraft().catchError((Object _) {
        if (mounted) {
          setState(
            () => _error =
                'Draft not saved. Keep this screen open and try Save play.',
          );
        }
      }),
    );
  }

  Widget _reviewPanel(BuildContext context) {
    final p = _pending!;
    final field = context.colors.field;
    final batted = p.result != PaResult.walk && p.result != PaResult.strikeout;
    final needsKind = p.result == PaResult.out;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hitter → $_destinationLabel',
                  style: context.text.titleMedium?.copyWith(
                    color: field.accent,
                  ),
                ),
                if (widget.trackLocation && batted) ...[
                  Text(
                    'Where did the ball go?',
                    style: context.text.titleLarge?.copyWith(color: field.on),
                  ),
                  Text(
                    _location?.label ?? 'Location unknown · optional',
                    style: context.text.bodySmall?.copyWith(color: field.muted),
                  ),
                  if (_location != null)
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () => _edit(() => _location = null),
                      child: const Text('Clear location'),
                    ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Result',
                  style: context.text.labelLarge?.copyWith(color: field.on),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final result in [
                      PaResult.single,
                      PaResult.double,
                      PaResult.triple,
                      PaResult.homer,
                      PaResult.walk,
                      PaResult.out,
                      PaResult.strikeout,
                      PaResult.reachOnError,
                      PaResult.fieldersChoice,
                    ])
                      ChoiceChip(
                        checkmarkColor: field.accent,
                        labelStyle: context.text.labelLarge?.copyWith(
                          color: field.on,
                        ),
                        key: Key('result-${result.wire}'),
                        label: Text(result.label),
                        selected: p.result == result,
                        onSelected: _saving
                            ? null
                            : (_) => _edit(() {
                                p.result = result;
                                if (result != PaResult.out) p.outKind = null;
                                if (result == PaResult.walk ||
                                    result == PaResult.strikeout) {
                                  _location = null;
                                }
                                if (widget.state.personal &&
                                    result == PaResult.homer &&
                                    (p.rbi ?? 0) < 1) {
                                  p.rbi = 1;
                                }
                              }),
                      ),
                  ],
                ),
                if (needsKind)
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final kind in OutKind.values)
                        ChoiceChip(
                          checkmarkColor: field.accent,
                          labelStyle: context.text.labelLarge?.copyWith(
                            color: field.on,
                          ),
                          key: Key('how-${kind.wire}'),
                          label: Text(kind.label),
                          selected: p.outKind == kind,
                          onSelected: _saving
                              ? null
                              : (_) => _edit(() => p.outKind = kind),
                        ),
                    ],
                  ),
                if (widget.state.personal) ...[
                  Text(
                    'RBI',
                    style: context.text.labelLarge?.copyWith(color: field.on),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (var n = _minRbi(p.result); n <= 4; n++)
                        ChoiceChip(
                          checkmarkColor: field.accent,
                          labelStyle: context.text.labelLarge?.copyWith(
                            color: field.on,
                          ),
                          key: Key('rbi-$n'),
                          label: Text('$n'),
                          selected: p.rbi == n,
                          onSelected: _saving
                              ? null
                              : (_) => _edit(() => p.rbi = n),
                        ),
                    ],
                  ),
                ],
                if (widget.trackLocation && batted)
                  ExpansionTile(
                    title: const Text('Optional detail'),
                    children: [
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final region in ContactLocation.regions)
                            ActionChip(
                              label: Text(region),
                              onPressed: _saving
                                  ? null
                                  : () => _edit(
                                      () => _location = ContactLocation(
                                        region: region,
                                        flight: _location?.flight,
                                        bats: _location?.bats,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final flight in ContactLocation.flights)
                            ChoiceChip(
                              checkmarkColor: field.accent,
                              labelStyle: context.text.labelLarge?.copyWith(
                                color: field.on,
                              ),
                              label: Text(flight),
                              selected: _location?.flight == flight,
                              onSelected: _saving
                                  ? null
                                  : (selected) => _edit(
                                      () => _location = ContactLocation(
                                        x: _location?.x,
                                        y: _location?.y,
                                        region: _location?.region,
                                        flight: selected ? flight : null,
                                        bats: _location?.bats,
                                      ),
                                    ),
                            ),
                        ],
                      ),
                      if (widget.state.personal ||
                          widget.state.settings.modules.contact)
                        Wrap(
                          spacing: 6,
                          children: [
                            for (final quality in ['weak', 'medium', 'hard'])
                              ChoiceChip(
                                checkmarkColor: field.accent,
                                labelStyle: context.text.labelLarge?.copyWith(
                                  color: field.on,
                                ),
                                label: Text(quality),
                                selected: _quality == quality,
                                onSelected: _saving
                                    ? null
                                    : (selected) => _edit(
                                        () => _quality = selected
                                            ? quality
                                            : null,
                                      ),
                              ),
                          ],
                        ),
                      Text(
                        'Batting side',
                        style: context.text.labelLarge?.copyWith(
                          color: field.on,
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        children: [
                          for (final side in ['left', 'right'])
                            ChoiceChip(
                              checkmarkColor: field.accent,
                              labelStyle: context.text.labelLarge?.copyWith(
                                color: field.on,
                              ),
                              label: Text(side),
                              selected:
                                  (_location?.bats ??
                                      widget.state.batter?.bats) ==
                                  side,
                              onSelected: _saving
                                  ? null
                                  : (_) => _edit(
                                      () => _location =
                                          (_location ?? const ContactLocation())
                                              .withDetails(bats: side),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                if (_error != null)
                  Text(
                    _error!,
                    style: context.text.bodySmall?.copyWith(color: field.onOut),
                  ),
                if (needsKind && p.outKind == null)
                  Text(
                    'Choose how the out was made',
                    style: context.text.bodySmall?.copyWith(color: field.muted),
                  ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                key: const Key('save-play'),
                onPressed: _saving || (needsKind && p.outKind == null)
                    ? null
                    : () => _file(
                        LoggedPlay(
                          result: p.result,
                          outKind: p.outKind,
                          rbi: p.rbi,
                          hitLocation: batted ? _location?.encode() : null,
                          qualityOfContact: batted ? _quality : null,
                        ),
                      ),
                child: const Text('Save play'),
              ),
              TextButton(
                key: const Key('cancel-play'),
                onPressed: _saving ? null : _cancel,
                child: const Text('Cancel play'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  int _minRbi(PaResult result) => result == PaResult.homer ? 1 : 0;
}

/// The row under the diamond. One question, one tap, plus a way out.
class _PillRow extends StatelessWidget {
  const _PillRow({
    super.key,
    required this.pills,
    required this.onCancel,
    this.label,
  });

  final List<Widget> pills;
  final VoidCallback onCancel;
  final String? label;

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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  label!,
                  style: context.text.labelSmall?.copyWith(
                    color: field.muted,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ...pills,
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Semantics(
                button: true,
                label: 'Cancel this play',
                excludeSemantics: true,
                child: InkWell(
                  key: const Key('ask-cancel'),
                  onTap: onCancel,
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    width: 32,
                    height: 30,
                    alignment: Alignment.center,
                    child: Icon(Icons.close, size: 16, color: field.muted),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    final g = geometry;
    final ground = Path()
      ..moveTo(g.home.dx, g.home.dy)
      ..lineTo(g.first.dx, g.first.dy)
      ..lineTo(g.second.dx, g.second.dy)
      ..lineTo(g.third.dx, g.third.dy)
      ..close();
    canvas.drawPath(
      ground,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.accent.withValues(alpha: .14),
            palette.accent.withValues(alpha: .025),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    final center = Offset(g.home.dx, (g.home.dy + g.second.dy) / 2);
    canvas.drawCircle(
      center,
      15 * g.scale,
      Paint()..color = palette.accent.withValues(alpha: .06),
    );
    canvas.drawCircle(
      center,
      15 * g.scale,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = palette.lineStrong,
    );
    canvas.drawLine(
      center - Offset(5 * g.scale, 0),
      center + Offset(5 * g.scale, 0),
      Paint()
        ..color = palette.muted
        ..strokeWidth = 2,
    );
    final lines = Path()
      ..moveTo(g.home.dx, g.home.dy)
      ..lineTo(g.first.dx, g.first.dy)
      ..lineTo(g.second.dx, g.second.dy)
      ..lineTo(g.third.dx, g.third.dy)
      ..close();
    canvas.drawPath(
      lines,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = palette.line,
    );

    final s = g.scale;
    final fence = Path()
      ..moveTo(40 * s, 34 * s)
      ..quadraticBezierTo(140 * s, -6 * s, 240 * s, 34 * s);
    if (fenceHot) {
      canvas.drawPath(
        fence,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..color = palette.accent.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawPath(
        fence,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..color = palette.accent,
      );
    } else {
      _dashed(canvas, fence, palette.lineStrong);
    }
  }

  void _dashed(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = color;
    for (final metric in path.computeMetrics()) {
      var at = 0.0;
      while (at < metric.length) {
        final end = (at + 4).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(at, end), paint);
        at += 9;
      }
    }
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
    required this.hot,
    required this.occupied,
    required this.label,
    required this.onTap,
  });

  final Offset at;
  final double scale;
  final bool hot;
  final bool occupied;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    const hit = 52.0;
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
              decoration: BoxDecoration(
                color: hot ? field.accent : field.surfaceHigh,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: hot || occupied ? field.accent : field.lineStrong,
                  width: 1.5,
                ),
                boxShadow: hot
                    ? [
                        BoxShadow(
                          color: field.accent.withValues(alpha: 0.16),
                          spreadRadius: 7,
                        ),
                        BoxShadow(
                          color: field.accent.withValues(alpha: 0.55),
                          blurRadius: 18,
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

class _Plate extends StatelessWidget {
  const _Plate({required this.at, required this.scale});

  final Offset at;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final side = 12 * scale;
    return Positioned(
      left: at.dx - side / 2,
      top: at.dy - side / 2,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: 0.7853981633974483,
          child: Container(
            width: side,
            height: side,
            decoration: BoxDecoration(
              color: field.bg,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: field.lineStrong, width: 1.5),
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
    required this.base,
    required this.instant,
    required this.geometry,
    required this.onTap,
  });

  final String name;
  final int base;
  final bool instant;
  final FieldGeometry geometry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final on = base > 0;
    final at = on ? geometry.base(base) : geometry.home;
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
