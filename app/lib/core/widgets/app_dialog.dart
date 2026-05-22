import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// The ONLY sanctioned dialog entry point. Never call `showDialog` /
/// `showGeneralDialog` directly — route through [AppDialog.show].
abstract final class AppDialog {
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: title,
      barrierColor: Colors.black54,
      useRootNavigator: false,
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      pageBuilder: (context, _, _) =>
          _DialogShell(title: title, content: content, actions: actions),
    );
  }
}

class _DialogShell extends StatelessWidget {
  const _DialogShell({
    required this.title,
    required this.content,
    required this.actions,
  });

  final String title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.lg),
        child: Material(
          color: colors.surface,
          borderRadius: BorderRadius.circular(radii.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: EdgeInsets.all(spacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: context.text.titleM),
                  SizedBox(height: spacing.md),
                  content,
                  if (actions.isNotEmpty) ...[
                    SizedBox(height: spacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final action in actions) ...[
                          Flexible(child: action),
                          if (action != actions.last)
                            SizedBox(width: spacing.sm),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
