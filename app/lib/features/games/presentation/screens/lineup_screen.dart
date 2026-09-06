import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class LineupScreen extends ConsumerWidget {
  const LineupScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    final players = teamId == null
        ? const AsyncValue<List<Player>>.data([])
        : ref.watch(playersStreamProvider(teamId));
    final lineup = ref.watch(lineupStreamProvider(gameId));

    return AppScaffold(
      title: 'Lineup',
      leading: homeLeading(context),
      body: players.when(
        data: (roster) {
          return lineup.when(
            data: (slots) {
              final selected = slots.map((s) => s.playerId).toList();
              if (roster.isEmpty) {
                return EmptyState(
                  title: 'No players yet.',
                  message: 'Add the roster, then pick tonight’s order.',
                  actionLabel: 'Add players',
                  onAction: () => context.push('/players'),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        for (final p in roster)
                          CheckboxListTile(
                            value: selected.contains(p.id),
                            title: Text(
                              '${p.jerseyNumber ?? ''} ${p.firstName} ${p.lastName}'.trim(),
                            ),
                            subtitle: selected.contains(p.id)
                                ? Text('Bats ${selected.indexOf(p.id) + 1}')
                                : null,
                            onChanged: (v) async {
                              final next = [...selected];
                              if (v == true) {
                                next.add(p.id);
                              } else {
                                next.remove(p.id);
                              }
                              if (teamId != null) {
                                await ref.read(trackerRepositoryProvider).setLineup(
                                      teamId: teamId,
                                      gameId: gameId,
                                      playerIds: next,
                                    );
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.themeSpacing.md),
                    child: AppButton(
                      label: selected.isEmpty ? 'Pick at least one batter' : 'Start scoring',
                      onPressed: selected.isEmpty
                          ? null
                          : () => context.push('/games/$gameId/play'),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Text('$e'),
      ),
    );
  }
}
