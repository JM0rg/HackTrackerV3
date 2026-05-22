import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sync_providers.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../data/games_repository.dart';
import '../../domain/game.dart';
import '../widgets/game_card.dart';
import 'game_detail_screen.dart';
import 'game_edit_screen.dart';

/// Games tab: the full schedule across all of the user's teams.
class GamesListScreen extends ConsumerWidget {
  const GamesListScreen({super.key});

  void _openCreate(BuildContext context) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => const GameEditScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  void _openDetail(BuildContext context, Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameDetailScreen(gameId: game.id)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesStreamProvider);

    return AppScaffold(
      title: 'Games',
      actions: const [SyncStatusIndicator()],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(syncEngineProvider).requestSync(),
        child: games.when(
          loading: () => const SkeletonLoader(),
          error: (e, _) => EmptyState.error(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.event_outlined,
                title: 'No games yet',
                message: 'Schedule a game to start tracking results.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => GameCard(
                game: list[i],
                onTap: () => _openDetail(context, list[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}
