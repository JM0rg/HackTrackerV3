import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../games/data/games_repository.dart';
import '../../../games/domain/game.dart';
import '../../data/groups_repository.dart';
import '../../domain/group.dart';
import 'group_edit_screen.dart';

/// Group home: summary, edit/delete, and toggling which of the team's games
/// belong to this group.
class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  void _edit(BuildContext context, Group group) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => GroupEditScreen(group: group),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete group?',
      message: 'This removes the group. Games stay on your schedule.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(groupsRepositoryProvider).softDelete(groupId);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupStreamProvider(groupId));
    final spacing = context.themeSpacing;

    return groupAsync.when(
      loading: () => const AppScaffold(title: 'Group', body: SizedBox()),
      error: (e, _) => AppScaffold(
        title: 'Group',
        body: EmptyState.error(message: '$e'),
      ),
      data: (group) {
        if (group == null) {
          return const AppScaffold(
            title: 'Group',
            body: EmptyState(icon: Icons.search_off, title: 'Group not found'),
          );
        }
        return AppScaffold(
          title: group.name,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, group),
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
                    Text(group.groupType.label, style: context.text.body),
                  ],
                ),
              ),
              SizedBox(height: spacing.lg),
              Text('Games in this group', style: context.text.label),
              SizedBox(height: spacing.sm),
              _GamesMembership(group: group),
              SizedBox(height: spacing.xl),
              AppButton(
                label: 'Delete group',
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

/// Lists the team's games with a switch reflecting group membership.
class _GamesMembership extends ConsumerWidget {
  const _GamesMembership({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamesAsync = ref.watch(gamesStreamProvider);
    final memberIdsAsync = ref.watch(groupGameIdsProvider(group.id));

    return gamesAsync.when(
      loading: () => const SkeletonLoader(count: 3),
      error: (e, _) => EmptyState.error(message: '$e'),
      data: (allGames) {
        final games = allGames.where((g) => g.teamId == group.teamId).toList();
        if (games.isEmpty) {
          return const EmptyState(
            icon: Icons.event_outlined,
            title: 'No games for this team',
            message: 'Schedule games to add them to this group.',
          );
        }
        final memberIds = memberIdsAsync.value ?? const <String>{};
        return Column(
          children: [
            for (final game in games) ...[
              _GameToggle(
                game: game,
                isMember: memberIds.contains(game.id),
                onToggle: (selected) {
                  final repo = ref.read(groupsRepositoryProvider);
                  if (selected) {
                    repo.linkGame(
                      gameId: game.id,
                      groupId: group.id,
                      teamId: group.teamId,
                    );
                  } else {
                    repo.unlinkGame(gameId: game.id, groupId: group.id);
                  }
                },
              ),
              SizedBox(height: context.themeSpacing.sm),
            ],
          ],
        );
      },
    );
  }
}

class _GameToggle extends StatelessWidget {
  const _GameToggle({
    required this.game,
    required this.isMember,
    required this.onToggle,
  });

  final Game game;
  final bool isMember;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final title = game.opponentName?.isNotEmpty == true
        ? game.opponentName!
        : 'TBD';
    final subtitle = [game.homeAway.label, game.status.label].join(' · ');

    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleM,
                ),
                Text(subtitle, style: context.text.caption),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          Switch(value: isMember, onChanged: onToggle),
        ],
      ),
    );
  }
}
