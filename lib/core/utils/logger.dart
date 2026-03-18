import 'package:flutter/foundation.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
}

class Logger {
  Logger._();

  static const String _defaultTag = 'TinyCast';

  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  static void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (level.index < _minLevel.index) {
      return;
    }

    final logTag = tag ?? _defaultTag;
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase();

    final logMessage = '[$timestamp] [$levelStr] [$logTag] $message';

    if (kDebugMode) {
      debugPrint(logMessage);
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }
}
