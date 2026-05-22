import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// The canonical screen scaffold. Bakes in a [SafeArea] and consistent
/// horizontal padding so every screen respects notches and spacing rhythm.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.padBody = true,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? leading;
  final bool padBody;

  @override
  Widget build(BuildContext context) {
    final spacing = context.themeSpacing;

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: context.text.titleM),
        leading: leading,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        child: padBody
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.md),
                child: body,
              )
            : body,
      ),
    );
  }
}
