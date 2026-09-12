import 'dart:convert';
import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'dart:math' as math;
import 'package:hacktracker/features/scoring/presentation/widgets/contact_scorer.dart';

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
import 'package:hacktracker/features/scoring/presentation/widgets/scoreboard.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/one_card_diamond.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/play_log.dart';
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
  bool _handoff = false;

  /// Close means "not right now": back to the tab, game stays live.
  void _leave() => context.go(state.personal ? '/' : '/team');

  FieldModeState get state => widget.state;
  String get gameId => widget.gameId;

  bool _contactMode(bool premium) {
    // Complete an already-started play in its original input mode. Plan changes
    // take effect for the following play, without deleting or reinterpreting it.
    try {
      final raw = jsonDecode(state.game.scoringDraft ?? 'null');
      final sequence = [
        0,
        ...state.events.map((e) => e.sequence),
        ...state.replay.pas.map((p) => p.sequence),
      ].reduce((a, b) => a > b ? a : b);
      if (raw is Map &&
          raw['batterId'] == state.batter?.id &&
          raw['sequence'] == sequence) {
        if (raw['version'] == 1) return false;
        if (raw['version'] == 2) return true;
      }
    } catch (_) {}
    return false;
  }

  static const _topRow = 48.0;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(scoringRepositoryProvider);
    final theirs = state.tracksScore && !state.replay.weBat;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final premium = ref.watch(locationTrackingProvider);
    final contact = _contactMode(premium);
    // Only a personal game keeping score ends its own half by hand.
    final byHand = state.personal && state.tracksScore && state.replay.weBat;

    if (state.isFinal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: _topRow, child: _sky(context)),
          Expanded(
            child: FinalCard(
              state: state,
              onReopen: () => repo.reopenGame(state.game),
              onBoxScore: () => context.push('/games/$gameId/box'),
            ),
          ),
        ],
      );
    }

    // Readings at the top, where the eyes are; the instrument at the bottom,
    // where the thumb is. Score and dugout are read, so they stack under the
    // sky. The field is dragged on every play, so it sits as low as the
    // question bar allows. Nothing is in a box except the thing that is
    // tapped.
    final Widget? surface;
    if (theirs) {
      surface = Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: TheirHalfCard(
          state: state,
          onRun: (delta) =>
              repo.bumpTheirHalfRuns(game: state.game, delta: delta),
          onEnd: () => repo.endTheirHalf(state.game),
        ),
      );
    } else if (contact) {
      surface = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: ContactScorer(
                captureEnabled: premium,
                key: ValueKey('contact-$gameId'),
                state: state,
                onWave: (id) => _wave(repo, id),
                onCommit: (play) => _record(repo, play),
                onDraftChanged: (draft) => repo.saveDraft(gameId, draft),
                onPendingChanged: (pending) {
                  if (mounted) setState(() => _awaitingAnswer = pending);
                },
              ),
            ),
          ),
        ],
      );
    } else {
      surface = null;
    }

    return LayoutBuilder(
      builder: (context, page) => Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: _topRow, child: _sky(context)),
              SizedBox(
                height: MediaQuery.textScalerOf(
                  context,
                ).scale(Scoreboard.height),
                child: Scoreboard(
                  state: state,
                  enabled: !_awaitingAnswer && !_handoff,
                  onTap: _handoff
                      ? null
                      : () => showLogSheet(context, gameId: gameId),
                  onEndGame: () => repo.finalizeGame(state.game),
                  onRun: byHand && !_awaitingAnswer
                      ? (delta) =>
                            repo.bumpOurHalfRuns(game: state.game, delta: delta)
                      : null,
                  onEndHalf: byHand && !_awaitingAnswer
                      ? () => repo.endOurHalf(state.game)
                      : null,
                ),
              ),
              if (surface != null) ...[
                if (!theirs)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                    child: _dugout(repo),
                  ),
                Expanded(child: surface),
              ] else ...[
                if (!state.personal || state.tracksScore)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                    child: _batterLine(repo),
                  ),
                // The game so far fills the room between the readings and the
                // wall, however much of it this phone has.
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _awaitingAnswer ? 0.35 : 1,
                      child: PlayLog(
                        state: state,
                        onUndo: state.hasLog && !_awaitingAnswer
                            ? () => repo.undoLast(state.game)
                            : null,
                        onFix: _awaitingAnswer || _handoff
                            ? null
                            : (pa) => showFixSheet(
                                context,
                                gameId: gameId,
                                paId: pa.paId,
                              ),
                        onViewAll: () => showLogSheet(context, gameId: gameId),
                      ),
                    ),
                  ),
                ),
                _instrument(context, repo, page, textScale, premium),
              ],
            ],
          ),
          if (!state.hasLineup && !theirs)
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
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
        ],
      ),
    );
  }

  /// The field and its question bar, sized once from the page so the plate
  /// sits as low as the bar allows. Width is the usual limit; on a short
  /// phone the height wins, leaving the log at least a row.
  Widget _instrument(
    BuildContext context,
    ScoringRepository repo,
    BoxConstraints page,
    double textScale,
    bool premium,
  ) {
    final ts = textScale;
    final byWidth = (page.maxWidth - 16) * (300 / 283);
    final above =
        _topRow +
        Scoreboard.height * ts +
        ((!state.personal || state.tracksScore) ? 62 : 0) +
        PlayLog.rowHeight * ts +
        12;
    final barRoom = 12 + OneCardDiamond.barSpace * ts;
    final byHeight = 300 * (page.maxHeight - above - barRoom) / 296;
    final geometry = FieldGeometry(
      math.min(byWidth, byHeight).clamp(180.0, 620.0),
    );
    return SizedBox(
      height: geometry.height + barRoom,
      child: OneCardDiamond(
        trackLocation: premium,
        state: state,
        geometry: geometry,
        enabled: state.hasLineup,
        showHint: state.replay.pas.length < 3,
        onCommit: (play) => _record(repo, play),
        onDraftChanged: (draft) => repo.saveDraft(gameId, draft),
        onWave: (playerId) => _wave(repo, playerId),
        onPendingChanged: (pending) {
          if (mounted) setState(() => _awaitingAnswer = pending);
        },
      ),
    );
  }

  /// Back, and the menu. While the phone is handed off, the menu is gone and
  /// Done brings it back.
  Widget _sky(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        key: const Key('field-close'),
        onPressed: _leave,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
        color: context.colors.field.muted,
        tooltip: 'Back to the tab, game stays live',
      ),
      if (_handoff)
        TextButton.icon(
          key: const Key('field-handoff'),
          onPressed: _awaitingAnswer
              ? null
              : () => setState(() => _handoff = false),
          icon: const Icon(Icons.check, size: 20),
          label: const Text('Done'),
          style: TextButton.styleFrom(foregroundColor: context.colors.field.on),
        )
      else if (!state.isFinal)
        IconButton(
          onPressed: () => _openMenu(context, ref),
          icon: const Icon(Icons.more_horiz),
          color: context.colors.field.muted,
          tooltip: 'Game menu',
        ),
    ],
  );

  /// Who is up: swipe down to undo, sideways through the order.
  Widget _batterLine(ScoringRepository repo) => BatterCard(
    state: state,
    onUndo: state.hasLog && !_awaitingAnswer
        ? () => repo.undoLast(state.game)
        : null,
    onNext: state.hasLineup && !state.personal && !_awaitingAnswer
        ? () => _jump(repo, 1)
        : null,
    onPrevious: state.hasLineup && !state.personal && !_awaitingAnswer
        ? () => _jump(repo, -1)
        : null,
  );

  /// Who is up, then what just happened. A personal game keeping only its
  /// own at-bats has its day on the scoreboard, so only the receipt.
  Widget _dugout(ScoringRepository repo) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (!state.personal || state.tracksScore) _batterLine(repo),
      AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _awaitingAnswer ? 0.35 : 1,
        child: LastPlayLine(
          state: state,
          onUndo: state.hasLog && !_awaitingAnswer
              ? () => repo.undoLast(state.game)
              : null,
          onFix: _awaitingAnswer || _handoff
              ? null
              : (pa) => showFixSheet(context, gameId: gameId, paId: pa.paId),
        ),
      ),
    ],
  );
  Future<void> _record(ScoringRepository repo, LoggedPlay play) {
    return repo.recordPa(
      game: state.game,
      result: play.result,
      outKind: play.outKind,
      runsOnPlay: play.rbi,
      hitLocation: play.hitLocation,
      qualityOfContact: play.qualityOfContact,
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
    await repo.scoreRunner(game: state.game, paId: pa.paId, playerId: playerId);
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
      case GameMenuAction.sprayChart:
        context.push('/spray?game=$gameId');
      case GameMenuAction.boxScore:
        context.push('/games/$gameId/box');
      case GameMenuAction.editLineup:
        context.push('/games/$gameId/lineup');
      case GameMenuAction.switchScope:
        final next = state.game.scope == GameScope.game
            ? GameScope.bat
            : GameScope.game;
        await ref
            .read(scoringRepositoryProvider)
            .setGameScope(game: state.game, scope: next);
      case GameMenuAction.handoff:
        setState(() => _handoff = true);
      case GameMenuAction.discard:
        // Already asked, in the menu. There is no game to come back to, so
        // leave rather than sit on a screen that has nothing to show. The
        // router is taken first: the delete swaps this screen out, and a
        // `mounted` check after it could strand the scorer on a dead game.
        final router = GoRouter.of(context);
        final home = state.personal ? '/' : '/team';
        await ref.read(scoringRepositoryProvider).discardGame(state.game);
        router.go(home);
      case GameMenuAction.endGame:
        final ok = await confirmAction(
          context,
          title: 'End this game?',
          body: 'You can reopen it after.',
        );
        if (!ok) return;
        await ref.read(scoringRepositoryProvider).finalizeGame(state.game);
    }
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
