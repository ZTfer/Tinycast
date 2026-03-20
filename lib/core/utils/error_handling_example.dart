import 'package:flutter/material.dart';
import 'package:tinycast/core/utils/error_handler.dart';
import 'package:tinycast/core/utils/error_toast.dart';
import 'package:tinycast/core/utils/error_dialog.dart';
import 'package:tinycast/core/utils/network_error_handler.dart';
import 'package:tinycast/core/utils/parse_error_handler.dart';
import 'package:tinycast/core/utils/storage_error_handler.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:dio/dio.dart' as dio;
import 'package:xml/xml.dart';
import 'dart:io';

/// 错误处理使用示例
///
/// 这个文件展示了如何在应用中使用错误处理和用户反馈系统
class ErrorHandlingExample {
  /// 示例1: 使用 ErrorHandler 处理异步操作
  Future<void> exampleUseErrorHandler() async {
    try {
      final result = await ErrorHandler.handleError(() async {
        // 执行可能出错的操作
        await Future.delayed(const Duration(seconds: 1));
        return 'Success';
      }, errorMessage: '执行操作失败');

      Logger.info('结果: $result');
    } catch (e) {
      Logger.error('错误: $e');
    }
  }

  /// 示例2: 使用 ErrorToast 显示错误提示
  void exampleShowErrorToast(BuildContext context) {
    // 显示通用错误
    ErrorToast.showError(context, '操作失败');

    // 显示网络错误
    ErrorToast.showNetworkError(context);

    // 显示解析错误
    ErrorToast.showParseError(context, customMessage: 'RSS 解析失败');

    // 显示存储错误
    ErrorToast.showStorageError(context);

    // 显示验证错误
    ErrorToast.showValidationError(context);

    // 显示成功提示
    ErrorToast.showSuccess(context, '操作成功');

    // 显示警告提示
    ErrorToast.showWarning(context, '请注意');

    // 根据异常类型显示对应的错误提示
    final exception = AppException.network('网络连接失败');
    ErrorToast.showException(context, exception);
  }

  /// 示例3: 使用 ErrorDialog 显示错误对话框
  Future<void> exampleShowErrorDialog(BuildContext context) async {
    // 显示通用错误对话框
    final exception = AppException.network('网络连接失败');
    await ErrorDialog.show(
      context,
      exception,
      onRetry: () {
        // 重试操作
        Logger.info('重试操作');
      },
      onDismiss: () {
        // 对话框关闭时的回调
        Logger.info('对话框关闭');
      },
    );

    // 显示网络错误对话框
    if (context.mounted) {
      await NetworkErrorDialog.show(
        context,
        message: '网络连接失败，请检查网络设置',
        onRetry: () {
          // 重试网络请求
          Logger.info('重试网络请求');
        },
      );
    }

    // 显示解析错误对话框
    if (context.mounted) {
      await ParseErrorDialog.show(
        context,
        message: '数据解析失败，请稍后重试',
        onRetry: () {
          // 重试解析
          Logger.info('重试解析');
        },
      );
    }

    // 显示存储错误对话框
    if (context.mounted) {
      await StorageErrorDialog.show(
        context,
        message: '存储操作失败，请重试',
        onRetry: () {
          // 重试存储操作
          Logger.info('重试存储操作');
        },
      );
    }
  }

  /// 示例4: 使用 NetworkErrorHandler 处理网络错误
  Future<void> exampleHandleNetworkError() async {
    final dioInstance = dio.Dio();

    try {
      final response = await dioInstance.get('https://api.example.com/data');
      Logger.info('响应: ${response.data}');
    } on dio.DioException catch (e) {
      // 使用 NetworkErrorHandler 处理 Dio 异常
      final exception = NetworkErrorHandler.handleDioException(e);
      Logger.error('网络错误: ${exception.message}');
    }

    // 使用带重试的网络请求
    try {
      final result = await NetworkErrorHandler.withRetry(
        () => dioInstance.get('https://api.example.com/data'),
        maxRetries: 3,
        retryDelay: const Duration(seconds: 1),
      );
      Logger.info('结果: $result');
    } catch (e) {
      Logger.error('重试失败: $e');
    }

    // 使用带超时的网络请求
    try {
      final result = await NetworkErrorHandler.withTimeout(
        () => dioInstance.get('https://api.example.com/data'),
        timeout: const Duration(seconds: 30),
      );
      Logger.info('结果: $result');
    } catch (e) {
      Logger.error('超时错误: $e');
    }
  }

  /// 示例5: 使用 ParseErrorHandler 处理解析错误
  void exampleHandleParseError() {
    // 验证 RSS 订阅源格式
    try {
      ParseErrorHandler.validateRssFeed('https://example.com/podcast.rss');
      Logger.info('RSS URL 验证通过');
    } catch (e) {
      Logger.error('验证失败: $e');
    }

    // 验证播客数据
    try {
      ParseErrorHandler.validatePodcastData({
        'title': '我的播客',
        'rssUrl': 'https://example.com/podcast.rss',
        'artworkUrl': 'https://example.com/cover.jpg',
      });
      Logger.info('播客数据验证通过');
    } catch (e) {
      Logger.error('验证失败: $e');
    }

    // 验证节目数据
    try {
      ParseErrorHandler.validateEpisodeData({
        'title': '节目1',
        'audioUrl': 'https://example.com/episode1.mp3',
        'podcastId': 1,
      });
      Logger.info('节目数据验证通过');
    } catch (e) {
      Logger.error('验证失败: $e');
    }
  }

  /// 示例6: 使用 StorageErrorHandler 处理存储错误
  Future<void> exampleHandleStorageError() async {
    // 验证文件路径
    try {
      StorageErrorHandler.validateFilePath('/path/to/file.txt');
      Logger.info('文件路径验证通过');
    } catch (e) {
      Logger.error('验证失败: $e');
    }

    // 安全创建目录
    try {
      final directory = await StorageErrorHandler.createDirectorySafely(
        '/path/to/directory',
      );
      Logger.info('目录创建成功: ${directory.path}');
    } catch (e) {
      Logger.error('创建目录失败: $e');
    }

    // 安全读取文件
    try {
      final content = await StorageErrorHandler.readFileSafely(
        '/path/to/file.txt',
      );
      Logger.info('文件内容: $content');
    } catch (e) {
      Logger.error('读取文件失败: $e');
    }

    // 安全写入文件
    try {
      await StorageErrorHandler.writeFileSafely(
        '/path/to/file.txt',
        'Hello, World!',
      );
      Logger.info('文件写入成功');
    } catch (e) {
      Logger.error('写入文件失败: $e');
    }

    // 安全删除文件
    try {
      await StorageErrorHandler.deleteFileSafely('/path/to/file.txt');
      Logger.info('文件删除成功');
    } catch (e) {
      Logger.error('删除文件失败: $e');
    }
  }

  /// 示例7: 在 Widget 中使用错误处理
  Widget exampleErrorHandlingInWidget(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        try {
          // 执行操作
          await _performOperation();

          // 显示成功提示
          if (context.mounted) {
            ErrorToast.showSuccess(context, '操作成功');
          }
        } catch (e) {
          // 处理错误
          AppException exception;
          if (e is AppException) {
            exception = e;
          } else {
            exception = AppException.unknown(
              '操作失败：${e.toString()}',
              originalError: e,
            );
          }

          // 显示错误对话框，提供重试选项
          if (context.mounted) {
            await ErrorDialog.show(
              context,
              exception,
              onRetry: () {
                // 重试操作
                exampleErrorHandlingInWidget(context);
              },
            );
          }
        }
      },
      child: const Text('执行操作'),
    );
  }

  /// 示例8: 在 Provider 中使用错误处理
  Future<void> exampleErrorHandlingInProvider() async {
    try {
      // 执行数据加载
      await _loadData();
    } catch (e) {
      // 在 Provider 中设置错误状态
      // state = state.copyWith(
      //   status: Status.error,
      //   error: e is AppException
      //       ? e
      //       : AppException.unknown(
      //           '加载数据失败：${e.toString()}',
      //           originalError: e,
      //         ),
      // );
    }
  }

  /// 模拟操作
  Future<void> _performOperation() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('操作失败');
  }

  /// 模拟加载数据
  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('加载数据失败');
  }
}

/// 错误处理最佳实践
class ErrorHandlingBestPractices {
  /// 最佳实践1: 始终使用 AppException 来表示应用错误
  void bestPracticeUseAppException() {
    // 好的做法
    try {
      // 执行操作
    } catch (e) {
      throw AppException.network('网络请求失败', originalError: e);
    }

    // 不好的做法
    try {
      // 执行操作
    } catch (e) {
      throw Exception('网络请求失败'); // 缺少错误类型和上下文
    }
  }

  /// 最佳实践2: 使用适当的错误类型
  void bestPracticeUseAppropriateErrorType(String errorType) {
    switch (errorType) {
      case 'network':
        throw AppException.network('网络连接失败');
      case 'storage':
        throw AppException.storage('文件写入失败');
      case 'validation':
        throw AppException.validation('输入格式不正确');
      case 'authentication':
        throw AppException.authentication('登录已过期');
      case 'permission':
        throw AppException.permission('没有访问权限');
      default:
        throw AppException.unknown('未知错误');
    }
  }

  /// 最佳实践3: 提供重试选项
  Future<void> bestPracticeProvideRetryOption(BuildContext context) async {
    try {
      await _performOperation();
    } catch (e) {
      if (e is AppException) {
        if (context.mounted) {
          await ErrorDialog.show(
            context,
            e,
            onRetry: () {
              // 提供重试选项
              bestPracticeProvideRetryOption(context);
            },
          );
        }
      }
    }
  }

  /// 最佳实践4: 显示用户友好的错误消息
  void bestPracticeShowUserFriendlyErrorMessages(BuildContext context) {
    // 使用 ErrorToast 显示简短错误
    ErrorToast.showNetworkError(context);

    // 使用 ErrorDialog 显示详细错误
    ErrorDialog.show(context, AppException.network('网络连接失败'));
  }

  /// 最佳实践5: 记录错误日志
  void bestPracticeLogErrors() {
    try {
      // 执行操作
    } catch (e, stackTrace) {
      // 记录错误日志
      Logger.error('操作失败', error: e, stackTrace: stackTrace);

      // 抛出应用异常
      throw AppException.unknown(
        '操作失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 最佳实践6: 使用专门的错误处理器
  Future<void> bestPracticeUseSpecializedErrorHandlers() async {
    // 使用 NetworkErrorHandler 处理网络错误
    try {
      // 执行网络请求
    } on dio.DioException catch (e) {
      final exception = NetworkErrorHandler.handleDioException(e);
      throw exception;
    }

    // 使用 ParseErrorHandler 处理解析错误
    try {
      // 执行解析操作
    } catch (e) {
      final exception = ParseErrorHandler.handleXmlException(e as XmlException);
      throw exception;
    }

    // 使用 StorageErrorHandler 处理存储错误
    try {
      // 执行存储操作
    } on FileSystemException catch (e) {
      final exception = StorageErrorHandler.handleFileSystemException(e);
      throw exception;
    }
  }

  /// 最佳实践7: 在 UI 层处理错误
  Future<void> bestPracticeHandleErrorsInUI(BuildContext context) async {
    try {
      await _performOperation();
    } catch (e) {
      // 在 UI 层处理错误
      if (e is AppException) {
        if (context.mounted) {
          ErrorToast.showException(context, e);
        }
      } else {
        if (context.mounted) {
          ErrorToast.showError(context, '操作失败');
        }
      }
    }
  }

  /// 模拟操作
  Future<void> _performOperation() async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('操作失败');
  }
}
