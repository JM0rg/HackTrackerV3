import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
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
          onPressed: () => context.push('/team/edit'),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
      body: teams.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.groups_outlined,
              title: 'No team yet',
              actionLabel: 'Create a team',
              onAction: () => context.push('/team/edit'),
            );
          }
          final selected = ref.watch(currentTeamIdProvider);
          final teamId = list.any((t) => t.id == selected)
              ? selected!
              : list.first.id;
          return _TeamHome(teamId: teamId, teams: list);
        },
        loading: () => const Center(child: SizedBox.shrink()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _TeamHome extends ConsumerWidget {
  const _TeamHome({required this.teamId, required this.teams});
  final String teamId;
  final List<Team> teams;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final games = ref.watch(gamesStreamProvider(teamId));
    final live = ref.watch(teamLiveGameProvider(teamId));
    final s = context.themeSpacing;
    return ListView(
      padding: EdgeInsets.all(s.md),
      children: [
        DropdownButton<String>(
          value: teamId,
          isExpanded: true,
          items: [
            for (final t in teams)
              DropdownMenuItem(value: t.id, child: Text(t.name)),
          ],
          onChanged: (id) =>
              ref.read(currentTeamIdProvider.notifier).state = id,
        ),
        if (live != null) ...[SizedBox(height: s.md), LiveCard(game: live)],
        SizedBox(height: s.md),
        AppButton(
          key: const Key('start-game'),
          label: 'Start a game',
          onPressed: () async {
            final id = await showStartSheet(context, teamId: teamId);
            if (id != null && context.mounted) context.push('/games/$id');
          },
        ),
        SizedBox(height: s.md),
        Wrap(
          spacing: s.sm,
          runSpacing: s.sm,
          children: [
            _Chip('Players', () => context.push('/players')),
            _Chip('Opponents', () => context.push('/opponents')),
            _Chip('Seasons / tourneys', () => context.push('/competitions')),
            _Chip('Stats', () => context.push('/team/stats')),
            _Chip('Settings', () => context.push('/team/settings')),
          ],
        ),
        SizedBox(height: s.lg),
        Text('Games', style: context.text.titleMedium),
        SizedBox(height: s.sm),
        games.when(
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.only(top: s.sm),
                child: Text(
                  'No games yet.',
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              );
            }
            return Column(
              children: [
                for (final g in list)
                  if (g.id != live?.id)
                    Padding(
                      padding: EdgeInsets.only(bottom: s.sm),
                      child: AppCard(
                        onTap: () => context.push('/games/${g.id}'),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 44,
                              child: Text(
                                g.startsAt == null
                                    ? ''
                                    : DateFormat(
                                        'MMM\nd',
                                      ).format(g.startsAt!).toUpperCase(),
                                style: context.text.labelSmall?.copyWith(
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                g.status == 'final'
                                    ? '${g.ourRuns > g.theirRuns
                                          ? 'Won'
                                          : g.ourRuns < g.theirRuns
                                          ? 'Lost'
                                          : 'Tied'} ${g.ourRuns}–${g.theirRuns}'
                                    : g.status,
                              ),
                            ),
                            Text(g.park ?? '', style: context.text.bodySmall),
                          ],
                        ),
                      ),
                    ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }
}
