import 'dart:developer' as developer;

/// Thin logging facade. Boundaries log failures here instead of swallowing
/// them; never use `print`.
abstract final class AppLogger {
  static void error(String message, [Object? error, StackTrace? stack]) {
    developer.log(
      message,
      name: 'hacktracker',
      level: 1000,
      error: error,
      stackTrace: stack,
    );
  }
}
