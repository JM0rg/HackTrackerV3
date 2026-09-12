import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:intl/intl.dart';

/// A game in progress, as the hero of the tab. It says which game before it
/// says anything else: when and where it is, who is playing, and how it is
/// going.
class LiveCard extends StatelessWidget {
  const LiveCard({
    super.key,
    required this.game,
    this.line,
    this.teamName,
    this.now,
  });

  final Game game;
  final GameLine? line;

  /// The side the app is scoring for, when it is a team game and the caller
  /// knows it. A personal game carries its own in `playedForName`.
  final String? teamName;

  /// For "is this today". Tests pin it; the app leaves it to the clock.
  final DateTime? now;

  /// Who is playing, as far as the game knows. Null when it knows neither
  /// side, and the card falls back to when it started.
  static String? matchup(Game game, {String? teamName}) {
    String? clean(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    final us = clean(teamName) ?? clean(game.playedForName);
    final them = clean(game.opponentName);
    if (us != null && them != null) return '$us vs $them';
    if (them != null) return 'vs $them';
    return us;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final keepsScore = game.teamId != null || game.scope == GameScope.game;
    final half = game.currentHalf == 'top' ? 'Top' : 'Bot';

    // When it started is always known, even when nothing else is: a personal
    // game may carry no names at all, but it was created at a moment.
    final started = (game.startsAt ?? game.createdAt).toLocal();
    final clock = now ?? DateTime.now();
    final today =
        started.year == clock.year &&
        started.month == clock.month &&
        started.day == clock.day;
    final named = matchup(game, teamName: teamName);
    final title = named ?? DateFormat('EEEE, MMM d').format(started);
    // The tag and the title never say the same thing. With the matchup for a
    // title, the tag carries the day (or just the time, when that is today);
    // with the day for a title, the tag carries the time.
    final when = named == null || today
        ? DateFormat.jm().format(started)
        : DateFormat.MMMd().format(started).toUpperCase();

    // When and where share the tag; who is the title; how it is going is the
    // line beneath. Each fact appears once.
    final park = game.park?.trim();
    final tag = [
      'LIVE',
      when,
      if (park != null && park.isNotEmpty) park.toUpperCase(),
    ].join(' · ');
    final lineText = line == null || line!.atBats == 0 && line!.rbi == 0
        ? null
        : [line!.summary, if (line!.rbi > 0) '${line!.rbi} RBI'].join(' · ');
    final standing = [
      if (keepsScore) '${game.ourRuns}–${game.theirRuns}',
      if (keepsScore) '$half ${game.currentInning}',
    ].join(' · ');

    return Semantics(
      button: true,
      label: 'Resume $title',
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
                          key: const Key('live-when'),
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
                  Text(
                    title,
                    key: const Key('live-title'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (lineText != null || standing.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (lineText != null)
                              TextSpan(
                                text: lineText,
                                style: TextStyle(
                                  color: colors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (lineText != null && standing.isNotEmpty)
                              const TextSpan(text: '   '),
                            if (standing.isNotEmpty) TextSpan(text: standing),
                          ],
                        ),
                        key: const Key('live-standing'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(
                          color: colors.muted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
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
