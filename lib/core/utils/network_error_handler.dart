import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'app_exception.dart';
import 'logger.dart';

/// 网络错误处理工具类
class NetworkErrorHandler {
  NetworkErrorHandler._();

  /// 处理 Dio 异常
  static AppException handleDioException(dio.DioException e) {
    Logger.error('网络请求失败', error: e);

    switch (e.type) {
      case dio.DioExceptionType.connectionTimeout:
        return AppException.network(
          '连接超时，请检查网络设置',
          originalError: e,
        );

      case dio.DioExceptionType.sendTimeout:
        return AppException.network(
          '发送请求超时，请重试',
          originalError: e,
        );

      case dio.DioExceptionType.receiveTimeout:
        return AppException.network(
          '接收数据超时，请重试',
          originalError: e,
        );

      case dio.DioExceptionType.badResponse:
        return _handleBadResponse(e);

      case dio.DioExceptionType.cancel:
        return AppException.network(
          '请求已取消',
          originalError: e,
        );

      case dio.DioExceptionType.connectionError:
        return AppException.network(
          '网络连接失败，请检查网络设置',
          originalError: e,
        );

      case dio.DioExceptionType.badCertificate:
        return AppException.network(
          '证书验证失败',
          originalError: e,
        );

      case dio.DioExceptionType.unknown:
        return AppException.network(
          '网络请求失败: ${e.message}',
          originalError: e,
        );
    }
  }

  /// 处理错误的响应
  static AppException _handleBadResponse(dio.DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String message = '请求失败';

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      message = data['error'] as String? ?? message;
    }

    switch (statusCode) {
      case 400:
        return AppException.validation(
          message,
          originalError: e,
        );

      case 401:
        return AppException.authentication(
          message,
          statusCode: statusCode,
          originalError: e,
        );

      case 403:
        return AppException.permission(
          message,
          originalError: e,
        );

      case 404:
        return AppException.network(
          '请求的资源不存在',
          statusCode: statusCode,
          originalError: e,
        );

      case 500:
        return AppException.network(
          '服务器错误，请稍后重试',
          statusCode: statusCode,
          originalError: e,
        );

      case 502:
      case 503:
      case 504:
        return AppException.network(
          '服务暂时不可用，请稍后重试',
          statusCode: statusCode,
          originalError: e,
        );

      default:
        return AppException.network(
          message,
          statusCode: statusCode,
          originalError: e,
        );
    }
  }

  /// 检查网络连接状态
  static Future<bool> isConnected() async {
    try {
      // 这里可以添加实际的网络连接检查逻辑
      // 例如使用 connectivity_plus 包
      return true;
    } catch (e) {
      Logger.error('检查网络连接失败', error: e);
      return false;
    }
  }

  /// 带重试的网络请求
  static Future<T> withRetry<T>(
    Future<T> Function() request, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    int retryCount = 0;
    AppException? lastException;

    while (retryCount <= maxRetries) {
      try {
        return await request();
      } on dio.DioException catch (e) {
        lastException = handleDioException(e);
        retryCount++;

        if (retryCount <= maxRetries) {
          Logger.warning(
            '请求失败，准备重试 ($retryCount/$maxRetries)',
          );
          await Future.delayed(retryDelay * retryCount);
        }
      } catch (e) {
        lastException = AppException.unknown(
          '未知错误: ${e.toString()}',
          originalError: e,
        );
        break;
      }
    }

    throw lastException ??
        AppException.network('请求失败，已重试 $maxRetries 次');
  }

  /// 带超时的网络请求
  static Future<T> withTimeout<T>(
    Future<T> Function() request, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException catch (e) {
      throw AppException.network(
        '请求超时',
        originalError: e,
      );
    }
  }
}
