/// How an out was made. Optional detail on an out; a strikeout is its own
/// result because K is its own stat.
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
