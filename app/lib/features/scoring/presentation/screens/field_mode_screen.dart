import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/scoring/presentation/providers/field_mode_providers.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/batter_card.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_sheets.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/final_card.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/last_play_line.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/one_card_diamond.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/score_hero.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/their_half_card.dart';
import 'package:hacktracker/features/scoring/services/game_replay.dart';

/// Field Mode: one batter, one diamond, one drag.
class FieldModeScreen extends ConsumerWidget {
  const FieldModeScreen({super.key, required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final field = context.colors.field;
    final async = ref.watch(fieldModeProvider(gameId));

    return Scaffold(
      backgroundColor: field.bg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -1),
            radius: 1.1,
            colors: [field.glow, field.bg],
            stops: const [0, 0.6],
          ),
        ),
        child: SafeArea(
          child: async.when(
            data: (state) {
              if (state == null) {
                return _Message(
                  text: 'That game is gone.',
                  actionLabel: 'Back',
                  onAction: () => leave(context),
                );
              }
              return _FieldBody(state: state, gameId: gameId);
            },
            loading: () => const SizedBox.shrink(),
            error: (error, _) => _Message(
              text: 'Scoring could not load.\n$error',
              actionLabel: 'Back',
              onAction: () => leave(context),
            ),
          ),
        ),
      ),
    );
  }

  static void leave(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }
}

class _FieldBody extends ConsumerStatefulWidget {
  const _FieldBody({required this.state, required this.gameId});

  final FieldModeState state;
  final String gameId;

  @override
  ConsumerState<_FieldBody> createState() => _FieldBodyState();
}

class _FieldBodyState extends ConsumerState<_FieldBody> {
  /// True while the diamond is waiting on an answer. Undo would take back the
  /// wrong play, so the rest of the screen stands down.
  bool _awaitingAnswer = false;

  FieldModeState get state => widget.state;
  String get gameId => widget.gameId;

  static const _topRow = 40.0;
  static const _hero = 122.0;
  static const _card = 96.0;

  /// A personal game with no score gives the card the hero's room.
  static const _cardHero = 168.0;
  static const _lastLine = 30.0;
  static const _askRow = 40.0;
  static const _nextUp = 26.0;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final repo = ref.read(scoringRepositoryProvider);
    final theirs = state.tracksScore && !state.replay.weBat;
    final heroHeight = state.tracksScore ? _hero : 0.0;
    final cardHeight = state.tracksScore ? _card : _cardHero;
    // Only a personal game keeping score ends its own half by hand.
    final byHand = state.personal && state.tracksScore && state.replay.weBat;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The diamond takes what the fixed rows leave, within reason.
        final spare = constraints.maxHeight -
            _topRow - heroHeight - cardHeight - _lastLine - _askRow - _nextUp - spacing.md * 2;
        final byHeight = spare * 280 / 240;
        final byWidth = constraints.maxWidth - spacing.md * 2;
        final width = math.min(byHeight, byWidth).clamp(190.0, 360.0);
        final geometry = FieldGeometry(width);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: _topRow,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => FieldModeScreen.leave(context),
                    icon: const Icon(Icons.close),
                    color: context.colors.field.muted,
                    tooltip: 'Leave scoring',
                  ),
                  IconButton(
                    onPressed: () => _openMenu(context, ref),
                    icon: const Icon(Icons.more_horiz),
                    color: context.colors.field.muted,
                    tooltip: 'Game menu',
                  ),
                ],
              ),
            ),
            if (!state.isFinal && state.tracksScore)
              SizedBox(
                height: _hero,
                child: Center(
                  child: ScoreHero(
                    state: state,
                    onTap: () => showLogSheet(context, gameId: gameId),
                    onRun: byHand && !_awaitingAnswer
                        ? (delta) =>
                            repo.bumpOurHalfRuns(game: state.game, delta: delta)
                        : null,
                    onEndHalf: byHand && !_awaitingAnswer
                        ? () => repo.endOurHalf(state.game)
                        : null,
                  ),
                ),
              ),
            if (state.isFinal)
              Expanded(
                child: FinalCard(
                  state: state,
                  onReopen: () => repo.reopenGame(state.game),
                  onBoxScore: () => context.push('/games/$gameId/box'),
                ),
              )
            else if (theirs)
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(spacing.sm, 0, spacing.sm, spacing.sm),
                  child: TheirHalfCard(
                    state: state,
                    onRun: (delta) =>
                        repo.bumpTheirHalfRuns(game: state.game, delta: delta),
                    onEnd: () => repo.endTheirHalf(state.game),
                  ),
                ),
              )
            else ...[
              BatterCard(
                state: state,
                height: cardHeight,
                onUndo: state.hasLog && !_awaitingAnswer
                    ? () => repo.undoLast(state.game)
                    : null,
                onNext: state.hasLineup && !state.personal && !_awaitingAnswer
                    ? () => _jump(repo, 1)
                    : null,
                onPrevious: state.hasLineup && !state.personal && !_awaitingAnswer
                    ? () => _jump(repo, -1)
                    : null,
              ),
              // The diamond floats low, where a thumb lives; spare height goes
              // above it two to one. The last play sits right against it:
              // history next to the next action.
              const Spacer(flex: 2),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _awaitingAnswer ? 0.35 : 1,
                child: LastPlayLine(
                  state: state,
                  onUndo: state.hasLog && !_awaitingAnswer
                      ? () => repo.undoLast(state.game)
                      : null,
                  onFix: _awaitingAnswer
                      ? null
                      : (pa) =>
                          showFixSheet(context, gameId: gameId, paId: pa.paId),
                ),
              ),
              SizedBox(height: spacing.xs),
              Center(
                child: OneCardDiamond(
                  state: state,
                  geometry: geometry,
                  enabled: state.hasLineup,
                  showHint: state.replay.pas.length < 3,
                  onCommit: (play) => _record(repo, play),
                  onWave: (playerId) => _wave(repo, playerId),
                  onPendingChanged: (pending) {
                    if (mounted) setState(() => _awaitingAnswer = pending);
                  },
                ),
              ),
              if (!state.hasLineup)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.md),
                  child: FilledButton(
                    onPressed: () => context.push('/games/$gameId/lineup'),
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.field.surfaceHigh,
                      foregroundColor: context.colors.field.on,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: const Text('Pick a batting order to start'),
                  ),
                ),
              const Spacer(flex: 1),
              SizedBox(height: _nextUp, child: _NextUp(state: state)),
              SizedBox(height: spacing.sm),
            ],
          ],
        );
      },
    );
  }

  Future<void> _record(ScoringRepository repo, LoggedPlay play) {
    return repo.recordPa(
      game: state.game,
      result: play.result,
      outKind: play.outKind,
      runsOnPlay: play.rbi,
    );
  }

  /// A tapped runner scores: one more run on the last play, if the engine
  /// left anyone to send.
  Future<void> _wave(ScoringRepository repo, String playerId) async {
    final ReplayedPa? pa = state.lastPa;
    if (pa == null) return;
    if (state.replay.bases.at(1) != playerId &&
        state.replay.bases.at(2) != playerId &&
        state.replay.bases.at(3) != playerId) {
      return;
    }
    if (pa.runs >= pa.maxRuns) return;
    await repo.setRunsOnPlay(game: state.game, paId: pa.paId, runs: pa.runs + 1);
  }

  Future<void> _jump(ScoringRepository repo, int delta) {
    final n = state.slots.length;
    if (n == 0) return Future.value();
    final next = (state.batterIndex + delta + n) % n;
    return repo.jumpToBatter(game: state.game, index: next);
  }

  Future<void> _openMenu(BuildContext context, WidgetRef ref) async {
    final action = await showGameMenu(context, state);
    if (action == null || !context.mounted) return;
    switch (action) {
      case GameMenuAction.boxScore:
        context.push('/games/$gameId/box');
      case GameMenuAction.editLineup:
        context.push('/games/$gameId/lineup');
      case GameMenuAction.switchScope:
        final next = state.game.scope == GameScope.game ? GameScope.bat : GameScope.game;
        await ref.read(scoringRepositoryProvider).setGameScope(game: state.game, scope: next);
      case GameMenuAction.endGame:
        final ok = await confirmAction(
          context,
          title: 'End this game?',
          body: 'It is marked final. You can reopen it after.',
        );
        if (!ok) return;
        await ref.read(scoringRepositoryProvider).finalizeGame(state.game);
    }
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.state});

  final FieldModeState state;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    final next = state.onDeck;
    if (state.personal || next == null) return const SizedBox.shrink();
    return Center(
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: 'NEXT  ',
              style: context.text.labelSmall?.copyWith(
                color: field.muted,
                letterSpacing: 1.8,
              ),
            ),
            TextSpan(
              text: next.firstName,
              style: context.text.labelSmall?.copyWith(
                color: field.on,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.text,
    required this.actionLabel,
    required this.onAction,
  });

  final String text;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.themeSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: field.on),
            ),
            SizedBox(height: context.themeSpacing.md),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: field.on,
                side: BorderSide(color: field.border),
              ),
              child: Text(
                actionLabel,
                style: context.text.bodyMedium?.copyWith(color: field.on),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
