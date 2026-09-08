import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/core/widgets/diamond_glyph.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/widgets/live_card.dart';
import 'package:hacktracker/features/games/presentation/widgets/start_sheet.dart';
import 'package:intl/intl.dart';

class TeamHomeScreen extends ConsumerWidget {
  const TeamHomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsStreamProvider);
    return AppScaffold(
      title: 'Teams',
      actions: [
        IconButton(
          tooltip: 'Create a team',
          icon: const Icon(Icons.add_rounded),
          onPressed: () => context.push('/team/edit'),
        ),
      ],
      body: teams.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ScorebookSurface(
                  accent: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ScorebookLabel('Team scorebook', accent: true),
                      const SizedBox(height: 24),
                      Text(
                        'Your lineup.\nYour club.',
                        style: context.text.displaySmall,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(child: DiamondGlyph(size: 170)),
                      ),
                      AppButton(
                        label: 'Create a team',
                        onPressed: () => context.push('/team/edit'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          final selected = ref.watch(currentTeamIdProvider);
          final team =
              list.where((t) => t.id == selected).firstOrNull ?? list.first;
          return _TeamHome(team: team, teams: list);
        },
      ),
    );
  }
}

class _TeamHome extends ConsumerWidget {
  const _TeamHome({required this.team, required this.teams});
  final Team team;
  final List<Team> teams;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesStreamProvider(team.id));
    final live = ref.watch(teamLiveGameProvider(team.id));
    final completed = (games.valueOrNull ?? const <Game>[]).where(
      (g) => g.status == 'final',
    );
    final wins = completed.where((g) => g.ourRuns > g.theirRuns).length;
    final losses = completed.where((g) => g.ourRuns < g.theirRuns).length;
    final ties = completed.where((g) => g.ourRuns == g.theirRuns).length;
    void open(String path) {
      ref.read(currentTeamIdProvider.notifier).state = team.id;
      context.push(path);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        if (teams.length > 1) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final t in teams)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(t.name),
                      selected: t.id == team.id,
                      onSelected: (_) =>
                          ref.read(currentTeamIdProvider.notifier).state = t.id,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ScorebookSurface(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.colors.accent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      team.name.trim().isEmpty
                          ? 'HT'
                          : team.name
                                .trim()
                                .characters
                                .take(2)
                                .toString()
                                .toUpperCase(),
                      style: context.text.headlineSmall?.copyWith(
                        color: context.colors.onAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ScorebookLabel('Clubhouse', accent: true),
                        const SizedBox(height: 5),
                        Text(team.name, style: context.text.headlineMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatColumn(value: '$wins', label: 'Wins'),
                  StatColumn(value: '$losses', label: 'Losses'),
                  StatColumn(value: '$ties', label: 'Ties'),
                  StatColumn(value: '${completed.length}', label: 'Played'),
                ],
              ),
              const SizedBox(height: 24),
              AppButton(
                key: const Key('start-game'),
                label: 'Start a game',
                onPressed: () async {
                  final id = await showStartSheet(context, teamId: team.id);
                  if (id != null && context.mounted) context.push('/games/$id');
                },
              ),
            ],
          ),
        ),
        if (live != null) ...[const SizedBox(height: 16), LiveCard(game: live)],
        const SizedBox(height: 24),
        const ScorebookLabel('Manage team'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ScorebookAction(
                icon: Icons.groups_outlined,
                label: 'Roster',
                onTap: () => open('/players'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ScorebookAction(
                icon: Icons.bar_chart_rounded,
                label: 'Stats',
                onTap: () => open('/team/stats'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ScorebookAction(
          icon: Icons.emoji_events_outlined,
          label: 'Seasons & tournaments',
          onTap: () => open('/competitions'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ScorebookAction(
                icon: Icons.shield_outlined,
                label: 'Opponents',
                onTap: () => open('/opponents'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ScorebookAction(
                icon: Icons.tune_rounded,
                label: 'Rules',
                onTap: () => open('/team/settings'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const ScorebookLabel('Recent games'),
        const SizedBox(height: 12),
        games.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (list) => Column(
            children: [
              if (list.isEmpty)
                ScorebookSurface(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No games yet.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                ),
              for (final g in list.where((g) => g.id != live?.id).take(20))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AppCard(
                    onTap: () => context.push('/games/${g.id}'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.opponentName ?? 'Team game',
                                style: context.text.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'EEE, MMM d',
                                ).format((g.startsAt ?? g.createdAt).toLocal()),
                                style: context.text.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${g.ourRuns} – ${g.theirRuns}',
                          style: context.text.headlineSmall,
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: context.colors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              if (list.length > 20)
                TextButton(
                  onPressed: () => context.go('/games'),
                  child: const Text('All games'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
