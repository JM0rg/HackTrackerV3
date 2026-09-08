import 'package:hacktracker/core/widgets/text_entry_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/widgets/scorebook_surface.dart';
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
                padding: const EdgeInsets.all(20),
                children: [
                  for (final c in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        onTap: () => context.push('/competitions/${c.id}'),
                        borderRadius: BorderRadius.circular(28),
                        child: ScorebookSurface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.emoji_events_outlined,
                                    color: context.colors.accent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: ScorebookLabel(c.type, accent: true),
                                  ),
                                  IconButton(
                                    tooltip: 'Edit competition',
                                    onPressed: () => _edit(
                                      context,
                                      ref,
                                      teamId,
                                      existing: c,
                                    ),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(c.name, style: context.text.headlineMedium),
                              if (c.leagueName != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  c.leagueName!,
                                  style: context.text.bodySmall,
                                ),
                              ],
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Games & stats',
                                      style: context.text.bodySmall,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: context.colors.accent,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
    var type = existing?.type ?? 'season';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => TextEntrySheet(
          header: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'season', label: Text('Season')),
              ButtonSegment(value: 'tournament', label: Text('Tournament')),
            ],
            selected: {type},
            onSelectionChanged: (v) => setState(() => type = v.first),
          ),
          fields: [
            TextEntryField(
              'Name',
              initial: existing?.name ?? '',
              required: true,
            ),
            TextEntryField(
              'League (optional)',
              initial: existing?.leagueName ?? '',
            ),
          ],
          onSave: (values) => ref
              .read(trackerRepositoryProvider)
              .upsertCompetition(
                id: existing?.id,
                teamId: teamId,
                type: type,
                name: values[0],
                leagueName: values[1].isEmpty ? null : values[1],
                location: existing?.location,
              ),
        ),
      ),
    );
  }
}
