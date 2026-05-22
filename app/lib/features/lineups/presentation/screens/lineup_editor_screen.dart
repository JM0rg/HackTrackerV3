import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../players/data/players_repository.dart';
import '../../../players/domain/player.dart';
import '../../data/lineups_repository.dart';
import '../../domain/lineup.dart';
import '../widgets/batting_order_list.dart';

/// Resolves (creating if needed) the lineup id for a given game/team.
final _lineupIdProvider =
    FutureProvider.family<String, ({String gameId, String teamId})>((
      ref,
      args,
    ) {
      return ref
          .read(lineupsRepositoryProvider)
          .ensureLineupForGame(gameId: args.gameId, teamId: args.teamId);
    });

/// Builds the batting order and field positions for a game's lineup.
class LineupEditorScreen extends ConsumerWidget {
  const LineupEditorScreen({
    required this.gameId,
    required this.teamId,
    super.key,
  });

  final String gameId;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineupId = ref.watch(
      _lineupIdProvider((gameId: gameId, teamId: teamId)),
    );

    return AppScaffold(
      title: 'Lineup',
      body: lineupId.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) => EmptyState.error(message: '$e'),
        data: (id) => _LineupBody(lineupId: id, teamId: teamId),
      ),
    );
  }
}

class _LineupBody extends ConsumerWidget {
  const _LineupBody({required this.lineupId, required this.teamId});

  final String lineupId;
  final String teamId;

  LineupsRepository _repo(WidgetRef ref) => ref.read(lineupsRepositoryProvider);

  Future<void> _reorder(
    WidgetRef ref,
    List<LineupSlot> slots,
    int oldIndex,
    int newIndex,
  ) async {
    final reordered = [...slots];
    final adjusted = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(adjusted, moved);
    final repo = _repo(ref);
    for (var i = 0; i < reordered.length; i++) {
      if (reordered[i].battingOrder != i) {
        await repo.setBattingOrder(reordered[i].id, i);
      }
    }
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    LineupSlot slot,
    String name,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Remove batter?',
      message: 'This removes $name from the lineup.',
      confirmLabel: 'Remove',
      isDestructive: true,
    );
    if (!confirmed) return;
    await _repo(ref).removeSlot(slot.id);
  }

  Future<void> _addBatter(
    BuildContext context,
    WidgetRef ref,
    List<Player> available,
    int nextOrder,
  ) async {
    final picked = await AppDialog.show<Player>(
      context,
      title: 'Add batter',
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final player in available)
                ListTile(
                  title: Text(player.name, style: context.text.body),
                  onTap: () => Navigator.of(context).pop(player),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    await _repo(ref).addSlot(
      lineupId: lineupId,
      teamId: teamId,
      playerId: picked.id,
      battingOrder: nextOrder,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsAsync = ref.watch(lineupSlotsProvider(lineupId));
    final playersAsync = ref.watch(playersForTeamProvider(teamId));

    return slotsAsync.when(
      loading: () => const SkeletonLoader(),
      error: (e, _) => EmptyState.error(message: '$e'),
      data: (slots) => playersAsync.when(
        loading: () => const SkeletonLoader(),
        error: (e, _) => EmptyState.error(message: '$e'),
        data: (players) {
          final byId = {for (final p in players) p.id: p};
          final usedIds = slots.map((s) => s.playerId).toSet();
          final available = players
              .where((p) => !usedIds.contains(p.id))
              .toList();

          String nameOf(String playerId) =>
              byId[playerId]?.name ?? 'Unknown player';

          return Column(
            children: [
              Expanded(
                child: slots.isEmpty
                    ? const EmptyState(
                        icon: Icons.list_alt_outlined,
                        title: 'No batters yet',
                        message: 'Add players to build the batting order.',
                      )
                    : BattingOrderList(
                        slots: slots,
                        nameOf: nameOf,
                        onReorder: (o, n) => _reorder(ref, slots, o, n),
                        onChangePosition: (slot, code) =>
                            _repo(ref).updateSlotPosition(slot.id, code),
                        onRemove: (slot) =>
                            _remove(context, ref, slot, nameOf(slot.playerId)),
                      ),
              ),
              _AddBatterBar(
                enabled: available.isNotEmpty,
                onAdd: () => _addBatter(context, ref, available, slots.length),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddBatterBar extends StatelessWidget {
  const _AddBatterBar({required this.enabled, required this.onAdd});

  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      child: AppButton(
        label: enabled ? 'Add batter' : 'All players added',
        variant: AppButtonVariant.secondary,
        icon: Icons.person_add_alt,
        onPressed: enabled ? onAdd : null,
      ),
    );
  }
}
