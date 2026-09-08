import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:intl/intl.dart';

class GameHistoryCard extends ConsumerWidget {
  const GameHistoryCard({
    super.key,
    required this.game,
    required this.teamName,
  });
  final Game game;
  final String teamName;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opponents = game.teamId == null
        ? const <Opponent>[]
        : ref.watch(opponentsStreamProvider(game.teamId!)).valueOrNull ??
              const <Opponent>[];
    final opponent =
        game.opponentName ??
        opponents.where((o) => o.id == game.opponentId).firstOrNull?.name ??
        'Opponent';
    final scored = game.kind == 'team' || game.scope == 'game';
    return InkWell(
      onTap: () => context.push('/games/${game.id}'),
      borderRadius: BorderRadius.circular(28),
      child: ScorebookSurface(
        accent: game.status == 'live',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ScorebookLabel(
                    DateFormat(
                      'EEE, MMM d',
                    ).format((game.startsAt ?? game.createdAt).toLocal()),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ScorebookLabel(game.status, accent: true),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _Side(
              name: teamName,
              score: scored ? game.ourRuns : null,
              ours: true,
            ),
            const SizedBox(height: 12),
            _Side(
              name: opponent,
              score: scored ? game.theirRuns : null,
              ours: false,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Icon(
                  scored
                      ? Icons.sports_baseball_outlined
                      : Icons.person_outline,
                  size: 16,
                  color: context.colors.muted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    game.park ??
                        (scored ? 'Team scores' : 'Personal scorebook'),
                    style: context.text.bodySmall,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: context.colors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.name, required this.score, required this.ours});
  final String name;
  final int? score;
  final bool ours;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ours
              ? context.colors.accent.withValues(alpha: .15)
              : context.colors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          ours ? Icons.shield_outlined : Icons.sports_baseball_outlined,
          size: 20,
          color: ours ? context.colors.accent : context.colors.muted,
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.titleMedium,
        ),
      ),
      if (score != null)
        Text(
          '$score',
          style: context.text.headlineMedium?.copyWith(
            color: ours ? context.colors.accent : context.colors.text,
          ),
        ),
    ],
  );
}
