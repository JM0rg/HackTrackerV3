import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../error/result.dart';

/// Contract for controller state that carries save/error plumbing. Freezed
/// state classes implement this by delegating to their generated `copyWith`.
abstract interface class BaseNotifierState<S> {
  bool get isSaving;
  String? get errorMessage;
  S withSaving(bool saving);
  S withError(String? error);
}

/// Wraps a mutating action in consistent saving/error state transitions so
/// every form controller behaves identically. Returns `true` on success.
mixin BaseNotifierMixin<S extends BaseNotifierState<S>> on Notifier<S> {
  Future<bool> guard(Future<Result<void>> Function() action) async {
    state = state.withSaving(true).withError(null);
    final result = await action();
    return result.when(
      ok: (_) {
        state = state.withSaving(false);
        return true;
      },
      err: (failure) {
        state = state.withSaving(false).withError(failure.message);
        return false;
      },
    );
  }
}
