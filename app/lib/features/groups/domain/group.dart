import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';

/// A group is either a recurring season or a one-off tournament.
enum GroupType {
  season('season', 'Season'),
  tournament('tournament', 'Tournament');

  const GroupType(this.code, this.label);
  final String code;
  final String label;

  static GroupType fromCode(String? code) =>
      GroupType.values.where((g) => g.code == code).firstOrNull ??
      GroupType.season;
}

/// A season or tournament that games belong to (many-to-many via game_groups).
/// Pure domain model — no Drift/Supabase types.
@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,
    required String teamId,
    required String name,
    required GroupType groupType,
    String? leagueName,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) = _Group;
}
