import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';

/// Shared scorebook surface: quiet depth, a restrained accent, clear hierarchy.
class ScorebookSurface extends StatelessWidget {
  const ScorebookSurface({
    super.key,
    required this.child,
    this.accent = false,
    this.padding = const EdgeInsets.all(20),
  });
  final Widget child;
  final bool accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent
                ? Color.alphaBlend(c.accent.withValues(alpha: .15), c.surface)
                : c.surfaceHigh,
            c.surface,
          ],
        ),
        border: Border.all(
          color: accent
              ? c.accent.withValues(alpha: .24)
              : c.border.withValues(alpha: .65),
        ),
      ),
      child: child,
    );
  }
}

class ScorebookLabel extends StatelessWidget {
  const ScorebookLabel(this.text, {super.key, this.accent = false});
  final String text;
  final bool accent;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: context.text.labelSmall?.copyWith(
      color: accent ? context.colors.accent : context.colors.muted,
      letterSpacing: 2,
      fontWeight: FontWeight.w700,
    ),
  );
}

class ScorebookAction extends StatelessWidget {
  const ScorebookAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.colors.border.withValues(alpha: .6),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.colors.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: context.text.titleSmall)),
            Icon(
              Icons.arrow_outward_rounded,
              size: 16,
              color: context.colors.muted,
            ),
          ],
        ),
      ),
    ),
  );
}
