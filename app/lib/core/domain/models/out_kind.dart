/// How a ball came off the bat. Every ball in play carries one, hit or out;
/// a strikeout and a walk carry none, because neither put a ball in play.
///
/// Named for outs because that is all it once described, and because the
/// column it is stored in is still `out_kind`. On an out it also decides the
/// result — see [scoresAsSacFly]; on a hit it is description only.
enum OutKind {
  fly,
  ground,
  line;

  String get wire => name;

  static OutKind? fromWire(String? value) {
    for (final kind in OutKind.values) {
      if (kind.wire == value) return kind;
    }
    return null;
  }

  String get label {
    return switch (this) {
      OutKind.fly => 'Fly',
      OutKind.ground => 'Ground',
      OutKind.line => 'Line',
    };
  }

  String get verb {
    return switch (this) {
      OutKind.fly => 'flied out',
      OutKind.ground => 'grounded out',
      OutKind.line => 'lined out',
    };
  }

  /// A run scoring on a ball in the air is a sacrifice fly. On the ground it
  /// is an RBI groundout, and the at-bat still counts.
  bool get scoresAsSacFly => this != OutKind.ground;
}
