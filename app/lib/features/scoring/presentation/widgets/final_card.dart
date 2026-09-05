import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// Shown once a game is marked final. Reopening is one tap, not a menu dive.
class FinalCard extends StatelessWidget {
  const FinalCard({
    super.key,
    required this.state,
    required this.onReopen,
    required this.onBoxScore,
  });

  final FieldModeState state;
  final VoidCallback onReopen;
  final VoidCallback onBoxScore;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final spacing = context.themeSpacing;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FINAL',
            style: context.text.labelMedium?.copyWith(
              color: field.muted,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: spacing.sm),
          Text.rich(
            TextSpan(
              style: context.text.displaySmall?.copyWith(
                color: field.on,
                fontSize: 52,
                fontFeatures: tabularFigures,
              ),
              children: [
                TextSpan(
                  text: '${state.replay.ourRuns}',
                  style: TextStyle(color: field.accent),
                ),
                const TextSpan(text: ' – '),
                TextSpan(text: '${state.replay.theirRuns}'),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          Text(
            state.game.opponentName ?? 'Game complete',
            style: context.text.bodyMedium?.copyWith(color: field.muted),
          ),
          SizedBox(height: spacing.lg),
          FilledButton(
            onPressed: onBoxScore,
            style: FilledButton.styleFrom(
              backgroundColor: field.accent,
              foregroundColor: field.onAccent,
            ),
            child: const Text('Box score'),
          ),
          SizedBox(height: spacing.sm),
          OutlinedButton(
            onPressed: onReopen,
            style: OutlinedButton.styleFrom(
              foregroundColor: field.on,
              side: BorderSide(color: field.border),
            ),
            child: Text(
              'Reopen game',
              style: context.text.bodyMedium?.copyWith(color: field.on),
            ),
          ),
        ],
      ),
    );
  }
}
