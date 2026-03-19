import 'package:flutter/foundation.dart';

/// 日志级别枚举
enum LogLevel {
  /// 调试级别
  debug,
  /// 信息级别
  info,
  /// 警告级别
  warning,
  /// 错误级别
  error,
}

/// 日志工具类
class Logger {
  Logger._();

  /// 默认日志标签
  static const String _defaultTag = 'TinyCast';

  /// 最小日志级别（调试模式下为 debug，否则为 info）
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 输出调试日志
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// 输出信息日志
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// 输出警告日志
  static void warning(String message, {String? tag}) {
    _log(LogLevel.warning, message, tag: tag);
  }

  /// 输出错误日志
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// 内部日志记录方法
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
        debugPrint('错误: $error');
      }
      if (stackTrace != null) {
        debugPrint('堆栈跟踪: $stackTrace');
      }
    }
  }
}
