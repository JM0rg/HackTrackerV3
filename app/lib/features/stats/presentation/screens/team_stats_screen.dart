import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class TeamStatsScreen extends ConsumerWidget {
  const TeamStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(
        title: 'Stats',
        body: Center(child: Text('Create a team first.')),
      );
    }
    final games = ref.watch(gamesStreamProvider(teamId));
    final players = ref.watch(playersStreamProvider(teamId));
    return AppScaffold(
      title: 'Stats',
      body: games.when(
        data: (glist) {
          return players.when(
            data: (roster) {
              return FutureBuilder<List<PlateAppearance>>(
                future: () async {
                  final repo = ref.read(scoringRepositoryProvider);
                  final all = <PlateAppearance>[];
                  for (final g in glist) {
                    all.addAll(await repo.plateAppearances(g.id));
                  }
                  return all;
                }(),
                builder: (context, snap) {
                  final list = snap.data ?? [];
                  final names = {
                    for (final p in roster)
                      p.id: '${p.firstName} ${p.lastName}'.trim(),
                  };
                  final rolled = const StatsAggregator().rollup([
                    for (final pa in list)
                      PaInput(
                        playerId: pa.playerId,
                        result: PaResult.fromWire(
                          pa.effectiveResult ?? pa.result,
                        ),
                        rbi: pa.rbi,
                        runsScored: pa.runsScored,
                      ),
                  ]);
                  if (rolled.isEmpty) {
                    return const EmptyState(
                      icon: Icons.bar_chart_rounded,
                      title: 'No lines yet',
                    );
                  }
                  return ListView(
                    children: [
                      for (final line in rolled.values)
                        ListTile(
                          title: Text(names[line.playerId] ?? line.playerId),
                          subtitle: Text(
                            '${line.hits}-${line.atBats}  HR ${line.homeRuns}  RBI ${line.rbi}  '
                            'OPS ${line.ops.toStringAsFixed(3)}',
                          ),
                        ),
                    ],
                  );
                },
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
