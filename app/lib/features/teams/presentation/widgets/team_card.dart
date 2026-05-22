import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/team.dart';

/// List row for a team.
class TeamCard extends StatelessWidget {
  const TeamCard({required this.team, required this.onTap, super.key});

  final Team team;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.themeSpacing;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colors.primary.withValues(alpha: 0.15),
            child: Icon(Icons.groups, color: colors.primary),
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleM,
                ),
                Text(team.teamType.label, style: context.text.caption),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colors.secondaryText),
        ],
      ),
    );
  }
}
