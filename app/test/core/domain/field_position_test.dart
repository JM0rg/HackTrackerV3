// Catches: FieldPosition.fromCode silently mis-mapping a server position
// code. Codes are also CHECK-constrained server-side (P, C, 1B, 2B, 3B,
// SS, LF, LCF, RCF, RF, EH) — drift breaks lineup rendering for any slot.
import 'package:app/core/domain/field_position.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every defined code round-trips to its enum', () {
    for (final position in FieldPosition.values) {
      expect(
        FieldPosition.fromCode(position.code),
        position,
        reason: 'code=${position.code}',
      );
    }
  });

  test('null returns null', () {
    expect(FieldPosition.fromCode(null), isNull);
  });

  test('unknown code returns null (no silent fallback)', () {
    expect(FieldPosition.fromCode('XX'), isNull);
    expect(FieldPosition.fromCode(''), isNull);
    expect(FieldPosition.fromCode('p'), isNull); // case-sensitive
  });

  test('expected slowpitch position set is exactly 11 codes', () {
    // Locks the allow-list size so adding a code requires updating both
    // the enum AND the matching server CHECK constraint.
    expect(FieldPosition.values.map((p) => p.code).toSet(), {
      'P',
      'C',
      '1B',
      '2B',
      '3B',
      'SS',
      'LF',
      'LCF',
      'RCF',
      'RF',
      'EH',
    });
  });
}
