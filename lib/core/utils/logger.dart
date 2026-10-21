import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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

  /// 最小日志级别：调试模式保留 info，发布模式至少保留 warning 便于排查问题
  static LogLevel _minLevel = kReleaseMode ? LogLevel.warning : LogLevel.info;

  /// 是否启用文件日志
  static bool _fileLoggingEnabled = false;

  /// 日志文件句柄
  static late File _logFile;

  /// 串行化文件写入，避免并发追加时日志行交错
  static Future<void> _pendingFileWrite = Future<void>.value();

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 初始化文件日志（在 main.dart 中调用一次即可）
  ///
  /// 默认写入应用支持目录，避免系统清理临时目录时丢失排查日志；
  /// 测试可通过 [logDirPath] 指定临时目录。
  static Future<void> initFileLogging({String? logDirPath}) async {
    if (_fileLoggingEnabled) return;
    try {
      final dir = logDirPath != null
          ? Directory(logDirPath)
          : await getApplicationSupportDirectory();
      final logDir = Directory(path.join(dir.path, 'log'));
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
    final sb = StringBuffer();
    sb.writeln(logMessage);
    if (error != null) {
      sb.writeln('  Error: $error');
    }
    if (stackTrace != null) {
      sb.writeln('  StackTrace: $stackTrace');
    }
    final text = sb.toString();

    _pendingFileWrite = _pendingFileWrite.then((_) async {
      if (!_fileLoggingEnabled) return;
      try {
        await _logFile.writeAsString(text, mode: FileMode.append);
      } catch (_) {
        _fileLoggingEnabled = false;
      }
    });
  }

  /// 等待已排队的文件日志全部落盘（测试用）。
  @visibleForTesting
  static Future<void> flushFileWrites() => _pendingFileWrite;
}
