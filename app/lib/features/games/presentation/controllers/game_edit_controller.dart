import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/base/base_notifier.dart';
import '../../data/games_repository.dart';
import '../../domain/game.dart';

part 'game_edit_controller.freezed.dart';

@freezed
abstract class GameFormState
    with _$GameFormState
    implements BaseNotifierState<GameFormState> {
  const factory GameFormState({
    @Default(false) bool isSaving,
    String? errorMessage,
  }) = _GameFormState;

  const GameFormState._();

  @override
  GameFormState withSaving(bool saving) => copyWith(isSaving: saving);

  @override
  GameFormState withError(String? error) =>
      copyWith(errorMessage: error, isSaving: isSaving);
}

/// Backs the create/edit game form. Null `id` creates; otherwise updates.
class GameEditController extends Notifier<GameFormState>
    with BaseNotifierMixin<GameFormState> {
  @override
  GameFormState build() => const GameFormState();

  GamesRepository get _repo => ref.read(gamesRepositoryProvider);

  Future<bool> save({
    String? id,
    required String teamId,
    required HomeAway homeAway,
    required GameStatus status,
    String? opponentName,
    String? parkName,
    String? cityOrAddress,
    DateTime? startTime,
    int? ourScore,
    int? oppScore,
    String? notes,
  }) {
    if (teamId.trim().isEmpty) {
      state = state.withError('Pick a team for this game');
      return Future.value(false);
    }
    return guard(
      () async => id == null
          ? (await _repo.create(
              teamId: teamId,
              homeAway: homeAway,
              status: status,
              opponentName: _blankToNull(opponentName),
              parkName: _blankToNull(parkName),
              cityOrAddress: _blankToNull(cityOrAddress),
              startTime: startTime,
              ourScore: ourScore,
              oppScore: oppScore,
              notes: _blankToNull(notes),
            )).map((_) {})
          : _repo.update(
              id,
              homeAway: homeAway,
              status: status,
              opponentName: _blankToNull(opponentName),
              parkName: _blankToNull(parkName),
              cityOrAddress: _blankToNull(cityOrAddress),
              startTime: startTime,
              ourScore: ourScore,
              oppScore: oppScore,
              notes: _blankToNull(notes),
            ),
    );
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final gameEditControllerProvider =
    NotifierProvider<GameEditController, GameFormState>(GameEditController.new);
