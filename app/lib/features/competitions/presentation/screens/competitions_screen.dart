import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class CompetitionsScreen extends ConsumerWidget {
  const CompetitionsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(
        title: 'Seasons & tournaments',
        body: EmptyState(
          icon: Icons.groups_outlined,
          title: 'No team yet',
          message: 'Seasons and tournaments belong to a team.',
        ),
      );
    }
    final rows = ref.watch(competitionsStreamProvider(teamId));
    return AppScaffold(
      title: 'Seasons & tournaments',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, teamId),
        child: const Icon(Icons.add),
      ),
      body: rows.when(
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.emoji_events_outlined,
                title: 'No seasons yet',
                actionLabel: 'Add a season',
                onAction: () => _edit(context, ref, teamId),
              )
            : ListView(
                children: [
                  for (final c in list)
                    ListTile(
                      title: Text(c.name),
                      subtitle: Text(c.type == 'tournament' ? 'Tournament' : 'Season'),
                      onTap: () => _edit(context, ref, teamId, existing: c),
                    ),
                ],
              ),
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Text('$e'),
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String teamId, {
    Competition? existing,
  }) async {
    final name = TextEditingController(text: existing?.name ?? '');
    final league = TextEditingController(text: existing?.leagueName ?? '');
    var type = existing?.type ?? 'season';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            return Padding(
              padding: EdgeInsets.all(context.themeSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'season', label: Text('Season')),
                      ButtonSegment(value: 'tournament', label: Text('Tournament')),
                    ],
                    selected: {type},
                    onSelectionChanged: (s) => setSt(() => type = s.first),
                  ),
                  SizedBox(height: context.themeSpacing.sm),
                  AppTextField(label: 'Name', controller: name),
                  SizedBox(height: context.themeSpacing.sm),
                  AppTextField(label: 'League (optional)', controller: league),
                  SizedBox(height: context.themeSpacing.md),
                  AppButton(
                    label: 'Save',
                    onPressed: () async {
                      await ref.read(trackerRepositoryProvider).upsertCompetition(
                            id: existing?.id,
                            teamId: teamId,
                            type: type,
                            name: name.text.trim(),
                            leagueName: league.text.trim().isEmpty ? null : league.text.trim(),
                          );
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
