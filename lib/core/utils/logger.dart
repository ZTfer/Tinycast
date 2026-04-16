import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

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
  static LogLevel _minLevel = kDebugMode ? LogLevel.info : LogLevel.error;

  /// 是否启用文件日志
  static bool _fileLoggingEnabled = false;

  /// 日志文件句柄
  static late File _logFile;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 初始化文件日志（在 main.dart 中调用一次即可）
  static Future<void> initFileLogging({String? logDirPath}) async {
    try {
      final dir = logDirPath != null
          ? Directory(logDirPath)
          : Directory.systemTemp;
      final logDir = Directory(path.join(dir.path, 'tinycast', 'log'));
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final logFilePath = path.join(logDir.path, '$dateStr.log');
      _logFile = File(logFilePath);

      if (!await _logFile.exists()) {
        await _logFile.create(recursive: true);
      }

      _fileLoggingEnabled = true;
      info('📝 [LOGGER] File logging initialized: $logFilePath');
    } catch (e) {
      _fileLoggingEnabled = false;
    }
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
  static void error(String message,
      {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message,
        error: error, stackTrace: stackTrace, tag: tag);
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

    if (_fileLoggingEnabled) {
      _writeToFile(logMessage, error: error, stackTrace: stackTrace);
    }
  }

  static void _writeToFile(String logMessage,
      {Object? error, StackTrace? stackTrace}) {
    try {
      final sb = StringBuffer();
      sb.writeln(logMessage);
      if (error != null) {
        sb.writeln('  Error: $error');
      }
      if (stackTrace != null) {
        sb.writeln('  StackTrace: $stackTrace');
      }
      _logFile.writeAsString(sb.toString(), mode: FileMode.append).catchError((_) {
        _fileLoggingEnabled = false;
        return _logFile;
      });
    } catch (_) {
      _fileLoggingEnabled = false;
    }
  }
}
