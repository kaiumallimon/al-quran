import 'dart:developer' as developer;

/// Structured logging utility.
class AppLogger {
  AppLogger._();

  static void info(String tag, String message) {
    developer.log(message, name: tag, level: 800);
  }

  static void warning(String tag, String message) {
    developer.log(message, name: tag, level: 900);
  }

  static void error(String tag, String message, [Object? error]) {
    developer.log(
      message,
      name: tag,
      level: 1000,
      error: error,
    );
  }
}
