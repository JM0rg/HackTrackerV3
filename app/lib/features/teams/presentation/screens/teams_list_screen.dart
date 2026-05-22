import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/sync_providers.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../data/teams_repository.dart';
import '../widgets/team_card.dart';
import 'team_edit_screen.dart';

/// Lists the user's teams. The home tab of the app.
class TeamsListScreen extends ConsumerWidget {
  const TeamsListScreen({super.key});

  void _openCreate(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const TeamEditScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsStreamProvider);

    return AppScaffold(
      title: 'Teams',
      actions: const [SyncStatusIndicator()],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncEngineProvider).requestSync(),
        child: teams.when(
          loading: () => const SkeletonLoader(),
          error: (e, _) => EmptyState.error(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return const _EmptyTeams();
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => TeamCard(
                team: list[i],
                onTap: () => context.go(Routes.teamDetailPath(list[i].id)),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyTeams extends StatelessWidget {
  const _EmptyTeams();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.groups_outlined,
      title: 'No teams yet',
      message: 'Create your first team to start building rosters and games.',
    );
  }
}
