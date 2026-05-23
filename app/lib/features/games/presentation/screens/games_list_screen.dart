import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sync_providers.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../../groups/data/groups_repository.dart';
import '../../../groups/domain/group.dart';
import '../../../groups/presentation/screens/groups_list_screen.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../teams/presentation/widgets/team_selector.dart';
import '../../data/games_repository.dart';
import '../../domain/game.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';
import 'game_edit_screen.dart';

/// Games tab: the schedule for the currently selected team. A horizontal
/// filter chip strip narrows the list to a single season/tournament when
/// the team has any; an app-bar action opens the seasons/tournaments
/// manager.
class GamesListScreen extends ConsumerStatefulWidget {
  const GamesListScreen({super.key});

  @override
  ConsumerState<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends ConsumerState<GamesListScreen> {
  /// Selected group id for filtering. Null = "All games" (no filter).
  String? _selectedGroupId;

  void _openCreate(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => const GameEditScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openDetail(BuildContext context, Game game) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameDetailScreen(gameId: game.id),
      ),
    );
  }

  void _openGroupsManager(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const GroupsListScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(currentTeamIdProvider);

    if (teamId == null) {
      return const AppScaffold(
        titleWidget: TeamSelector(),
        body: EmptyState(
          icon: Icons.event_outlined,
          title: 'No team selected',
          message: 'Add a team from the dropdown above to schedule games.',
        ),
      );
    }

    final games = ref.watch(gamesForTeamProvider(teamId));
    final groups = ref.watch(groupsForTeamProvider(teamId)).value ?? const [];

    // Drop a stale filter if the chosen group no longer exists.
    if (_selectedGroupId != null &&
        !groups.any((g) => g.id == _selectedGroupId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedGroupId = null);
      });
    }

    final selectedGameIds = _selectedGroupId == null
        ? null
        : ref.watch(groupGameIdsProvider(_selectedGroupId!)).value;

    return AppScaffold(
      titleWidget: const TeamSelector(),
      padBody: false,
      actions: [
        const SyncStatusIndicator(),
        IconButton(
          icon: const Icon(Icons.emoji_events_outlined),
          tooltip: 'Seasons & tournaments',
          onPressed: () => _openGroupsManager(context),
        ),
      ],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (groups.isNotEmpty)
            _GroupFilterStrip(
              groups: groups,
              selectedId: _selectedGroupId,
              onSelected: (id) => setState(() => _selectedGroupId = id),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(syncEngineProvider).requestSync(),
              child: games.when(
                loading: () => const SkeletonLoader(),
                error: (e, _) => EmptyState.error(message: '$e'),
                data: (list) {
                  final filtered = selectedGameIds == null
                      ? list
                      : list
                            .where((g) => selectedGameIds.contains(g.id))
                            .toList();
                  if (filtered.isEmpty) {
                    return EmptyState(
                      icon: Icons.event_outlined,
                      title: _selectedGroupId == null
                          ? 'No games yet'
                          : 'No games in this group',
                      message: _selectedGroupId == null
                          ? 'Schedule a game to start tracking results.'
                          : 'Add games to this season or tournament from the '
                                'group detail screen.',
                    );
                  }
                  return ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.themeSpacing.md,
                      vertical: 16,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => GameCard(
                      game: filtered[i],
                      onTap: () => _openDetail(context, filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal scrolling filter chips: an "All" chip plus one per group.
class _GroupFilterStrip extends StatelessWidget {
  const _GroupFilterStrip({
    required this.groups,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Group> groups;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.sm,
        ),
        child: Row(
          children: [
            FilterChip(
              label: const Text('All'),
              selected: selectedId == null,
              onSelected: (_) => onSelected(null),
            ),
            for (final group in groups) ...[
              SizedBox(width: spacing.xs),
              FilterChip(
                label: Text(group.name),
                selected: selectedId == group.id,
                onSelected: (_) => onSelected(group.id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
