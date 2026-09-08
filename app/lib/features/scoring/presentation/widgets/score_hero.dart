import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

class ScoreHero extends StatelessWidget {
  const ScoreHero({
    super.key,
    required this.state,
    required this.onTap,
    this.onRun,
    this.onEndHalf,
  });
  final FieldModeState state;
  final VoidCallback? onTap;
  final ValueChanged<int>? onRun;
  final VoidCallback? onEndHalf;

  @override
  Widget build(BuildContext context) {
    final f = context.colors.field;
    final r = state.replay;
    final theirs = !r.weBat;
    final opponent = state.game.opponentName?.trim();
    final where =
        '${r.half == 'top' ? 'Top' : 'Bot'} ${r.inning}${theirs
            ? ' · they bat'
            : !state.personal
            ? ' · ${r.outs} out'
            : ''}${opponent == null || opponent.isEmpty ? '' : ' · $opponent'}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
      decoration: BoxDecoration(
        color: f.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: f.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _Score(
                  key: const Key('us-runs'),
                  label: 'US',
                  value: r.ourRuns,
                  active: r.weBat,
                  onTap: onRun == null ? null : () => onRun!(1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Icon(
                      theirs
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 16,
                      color: f.accent,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${r.inning}'.padLeft(2, '0'),
                      style: context.text.titleMedium?.copyWith(
                        color: f.on,
                        fontFeatures: tabularFigures,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var i = 0; i < 3; i++)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < r.outs ? f.accent : f.lineStrong,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _Score(
                  key: const Key('them-runs'),
                  label: 'THEM',
                  value: r.theirRuns,
                  active: !r.weBat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            key: const Key('situation'),
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            onHorizontalDragEnd: onEndHalf == null
                ? null
                : (d) {
                    if ((d.primaryVelocity ?? 0).abs() > 150) onEndHalf!();
                  },
            child: SizedBox(
              height: 44,
              width: double.infinity,
              child: Center(
                child: Text(
                  where,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(color: f.muted),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  const _Score({
    super.key,
    required this.label,
    required this.value,
    required this.active,
    this.onTap,
  });
  final String label;
  final int value;
  final bool active;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final f = context.colors.field;
    return Semantics(
      label: '$label $value',
      button: onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: active ? f.accent : f.muted,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$value',
                style: context.text.displayMedium?.copyWith(
                  color: active ? f.accent : f.on,
                  fontFeatures: tabularFigures,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
