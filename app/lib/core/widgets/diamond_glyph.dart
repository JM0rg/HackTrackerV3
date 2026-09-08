import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';

/// The app's own motif, drawn quietly. Used where a screen has nothing to
/// show yet and needs something better than an icon.
class DiamondGlyph extends StatelessWidget {
  const DiamondGlyph({super.key, this.size = 120});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _Painter(
          line: colors.muted.withValues(alpha: 0.28),
          accent: colors.accent,
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({required this.line, required this.accent});

  final Color line;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final home = Offset(w * 0.5, w * 0.9);
    final first = Offset(w * 0.88, w * 0.52);
    final second = Offset(w * 0.5, w * 0.14);
    final third = Offset(w * 0.12, w * 0.52);

    canvas.drawPath(
      Path()
        ..moveTo(home.dx, home.dy)
        ..lineTo(first.dx, first.dy)
        ..lineTo(second.dx, second.dy)
        ..lineTo(third.dx, third.dy)
        ..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = line,
    );

    void bag(Offset at, double side, Color color) {
      canvas.save();
      canvas.translate(at.dx, at.dy);
      canvas.rotate(0.7853981633974483);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: side, height: side),
          const Radius.circular(2),
        ),
        Paint()..color = color,
      );
      canvas.restore();
    }

    bag(second, w * 0.075, line);
    bag(first, w * 0.075, line);
    bag(third, w * 0.075, line);
    // The batter, waiting at the plate.
    bag(home, w * 0.085, accent);
  }

  @override
  bool shouldRepaint(_Painter old) => old.line != line || old.accent != accent;
}
