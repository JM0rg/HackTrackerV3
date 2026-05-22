import 'package:flutter/material.dart';

import '../theme/theme_context_extensions.dart';

/// Shimmering placeholder shown while data loads. The only sanctioned loading
/// affordance — no [CircularProgressIndicator] in screen bodies.
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({this.height = 64, this.count = 6, super.key});

  final double height;
  final int count;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radii = context.themeRadii;
    final spacing = context.themeSpacing;

    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: spacing.md),
      itemCount: widget.count,
      separatorBuilder: (_, _) => SizedBox(height: spacing.sm),
      itemBuilder: (context, _) => FadeTransition(
        opacity: _controller.drive(Tween(begin: 0.4, end: 0.9)),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(radii.lg),
            border: Border.all(color: colors.border),
          ),
        ),
      ),
    );
  }
}
