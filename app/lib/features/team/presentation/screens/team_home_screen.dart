import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class TeamHomeScreen extends ConsumerWidget {
  const TeamHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsStreamProvider);
    return AppScaffold(
      title: 'Team',
      body: teams.when(
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: 'No team yet.',
              message: 'Optional. Create one when you want to score a full lineup.',
              actionLabel: 'New team',
              onAction: () => context.push('/team/edit'),
            );
          }
          final teamId = ref.watch(currentTeamIdProvider) ?? list.first.id;
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
          onChanged: (id) => ref.read(currentTeamIdProvider.notifier).state = id,
        ),
        SizedBox(height: s.md),
        AppButton(
          label: 'Start a game',
          onPressed: () => context.push('/games/new'),
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
              return const Text('No games yet.');
            }
            return Column(
              children: [
                for (final g in list)
                  Padding(
                    padding: EdgeInsets.only(bottom: s.sm),
                    child: AppCard(
                      onTap: () => context.push('/games/${g.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${g.status.toUpperCase()}  ${g.ourRuns}–${g.theirRuns}',
                            ),
                          ),
                          Text(g.park ?? ''),
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
