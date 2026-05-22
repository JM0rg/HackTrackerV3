import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

enum AppButtonVariant { primary, secondary, destructive }

/// The canonical button. Variants cover the only three intents we support;
/// minimum 48pt height satisfies the touch-target quality bar.
class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isBusy = false,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isBusy;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;
    final enabled = onPressed != null && !isBusy;

    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (colors.primary, colors.onPrimary, null),
      AppButtonVariant.secondary => (
        colors.surfaceAlt,
        colors.text,
        colors.border,
      ),
      AppButtonVariant.destructive => (colors.danger, colors.onPrimary, null),
    };

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          SizedBox(width: spacing.sm),
        ],
        Flexible(
          child: Text(
            isBusy ? '$label…' : label,
            overflow: TextOverflow.ellipsis,
            style: context.text.label.copyWith(color: fg),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(radii.md),
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(radii.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            width: expand ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: spacing.lg),
            decoration: border == null
                ? null
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(radii.md),
                    border: Border.all(color: border),
                  ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
