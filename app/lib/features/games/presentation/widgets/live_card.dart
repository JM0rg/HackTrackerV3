import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';

/// A game in progress, as the hero of the tab. Lit from one corner, your line
/// as the headline, one tap to resume.
class LiveCard extends StatelessWidget {
  const LiveCard({super.key, required this.game, this.line});

  final Game game;
  final GameLine? line;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final opponent = game.opponentName;
    final keepsScore = game.teamId != null || game.scope == GameScope.game;
    final half = game.currentHalf == 'top' ? 'Top' : 'Bot';

    final tag = [
      'LIVE',
      if (opponent != null && opponent.isNotEmpty) opponent.toUpperCase(),
    ].join(' · ');
    final meta = [
      if (game.playedForName != null) game.playedForName!,
      if (keepsScore) '${game.ourRuns} – ${game.theirRuns}',
    ].join(' · ');

    return Semantics(
      button: true,
      label: 'Resume live game',
      child: Surface(
        key: const Key('live-card'),
        gradientFrom: colors.accent.withValues(alpha: 0.16),
        padding: EdgeInsets.fromLTRB(
          context.themeSpacing.md + 2,
          context.themeSpacing.md + 2,
          context.themeSpacing.md,
          context.themeSpacing.md,
        ),
        onTap: () => context.push('/games/${game.id}'),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.accent,
                          boxShadow: [
                            BoxShadow(
                              color: colors.accent.withValues(alpha: 0.2),
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          tag,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(
                            color: colors.accent,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.themeSpacing.sm + 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          line?.summary ??
                              (game.kind == 'team'
                                  ? 'Resume game'
                                  : 'No at-bats yet'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.headlineLarge?.copyWith(
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (keepsScore) ...[
                        const SizedBox(width: 8),
                        Text(
                          '$half ${game.currentInning}',
                          style: context.text.titleSmall?.copyWith(
                            color: colors.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (meta.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(meta, style: context.text.bodySmall),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.muted),
          ],
        ),
      ),
    );
  }
}
