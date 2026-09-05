import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class OpponentsScreen extends ConsumerWidget {
  const OpponentsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(title: 'Opponents', body: Center(child: Text('Create a team first.')));
    }
    final rows = ref.watch(opponentsStreamProvider(teamId));
    return AppScaffold(
      title: 'Opponents',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref, teamId),
        child: const Icon(Icons.add),
      ),
      body: rows.when(
        data: (list) => ListView(
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
    final name = TextEditingController(text: existing?.name ?? '');
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.all(context.themeSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Opponent name', controller: name),
              SizedBox(height: context.themeSpacing.md),
              AppButton(
                label: 'Save',
                onPressed: () async {
                  await ref.read(trackerRepositoryProvider).upsertOpponent(
                        id: existing?.id,
                        teamId: teamId,
                        name: name.text.trim(),
                      );
                  if (ctx.mounted) Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
