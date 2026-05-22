import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/game.dart';

/// List row for a game: opponent, date, home/away, and a result/score chip
/// when the game is final.
class GameCard extends StatelessWidget {
  const GameCard({required this.game, required this.onTap, super.key});

  final Game game;
  final VoidCallback onTap;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'No date';
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${_months[local.month - 1]} ${local.day} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.themeSpacing;

    final subtitle = [
      _formatDate(game.startTime),
      game.homeAway.label,
    ].join(' · ');

    final isFinal = game.status == GameStatus.finalized;
    final hasScores = game.ourScore != null && game.oppScore != null;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  game.opponentName?.isNotEmpty == true
                      ? game.opponentName!
                      : 'TBD',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleM,
                ),
                Text(subtitle, style: context.text.caption),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          if (isFinal && hasScores)
            _ResultChip(
              result: game.result,
              ourScore: game.ourScore!,
              oppScore: game.oppScore!,
            )
          else
            _StatusChip(label: game.status.label),
          SizedBox(width: spacing.sm),
          Icon(Icons.chevron_right, color: colors.secondaryText),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.result,
    required this.ourScore,
    required this.oppScore,
  });

  final String? result;
  final int ourScore;
  final int oppScore;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    final bg = switch (result) {
      'W' => colors.success,
      'L' => colors.danger,
      _ => colors.secondaryText,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radii.sm),
      ),
      child: Text(
        '${result ?? '–'} $ourScore-$oppScore',
        style: context.text.label.copyWith(color: colors.onPrimary),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm,
        vertical: spacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radii.sm),
        border: Border.all(color: colors.border),
      ),
      child: Text(label, style: context.text.caption),
    );
  }
}
