import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
import 'package:hacktracker/core/widgets/diamond_glyph.dart';
import 'package:hacktracker/core/widgets/surfaces.dart';
import 'package:hacktracker/features/stats/services/stats_aggregator.dart';

class FirstGameCard extends StatelessWidget {
  const FirstGameCard({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ScorebookSurface(
        accent: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScorebookLabel('Personal scorebook', accent: true),
            const SizedBox(height: 20),
            Text(
              'Your first at-bat',
              style: context.text.displaySmall?.copyWith(height: 1.05),
            ),
            const SizedBox(height: 8),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 204,
                      height: 204,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            context.colors.accent.withValues(alpha: .13),
                            context.colors.accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                    const DiamondGlyph(size: 180),
                  ],
                ),
              ),
            ),
            FilledButton(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded),
                  SizedBox(width: 8),
                  Text('Start a game'),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const ScorebookLabel('Your club'),
      const SizedBox(height: 12),
      ScorebookAction(
        icon: Icons.groups_outlined,
        label: 'Create a team',
        onTap: () => context.push('/team/edit'),
      ),
    ],
  );
}

class CareerCard extends StatelessWidget {
  const CareerCard({super.key, required this.line});
  final PlayerLine? line;
  String rate(double? value) =>
      (value ?? 0).toStringAsFixed(3).replaceFirst(RegExp(r'^0'), '');
  @override
  Widget build(BuildContext context) => ScorebookSurface(
    accent: true,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ScorebookLabel('Batting / career', accent: true),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rate(line?.avg),
                    style: context.text.displayLarge?.copyWith(
                      color: context.colors.accent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Average', style: context.text.bodySmall),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${line?.hits ?? 0} / ${line?.atBats ?? 0}',
                  style: context.text.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text('hits / at-bats', style: context.text.bodySmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: 22),
        Divider(color: context.colors.accent.withValues(alpha: .2), height: 1),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final large = MediaQuery.textScalerOf(context).scale(1) > 1.3;
            final metrics = [
              StatColumn(value: '${line?.homeRuns ?? 0}', label: 'Home runs'),
              StatColumn(value: '${line?.rbi ?? 0}', label: 'RBI'),
              StatColumn(value: rate(line?.obp), label: 'OBP'),
              StatColumn(value: rate(line?.ops), label: 'OPS'),
            ];
            return Wrap(
              spacing: 12,
              runSpacing: 16,
              children: [
                for (final metric in metrics)
                  SizedBox(
                    width:
                        (constraints.maxWidth - (large ? 12 : 36)) /
                        (large ? 2 : 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: metric,
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    ),
  );
}
