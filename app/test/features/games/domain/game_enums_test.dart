// Catches: HomeAway / GameStatus.fromCode silently mis-mapping a server
// value. GameStatus is especially sensitive because the Dart name
// `finalized` differs from the server's `final` (reserved word) — losing
// that bridge silently demotes every completed game back to "scheduled".
import 'package:app/features/games/domain/game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeAway.fromCode', () {
    test('every defined code round-trips to its enum', () {
      for (final value in HomeAway.values) {
        expect(
          HomeAway.fromCode(value.code),
          value,
          reason: 'code=${value.code}',
        );
      }
    });

    test('null falls back to home', () {
      expect(HomeAway.fromCode(null), HomeAway.home);
    });

    test('unknown code falls back to home', () {
      expect(HomeAway.fromCode('road'), HomeAway.home);
      expect(HomeAway.fromCode(''), HomeAway.home);
    });
  });

  group('GameStatus.fromCode', () {
    test('every defined code round-trips to its enum', () {
      for (final value in GameStatus.values) {
        expect(
          GameStatus.fromCode(value.code),
          value,
          reason: 'code=${value.code}',
        );
      }
    });

    test('"final" maps to GameStatus.finalized (reserved-word bridge)', () {
      expect(GameStatus.fromCode('final'), GameStatus.finalized);
    });

    test('null falls back to scheduled', () {
      expect(GameStatus.fromCode(null), GameStatus.scheduled);
    });

    test(
      'unknown code falls back to scheduled (never silently completes a game)',
      () {
        expect(GameStatus.fromCode('played'), GameStatus.scheduled);
        expect(GameStatus.fromCode(''), GameStatus.scheduled);
      },
    );
  });
}
