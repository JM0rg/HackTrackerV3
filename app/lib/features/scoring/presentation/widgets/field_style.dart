import 'dart:math' as math;
import 'dart:ui' show FontFeature, Offset;

/// Scoreboard digits line up in columns, so they are always tabular.
const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

/// A softball field seen from behind the plate: home at the bottom, foul lines
/// opening to a right angle, and a fence swept around them at a constant
/// radius. Everything is stated in design units for a 300-wide field and
/// scaled from there, so a drag feels the same on every phone.
///
/// The infield is drawn about 1.6x life size. At true scale — 65-foot
/// basepaths inside a 300-foot fence — the bases would sit close enough
/// together that their touch targets would overlap. The outfield still takes
/// the greater half of the depth, which is what makes it read as a field.
class FieldGeometry {
  FieldGeometry(this.width) : scale = width / design;

  /// The field whose fence is [radius] from the plate — for drawing it around
  /// a set of points already measured in fence-lengths, like a spray chart.
  factory FieldGeometry.forFence(double radius) =>
      FieldGeometry(radius * design / _fence);

  /// The width every measurement below is quoted at, and the height that
  /// goes with it.
  static const design = 300.0;
  static const designHeight = 266.0;

  /// Home to the fence, straightaway.
  static const _fence = 200.0;

  /// Home to first, drawn.
  static const _basepath = 68.0;

  /// The wall's apex sits 14 units under the top of the box: nothing above
  /// it but the tap zone for a home run.
  static const _homeY = 214.0;

  final double width;
  final double scale;

  double get height => designHeight * scale;

  Offset get home => const Offset(design / 2, _homeY) * scale;

  /// The fence, and the foul lines that meet it at 45 degrees either side.
  double get fenceRadius => _fence * scale;

  Offset get first =>
      home + Offset(_basepath, -_basepath) * (math.sqrt1_2 * scale);
  Offset get second => home - Offset(0, _basepath * math.sqrt2 * scale);
  Offset get third =>
      home + Offset(-_basepath, -_basepath) * (math.sqrt1_2 * scale);

  /// Straightaway centre field: the top of the fence, and the only place the
  /// old flat-topped field agreed with this one.
  double get fenceY => home.dy - fenceRadius;

  /// Where the pitcher stands, 50 feet of a 65-foot basepath up the middle.
  Offset get pitcher => home - Offset(0, _basepath * (50 / 65) * scale);

  /// Below this line is an out.
  double get outY => home.dy + 36 * scale;

  /// How far from the plate a drag must travel before it means anything.
  double get deadZone => 24 * scale;

  /// A base's touch target, kept clear of its neighbours on small phones.
  double get baseTouch => math.min(52.0, _basepath * scale * 0.82);

  Offset base(int number) {
    return switch (number) {
      1 => first,
      2 => second,
      3 => third,
      _ => home,
    };
  }
}
