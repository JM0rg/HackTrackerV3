// Catches: UUID v4 spec drift (wrong version nibble, wrong variant bits,
// malformed shape) and RNG collisions. Either failure breaks sync —
// Postgres rejects malformed `uuid` PKs and a collision corrupts the
// offline-write contract.
import 'package:app/core/utils/uuid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns the canonical 8-4-4-4-12 lowercase-hex format', () {
    final id = Uuid.v4();
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('version nibble (char 14) is always "4"', () {
    for (var i = 0; i < 50; i++) {
      expect(Uuid.v4()[14], '4');
    }
  });

  test('variant nibble (char 19) is always 8, 9, a, or b (RFC 4122)', () {
    for (var i = 0; i < 50; i++) {
      expect(Uuid.v4()[19], anyOf('8', '9', 'a', 'b'));
    }
  });

  test('2000 calls produce no duplicates', () {
    final ids = List.generate(2000, (_) => Uuid.v4());
    expect(ids.toSet().length, ids.length);
  });
}
