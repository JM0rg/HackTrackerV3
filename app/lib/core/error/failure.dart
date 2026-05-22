/// Typed failure hierarchy. Boundaries (DB, network, platform) convert raw
/// exceptions into one of these; domain code matches exhaustively.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable, safe to surface in UI state.
  final String message;
}

/// Local persistence (Drift) failed.
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

/// A remote Supabase call failed (sync, auth, storage).
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Authentication / authorization failed.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// User input failed validation before any side effect ran.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Anything not covered above.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
