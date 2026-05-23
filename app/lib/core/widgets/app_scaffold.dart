import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// The canonical screen scaffold. Bakes in a [SafeArea] and consistent
/// horizontal padding so every screen respects notches and spacing rhythm.
///
/// Pass either a plain [title] string or a [titleWidget] (e.g. for the
/// team-selector dropdown). Exactly one must be provided.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.title,
    this.titleWidget,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.leading,
    this.padBody = true,
    super.key,
  }) : assert(
         (title == null) != (titleWidget == null),
         'AppScaffold needs exactly one of title or titleWidget',
       );

  final String? title;
  final Widget? titleWidget;
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
        title: titleWidget ?? Text(title!, style: context.text.titleM),
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
