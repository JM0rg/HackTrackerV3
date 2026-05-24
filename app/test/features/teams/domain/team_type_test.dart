// Catches: TeamType.fromCode silently mis-mapping a server value or
// losing its safe fallback. Server emits `team_type` strings; if the
// mapping breaks, every team reads as the wrong type with no error.
import 'package:app/features/teams/domain/team.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every defined code round-trips to its enum', () {
    for (final value in TeamType.values) {
      expect(
        TeamType.fromCode(value.code),
        value,
        reason: 'code=${value.code}',
      );
    }
  });

  test(
    'null falls back to coed (a team that exists must always have a type)',
    () {
      expect(TeamType.fromCode(null), TeamType.coed);
    },
  );

  test(
    'unknown code falls back to coed (forward-compat with new server values)',
    () {
      expect(TeamType.fromCode('rec'), TeamType.coed);
      expect(TeamType.fromCode(''), TeamType.coed);
      expect(TeamType.fromCode('MENS'), TeamType.coed); // case-sensitive
    },
  );
}
