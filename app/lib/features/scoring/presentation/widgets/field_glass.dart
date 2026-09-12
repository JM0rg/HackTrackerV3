import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';

/// Chrome that floats over the field instead of stacking above it. Blurred, and
/// deliberately unbordered: the grass showing through is what separates it from
/// the field, so nothing needs an edge drawn around it.
class FieldGlass extends StatelessWidget {
  const FieldGlass({
    super.key,
    required this.child,
    this.radius = 22,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  /// One capsule, one blur. Every floating surface on the field uses these.
  static const blur = 20.0;
  static const opacity = 0.72;

  @override
  Widget build(BuildContext context) {
    final field = context.colors.field;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          color: field.surface.withValues(alpha: opacity),
          child: child,
        ),
      ),
    );
  }
}

/// The hairline that divides two readings inside one capsule. The only rule
/// left in the chrome, and it separates rather than encloses.
class GlassDivider extends StatelessWidget {
  const GlassDivider({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: inset, vertical: 10),
    child: Container(height: 1, color: context.colors.field.line),
  );
}
