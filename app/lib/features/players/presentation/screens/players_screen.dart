import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/di/repository_providers.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/database/app_database.dart';

class PlayersScreen extends ConsumerWidget {
  const PlayersScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = ref.watch(currentTeamIdProvider);
    if (teamId == null) {
      return const AppScaffold(title: 'Players', body: Center(child: Text('Create a team first.')));
    }
    final players = ref.watch(playersStreamProvider(teamId));
    final me = ref.watch(meStreamProvider).valueOrNull;
    return AppScaffold(
      title: 'Players',
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editPlayer(context, ref, teamId),
        child: const Icon(Icons.add),
      ),
      body: players.when(
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.person_add_alt,
                title: 'No players yet',
                actionLabel: 'Add a player',
                onAction: () => _editPlayer(context, ref, teamId),
              )
            : ListView(
                children: [
                  for (final p in list)
                    ListTile(
                      title: Text('${p.jerseyNumber ?? ''} ${p.firstName} ${p.lastName}'.trim()),
                      subtitle: me != null && p.personId == me.id
                          ? const Text("That's me")
                          : null,
                      trailing: TextButton(
                        onPressed: () async {
                          await ref.read(meRepositoryProvider).ensureMe();
                          await ref.read(meRepositoryProvider).setRosterSlotAsMe(
                                teamId: teamId,
                                playerId: p.id,
                              );
                        },
                        child: Text(
                          me != null && p.personId == me.id ? 'You' : "That's me",
                        ),
                      ),
                      onTap: () => _editPlayer(context, ref, teamId, player: p),
                    ),
                ],
              ),
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Text('$e'),
      ),
    );
  }

  Future<void> _editPlayer(
    BuildContext context,
    WidgetRef ref,
    String teamId, {
    Player? player,
  }) async {
    final first = TextEditingController(text: player?.firstName ?? '');
    final last = TextEditingController(text: player?.lastName ?? '');
    final num = TextEditingController(text: player?.jerseyNumber ?? '');
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.themeSpacing.md,
            context.themeSpacing.md,
            context.themeSpacing.md,
            MediaQuery.of(ctx).viewInsets.bottom + context.themeSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'First name', controller: first),
              SizedBox(height: context.themeSpacing.sm),
              AppTextField(label: 'Last name', controller: last),
              SizedBox(height: context.themeSpacing.sm),
              AppTextField(label: 'Number', controller: num),
              SizedBox(height: context.themeSpacing.md),
              AppButton(
                label: 'Save',
                onPressed: () async {
                  await ref.read(trackerRepositoryProvider).upsertPlayer(
                        id: player?.id,
                        teamId: teamId,
                        firstName: first.text.trim(),
                        lastName: last.text.trim(),
                        jerseyNumber: num.text.trim().isEmpty ? null : num.text.trim(),
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
