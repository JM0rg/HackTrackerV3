import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// A tappable surface panel used for list rows and grouped content.
class AppCard extends StatelessWidget {
  const AppCard({required this.child, this.onTap, this.padding, super.key});

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    return Material(
      color: colors.surfaceAlt,
      borderRadius: BorderRadius.circular(radii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radii.lg),
        child: Container(
          padding: padding ?? EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radii.lg),
            border: Border.all(color: colors.border),
          ),
          child: child,
        ),
      ),
    );
  }
}
