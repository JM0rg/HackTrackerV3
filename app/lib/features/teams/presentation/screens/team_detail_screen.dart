import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../players/presentation/screens/players_list_screen.dart';
import '../../data/teams_repository.dart';
import '../../domain/team.dart';
import 'team_edit_screen.dart';

/// Team home: summary plus entry points to the roster (and, later, the team's
/// games and lineups).
class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({required this.teamId, super.key});

  final String teamId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete team?',
      message:
          'This removes the team and its roster from your device and the '
          'cloud. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(teamsRepositoryProvider).softDelete(teamId);
    if (context.mounted) context.go(Routes.teams);
  }

  void _edit(BuildContext context, Team team) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => TeamEditScreen(team: team),
        fullscreenDialog: true,
      ),
    );
  }

  void _openRoster(BuildContext context, Team team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayersListScreen(teamId: team.id, teamName: team.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamAsync = ref.watch(teamStreamProvider(teamId));
    final spacing = context.themeSpacing;

    return teamAsync.when(
      loading: () => const AppScaffold(title: 'Team', body: SizedBox()),
      error: (e, _) => AppScaffold(
        title: 'Team',
        body: EmptyState.error(message: '$e'),
      ),
      data: (team) {
        if (team == null) {
          return const AppScaffold(
            title: 'Team',
            body: EmptyState(icon: Icons.search_off, title: 'Team not found'),
          );
        }
        return AppScaffold(
          title: team.name,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(Routes.teams),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, team),
            ),
          ],
          body: ListView(
            children: [
              SizedBox(height: spacing.md),
              AppCard(
                child: Row(
                  children: [
                    Text('Type', style: context.text.label),
                    const Spacer(),
                    Text(team.teamType.label, style: context.text.body),
                  ],
                ),
              ),
              SizedBox(height: spacing.md),
              AppCard(
                onTap: () => _openRoster(context, team),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: context.colors.primary),
                    SizedBox(width: spacing.md),
                    Expanded(child: Text('Roster', style: context.text.titleM)),
                    Icon(
                      Icons.chevron_right,
                      color: context.colors.secondaryText,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.xl),
              AppButton(
                label: 'Delete team',
                variant: AppButtonVariant.destructive,
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
        );
      },
    );
  }
}
