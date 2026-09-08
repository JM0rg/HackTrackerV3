import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/features/stats/presentation/providers/team_stats_providers.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class TeamStatsScreen extends ConsumerStatefulWidget {
  const TeamStatsScreen({super.key, this.initialCompetitionId});
  final String? initialCompetitionId;
  @override
  ConsumerState<TeamStatsScreen> createState() => _TeamStatsScreenState();
}

class _TeamStatsScreenState extends ConsumerState<TeamStatsScreen> {
  String? _competition;
  @override
  void initState() {
    super.initState();
    _competition = widget.initialCompetitionId;
  }

  @override
  Widget build(BuildContext context) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(
        title: 'Team stats',
        body: Center(child: Text('Create a team first.')),
      );
    }
    final roster =
        ref.watch(playersStreamProvider(teamId)).valueOrNull ?? const [];
    final names = {
      for (final p in roster) p.id: '${p.firstName} ${p.lastName}'.trim(),
    };
    final competitions =
        ref.watch(competitionsStreamProvider(teamId)).valueOrNull ?? const [];
    final selected = competitions.any((c) => c.id == _competition)
        ? _competition
        : null;
    final pas = ref.watch(
      teamStatRowsProvider((teamId: teamId, competitionId: selected)),
    );
    return AppScaffold(
      title: 'Team stats',
      actions: [
        IconButton(
          tooltip: 'Spray chart',
          icon: const Icon(Icons.scatter_plot),
          onPressed: () => context.push(
            '/spray?team=$teamId${selected == null ? '' : '&competition=$selected'}',
          ),
        ),
      ],
      body: pas.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Center(child: Text('$e')),
        data: (rows) {
          final rolled = const StatsAggregator().rollup([
            for (final pa in rows)
              PaInput(
                playerId: pa.playerId,
                result: PaResult.fromWire(pa.effectiveResult ?? pa.result),
                rbi: pa.rbi,
                runsScored: pa.runsScored,
              ),
          ]);
          final lines = rolled.values.toList()
            ..sort(
              (a, b) =>
                  (names[a.playerId] ?? '').compareTo(names[b.playerId] ?? ''),
            );
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                key: ValueKey(selected),
                initialValue: selected ?? '',
                decoration: const InputDecoration(labelText: 'Scorebook'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('All games')),
                  for (final c in competitions)
                    DropdownMenuItem(value: c.id, child: Text(c.name)),
                ],
                onChanged: (v) =>
                    setState(() => _competition = v == '' ? null : v),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: ScorebookLabel('Batting lines')),
                  Text('${rows.length} PA', style: context.text.bodySmall),
                ],
              ),
              const SizedBox(height: 12),
              if (lines.isEmpty)
                const ScorebookSurface(
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 44),
                      SizedBox(height: 16),
                      Text('No lines yet'),
                    ],
                  ),
                ),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: ScorebookSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                names[line.playerId] ?? 'Former player',
                                style: context.text.titleLarge,
                              ),
                            ),
                            Text(
                              rate(line.avg),
                              style: context.text.headlineMedium?.copyWith(
                                color: context.colors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${line.hits} hits / ${line.atBats} at-bats · ${line.plateAppearances} PA',
                          style: context.text.bodySmall,
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 20,
                          runSpacing: 14,
                          children: [
                            _stat(context, '1B', '${line.singles}'),
                            _stat(context, '2B', '${line.doubles}'),
                            _stat(context, '3B', '${line.triples}'),
                            _stat(context, 'HR', '${line.homeRuns}'),
                            _stat(context, 'RBI', '${line.rbi}'),
                            _stat(context, 'R', '${line.runs}'),
                            _stat(context, 'BB', '${line.walks}'),
                            _stat(context, 'K', '${line.strikeouts}'),
                            _stat(context, 'SF', '${line.sacFlies}'),
                            _stat(context, 'OBP', rate(line.obp)),
                            _stat(context, 'SLG', rate(line.slg)),
                            _stat(context, 'OPS', rate(line.ops)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String rate(double n) => n.toStringAsFixed(3).replaceFirst(RegExp(r'^0'), '');
  Widget _stat(BuildContext context, String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: context.text.titleMedium),
      const SizedBox(height: 3),
      Text(label, style: context.text.labelSmall),
    ],
  );
}
