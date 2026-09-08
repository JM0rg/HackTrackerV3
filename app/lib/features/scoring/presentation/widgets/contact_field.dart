import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';

/// True scale: 65-foot basepaths and a 300-foot radial fence. Controls are
/// independently sized; field geometry never stretches to enlarge touch targets.
class ContactFieldGeometry {
  ContactFieldGeometry(this.size, {this.origin, this.fieldRadius});
  final Offset? origin;
  final double? fieldRadius;
  final Size size;
  double get radius =>
      fieldRadius ?? math.min(size.width / 1.65, (size.height - 58) / 1.12);
  Offset get home => origin ?? Offset(size.width / 2, radius + 18);
  Offset point(double x, double y) => home + Offset(x * radius, -y * radius);
  Offset get first => point(65 / 300 / math.sqrt2, 65 / 300 / math.sqrt2);
  Offset get second => point(0, 65 / 300 * math.sqrt2);
  Offset get third => point(-65 / 300 / math.sqrt2, 65 / 300 / math.sqrt2);
  ContactLocation? locate(Offset p) {
    final x = (p.dx - home.dx) / radius, y = (home.dy - p.dy) / radius;
    final encoded = ContactLocation(x: x, y: y).encode();
    return ContactLocation.parse(encoded);
  }
}

class ContactField extends StatefulWidget {
  const ContactField({
    super.key,
    this.location,
    this.onLocation,
    this.onOut,
    this.marks = const [],
    this.showLabels = true,
    this.fieldMode = false,
    this.geometry,
    this.drawSurface = true,
  });
  final ContactLocation? location;
  final ValueChanged<ContactLocation>? onLocation;
  final VoidCallback? onOut;
  final List<({ContactLocation location, bool hit})> marks;
  final bool showLabels;
  final bool fieldMode;
  final ContactFieldGeometry? geometry;
  final bool drawSurface;
  @override
  State<ContactField> createState() => _ContactFieldState();
}

class _ContactFieldState extends State<ContactField> {
  Offset? _drag;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final size =
          widget.geometry?.size ?? Size(c.maxWidth, c.maxWidth * .68 + 44);
      final g = widget.geometry ?? ContactFieldGeometry(size);
      Offset aim(Offset p) =>
          p.dy > g.home.dy + 22 ? p : p - const Offset(0, 32);
      void finish(Offset p) {
        setState(() => _drag = null);
        if (p.dy > g.home.dy + 22 && widget.onOut != null) {
          widget.onOut!();
          return;
        }
        final location = g.locate(p);
        if (location != null && (p - g.home).distance > 12) {
          widget.onLocation?.call(location);
        }
      }

      return Semantics(
        label:
            'Tap or drag to where the ball was first fielded or landed. Region buttons are also available.',
        child: GestureDetector(
          key: const Key('contact-field'),
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.onLocation == null
              ? null
              : (d) => finish(d.localPosition),
          onPanStart: widget.onLocation == null
              ? null
              : (d) => setState(() => _drag = aim(d.localPosition)),
          onPanUpdate: widget.onLocation == null
              ? null
              : (d) => setState(() => _drag = aim(d.localPosition)),
          onPanEnd: widget.onLocation == null
              ? null
              : (_) {
                  if (_drag != null) finish(_drag!);
                },
          onPanCancel: () => setState(() => _drag = null),
          child: CustomPaint(
            size: size,
            painter: _ContactPainter(
              g,
              widget.location,
              _drag,
              widget.marks,
              widget.fieldMode
                  ? context.colors.field.accent
                  : context.colors.accent,
              widget.fieldMode
                  ? context.colors.field.lineStrong
                  : context.colors.border,
              widget.fieldMode
                  ? context.colors.field.muted
                  : context.colors.muted,
              widget.showLabels,
              widget.drawSurface,
              widget.onOut != null,
              context.text.bodyMedium?.fontFamily,
            ),
          ),
        ),
      );
    },
  );
}

class _ContactPainter extends CustomPainter {
  _ContactPainter(
    this.g,
    this.location,
    this.drag,
    this.marks,
    this.accent,
    this.line,
    this.text,
    this.labels,
    this.drawSurface,
    this.out,
    this.fontFamily,
  );
  final ContactFieldGeometry g;
  final ContactLocation? location;
  final Offset? drag;
  final List<({ContactLocation location, bool hit})> marks;
  final Color accent, line, text;
  final bool labels, out, drawSurface;
  final String? fontFamily;
  void label(Canvas c, String s, Offset p, {Color? color}) {
    final t = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontSize: 11,
          color: color ?? text,
          fontFamily: fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    t.paint(c, p - Offset(t.width / 2, t.height / 2));
  }

  @override
  void paint(Canvas c, Size size) {
    if (drawSurface) {
      final fair = Path()
        ..moveTo(g.home.dx, g.home.dy)
        ..lineTo(
          g.point(-math.sqrt1_2, math.sqrt1_2).dx,
          g.point(-math.sqrt1_2, math.sqrt1_2).dy,
        )
        ..arcTo(
          Rect.fromCircle(center: g.home, radius: g.radius),
          -3 * math.pi / 4,
          math.pi / 2,
          false,
        )
        ..close();
      c.drawPath(fair, Paint()..color = accent.withValues(alpha: .10));
      c.drawArc(
        Rect.fromCircle(center: g.home, radius: g.radius),
        -3 * math.pi / 4,
        math.pi / 2,
        false,
        Paint()
          ..color = text
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      for (final sign in [-1, 1]) {
        c.drawLine(
          g.home,
          g.point(sign * .78, .78),
          Paint()
            ..color = text.withValues(alpha: .6)
            ..strokeWidth = 1,
        );
      }
      final diamond = Path()
        ..moveTo(g.home.dx, g.home.dy)
        ..lineTo(g.first.dx, g.first.dy)
        ..lineTo(g.second.dx, g.second.dy)
        ..lineTo(g.third.dx, g.third.dy)
        ..close();
      c.drawPath(diamond, Paint()..color = accent.withValues(alpha: .14));
      c.drawPath(
        diamond,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      for (final p in [g.first, g.second, g.third]) {
        c.save();
        c.translate(p.dx, p.dy);
        c.rotate(math.pi / 4);
        c.drawRect(const Rect.fromLTWH(-3, -3, 6, 6), Paint()..color = text);
        c.restore();
      }
      c.drawLine(
        g.point(-.02, 50 / 300),
        g.point(.02, 50 / 300),
        Paint()
          ..color = text
          ..strokeWidth = 2,
      );
    }
    for (final m in marks.where((m) => m.location.hasPoint)) {
      final p = g.point(m.location.x!, m.location.y!);
      if (m.hit) {
        c.drawCircle(p, 4, Paint()..color = accent);
      } else {
        c.drawLine(
          p - const Offset(4, 4),
          p + const Offset(4, 4),
          Paint()
            ..color = text
            ..strokeWidth = 2,
        );
        c.drawLine(
          p + const Offset(-4, 4),
          p + const Offset(4, -4),
          Paint()
            ..color = text
            ..strokeWidth = 2,
        );
      }
    }
    final pin =
        drag ??
        (location?.hasPoint == true
            ? g.point(location!.x!, location!.y!)
            : null);
    if (pin != null) {
      c.drawLine(
        g.home,
        pin,
        Paint()
          ..color = accent
          ..strokeWidth = 1.5,
      );
      c.drawCircle(pin, 7, Paint()..color = accent);
      c.drawCircle(
        pin,
        12,
        Paint()
          ..color = accent
          ..style = PaintingStyle.stroke,
      );
    }
    if (out) c.drawCircle(g.home, 10, Paint()..color = accent);
    if (labels) {
      label(c, 'LF', g.point(-.46, .62));
      label(c, 'CF', g.point(0, .82));
      label(c, 'RF', g.point(.46, .62));
      label(c, '65 ft bases · 300 ft fence', Offset(size.width / 2, 8));
      if (out) {
        label(c, '↓ OUT · location unknown', g.home + const Offset(0, 38));
      }
    }
    if (drag != null) {
      final l = g.locate(drag!);
      if (l != null) {
        label(c, l.label, Offset(size.width / 2, 35), color: accent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ContactPainter old) => true;
}
