import 'dart:ui' show FontFeature, Offset;

/// Scoreboard digits line up in columns, so they are always tabular.
const tabularFigures = <FontFeature>[FontFeature.tabularFigures()];

/// Where everything sits on the diamond, in logical pixels, for a given width.
/// Designed at 280 wide and scaled from there so drags feel the same on every
/// phone.
class FieldGeometry {
  FieldGeometry(this.width) : scale = width / 280;

  final double width;
  final double scale;

  double get height => 240 * scale;

  Offset get home => Offset(140, 206) * scale;
  Offset get first => Offset(238, 122) * scale;
  Offset get second => Offset(140, 42) * scale;
  Offset get third => Offset(42, 122) * scale;

  /// Above this line is over the fence.
  double get fenceY => 34 * scale;

  /// Below this line is an out.
  double get outY => (206 + 38) * scale;

  /// How far from the plate a drag must travel before it means anything.
  double get deadZone => 26 * scale;

  /// How close to a base counts as that base.
  double get snap => 80 * scale;

  Offset base(int number) {
    return switch (number) {
      1 => first,
      2 => second,
      3 => third,
      _ => home,
    };
  }
}
