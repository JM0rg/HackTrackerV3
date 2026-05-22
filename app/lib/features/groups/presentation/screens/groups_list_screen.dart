import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sync_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../data/groups_repository.dart';
import '../../domain/group.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import 'group_edit_screen.dart';

/// Groups tab (seasons & tournaments) across all of the user's teams.
class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  void _openCreate(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const GroupEditScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openDetail(BuildContext context, Group group) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsStreamProvider);

    return AppScaffold(
      title: 'Groups',
      actions: const [SyncStatusIndicator()],
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
                title: 'No groups yet',
                message: 'Create a season or tournament to group games.',
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
