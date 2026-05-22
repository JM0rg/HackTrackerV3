import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../data/players_repository.dart';
import '../../domain/player.dart';

part 'player_edit_controller.freezed.dart';

@freezed
abstract class PlayerFormState
    with _$PlayerFormState
    implements BaseNotifierState<PlayerFormState> {
  const factory PlayerFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _PlayerFormState;

  const PlayerFormState._();

  @override
  PlayerFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  PlayerFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Backs the create/edit player form. Null `id` creates; otherwise updates.
class PlayerEditController extends Notifier<PlayerFormState>
    with BaseNotifierMixin<PlayerFormState> {
  @override
  PlayerFormState build() => const PlayerFormState();

  PlayersRepository get _repo => ref.read(playersRepositoryProvider);

  Future<bool> save({
    String? id,
    required String teamId,
    required String name,
    required PlayerStatus status,
    String? jerseyNumber,
    Handedness? throws,
    BattingSide? bats,
    String? gender,
    List<String> defaultPositions = const [],
    String? phone,
    String? email,
  }) {
    if (name.trim().isEmpty) {
      state = state.withError('Player name is required');
      return Future.value(false);
    }
    return guard(
      () => id == null
          ? _repo.create(
              teamId: teamId,
              name: name.trim(),
              status: status,
              jerseyNumber: _blankToNull(jerseyNumber),
              throws: throws,
              bats: bats,
              gender: gender,
              defaultPositions: defaultPositions,
              phone: _blankToNull(phone),
              email: _blankToNull(email),
            )
          : _repo.update(
              id,
              name: name.trim(),
              status: status,
              jerseyNumber: _blankToNull(jerseyNumber),
              throws: throws,
              bats: bats,
              gender: gender,
              defaultPositions: defaultPositions,
              phone: _blankToNull(phone),
              email: _blankToNull(email),
            ),
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final playerEditControllerProvider =
    NotifierProvider<PlayerEditController, PlayerFormState>(
      PlayerEditController.new,
    );
