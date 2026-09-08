import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/premium/data/plan_provider.dart';

class PlanPreview extends ConsumerWidget {
  const PlanPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!planPreviewEnabled) return const SizedBox.shrink();
    final plan = ref.watch(planPreviewProvider);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Plan preview', style: context.text.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Development build · no purchase required',
            style: context.text.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final value in Plan.values)
                ChoiceChip(
                  label: Text(value.label),
                  selected: value == plan,
                  onSelected: (_) =>
                      ref.read(planPreviewProvider.notifier).select(value),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Every plan: unlimited local scoring, teams, seasons, stats, and backups.',
          ),
          const SizedBox(height: 8),
          Text(switch (plan) {
            Plan.free => 'Free keeps your games on this device.',
            Plan.playerPlus =>
              'Player Plus previews personal cloud backup and stats across devices.',
            Plan.teamPlus =>
              'Team Plus previews team sharing, player invites, and team cloud backup.',
          }),
          const SizedBox(height: 8),
          Text(
            'Cloud access still requires server authorization. This switch previews the plan; it does not upload your games.',
            style: context.text.bodySmall,
          ),
        ],
      ),
    );
  }
}
