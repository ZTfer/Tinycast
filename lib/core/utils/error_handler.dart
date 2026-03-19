import 'dart:async';
// import 'package:flutter/foundation.dart';
/// 应用异常类导入
import 'app_exception.dart';

/// 日志工具类导入
import 'logger.dart';

/// 错误处理类
class ErrorHandler {
  ErrorHandler._();

  /// 错误处理器列表
  static final List<void Function(AppException)> _errorHandlers = [];

  /// 注册错误处理器
  static void registerErrorHandler(void Function(AppException) handler) {
    _errorHandlers.add(handler);
  }

  /// 注销错误处理器
  static void unregisterErrorHandler(void Function(AppException) handler) {
    _errorHandlers.remove(handler);
  }

  /// 处理异步操作中的错误
  static Future<T> handleError<T>(
    FutureOr<T> Function() operation, {
    String? errorMessage,
    void Function(AppException)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final exception = _convertToAppException(error, stackTrace, errorMessage);

      Logger.error(
        errorMessage ?? 'An error occurred',
        error: error,
        stackTrace: stackTrace,
      );

      for (final handler in _errorHandlers) {
        try {
          handler(exception);
        } catch (e) {
          Logger.error('Error in error handler', error: e);
        }
      }

      if (onError != null) {
        onError(exception);
      }

      throw exception;
    }
  }

  /// 将错误转换为应用异常
  static AppException _convertToAppException(
    Object error,
    StackTrace stackTrace,
    String? customMessage,
  ) {
    if (error is AppException) {
      return error;
    }

    final message = customMessage ?? error.toString();

    if (error is FormatException) {
      return AppException.validation(
        'Invalid format: $message',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppException.network(
        'Request timeout: $message',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is StateError) {
      return AppException.validation(
        'Invalid state: $message',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppException.unknown(
      message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// 获取用户友好的错误消息
  static String getUserFriendlyMessage(AppException exception) {
    switch (exception.type) {
      case ExceptionType.network:
        return 'Network error: ${exception.message}. Please check your connection.';
      case ExceptionType.storage:
        return 'Storage error: ${exception.message}. Please try again.';
      case ExceptionType.authentication:
        return 'Authentication error: ${exception.message}. Please log in again.';
      case ExceptionType.validation:
        return 'Validation error: ${exception.message}. Please check your input.';
      case ExceptionType.permission:
        return 'Permission error: ${exception.message}. Please grant the required permissions.';
      case ExceptionType.unknown:
        return 'An unexpected error occurred: ${exception.message}. Please try again.';
    }
  }

  /// 记录错误日志
  static void logError(AppException exception) {
    Logger.error(
      exception.message,
      error: exception.originalError,
      stackTrace: exception.stackTrace,
    );
  }
}
