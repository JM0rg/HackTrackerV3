import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';
import 'app_button.dart';

/// Deliberate empty / error state for any data-driven screen. Every list
/// renders this when there's nothing to show (quality bar #6).
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Convenience constructor for the error variant.
  const EmptyState.error({
    required String message,
    VoidCallback? onRetry,
    Key? key,
  }) : this(
         icon: Icons.error_outline,
         title: 'Something went wrong',
         message: message,
         actionLabel: onRetry == null ? null : 'Retry',
         onAction: onRetry,
         key: key,
       );

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.themeSpacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.secondaryText),
            SizedBox(height: spacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.titleM,
            ),
            if (message != null) ...[
              SizedBox(height: spacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.body.copyWith(color: colors.secondaryText),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: spacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                variant: AppButtonVariant.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
