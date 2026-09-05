/// How much of a game a personal scorer keeps. Team games are always [game].
abstract final class GameScope {
  /// Just your at-bats. No score, no innings.
  static const bat = 'bat';

  /// Your at-bats plus both teams' scores, half by half.
  static const game = 'game';
}
