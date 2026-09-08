import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/widgets/start_sheet.dart';
import 'package:intl/intl.dart';

final allGamesProvider = StreamProvider<List<Game>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.games)
        ..where((g) => g.deletedAt.isNull())
        ..orderBy([
          (g) => OrderingTerm.desc(g.startsAt),
          (g) => OrderingTerm.desc(g.createdAt),
        ]))
      .watch();
});

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});
  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  String _filter = 'All';

  Future<void> _start() async {
    final teams = ref.read(teamsStreamProvider).valueOrNull ?? const <Team>[];
    final selected = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Who are you scoring for?'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Just my at-bats'),
              onTap: () => Navigator.pop(context, 'personal'),
            ),
            for (final team in teams)
              ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(team.name),
                onTap: () => Navigator.pop(context, team.id),
              ),
          ],
        ),
      ),
    );
    if (!mounted || selected == null) return;
    final id = await showStartSheet(
      context,
      teamId: selected == 'personal' ? null : selected,
    );
    if (mounted && id != null) context.push('/games/$id');
  }

  @override
  Widget build(BuildContext context) {
    final games = ref.watch(allGamesProvider);
    final teams = ref.watch(teamsStreamProvider).valueOrNull ?? const <Team>[];
    final names = {for (final t in teams) t.id: t.name};
    return AppScaffold(
      title: 'Games',
      actions: [
        IconButton(
          tooltip: 'Account & settings',
          icon: const Icon(Icons.tune_rounded),
          onPressed: () => context.push('/more'),
        ),
      ],
      body: games.when(
        loading: () => const SizedBox.shrink(),
        error: (error, _) =>
            Center(child: Text('Could not read games: $error')),
        data: (all) {
          final visible = all
              .where(
                (g) => switch (_filter) {
                  'Live' => g.status == 'live',
                  'Final' => g.status == 'final',
                  'Personal' => g.kind == GameKind.personal,
                  _ => true,
                },
              )
              .toList();
          visible.sort((a, b) {
            final priority = (a.status == 'live' ? 0 : 1).compareTo(
              b.status == 'live' ? 0 : 1,
            );
            return priority != 0
                ? priority
                : (b.startsAt ?? b.createdAt).compareTo(
                    a.startsAt ?? a.createdAt,
                  );
          });
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: visible.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(label: 'Start a game', onPressed: _start),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final label in [
                          'All',
                          'Live',
                          'Final',
                          'Personal',
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: _filter == label,
                            onSelected: (_) => setState(() => _filter = label),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          all.isEmpty
                              ? 'Every game, across every team. Start one when you’re ready.'
                              : 'No games in this view yet.',
                          style: context.text.bodyLarge,
                        ),
                      ),
                  ],
                );
              }
              final game = visible[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => context.push('/games/${game.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              game.kind == GameKind.personal
                                  ? (game.playedForName ?? 'Your at-bats')
                                  : (names[game.teamId] ?? 'Team game'),
                              style: context.text.titleMedium,
                            ),
                          ),
                          Text(
                            game.status == 'live'
                                ? 'LIVE'
                                : game.status.toUpperCase(),
                            style: context.text.labelSmall?.copyWith(
                              color: game.status == 'live'
                                  ? context.colors.accent
                                  : context.colors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${DateFormat('EEE, MMM d').format((game.startsAt ?? game.createdAt).toLocal())}${game.park == null ? '' : ' · ${game.park}'}',
                        style: context.text.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        game.kind == GameKind.personal && game.scope == 'bat'
                            ? 'Personal scorebook'
                            : '${game.ourRuns} – ${game.theirRuns}',
                        style: context.text.headlineMedium,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
