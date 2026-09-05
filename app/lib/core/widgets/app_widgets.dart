import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final child = Text(label);
    final button = danger
        ? FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: child,
          )
        : FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.accent,
              foregroundColor: context.colors.onAccent,
            ),
            onPressed: onPressed,
            child: child,
          );
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.placeholder,
  });

  final String label;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? placeholder;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: placeholder,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.themeRadii.md),
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.themeRadii.md);
    return Material(
      color: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.colors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Padding(padding: EdgeInsets.all(context.themeSpacing.md), child: child),
      ),
    );
  }
}

class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  var _online = true;
  StreamSubscription<List<ConnectivityResult>>? _sub;

  @override
  void initState() {
    super.initState();
    final connectivity = Connectivity();
    connectivity.checkConnectivity().then((results) {
      if (mounted) {
        setState(() {
          _online = results.any((r) => r != ConnectivityResult.none);
        });
      }
    });
    _sub = connectivity.onConnectivityChanged.listen((results) {
      if (mounted) {
        setState(() {
          _online = results.any((r) => r != ConnectivityResult.none);
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_online) return const SizedBox.shrink();
    return ColoredBox(
      color: context.colors.danger,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.themeSpacing.xs),
        child: Text(
          'Offline — scoring is saved on this device',
          style: context.text.labelMedium?.copyWith(color: context.colors.fieldOn),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottom,
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    this.message,
  });

  final String title;
  final String? message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.themeSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: context.text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              SizedBox(height: context.themeSpacing.sm),
              Text(message!, style: context.text.bodySmall, textAlign: TextAlign.center),
            ],
            SizedBox(height: context.themeSpacing.md),
            AppButton(label: actionLabel, onPressed: onAction, expand: false),
          ],
        ),
      ),
    );
  }
}

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      );
    },
  );
  return result ?? false;
}
