import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/group.dart';

/// List row for a group: name, type, and league/location.
class GroupCard extends StatelessWidget {
  const GroupCard({required this.group, required this.onTap, super.key});

  final Group group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.themeSpacing;

    final details = <String>[
      group.groupType.label,
      if (group.leagueName?.isNotEmpty == true) group.leagueName!,
      if (group.location?.isNotEmpty == true) group.location!,
    ].join(' · ');

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            group.groupType == GroupType.tournament
                ? Icons.emoji_events_outlined
                : Icons.calendar_month_outlined,
            color: colors.primary,
          ),
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.name,
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
