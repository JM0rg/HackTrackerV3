import 'package:freezed_annotation/freezed_annotation.dart';

part 'player.freezed.dart';

enum Handedness {
  left('left', 'Left'),
  right('right', 'Right');

  const Handedness(this.code, this.label);
  final String code;
  final String label;

  static Handedness? fromCode(String? code) => code == null
      ? null
      : Handedness.values.where((h) => h.code == code).firstOrNull;
}

enum BattingSide {
  left('left', 'Left'),
  right('right', 'Right'),
  switchHitter('switch', 'Switch');

  const BattingSide(this.code, this.label);
  final String code;
  final String label;

  static BattingSide? fromCode(String? code) => code == null
      ? null
      : BattingSide.values.where((b) => b.code == code).firstOrNull;
}

enum PlayerStatus {
  fullTime('full_time', 'Full-time'),
  sub('sub', 'Sub'),
  inactive('inactive', 'Inactive'),
  injured('injured', 'Injured');

  const PlayerStatus(this.code, this.label);
  final String code;
  final String label;

  static PlayerStatus fromCode(String? code) =>
      PlayerStatus.values.where((s) => s.code == code).firstOrNull ??
      PlayerStatus.fullTime;
}

/// A roster player. Pure domain model.
@freezed
abstract class Player with _$Player {
  const factory Player({
    required String id,
    required String teamId,
    required String name,
    required PlayerStatus status,
    @Default([]) List<String> defaultPositions,
    String? jerseyNumber,
    Handedness? throws,
    BattingSide? bats,
    String? gender,
    String? phone,
    String? email,
  }) = _Player;
}
