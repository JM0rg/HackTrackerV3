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
  final VoidCallback onTap;

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

    return Semantics(
      button: true,
      label: 'Us ${replay.ourRuns}, them ${replay.theirRuns}. Open game log',
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _Side(
                      label: 'US',
                      runs: replay.ourRuns,
                      color: field.accent,
                      pop: _pop,
                      numberKey: const Key('us-runs'),
                    ),
                  ),
                  Expanded(
                    child: _Side(
                      label: 'THEM',
                      runs: replay.theirRuns,
                      color: field.on,
                      pop: false,
                      numberKey: const Key('them-runs'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _SituationPill(state: state, theirs: theirs),
                  if (widget.onRun != null) ...[
                    const SizedBox(width: 6),
                    _ActionPill(
                      key: const Key('our-run'),
                      label: '+ RUN',
                      accent: true,
                      onTap: () => widget.onRun!(1),
                    ),
                  ],
                  if (widget.onEndHalf != null) ...[
                    const SizedBox(width: 6),
                    _ActionPill(
                      key: const Key('end-our-half'),
                      label: 'END HALF ›',
                      accent: false,
                      onTap: widget.onEndHalf!,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({
    required this.label,
    required this.runs,
    required this.color,
    required this.pop,
    required this.numberKey,
  });

  final String label;
  final int runs;
  final Color color;
  final bool pop;
  final Key numberKey;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Column(
      children: [
        AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: pop ? 1.16 : 1,
          child: Text(
            '$runs',
            key: numberKey,
            style: context.text.displaySmall?.copyWith(
              color: color,
              fontSize: 52,
              fontWeight: FontWeight.w600,
              height: 1,
              fontFeatures: tabularFigures,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.text.labelSmall?.copyWith(
            color: field.muted,
            letterSpacing: 2.4,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Half, inning and outs on a team. The opponent in a personal game, since
/// that is the thing you forget.
class _SituationPill extends StatelessWidget {
  const _SituationPill({required this.state, required this.theirs});

  final FieldModeState state;
  final bool theirs;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final replay = state.replay;

    final String text;
    final half = replay.half == 'top' ? 'TOP' : 'BOT';
    if (theirs) {
      text = '$half ${replay.inning} · THEY BAT';
    } else if (state.personal) {
      // No lineup, so no outs to count.
      text = '$half ${replay.inning}';
    } else {
      final outs = replay.outs;
      text = '$half ${replay.inning} · $outs OUT${outs == 1 ? '' : 'S'}';
    }

    return Container(
      key: const Key('situation'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theirs ? field.out : field.surfaceHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: context.text.labelSmall?.copyWith(
              color: theirs ? field.onOut : field.on,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              fontSize: 11,
            ),
          ),
          if (!state.personal && !theirs) ...[
            const SizedBox(width: 6),
            for (var i = 0; i < 3; i++)
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(left: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < replay.outs ? field.onOut : Colors.transparent,
                  border: Border.all(
                    color: i < replay.outs ? field.onOut : field.muted,
                    width: 1.2,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  const _ActionPill({
    super.key,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: field.lineStrong, width: 1.5),
          ),
          child: Text(
            label,
            style: context.text.labelSmall?.copyWith(
              color: accent ? field.accent : field.muted,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}
