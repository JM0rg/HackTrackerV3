// Catches: the sign-in regex drifting too loose (accepts "foo@bar" so the
// app fires a doomed Supabase OTP request) or too strict (rejects legit
// tagged/uppercase/whitespace-padded addresses, blocking real signups).
import 'package:app/core/utils/email_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('accepts well-formed addresses', () {
    const cases = [
      'a@b.co',
      'jordan@example.com',
      'jordan.doe@example.com',
      'jordan+tag@example.com',
      'JORDAN@EXAMPLE.COM',
      'jordan@sub.example.com',
      '  jordan@example.com  ', // whitespace is trimmed before matching
    ];
    for (final input in cases) {
      test('accepts: "$input"', () {
        expect(EmailValidator.isValid(input), isTrue);
      });
    }
  });

  group('rejects malformed addresses', () {
    const cases = [
      '',
      'jordan',
      'jordan@',
      '@example.com',
      'jordan@example', // no TLD
      'jordan @example.com', // internal space
      'jordan@example .com',
      'jordan@.com',
      'jordan@example.c', // TLD too short
      'jordan@@example.com',
    ];
    for (final input in cases) {
      test('rejects: "$input"', () {
        expect(EmailValidator.isValid(input), isFalse);
      });
    }
  });
}
