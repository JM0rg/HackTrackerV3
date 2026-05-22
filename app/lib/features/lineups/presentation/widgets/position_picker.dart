import 'package:flutter/material.dart';

import '../../../../core/domain/field_position.dart';
import '../../../../core/theme/theme_context_extensions.dart';

/// Compact popup menu for choosing a slot's field position (or clearing it).
class PositionPicker extends StatelessWidget {
  const PositionPicker({
    required this.code,
    required this.onChanged,
    super.key,
  });

  final String? code;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    return PopupMenuButton<String?>(
      tooltip: 'Field position',
      onSelected: onChanged,
      itemBuilder: (context) => [
        const PopupMenuItem<String?>(child: Text('No position')),
        for (final pos in FieldPosition.values)
          PopupMenuItem<String?>(
            value: pos.code,
            child: Text('${pos.code} · ${pos.label}'),
          ),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radii.sm),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code ?? '—',
              style: context.text.label.copyWith(
                color: code == null ? colors.secondaryText : colors.text,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: colors.secondaryText, size: 18),
          ],
        ),
      ),
    );
  }
}
