import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../data/players_repository.dart';
import '../../domain/player.dart';
import '../widgets/player_card.dart';
import 'player_edit_screen.dart';

/// Roster for a team. Reached from the team detail screen.
class PlayersListScreen extends ConsumerWidget {
  const PlayersListScreen({
    required this.teamId,
    required this.teamName,
    super.key,
  });

  final String teamId;
  final String teamName;

  void _openEdit(BuildContext context, {Player? player}) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => PlayerEditScreen(teamId: teamId, player: player),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersForTeamProvider(teamId));

    return AppScaffold(
      title: '$teamName · Roster',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context),
        child: const Icon(Icons.person_add_alt),
      ),
      body: players.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) => EmptyState.error(message: '$e'),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.person_outline,
              title: 'No players yet',
              message: 'Add players to build your roster and lineups.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => PlayerCard(
              player: list[i],
              onTap: () => _openEdit(context, player: list[i]),
            ),
          );
        },
      ),
    );
  }
}
