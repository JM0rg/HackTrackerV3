import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';
import 'app_button.dart';
import 'app_dialog.dart';

/// Standard yes/no confirmation. Built on [AppDialog]; supports a destructive
/// styling for irreversible actions. Returns `true` when confirmed.
abstract final class ConfirmationDialog {
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await AppDialog.show<bool>(
      context,
      title: title,
      content: Text(
        message,
        style: context.text.body.copyWith(color: context.colors.secondaryText),
      ),
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.secondary,
          expand: false,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          variant: isDestructive
              ? AppButtonVariant.destructive
              : AppButtonVariant.primary,
          expand: false,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    return result ?? false;
  }
}
