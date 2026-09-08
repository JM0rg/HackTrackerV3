import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// The score, big enough to read from the bench, with one pill for the
/// situation under it. Tap it to open the game log.
class ScoreHero extends StatefulWidget {
  const ScoreHero({
    super.key,
    required this.state,
    required this.onTap,
    this.onRun,
    this.onEndHalf,
  });

  final FieldModeState state;
  final VoidCallback? onTap;

  /// A personal game keeping score has no lineup to end its own half, so the
  /// situation row grows two pills: a teammate's run, and the end of the half.
  final ValueChanged<int>? onRun;
  final VoidCallback? onEndHalf;

  @override
  State<ScoreHero> createState() => _ScoreHeroState();
}

class _ScoreHeroState extends State<ScoreHero> {
  int? _lastUs;
  bool _pop = false;

  @override
  void initState() {
    super.initState();
    _lastUs = widget.state.replay.ourRuns;
  }

  @override
  void didUpdateWidget(ScoreHero old) {
    super.didUpdateWidget(old);
    final us = widget.state.replay.ourRuns;
    if (_lastUs != null && us > _lastUs!) {
      setState(() => _pop = true);
      Future<void>.delayed(const Duration(milliseconds: 220), () {
        if (mounted) setState(() => _pop = false);
      });
    }
    _lastUs = us;
  }

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final state = widget.state;
    final replay = state.replay;
    final theirs = state.tracksScore && !replay.weBat;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tap a score to add a run in a game with no lineup to count outs.
        Semantics(
          button: widget.onRun != null,
          label: 'Us ${replay.ourRuns}, them ${replay.theirRuns}',
          excludeSemantics: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _Number(
                key: const Key('us-runs'),
                value: replay.ourRuns,
                color: field.accent,
                pop: _pop,
                onTap: widget.onRun == null ? null : () => widget.onRun!(1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '–',
                  style: context.text.headlineSmall?.copyWith(
                    color: field.muted,
                  ),
                ),
              ),
              _Number(
                key: const Key('them-runs'),
                value: replay.theirRuns,
                color: field.on,
                pop: false,
                onTap: null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Situation(
          state: state,
          theirs: theirs,
          onEndHalf: widget.onEndHalf,
          onOpenLog: widget.onTap,
        ),
      ],
    );
  }
}

/// The score itself. Tapping ours adds a teammate's run where that applies.
class _Number extends StatelessWidget {
  const _Number({
    super.key,
    required this.value,
    required this.color,
    required this.pop,
    required this.onTap,
  });

  final int value;
  final Color color;
  final bool pop;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        scale: pop ? 1.12 : 1,
        child: Text(
          '$value',
          style: context.text.displayMedium?.copyWith(
            color: color,
            fontFeatures: tabularFigures,
          ),
        ),
      ),
    );
  }
}

/// One quiet line under the score. Swipe it to end our half where that
/// applies; tap it for the log.
class _Situation extends StatelessWidget {
  const _Situation({
    required this.state,
    required this.theirs,
    required this.onEndHalf,
    required this.onOpenLog,
  });

  final FieldModeState state;
  final bool theirs;
  final VoidCallback? onEndHalf;
  final VoidCallback? onOpenLog;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final replay = state.replay;
    final opponent = state.game.opponentName?.trim();

    final where = <String>[];
    if (state.tracksScore) {
      where.add('${replay.half == 'top' ? 'Top' : 'Bot'} ${replay.inning}');
      if (theirs) {
        where.add('they bat');
      } else if (!state.personal) {
        where.add('${replay.outs} out');
      }
    }
    if (opponent != null && opponent.isNotEmpty) where.add(opponent);
    if (where.isEmpty) where.add('Personal game');

    return GestureDetector(
      key: const Key('situation'),
      onTap: onOpenLog,
      onHorizontalDragEnd: onEndHalf == null
          ? null
          : (d) {
              if (d.primaryVelocity != null && d.primaryVelocity!.abs() > 150) {
                onEndHalf!();
              }
            },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: where.first,
                style: TextStyle(
                  color: theirs ? field.onOut : field.on,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (where.length > 1)
                TextSpan(text: ' · ${where.skip(1).join(' · ')}'),
            ],
          ),
          style: context.text.bodyMedium?.copyWith(color: field.muted),
        ),
      ),
    );
  }
}
