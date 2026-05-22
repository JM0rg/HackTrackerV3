import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../lineups/presentation/screens/lineup_editor_screen.dart';
import '../../data/games_repository.dart';
import '../../domain/game.dart';
import 'game_edit_screen.dart';

/// Game home: summary, edit/delete, and an entry point to the lineup editor.
class GameDetailScreen extends ConsumerWidget {
  const GameDetailScreen({required this.gameId, super.key});

  final String gameId;

  void _edit(BuildContext context, Game game) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => GameEditScreen(game: game),
        fullscreenDialog: true,
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete game?',
      message:
          'This removes the game from your schedule. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(gamesRepositoryProvider).softDelete(gameId);
    if (context.mounted) Navigator.of(context).pop();
  }

  void _manageLineup(BuildContext context, Game game) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            LineupEditorScreen(gameId: game.id, teamId: game.teamId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameStreamProvider(gameId));
    final spacing = context.themeSpacing;

    return gameAsync.when(
      loading: () => const AppScaffold(title: 'Game', body: SizedBox()),
      error: (e, _) => AppScaffold(
        title: 'Game',
        body: EmptyState.error(message: '$e'),
      ),
      data: (game) {
        if (game == null) {
          return const AppScaffold(
            title: 'Game',
            body: EmptyState(icon: Icons.search_off, title: 'Game not found'),
          );
        }
        return AppScaffold(
          title: game.opponentName?.isNotEmpty == true
              ? 'vs ${game.opponentName}'
              : 'Game',
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, game),
            ),
          ],
          body: ListView(
            children: [
              SizedBox(height: spacing.md),
              _SummaryCard(game: game),
              SizedBox(height: spacing.md),
              AppCard(
                onTap: () => _manageLineup(context, game),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt_outlined,
                      color: context.colors.primary,
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: Text('Manage lineup', style: context.text.titleM),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: context.colors.secondaryText,
                    ),
                  ],
                ),
              ),
              SizedBox(height: spacing.xl),
              AppButton(
                label: 'Delete game',
                variant: AppButtonVariant.destructive,
                onPressed: () => _delete(context, ref),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.game});

  final Game game;

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'No date set';
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour < 12 ? 'AM' : 'PM';
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')} · $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    final rows = <(String, String)>[
      ('Status', game.status.label),
      ('Home / away', game.homeAway.label),
      ('Date', _formatDate(game.startTime)),
      if (game.parkName?.isNotEmpty == true) ('Park', game.parkName!),
      if (game.cityOrAddress?.isNotEmpty == true)
        ('Location', game.cityOrAddress!),
      if (game.ourScore != null && game.oppScore != null)
        ('Score', '${game.ourScore} - ${game.oppScore}'),
      if (game.result != null) ('Result', game.result!),
      if (game.notes?.isNotEmpty == true) ('Notes', game.notes!),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (label, value) in rows) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: context.text.label),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: context.text.body,
                  ),
                ),
              ],
            ),
            if ((label, value) != rows.last) SizedBox(height: spacing.sm),
          ],
        ],
      ),
    );
  }
}
