import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/widgets/line_score.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';
import 'package:share_plus/share_plus.dart';

class BoxScoreScreen extends ConsumerWidget {
  const BoxScoreScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pas = ref.watch(paStreamProvider(gameId));
    final players = ref.watch(gamePlayersStreamProvider(gameId));
    final innings = ref.watch(gameInningsStreamProvider(gameId));
    final game = ref.watch(gameStreamProvider(gameId)).valueOrNull;

    return AppScaffold(
      title: 'Box score',
      leading: homeLeading(context),
      actions: [
        IconButton(
          tooltip: 'Share',
          icon: const Icon(Icons.ios_share),
          onPressed: () async {
            final text = boxScoreText(
              pas.valueOrNull ?? const [],
              players.valueOrNull ?? const [],
              innings.valueOrNull ?? const [],
              game,
            );
            await SharePlus.instance.share(ShareParams(text: text));
          },
        ),
      ],
      body: pas.when(
        data: (list) {
          return players.when(
            data: (roster) {
              final names = {
                for (final p in roster)
                  p.id: '${p.firstName} ${p.lastName}'.trim(),
              };
              final rolled = const StatsAggregator().rollup([
                for (final pa in list)
                  PaInput(
                    playerId: pa.playerId,
                    result: PaResult.fromWire(pa.effectiveResult ?? pa.result),
                    rbi: pa.rbi,
                    runsScored: pa.runsScored,
                  ),
              ]);
              if (rolled.isEmpty) {
                return const EmptyState(
                  icon: Icons.sports_baseball_outlined,
                  title: 'No plays yet',
                );
              }
              return ListView(
                padding: EdgeInsets.all(context.themeSpacing.md),
                children: [
                  if (game != null)
                    LineScore(
                      innings: innings.valueOrNull ?? const [],
                      game: game,
                    ),
                  SizedBox(height: context.themeSpacing.md),
                  for (final line in rolled.values)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(names[line.playerId] ?? 'Unknown'),
                      subtitle: Text(
                        '${line.hits}-${line.atBats}  HR ${line.homeRuns}  '
                        'RBI ${line.rbi}  R ${line.runs}  '
                        'AVG ${line.avg.toStringAsFixed(3)}  '
                        'OPS ${line.ops.toStringAsFixed(3)}',
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

/// Plain text for sharing: a readable summary, then CSV for spreadsheets.
String boxScoreText(
  List<PlateAppearance> pas,
  List<Player> roster,
  List<GameInning> innings,
  Game? game,
) {
  final names = {
    for (final p in roster) p.id: '${p.firstName} ${p.lastName}'.trim(),
  };
  final rolled = const StatsAggregator().rollup([
    for (final pa in pas)
      PaInput(
        playerId: pa.playerId,
        result: PaResult.fromWire(pa.effectiveResult ?? pa.result),
        rbi: pa.rbi,
        runsScored: pa.runsScored,
      ),
  ]);
  final buf = StringBuffer('HackTracker box score\n');
  if (game != null) {
    buf.writeln(
      '${game.opponentName ?? 'Game'}  ${game.ourRuns}-${game.theirRuns}',
    );
  }
  buf.writeln();
  for (final line in rolled.values) {
    buf.writeln(
      '${names[line.playerId] ?? line.playerId}: ${line.hits}-${line.atBats}, '
      '${line.homeRuns} HR, ${line.rbi} RBI, ${line.runs} R',
    );
  }
  buf.writeln();
  buf.writeln('player,ab,h,hr,rbi,r,bb,k');
  for (final line in rolled.values) {
    buf.writeln(
      '${names[line.playerId] ?? line.playerId},${line.atBats},${line.hits},'
      '${line.homeRuns},${line.rbi},${line.runs},${line.walks},${line.strikeouts}',
    );
  }
  return buf.toString();
}
