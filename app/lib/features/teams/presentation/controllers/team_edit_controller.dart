import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../../../core/di/supabase_providers.dart';
import '../../data/teams_repository.dart';
import '../../domain/team.dart';

part 'team_edit_controller.freezed.dart';

@freezed
abstract class TeamFormState
    with _$TeamFormState
    implements BaseNotifierState<TeamFormState> {
  const factory TeamFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _TeamFormState;

  const TeamFormState._();

  @override
  TeamFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  TeamFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Backs the create/edit team form. Passing a null `id` creates; otherwise it
/// updates. Returns the team's id on success (so callers can auto-select the
/// newly-created team) or null on failure.
class TeamEditController extends Notifier<TeamFormState>
    with BaseNotifierMixin<TeamFormState> {
  @override
  TeamFormState build() => const TeamFormState();

  TeamsRepository get _repo => ref.read(teamsRepositoryProvider);

  Future<String?> save({
    String? id,
    required String name,
    required TeamType teamType,
    String? primaryColor,
    String? secondaryColor,
  }) async {
    if (name.trim().isEmpty) {
      state = state.withError('Team name is required');
      return null;
    }
    if (id == null) {
      final ownerId = ref.read(currentUserIdProvider);
      if (ownerId == null) {
        state = state.withError('You must be signed in');
        return null;
      }
      state = state.withSaving(true).withError(null);
      final result = await _repo.create(
        name: name.trim(),
        teamType: teamType,
        ownerId: ownerId,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );
      return result.when(
        ok: (newId) {
          state = state.withSaving(false);
          return newId;
        },
        err: (failure) {
          state = state.withSaving(false).withError(failure.message);
          return null;
        },
      );
    }
    final ok = await guard(
      () => _repo.update(
        id,
        name: name.trim(),
        teamType: teamType,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      ),
    );
    return ok ? id : null;
  }
}

final teamEditControllerProvider =
    NotifierProvider.autoDispose<TeamEditController, TeamFormState>(
      TeamEditController.new,
    );
