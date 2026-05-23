import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../data/teams_repository.dart';
import '../screens/team_edit_screen.dart';

/// Dropdown shown in the app bar of team-scoped tabs. Tap the name to switch
/// teams or add a new one. When the user has no teams, collapses to an
/// "Add team" button.
class TeamSelector extends ConsumerWidget {
  const TeamSelector({super.key});

  static const _addSentinel = '__add_team__';

  void _openCreateTeam(BuildContext context, WidgetRef ref) {
    Navigator.of(context, rootNavigator: true)
        .push(
          MaterialPageRoute<String>(
            builder: (_) => const TeamEditScreen(),
            fullscreenDialog: true,
          ),
        )
        .then((createdId) {
          if (createdId != null) {
            ref.read(teamSelectionProvider.notifier).select(createdId);
          }
        });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsStreamProvider).value ?? const [];
    final current = ref.watch(currentTeamProvider);
    final colors = context.colors;
    final spacing = context.themeSpacing;

    if (teams.isEmpty) {
      return TextButton.icon(
        onPressed: () => _openCreateTeam(context, ref),
        icon: Icon(Icons.add, color: colors.primary),
        label: Text(
          'Add team',
          style: context.text.titleM.copyWith(color: colors.primary),
        ),
      );
    }

    return PopupMenuButton<String>(
      tooltip: 'Switch team',
      position: PopupMenuPosition.under,
      onSelected: (value) {
        if (value == _addSentinel) {
          _openCreateTeam(context, ref);
        } else {
          ref.read(teamSelectionProvider.notifier).select(value);
        }
      },
      itemBuilder: (_) => [
        for (final team in teams)
          PopupMenuItem<String>(
            value: team.id,
            child: Row(
              children: [
                Icon(
                  team.id == current?.id ? Icons.check : null,
                  size: 18,
                  color: colors.primary,
                ),
                SizedBox(width: spacing.sm),
                Flexible(
                  child: Text(team.name, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem<String>(
          value: _addSentinel,
          child: Row(
            children: [
              Icon(Icons.add, size: 18, color: colors.primary),
              SizedBox(width: spacing.sm),
              Text(
                'Add team',
                style: context.text.body.copyWith(color: colors.primary),
              ),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                current?.name ?? 'Select team',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.titleM,
              ),
            ),
            Icon(Icons.expand_more, color: colors.secondaryText),
          ],
        ),
      ),
    );
  }
}
