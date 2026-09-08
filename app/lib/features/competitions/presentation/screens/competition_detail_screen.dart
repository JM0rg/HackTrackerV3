import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/features/competitions/presentation/providers/competition_providers.dart';
import 'package:hacktracker/features/games/presentation/widgets/game_history_card.dart';

class CompetitionDetailScreen extends ConsumerWidget {
  const CompetitionDetailScreen({super.key, required this.competitionId});
  final String competitionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competition = ref.watch(competitionProvider(competitionId));
    final games = ref.watch(competitionGamesProvider(competitionId));
    return AppScaffold(
      title: 'Competition',
      body: competition.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (c) {
          if (c == null) {
            return const EmptyState(
              icon: Icons.emoji_events_outlined,
              title: 'Competition not found',
            );
          }
          final team = ref
              .watch(teamsStreamProvider)
              .valueOrNull
              ?.where((t) => t.id == c.teamId)
              .firstOrNull;
          final list = games.valueOrNull ?? const [];
          final finalGames = list.where((g) => g.status == 'final');
          final wins = finalGames.where((g) => g.ourRuns > g.theirRuns).length;
          final losses = finalGames
              .where((g) => g.ourRuns < g.theirRuns)
              .length;
          final ties = finalGames.where((g) => g.ourRuns == g.theirRuns).length;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ScorebookSurface(
                accent: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          color: context.colors.accent,
                        ),
                        const SizedBox(width: 10),
                        ScorebookLabel(c.type, accent: true),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(c.name, style: context.text.displaySmall),
                    if (c.leagueName != null) ...[
                      const SizedBox(height: 8),
                      Text(c.leagueName!, style: context.text.bodySmall),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatColumn(value: '$wins', label: 'Wins'),
                        StatColumn(value: '$losses', label: 'Losses'),
                        StatColumn(value: '$ties', label: 'Ties'),
                        StatColumn(value: '${list.length}', label: 'Games'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ScorebookAction(
                icon: Icons.bar_chart_rounded,
                label: 'Competition stats',
                onTap: () {
                  ref.read(currentTeamIdProvider.notifier).state = c.teamId;
                  context.push('/team/stats?competition=${c.id}');
                },
              ),
              const SizedBox(height: 28),
              const ScorebookLabel('Game log'),
              const SizedBox(height: 12),
              if (games.hasError) Text('${games.error}'),
              if (games.hasValue && list.isEmpty)
                const ScorebookSurface(
                  child: Text('No games in this competition yet.'),
                ),
              for (final game in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: GameHistoryCard(
                    game: game,
                    teamName: team?.name ?? 'Your team',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
