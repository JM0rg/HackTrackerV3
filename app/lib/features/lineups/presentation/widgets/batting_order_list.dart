import 'package:flutter/material.dart';

import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/lineup.dart';
import 'position_picker.dart';

/// Reorderable batting list. Each row shows the batting number, the player's
/// name, a position picker, and a delete affordance.
class BattingOrderList extends StatelessWidget {
  const BattingOrderList({
    required this.slots,
    required this.nameOf,
    required this.onReorder,
    required this.onChangePosition,
    required this.onRemove,
    super.key,
  });

  final List<LineupSlot> slots;
  final String Function(String playerId) nameOf;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(LineupSlot slot, String? code) onChangePosition;
  final void Function(LineupSlot slot) onRemove;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      itemCount: slots.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final slot = slots[index];
        return Padding(
          key: ValueKey(slot.id),
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: AppCard(
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${index + 1}',
                    style: context.text.titleM,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    nameOf(slot.playerId),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.body,
                  ),
                ),
                SizedBox(width: spacing.sm),
                PositionPicker(
                  code: slot.fieldPosition,
                  onChanged: (code) => onChangePosition(slot, code),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: context.colors.secondaryText,
                  ),
                  onPressed: () => onRemove(slot),
                ),
                ReorderableDragStartListener(
                  index: index,
                  child: Icon(
                    Icons.drag_handle,
                    color: context.colors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
