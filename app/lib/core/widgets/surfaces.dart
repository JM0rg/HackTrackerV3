import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';

/// A raised surface. One step up the tonal ladder, never a stroke.
class Surface extends StatelessWidget {
  const Surface({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.high = false,
    this.gradientFrom,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  /// Use the higher of the two surfaces, for something sitting on a card.
  final bool high;

  /// Lights the card from its top-left corner.
  final Color? gradientFrom;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(context.themeRadii.lg + 6);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradientFrom == null
            ? (high ? colors.surfaceHigh : colors.surface)
            : null,
        gradient: gradientFrom == null
            ? null
            : RadialGradient(
                center: const Alignment(-1, -1),
                radius: 1.6,
                colors: [gradientFrom!, colors.surface],
                stops: const [0, 0.6],
              ),
        borderRadius: radius,
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? EdgeInsets.all(context.themeSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A grouped list, the way Settings asks a question. Rows sit on one surface
/// with hairlines between them.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = BorderRadius.circular(context.themeRadii.lg);
    return ClipRRect(
      borderRadius: radius,
      child: ColoredBox(
        color: colors.surfaceHigh,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.text.withValues(alpha: 0.06),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// One row in a [SettingsGroup]: a title, an optional value, and whatever
/// control the answer needs.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: EdgeInsets.symmetric(
          horizontal: context.themeSpacing.md,
          vertical: context.themeSpacing.sm + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: context.text.bodyLarge),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(subtitle!, style: context.text.bodySmall),
                    ),
                ],
              ),
            ),
            if (value != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  value!,
                  style: context.text.bodyMedium?.copyWith(color: colors.muted),
                ),
              ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: trailing!,
              ),
            if (onTap != null && trailing == null)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Icon(Icons.chevron_right, size: 20, color: colors.muted),
              ),
          ],
        ),
      ),
    );
  }
}

/// A number and its quiet label. No box.
class StatColumn extends StatelessWidget {
  const StatColumn({
    super.key,
    required this.value,
    required this.label,
    this.color,
  });

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: context.text.headlineMedium?.copyWith(
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: context.text.labelSmall),
      ],
    );
  }
}

/// A hairline separator. The only line in the app.
class Hairline extends StatelessWidget {
  const Hairline({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: context.colors.text.withValues(alpha: 0.06),
    );
  }
}

/// A filled capsule tag, for hit types.
class HitTag extends StatelessWidget {
  const HitTag({super.key, required this.label, this.tone, this.onTone});

  final String label;
  final Color? tone;
  final Color? onTone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fill = tone ?? colors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(context.themeRadii.sm + 2),
      ),
      child: Text(
        label,
        style: context.text.labelMedium?.copyWith(
          color: onTone ?? fill,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
