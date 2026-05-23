import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../../../core/di/supabase_providers.dart';
import '../../../profile/data/profile_repository.dart';

part 'welcome_controller.freezed.dart';

@freezed
abstract class WelcomeFormState
    with _$WelcomeFormState
    implements BaseNotifierState<WelcomeFormState> {
  const factory WelcomeFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _WelcomeFormState;

  const WelcomeFormState._();

  @override
  WelcomeFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  WelcomeFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Saves the user's display name on the welcome step. The router redirect
/// picks up the profile change and advances to the next onboarding screen.
class WelcomeController extends Notifier<WelcomeFormState>
    with BaseNotifierMixin<WelcomeFormState> {
  @override
  WelcomeFormState build() => const WelcomeFormState();

  Future<bool> saveDisplayName(String name) {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      state = state.withError('You must be signed in');
      return Future.value(false);
    }
    return guard(
      () => ref
          .read(profilesRepositoryProvider)
          .setDisplayName(id: userId, displayName: name),
    );
  }
}

final welcomeControllerProvider =
    NotifierProvider<WelcomeController, WelcomeFormState>(
      WelcomeController.new,
    );
