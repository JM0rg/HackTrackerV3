import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../data/groups_repository.dart';
import '../../domain/group.dart';

part 'group_edit_controller.freezed.dart';

@freezed
abstract class GroupFormState
    with _$GroupFormState
    implements BaseNotifierState<GroupFormState> {
  const factory GroupFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _GroupFormState;

  const GroupFormState._();

  @override
  GroupFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  GroupFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Backs the create/edit group form. Null `id` creates; otherwise updates.
class GroupEditController extends Notifier<GroupFormState>
    with BaseNotifierMixin<GroupFormState> {
  @override
  GroupFormState build() => const GroupFormState();

  GroupsRepository get _repo => ref.read(groupsRepositoryProvider);

  Future<bool> save({
    String? id,
    required String teamId,
    required String name,
    required GroupType groupType,
    String? leagueName,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    if (teamId.trim().isEmpty) {
      state = state.withError('Pick a team for this group');
      return Future.value(false);
    }
    if (name.trim().isEmpty) {
      state = state.withError('Group name is required');
      return Future.value(false);
    }
    return guard(
      () async => id == null
          ? (await _repo.create(
              teamId: teamId,
              name: name.trim(),
              groupType: groupType,
              leagueName: _blankToNull(leagueName),
              location: _blankToNull(location),
              startDate: startDate,
              endDate: endDate,
            )).map((_) {})
          : _repo.update(
              id,
              name: name.trim(),
              groupType: groupType,
              leagueName: _blankToNull(leagueName),
              location: _blankToNull(location),
              startDate: startDate,
              endDate: endDate,
            ),
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final groupEditControllerProvider =
    NotifierProvider.autoDispose<GroupEditController, GroupFormState>(
      GroupEditController.new,
    );
