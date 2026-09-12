import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:hacktracker/core/domain/models/contact_location.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_surface.dart';

/// True scale: 65-foot basepaths and a 300-foot radial fence. Controls are
/// independently sized; field geometry never stretches to enlarge touch targets.
class ContactFieldGeometry {
  ContactFieldGeometry(this.size, {this.origin, this.fieldRadius});
  final Offset? origin;
  final double? fieldRadius;
  final Size size;

  /// The fence, as large as the box allows. The fan is 1.41 fence-lengths
  /// across, so the width leaves a hair either side; below the plate there is
  /// room for the plate itself and the out line under it.
  double get radius =>
      fieldRadius ?? math.min(size.width / 1.5, size.height - _below - _above);
  Offset get home => origin ?? Offset(size.width / 2, radius + _above);

  static const _above = 10.0;
  static const _below = 52.0;
  Offset point(double x, double y) => home + Offset(x * radius, -y * radius);
  Offset get first => point(65 / 300 / math.sqrt2, 65 / 300 / math.sqrt2);
  Offset get second => point(0, 65 / 300 * math.sqrt2);
  Offset get third => point(-65 / 300 / math.sqrt2, 65 / 300 / math.sqrt2);

  /// The nearest point on the field itself: inside the foul lines, and no
  /// deeper than the fence. A batted ball a runner reached base on was fair
  /// and stayed in the park, and there is no field drawn anywhere else.
  Offset onField(Offset p) {
    final v = p - home;
    if (v.distance < 0.001) return home;
    final angle = math.atan2(v.dx, -v.dy).clamp(-math.pi / 4, math.pi / 4);
    final reach = math.min(v.distance, radius);
    return home + Offset(math.sin(angle), -math.cos(angle)) * reach;
  }

  ContactLocation? locate(Offset p) {
    final on = onField(p);
    final x = (on.dx - home.dx) / radius, y = (home.dy - on.dy) / radius;
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
          widget.geometry?.size ?? Size(c.maxWidth, c.maxWidth * .72 + 60);
      final g = widget.geometry ?? ContactFieldGeometry(size);
      final onField = widget.fieldMode || widget.drawSurface;
      Offset aim(Offset p) =>
          p.dy > g.home.dy + 22 ? p : p - const Offset(0, 32);
      void hold(Offset? p) {
        if (!mounted) return;
        // Below the plate is the shortcut to an out, not a place on the field,
        // so it is the one point that is left where the finger put it.
        final out = p != null && widget.onOut != null && p.dy > g.home.dy + 22;
        setState(() => _drag = p == null || out ? p : g.onField(p));
      }

      void finish(Offset p) {
        hold(null);
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
          // Touch down and the ball is already on the line, under the finger.
          // Slide and it lifts clear so it can be seen; let go to place it.
          onPanDown: widget.onLocation == null
              ? null
              : (d) => hold(d.localPosition),
          onTapUp: widget.onLocation == null
              ? null
              : (d) => finish(d.localPosition),
          onPanStart: widget.onLocation == null
              ? null
              : (d) => hold(aim(d.localPosition)),
          onPanUpdate: widget.onLocation == null
              ? null
              : (d) => hold(aim(d.localPosition)),
          onPanEnd: widget.onLocation == null
              ? null
              : (_) {
                  if (_drag != null) finish(_drag!);
                },
          onPanCancel: () => hold(null),
          child: CustomPaint(
            size: size,
            painter: _ContactPainter(
              g,
              widget.location,
              _drag,
              widget.marks,
              // Marks sit on turf whenever the field is drawn, so they take
              // the field's colours, not the page's.
              onField ? context.colors.field.accent : context.colors.accent,
              onField ? context.colors.field.lineStrong : context.colors.border,
              onField ? context.colors.field.muted : context.colors.muted,
              widget.showLabels,
              widget.drawSurface,
              widget.onOut != null,
              context.text.bodyMedium?.fontFamily,
              onField ? context.colors.field.spray : context.colors.danger,
              context.colors.field,
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
    this.spray,
    this.palette,
  );
  final ContactFieldGeometry g;
  final ContactLocation? location;
  final Offset? drag;
  final List<({ContactLocation location, bool hit})> marks;
  final Color accent, line, text;
  final bool labels, out, drawSurface;
  final String? fontFamily;

  /// The batted ball's path from the plate.
  final Color spray;

  /// The field's own materials, for the surface.
  final FieldPalette palette;

  /// The flight from home to [pin]: a chord bowed away from the centre line,
  /// so a ball down the line hooks and one up the middle stays straight.
  Path _flight(Offset pin) {
    final chord = pin - g.home;
    final away =
        (pin.dx - g.home.dx) / ((pin.dx - g.home.dx).abs() + g.radius * .3);
    final bow = Offset(-chord.dy, chord.dx) * (0.16 * away);
    final control = g.home + chord * 0.5 + bow;
    return Path()
      ..moveTo(g.home.dx, g.home.dy)
      ..quadraticBezierTo(control.dx, control.dy, pin.dx, pin.dy);
  }

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
      // The field the game is scored on, fence laid on this chart's fence, so
      // a ball comes down here exactly where it was placed there. That field
      // draws its infield larger than life so the bases can be tapped, and
      // the chart is measured against the same drawing.
      final field = FieldGeometry.forFence(g.radius);
      c.save();
      c.translate(g.home.dx - field.home.dx, g.home.dy - field.home.dy);
      FieldSurface.paint(c, field, palette);
      c.restore();
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
      final flight = _flight(pin);
      c.drawPath(
        flight,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = spray.withValues(alpha: .30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      c.drawPath(
        flight,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..color = spray,
      );
      c.drawCircle(pin, 6, Paint()..color = spray);
      c.drawCircle(
        pin,
        11,
        Paint()
          ..color = spray.withValues(alpha: .55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
    if (out) c.drawCircle(g.home, 10, Paint()..color = accent);
    if (labels) {
      label(c, 'LF', g.point(-.46, .62));
      label(c, 'CF', g.point(0, .82));
      label(c, 'RF', g.point(.46, .62));
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
