import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/sync_status_indicator.dart';
import '../../../teams/data/teams_repository.dart';
import '../../../teams/presentation/widgets/team_selector.dart';

/// Stats tab — placeholder until stat logging ships. The hitting line and
/// team aggregates land here once at-bats can be recorded from game detail.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);

    if (teamId == null) {
      return const AppScaffold(
        titleWidget: TeamSelector(),
        body: EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'No team selected',
          message:
              'Add a team from the dropdown above to start tracking stats.',
        ),
      );
    }

    final spacing = context.themeSpacing;
    final colors = context.colors;

    return AppScaffold(
      titleWidget: const TeamSelector(),
      actions: const [SyncStatusIndicator()],
      body: ListView(
        children: [
          SizedBox(height: spacing.lg),
          Icon(Icons.bar_chart_outlined, size: 56, color: colors.primary),
          SizedBox(height: spacing.md),
          Text(
            'Stats coming soon',
            textAlign: TextAlign.center,
            style: context.text.titleL,
          ),
          SizedBox(height: spacing.xs),
          Text(
            'Log at-bats from a game and the hitting line shows up here — '
            'per player, per team, filterable by season or tournament.',
            textAlign: TextAlign.center,
            style: context.text.body.copyWith(color: colors.secondaryText),
          ),
          SizedBox(height: spacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('On the roadmap', style: context.text.label),
                SizedBox(height: spacing.sm),
                Text(
                  '• Hitting line: AVG / OBP / SLG / OPS\n'
                  '• Per-game and per-player splits\n'
                  '• Season & tournament filters (W-L, totals)\n'
                  '• Tap-to-log at-bats during a live game',
                  style: context.text.body.copyWith(
                    color: colors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
