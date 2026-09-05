import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:intl/intl.dart';
import 'package:hacktracker/core/domain/models/you_filter.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(ensureMeProvider);
    final games = ref.watch(myGamesStreamProvider);
    final teams = ref.watch(myTeamsStreamProvider);
    final pas = ref.watch(myPaRowsStreamProvider);
    final filter = ref.watch(youFilterProvider);
    final s = context.themeSpacing;

    return AppScaffold(
      title: 'You',
      actions: [
        IconButton(
          tooltip: 'Edit name',
          onPressed: () => _editName(context, ref, me.valueOrNull),
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
      body: me.when(
        data: (person) {
          final myTeams = teams.valueOrNull ?? const <Team>[];
          final line = ref.read(meRepositoryProvider).careerLine(
                pas.valueOrNull ?? const [],
                filter,
                person.id,
              );
          final visibleGames = _filteredGames(games.valueOrNull ?? const [], filter);
          return ListView(
            padding: EdgeInsets.all(s.md),
            children: [
              Text(person.displayName, style: context.text.titleMedium),
              SizedBox(height: s.sm),
              _CareerStrip(line: line),
              if (myTeams.isNotEmpty) ...[
                SizedBox(height: s.md),
                Wrap(
                  spacing: s.sm,
                  runSpacing: s.sm,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: filter.kind == YouFilterKind.all,
                      onSelected: (_) =>
                          ref.read(youFilterProvider.notifier).state = const YouFilter.all(),
                    ),
                    FilterChip(
                      label: const Text('Free agent'),
                      selected: filter.kind == YouFilterKind.personal,
                      onSelected: (_) =>
                          ref.read(youFilterProvider.notifier).state = const YouFilter.personal(),
                    ),
                    for (final team in myTeams)
                      FilterChip(
                        label: Text(team.name),
                        selected: filter.kind == YouFilterKind.team && filter.teamId == team.id,
                        onSelected: (_) =>
                            ref.read(youFilterProvider.notifier).state = YouFilter.team(team.id),
                      ),
                  ],
                ),
              ],
              SizedBox(height: s.md),
              AppButton(
                label: 'Log my game',
                onPressed: () => context.push('/games/personal/new'),
              ),
              SizedBox(height: s.md),
              Text('My games', style: context.text.titleMedium),
              SizedBox(height: s.sm),
              if (visibleGames.isEmpty)
                const Text('No games yet.')
              else
                for (final g in visibleGames)
                  Padding(
                    padding: EdgeInsets.only(bottom: s.sm),
                    child: AppCard(
                      onTap: () => context.push('/games/${g.id}'),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(_gameLabel(g)),
                          ),
                          if (g.scope == GameScope.game)
                            Text('${g.ourRuns}–${g.theirRuns}')
                          else
                            Text('at-bats', style: context.text.bodySmall),
                        ],
                      ),
                    ),
                  ),
            ],
          );
        },
        loading: () => const Center(child: SizedBox.shrink()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  List<Game> _filteredGames(List<Game> games, YouFilter filter) {
    return switch (filter.kind) {
      YouFilterKind.all => games,
      YouFilterKind.personal => games.where((g) => g.kind == GameKind.personal).toList(),
      YouFilterKind.team => games.where((g) => g.teamId == filter.teamId).toList(),
    };
  }

  String _gameLabel(Game game) {
    final opponent = game.opponentName;
    final vs = opponent != null && opponent.isNotEmpty
        ? opponent
        : (game.startsAt == null ? 'Game' : DateFormat.MMMd().format(game.startsAt!));
    if (game.kind == GameKind.personal) {
      final pickup = game.playedForName;
      if (pickup != null && pickup.isNotEmpty) return '$vs · $pickup';
      return '$vs · Free agent';
    }
    return '${game.status.toUpperCase()}  $vs';
  }

  Future<void> _editName(BuildContext context, WidgetRef ref, Person? person) async {
    final first = TextEditingController(text: person?.firstName ?? '');
    final last = TextEditingController(text: person?.lastName ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.themeSpacing.md,
            context.themeSpacing.md,
            context.themeSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + context.themeSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'First name', controller: first),
              SizedBox(height: context.themeSpacing.sm),
              AppTextField(label: 'Last name', controller: last),
              SizedBox(height: context.themeSpacing.md),
              AppButton(
                label: 'Save',
                onPressed: () async {
                  await ref.read(meRepositoryProvider).updateMe(
                        firstName: first.text,
                        lastName: last.text,
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CareerStrip extends StatelessWidget {
  const _CareerStrip({required this.line});
  final PlayerLine? line;

  @override
  Widget build(BuildContext context) {
    final l = line;
    if (l == null) {
      return Text('Log a game to start your line.', style: context.text.bodySmall);
    }
    return AppCard(
      child: Text(
        '${l.hits}-${l.atBats}  AVG ${l.avg.toStringAsFixed(3)}  '
        'OPS ${l.ops.toStringAsFixed(3)}  HR ${l.homeRuns}  RBI ${l.rbi}',
        style: context.text.titleSmall,
      ),
    );
  }
}
