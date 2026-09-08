import 'package:hacktracker/core/widgets/text_entry_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class OpponentsScreen extends ConsumerWidget {
  const OpponentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(
        title: 'Opponents',
        body: EmptyState(
          icon: Icons.groups_outlined,
          title: 'No team yet',
          message: 'Opponents belong to a team.',
        ),
      );
    }
    final rows = ref.watch(opponentsStreamProvider(teamId));
    return AppScaffold(
      title: 'Opponents',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, teamId),
        child: const Icon(Icons.add),
      ),
      body: rows.when(
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.shield_outlined,
                title: 'No opponents saved',
                actionLabel: 'Add an opponent',
                onAction: () => _edit(context, ref, teamId),
              )
            : ListView(
                children: [
                  for (final o in list)
                    ListTile(
                      title: Text(o.name),
                      onTap: () => _edit(context, ref, teamId, existing: o),
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
    Opponent? existing,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TextEntrySheet(
        fields: [
          TextEntryField(
            'Opponent name',
            initial: existing?.name ?? '',
            required: true,
          ),
        ],
        onSave: (values) => ref
            .read(trackerRepositoryProvider)
            .upsertOpponent(id: existing?.id, teamId: teamId, name: values[0]),
      ),
    );
  }
}
