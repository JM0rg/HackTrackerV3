import 'game.dart';

/// Computes the W / L / T result for a game from its scores. Mirrors the
/// server's GENERATED column logic on `games.result` exactly — they must
/// stay in lockstep so optimistic local writes match what sync pulls back.
///
/// Returns null until the game is final AND both scores are non-null.
String? computeGameResult({
  required GameStatus status,
  required int? ourScore,
  required int? oppScore,
}) {
  if (status != GameStatus.finalized || ourScore == null || oppScore == null) {
    return null;
  }
  if (ourScore > oppScore) return 'W';
  if (ourScore < oppScore) return 'L';
  return 'T';
}
