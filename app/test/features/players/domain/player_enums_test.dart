// Catches: Handedness / BattingSide / PlayerStatus.fromCode silently
// mis-mapping a server value or losing their null-vs-default contract.
// Server emits the `code` field; if the mapping drifts, every pulled
// player row reads as the wrong handedness/status with no error.
import 'package:app/features/players/domain/player.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Handedness.fromCode', () {
    test('every defined code round-trips to its enum', () {
      for (final value in Handedness.values) {
        expect(
          Handedness.fromCode(value.code),
          value,
          reason: 'code=${value.code}',
        );
      }
    });
    test('null returns null (no default)', () {
      expect(Handedness.fromCode(null), isNull);
    });
    test('unknown code returns null (no silent fallback)', () {
      expect(Handedness.fromCode('switch'), isNull);
      expect(Handedness.fromCode(''), isNull);
      expect(Handedness.fromCode('LEFT'), isNull); // case-sensitive
    });
  });

  group('BattingSide.fromCode', () {
    test('every defined code round-trips to its enum', () {
      for (final value in BattingSide.values) {
        expect(
          BattingSide.fromCode(value.code),
          value,
          reason: 'code=${value.code}',
        );
      }
    });
    test(
      '"switch" maps to BattingSide.switchHitter (reserved-word workaround)',
      () {
        // The Dart enum is `switchHitter` because `switch` is a reserved word,
        // but the server code is the bare string 'switch' — must not regress.
        expect(BattingSide.fromCode('switch'), BattingSide.switchHitter);
      },
    );
    test('null returns null', () {
      expect(BattingSide.fromCode(null), isNull);
    });
    test('unknown code returns null', () {
      expect(BattingSide.fromCode('both'), isNull);
      expect(BattingSide.fromCode(''), isNull);
    });
  });

  group('PlayerStatus.fromCode', () {
    test('every defined code round-trips to its enum', () {
      for (final value in PlayerStatus.values) {
        expect(
          PlayerStatus.fromCode(value.code),
          value,
          reason: 'code=${value.code}',
        );
      }
    });
    test('"full_time" maps to fullTime (snake_case ↔ camelCase contract)', () {
      expect(PlayerStatus.fromCode('full_time'), PlayerStatus.fullTime);
    });
    test('null falls back to fullTime (default)', () {
      expect(PlayerStatus.fromCode(null), PlayerStatus.fullTime);
    });
    test(
      'unknown code falls back to fullTime (server never silently drops a player)',
      () {
        expect(PlayerStatus.fromCode('retired'), PlayerStatus.fullTime);
        expect(PlayerStatus.fromCode(''), PlayerStatus.fullTime);
      },
    );
  });
}
