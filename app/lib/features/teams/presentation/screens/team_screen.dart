import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../../players/presentation/screens/players_list_screen.dart';
import '../../data/teams_repository.dart';
import '../../domain/team.dart';
import '../widgets/team_selector.dart';
import 'team_edit_screen.dart';

/// The "Team" tab. Settings + entry points (roster, edit, delete) for the
/// currently selected team. The team is chosen via the [TeamSelector] in the
/// app bar; switching teams swaps this screen's data automatically.
class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  void _openEdit(BuildContext context, Team team) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => TeamEditScreen(team: team),
        fullscreenDialog: true,
      ),
    );
  }

  void _openRoster(BuildContext context, Team team) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayersListScreen(teamId: team.id, teamName: team.name),
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Team team) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete ${team.name}?',
      message:
          'This removes the team and its roster from this device and the '
          'cloud. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(teamsRepositoryProvider).softDelete(team.id);
    // The currentTeam provider auto-shifts to the next team (or null).
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final team = ref.watch(currentTeamProvider);
    final spacing = context.themeSpacing;
    final colors = context.colors;

    if (team == null) {
      return const AppScaffold(
        titleWidget: TeamSelector(),
        body: EmptyState(
          icon: Icons.groups_outlined,
          title: 'No teams yet',
          message: 'Tap "Add team" above to create your first team.',
        ),
      );
    }

    return AppScaffold(
      titleWidget: const TeamSelector(),
      actions: const [SyncStatusIndicator()],
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(team.name, style: context.text.titleL),
                SizedBox(height: spacing.xs),
                Text(
                  team.teamType.label,
                  style: context.text.body.copyWith(
                    color: colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
          AppCard(
            onTap: () => _openRoster(context, team),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: colors.primary),
                SizedBox(width: spacing.md),
                Expanded(child: Text('Roster', style: context.text.titleM)),
                Icon(Icons.chevron_right, color: colors.secondaryText),
              ],
            ),
          ),
          SizedBox(height: spacing.md),
          AppCard(
            onTap: () => _openEdit(context, team),
            child: Row(
              children: [
                Icon(Icons.tune, color: colors.primary),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text('Edit team details', style: context.text.titleM),
                ),
                Icon(Icons.chevron_right, color: colors.secondaryText),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: 'Delete team',
            variant: AppButtonVariant.destructive,
            onPressed: () => _delete(context, ref, team),
          ),
        ],
      ),
    );
  }
}
