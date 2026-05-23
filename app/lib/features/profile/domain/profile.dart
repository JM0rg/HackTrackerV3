import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';

/// The signed-in user's identity. Pure domain model — no Drift/Supabase types.
@freezed
abstract class Profile with _$Profile {
  const factory Profile({
    required String id,
    String? displayName,
    String? avatarPath,
  }) = _Profile;

  const Profile._();

  /// True once the user has completed the "What should we call you?" step.
  bool get hasDisplayName =>
      displayName != null && displayName!.trim().isNotEmpty;
}
