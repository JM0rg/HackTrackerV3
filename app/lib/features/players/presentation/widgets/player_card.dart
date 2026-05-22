import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/player.dart';

/// List row for a roster player.
class PlayerCard extends StatelessWidget {
  const PlayerCard({required this.player, required this.onTap, super.key});

  final Player player;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.themeSpacing;

    final details = <String>[
      if (player.bats != null) 'B:${player.bats!.label[0]}',
      if (player.throws != null) 'T:${player.throws!.label[0]}',
      player.status.label,
    ].join(' · ');

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.surface,
            child: Text(
              player.jerseyNumber?.isNotEmpty == true
                  ? player.jerseyNumber!
                  : '–',
              style: context.text.label,
            ),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleM,
                ),
                Text(details, style: context.text.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.secondaryText),
        ],
      ),
    );
  }
}
