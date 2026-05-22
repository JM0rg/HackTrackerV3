import 'package:freezed_annotation/freezed_annotation.dart';

part 'team.freezed.dart';

/// Classification driving coed lineup rules (future) and filtering.
enum TeamType {
  mens('mens', "Men's"),
  womens('womens', "Women's"),
  coed('coed', 'Coed');

  const TeamType(this.code, this.label);

  /// The value stored in the DB.
  final String code;

  /// The human-readable label.
  final String label;

  static TeamType fromCode(String? code) =>
      TeamType.values.firstWhere((t) => t.code == code, orElse: () => coed);
}

/// A team the user owns. Pure domain model — no Drift/Supabase types.
@freezed
abstract class Team with _$Team {
  const factory Team({
    required String id,
    required String name,
    required TeamType teamType,
    String? logoPath,
    String? primaryColor,
    String? secondaryColor,
  }) = _Team;
}
