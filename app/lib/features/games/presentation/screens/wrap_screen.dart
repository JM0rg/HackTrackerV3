import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/features/games/presentation/screens/box_score_screen.dart';
import 'package:hacktracker/features/games/presentation/widgets/line_score.dart';
import 'package:hacktracker/features/games/presentation/widgets/share_card.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/last_play_line.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

/// The finish. Your line is the headline, the game is a card under it, and
/// the at-bats are hairline rows. Share is the system icon; Done is a word.
class WrapScreen extends ConsumerStatefulWidget {
  const WrapScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<WrapScreen> createState() => _WrapScreenState();
}

class _WrapScreenState extends ConsumerState<WrapScreen> {
  final _cardKey = GlobalKey();

  void _home(FieldModeState state) => context.go(state.personal ? '/' : '/team');

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fieldModeProvider(widget.gameId));
    final state = async.valueOrNull;
    if (state == null) {
      return Scaffold(
        body: Center(child: async.hasError ? Text('${async.error}') : null),
      );
    }
    final colors = context.colors;
    final s = context.themeSpacing;
    final game = state.game;
    final replay = state.replay;
    final innings =
        ref.watch(gameInningsStreamProvider(widget.gameId)).valueOrNull ?? const [];
    final opponent = game.opponentName?.trim();
    final when = game.startsAt == null ? '' : DateFormat.MMMd().format(game.startsAt!);

    final me = state.batter;
    final line = me == null ? null : state.lineFor(me.id);
    final rbi = replay.pas.fold<int>(0, (a, p) => a + p.rbi);
    final runs = replay.pas.fold<int>(0, (a, p) => a + p.runsScored);
    final personalHero = state.personal && line != null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key('wrap-share'),
                    onPressed: () => _shareFrom(state),
                    icon: const Icon(Icons.ios_share),
                    color: colors.muted,
                    tooltip: 'Share',
                  ),
                  Row(
                    children: [
                      PopupMenuButton<String>(
                        key: const Key('wrap-menu'),
                        icon: Icon(Icons.more_horiz, color: colors.muted),
                        onSelected: (v) async {
                          if (v == 'reopen') {
                            await ref
                                .read(scoringRepositoryProvider)
                                .reopenGame(game);
                          } else if (v == 'box' && context.mounted) {
                            context.push('/games/${widget.gameId}/box');
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'reopen', child: Text('Reopen game')),
                          PopupMenuItem(value: 'box', child: Text('Box score')),
                        ],
                      ),
                      TextButton(
                        key: const Key('wrap-done'),
                        onPressed: () => _home(state),
                        child: const Text('Done'),
                      ),
                      SizedBox(width: s.xs),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(s.md, s.sm, s.md, s.xl),
                children: [
                  Text(
                    [
                      if (game.playedForName != null) game.playedForName!,
                      if (opponent != null && opponent.isNotEmpty) 'vs $opponent',
                      when,
                    ].where((t) => t.isNotEmpty).join(' · '),
                    style: context.text.bodyMedium?.copyWith(color: colors.muted),
                  ),
                  SizedBox(height: s.xs),
                  if (personalHero) ...[
                    Text(
                      '${line.hits} for ${line.atBats}',
                      key: const Key('wrap-line'),
                      style: context.text.displayLarge
                          ?.copyWith(fontFeatures: tabularFigures),
                    ),
                    if (line.results.isNotEmpty) ...[
                      SizedBox(height: s.sm + 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [for (final r in line.results) HitTag(label: r)],
                      ),
                    ],
                    SizedBox(height: s.sm + 4),
                    Text(
                      [
                        '$rbi RBI',
                        '$runs run${runs == 1 ? '' : 's'}',
                        '${replay.plateAppearanceCount} plate appearance${replay.plateAppearanceCount == 1 ? '' : 's'}',
                      ].join(' · '),
                      style: context.text.bodyMedium?.copyWith(color: colors.muted),
                    ),
                  ] else
                    Text.rich(
                      TextSpan(
                        style: context.text.displayLarge
                            ?.copyWith(fontFeatures: tabularFigures),
                        children: [
                          TextSpan(
                            text: '${replay.ourRuns}',
                            style: TextStyle(color: colors.accent),
                          ),
                          const TextSpan(text: ' – '),
                          TextSpan(text: '${replay.theirRuns}'),
                        ],
                      ),
                    ),
                  if (state.tracksScore && personalHero) ...[
                    SizedBox(height: s.lg),
                    Surface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text.rich(
                                TextSpan(
                                  style: context.text.headlineLarge
                                      ?.copyWith(fontFeatures: tabularFigures),
                                  children: [
                                    TextSpan(
                                      text: '${replay.ourRuns}',
                                      style: TextStyle(color: colors.accent),
                                    ),
                                    const TextSpan(text: ' – '),
                                    TextSpan(text: '${replay.theirRuns}'),
                                  ],
                                ),
                              ),
                              Text('Final', style: context.text.bodySmall),
                            ],
                          ),
                          if (innings.isNotEmpty) ...[
                            SizedBox(height: s.sm),
                            LineScore(innings: innings, game: game),
                          ],
                        ],
                      ),
                    ),
                  ] else if (state.tracksScore && innings.isNotEmpty) ...[
                    SizedBox(height: s.lg),
                    Surface(child: LineScore(innings: innings, game: game)),
                  ],
                  if (!state.personal) ...[
                    SizedBox(height: s.lg),
                    _BattingLines(state: state),
                  ],
                  if (replay.pas.isNotEmpty) ...[
                    SizedBox(height: s.lg),
                    for (final pa in replay.pas.reversed.take(state.personal ? 12 : 8))
                      _PlayRow(state: state, pa: pa),
                  ],
                  // Rendered off-screen so Share has something to capture.
                  if (personalHero)
                    Offstage(
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: SizedBox(
                          width: 320,
                          child: ShareCard(
                            eyebrow: [
                              if (game.playedForName != null) game.playedForName!,
                              if (opponent != null && opponent.isNotEmpty)
                                'vs $opponent',
                            ].join(' · '),
                            headline: '${line.hits} for ${line.atBats}',
                            tags: line.results,
                            line: _shareLine(state, rbi, runs),
                            who: me?.firstName ?? 'You',
                            sub: [
                              if (game.playedForName != null) game.playedForName!,
                              when,
                            ].where((t) => t.isNotEmpty).join(' · '),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _shareLine(FieldModeState state, int rbi, int runs) {
    final r = state.replay;
    return [
      '$rbi RBI',
      '$runs run${runs == 1 ? '' : 's'}',
      if (state.tracksScore)
        '${r.ourRuns > r.theirRuns ? 'won' : r.ourRuns < r.theirRuns ? 'lost' : 'tied'} ${r.ourRuns}–${r.theirRuns}',
    ].join(' · ');
  }

  void _shareFrom(FieldModeState state) {
    final me = state.batter;
    final line = me == null ? null : state.lineFor(me.id);
    final rbi = state.replay.pas.fold<int>(0, (a, p) => a + p.rbi);
    final runs = state.replay.pas.fold<int>(0, (a, p) => a + p.runsScored);
    unawaited(_share(state, line, rbi, runs));
  }

  Future<void> _share(
    FieldModeState state,
    ({int hits, int atBats, List<String> results})? line,
    int rbi,
    int runs,
  ) async {
    if (state.personal && line != null) {
      final opponent = state.game.opponentName?.trim();
      final text = [
        '${line.hits} for ${line.atBats}',
        if (line.results.isNotEmpty) line.results.join(' '),
        '$rbi RBI',
        if (opponent != null && opponent.isNotEmpty) 'vs $opponent',
      ].join(' · ');
      await shareBoundaryAsImage(_cardKey, text: text);
      return;
    }
    final pas =
        await ref.read(scoringRepositoryProvider).plateAppearances(widget.gameId);
    final innings =
        await ref.read(scoringRepositoryProvider).watchInnings(widget.gameId).first;
    await SharePlus.instance.share(
      ShareParams(text: boxScoreText(pas, state.roster, innings, state.game)),
    );
  }
}

class _PlayRow extends StatelessWidget {
  const _PlayRow({required this.state, required this.pa});

  final FieldModeState state;
  final dynamic pa;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isOut = pa.effective.recordsOut as bool;
    return Column(
      children: [
        const Hairline(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  pa.effective.label as String,
                  style: context.text.labelMedium?.copyWith(
                    color: isOut ? colors.danger : colors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  LastPlayLine.describe(state, pa),
                  style: context.text.bodyMedium,
                ),
              ),
              if (state.tracksScore)
                Text(_ordinal(pa.inning as int), style: context.text.labelSmall),
            ],
          ),
        ),
      ],
    );
  }

  String _ordinal(int n) {
    final suffix = switch (n % 10) {
      1 when n % 100 != 11 => 'st',
      2 when n % 100 != 12 => 'nd',
      3 when n % 100 != 13 => 'rd',
      _ => 'th',
    };
    return '$n$suffix';
  }
}

class _BattingLines extends StatelessWidget {
  const _BattingLines({required this.state});

  final FieldModeState state;

  @override
  Widget build(BuildContext context) {
    final rolled = const StatsAggregator().rollup([
      for (final pa in state.replay.pas)
        PaInput(
          playerId: pa.playerId,
          result: pa.effective,
          rbi: pa.rbi,
          runsScored: pa.runsScored,
        ),
    ]);
    return Surface(
      child: Column(
        children: [
          for (final entry in rolled.values.toList().asMap().entries) ...[
            if (entry.key > 0) const Hairline(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.playerById(entry.value.playerId)?.firstName ?? 'Unknown',
                      style: context.text.bodyMedium,
                    ),
                  ),
                  Text(
                    '${entry.value.hits}-${entry.value.atBats}',
                    style: context.text.titleSmall
                        ?.copyWith(fontFeatures: tabularFigures),
                  ),
                  SizedBox(width: context.themeSpacing.sm),
                  SizedBox(
                    width: 52,
                    child: Text(
                      '${entry.value.rbi} RBI',
                      textAlign: TextAlign.right,
                      style: context.text.labelSmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
