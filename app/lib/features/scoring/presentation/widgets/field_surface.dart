import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/app_palette.dart';
import 'package:hacktracker/features/scoring/presentation/widgets/field_style.dart';

/// The field, in nine layers: turf, mow pattern, warning track, skinned
/// infield, mottle, chalk, bags, wall, light. One painter for every field in
/// the app — the one you score on and the one your spray chart is drawn on —
/// so a ball lands on the chart exactly where it was placed.
///
/// Every layer depends only on the field's size and the palette, never on a
/// play, so each size is recorded once into a [ui.Picture] and replayed as a
/// single draw call.
abstract final class FieldSurface {
  /// The fan of fair territory: 45 degrees either side of straightaway.
  static const _start = -3 * math.pi / 4;
  static const _sweep = math.pi / 2;

  /// A handful of recorded fields, by size and palette. More than one field
  /// can be on screen, and a phone only ever has a few sizes.
  static final _cache = <(double, FieldPalette), ui.Picture>{};

  /// Fair territory, as a path.
  static Path fan(FieldGeometry g) {
    final foulLeft =
        g.home + Offset(-g.fenceRadius, -g.fenceRadius) * math.sqrt1_2;
    return Path()
      ..moveTo(g.home.dx, g.home.dy)
      ..lineTo(foulLeft.dx, foulLeft.dy)
      ..arcTo(
        Rect.fromCircle(center: g.home, radius: g.fenceRadius),
        _start,
        _sweep,
        false,
      )
      ..close();
  }

  /// Draw the field with its plate at [g]'s home, in the canvas as it stands.
  static void paint(Canvas canvas, FieldGeometry g, FieldPalette palette) {
    final key = (g.width, palette);
    var picture = _cache[key];
    if (picture == null) {
      // Never disposed: another painter may still be replaying it.
      if (_cache.length >= 6) _cache.remove(_cache.keys.first);
      final recorder = ui.PictureRecorder();
      _record(Canvas(recorder), g, palette);
      picture = _cache[key] = recorder.endRecording();
    }
    canvas.drawPicture(picture);
  }

  static void _record(Canvas canvas, FieldGeometry g, FieldPalette palette) {
    final R = g.fenceRadius;
    final outfield = Rect.fromCircle(center: g.home, radius: R);
    final foulLeft = g.home + Offset(-R, -R) * math.sqrt1_2;
    final foulRight = g.home + Offset(R, -R) * math.sqrt1_2;
    final fair = fan(g);

    // 1 — turf, with the light coming from the outfield.
    canvas.save();
    canvas.clipPath(fair);
    canvas.drawRect(
      outfield.inflate(8),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(g.home.dx, g.home.dy - R),
          g.home,
          [_lift(palette.turf, .05), palette.turf],
        ),
    );

    // 2 — the mow pattern: wedges fanned from the plate, every other one cut
    // the opposite way, the way a mower turns at the warning track.
    if (palette.textured) {
      final mow = Paint()
        ..color = const Color(0xFFFFFFFF).withValues(alpha: .022);
      for (var i = 0; i < 9; i += 2) {
        final a0 = _start + i * _sweep / 9;
        canvas.drawPath(
          Path()
            ..moveTo(g.home.dx, g.home.dy)
            ..arcTo(outfield, a0, _sweep / 9, false)
            ..close(),
          mow,
        );
      }
    }

    // 3 — the warning track: ground in front of the wall.
    canvas.drawArc(
      Rect.fromCircle(center: g.home, radius: R * 0.973),
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = R * 0.055
        ..color = palette.track,
    );

    // 4 — the skinned infield, swung from the rubber and cut by the foul
    // lines, plus the ring around the plate.
    final skin = (g.second - g.pitcher).distance * 1.32;
    canvas.drawCircle(
      g.pitcher,
      skin,
      Paint()
        ..shader = ui.Gradient.radial(g.pitcher - Offset(0, skin * .4), skin, [
          _lift(palette.dirt, .06),
          palette.dirt,
        ]),
    );
    canvas.drawCircle(
      g.home,
      (g.first - g.home).distance * 0.42,
      Paint()..color = palette.dirt,
    );
    // The lip: the skin sits proud of the turf.
    canvas.drawCircle(
      g.pitcher,
      skin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, R * .005)
        ..color = _lift(palette.dirt, .18).withValues(alpha: .5),
    );

    // 5 — mottle: turf is never one flat value. Large and soft rather than
    // per-pixel grain, which at this size would cost more than it shows.
    if (palette.textured) {
      const spots = [
        Offset(-.42, .58),
        Offset(.36, .70),
        Offset(-.10, .34),
        Offset(.52, .40),
        Offset(-.60, .30),
        Offset(.08, .84),
      ];
      for (var i = 0; i < spots.length; i++) {
        final at = g.home + Offset(spots[i].dx * R, -spots[i].dy * R);
        final blur = R * (0.22 + (i.isEven ? .06 : 0));
        canvas.drawCircle(
          at,
          blur,
          Paint()
            ..color = (i.isEven ? Colors.white : Colors.black).withValues(
              alpha: .018,
            )
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur * .7),
        );
      }
    }
    canvas.restore();

    // 6 — chalk. The brightest thing on a field, and until now the same grey
    // as the fence.
    final chalk = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, R * .007)
      ..color = palette.chalk.withValues(alpha: .62);
    canvas.drawLine(g.home, foulLeft, chalk);
    canvas.drawLine(g.home, foulRight, chalk);
    canvas.drawPath(
      Path()
        ..moveTo(g.home.dx, g.home.dy)
        ..lineTo(g.first.dx, g.first.dy)
        ..lineTo(g.second.dx, g.second.dy)
        ..lineTo(g.third.dx, g.third.dy)
        ..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, R * .006)
        ..color = palette.chalk.withValues(alpha: .46),
    );
    canvas.drawCircle(
      g.pitcher,
      R * .065,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, R * .005)
        ..color = palette.chalk.withValues(alpha: .42),
    );

    // 7 — the rubber, and home plate: five sides, flat edge to the pitcher.
    canvas.drawRect(
      Rect.fromCenter(center: g.pitcher, width: R * .056, height: R * .013),
      Paint()..color = palette.bag,
    );
    final p = R * .030;
    canvas.drawPath(
      Path()
        ..moveTo(g.home.dx - p, g.home.dy - p * .6)
        ..lineTo(g.home.dx + p, g.home.dy - p * .6)
        ..lineTo(g.home.dx + p, g.home.dy + p * .2)
        ..lineTo(g.home.dx, g.home.dy + p)
        ..lineTo(g.home.dx - p, g.home.dy + p * .2)
        ..close(),
      Paint()..color = palette.bag,
    );

    // 8 — the wall.
    canvas.drawArc(
      outfield,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.5, R * .008)
        ..color = palette.fence,
    );

    // 9 — one lamp over the whole thing.
    if (palette.textured) {
      canvas.save();
      canvas.clipPath(fair);
      canvas.drawRect(
        outfield.inflate(8),
        Paint()
          ..shader = ui.Gradient.radial(
            Offset(g.home.dx, g.home.dy - R * .45),
            R * 1.25,
            [
              const Color(0xFFFFFFFF).withValues(alpha: .035),
              const Color(0x00000000),
              const Color(0xFF000000).withValues(alpha: .42),
            ],
            const [0, .55, 1],
          )
          ..blendMode = BlendMode.srcOver,
      );
      canvas.restore();
    }
  }

  /// Over the fence: the wall picks up the light.
  static void lightTheWall(
    Canvas canvas,
    FieldGeometry g,
    FieldPalette palette,
  ) {
    final rect = Rect.fromCircle(center: g.home, radius: g.fenceRadius);
    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5 * g.scale
        ..color = palette.accent.withValues(alpha: .35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * g.scale),
    );
    canvas.drawArc(
      rect,
      _start,
      _sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * g.scale
        ..color = palette.accent,
    );
  }

  static Color _lift(Color base, double amount) =>
      Color.lerp(base, const Color(0xFFFFFFFF), amount)!;
}
