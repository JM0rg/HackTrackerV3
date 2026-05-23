import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sync_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../teams/data/teams_repository.dart';
import '../../data/groups_repository.dart';
import '../../domain/group.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'group_edit_screen.dart';

/// Seasons & tournaments manager for the current team. Reached from the
/// Games tab's app-bar action. Not a top-level tab — groups are an
/// organizational aid for games, not a peer concept.
class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  void _openCreate(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const GroupEditScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openDetail(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupDetailScreen(groupId: group.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);

    if (teamId == null) {
      return const AppScaffold(
        title: 'Seasons & Tournaments',
        body: EmptyState(
          icon: Icons.emoji_events_outlined,
          title: 'No team selected',
          message: 'Switch to a team to manage its seasons and tournaments.',
        ),
      );
    }

    final groups = ref.watch(groupsForTeamProvider(teamId));

    return AppScaffold(
      title: 'Seasons & Tournaments',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncEngineProvider).requestSync(),
        child: groups.when(
          loading: () => const SkeletonLoader(),
          error: (e, _) => EmptyState.error(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No seasons or tournaments yet',
                message: 'Create one to group games for standings and stats.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => GroupCard(
                group: list[i],
                onTap: () => _openDetail(context, list[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}
