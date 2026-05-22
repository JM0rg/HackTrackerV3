/// Slowpitch field positions. Codes are the canonical values stored in the DB
/// (`players.default_positions` and `lineup_slots.field_position`) and validated
/// against the same allow-list server-side.
enum FieldPosition {
  pitcher('P', 'Pitcher'),
  catcher('C', 'Catcher'),
  first('1B', 'First Base'),
  second('2B', 'Second Base'),
  third('3B', 'Third Base'),
  shortstop('SS', 'Shortstop'),
  leftField('LF', 'Left Field'),
  leftCenter('LCF', 'Left Center'),
  rightCenter('RCF', 'Right Center'),
  rightField('RF', 'Right Field'),
  extraHitter('EH', 'Extra Hitter');

  const FieldPosition(this.code, this.label);

  final String code;
  final String label;

  static FieldPosition? fromCode(String? code) {
    if (code == null) return null;
    for (final p in FieldPosition.values) {
      if (p.code == code) return p;
    }
    return null;
  }
}
