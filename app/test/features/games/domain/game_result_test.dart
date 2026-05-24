// Catches: local W/L/T computation diverging from the server's GENERATED
// column on `games.result`. Either side breaking the contract leads to a
// row whose `result` flickers between optimistic write and pulled-back
// value. Same status/score thresholds, same null-handling rules.
import 'package:app/features/games/domain/game.dart';
import 'package:app/features/games/domain/game_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('returns null when the game cannot yet have a result', () {
    test('every non-final status yields null even with both scores', () {
      for (final status in GameStatus.values.where(
        (s) => s != GameStatus.finalized,
      )) {
        expect(
          computeGameResult(status: status, ourScore: 7, oppScore: 5),
          isNull,
          reason: 'status=$status',
        );
      }
    });

    test('final + ourScore null yields null', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: null,
          oppScore: 5,
        ),
        isNull,
      );
    });

    test('final + oppScore null yields null', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: 7,
          oppScore: null,
        ),
        isNull,
      );
    });

    test('final + both scores null yields null', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: null,
          oppScore: null,
        ),
        isNull,
      );
    });
  });

  group('final + both scores yields W / L / T', () {
    test('our > opp returns W', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: 10,
          oppScore: 7,
        ),
        'W',
      );
    });

    test('our < opp returns L', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: 2,
          oppScore: 8,
        ),
        'L',
      );
    });

    test('our == opp returns T', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: 5,
          oppScore: 5,
        ),
        'T',
      );
    });

    test('0-0 final is a tie (not null)', () {
      expect(
        computeGameResult(
          status: GameStatus.finalized,
          ourScore: 0,
          oppScore: 0,
        ),
        'T',
      );
    });
  });
}
