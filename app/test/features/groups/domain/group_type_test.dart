// Catches: GroupType.fromCode silently mis-mapping a server value or
// losing its safe fallback. Determines whether a group shows up in season
// filters vs tournament filters in the Games tab — a wrong mapping
// silently hides games from their group.
import 'package:app/features/groups/domain/group.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every defined code round-trips to its enum', () {
    for (final value in GroupType.values) {
      expect(
        GroupType.fromCode(value.code),
        value,
        reason: 'code=${value.code}',
      );
    }
  });

  test('null falls back to season', () {
    expect(GroupType.fromCode(null), GroupType.season);
  });

  test('unknown code falls back to season', () {
    expect(GroupType.fromCode('league'), GroupType.season);
    expect(GroupType.fromCode(''), GroupType.season);
  });
}
