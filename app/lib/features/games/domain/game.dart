import 'package:freezed_annotation/freezed_annotation.dart';

part 'game.freezed.dart';

/// Where the game is played, relative to our team.
enum HomeAway {
  home('home', 'Home'),
  away('away', 'Away'),
  neutral('neutral', 'Neutral');

  const HomeAway(this.code, this.label);
  final String code;
  final String label;

  static HomeAway fromCode(String? code) =>
      HomeAway.values.where((h) => h.code == code).firstOrNull ?? HomeAway.home;
}

/// Lifecycle of a scheduled/played game.
enum GameStatus {
  scheduled('scheduled', 'Scheduled'),
  live('live', 'Live'),
  finalized('final', 'Final'),
  postponed('postponed', 'Postponed'),
  cancelled('cancelled', 'Cancelled');

  const GameStatus(this.code, this.label);
  final String code;
  final String label;

  static GameStatus fromCode(String? code) =>
      GameStatus.values.where((s) => s.code == code).firstOrNull ??
      GameStatus.scheduled;
}

/// A scheduled or played game. Pure domain model — no Drift/Supabase types.
/// [result] (W/L/T) is derived from the scores when [status] is final.
@freezed
abstract class Game with _$Game {
  const factory Game({
    required String id,
    required String teamId,
    required HomeAway homeAway,
    required GameStatus status,
    String? opponentName,
    String? parkName,
    String? cityOrAddress,
    DateTime? startTime,
    int? ourScore,
    int? oppScore,
    String? result,
    String? notes,
  }) = _Game;
}
