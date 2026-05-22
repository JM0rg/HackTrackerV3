import 'package:freezed_annotation/freezed_annotation.dart';

part 'lineup.freezed.dart';

/// A batting/fielding lineup for a game. Pure domain model.
@freezed
abstract class Lineup with _$Lineup {
  const factory Lineup({
    required String id,
    required String gameId,
    required String teamId,
    String? name,
  }) = _Lineup;
}

/// One batting slot within a lineup. [fieldPosition] is a slowpitch position
/// code (P..RF, EH) or null.
@freezed
abstract class LineupSlot with _$LineupSlot {
  const factory LineupSlot({
    required String id,
    required String lineupId,
    required String teamId,
    required String playerId,
    required int battingOrder,
    String? fieldPosition,
  }) = _LineupSlot;
}
