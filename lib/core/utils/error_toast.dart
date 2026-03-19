import 'package:flutter/material.dart';
import '../../presentation/dialogs/toast/vertical_icon_toast.dart';
import 'app_exception.dart';

/// 错误提示工具类
class ErrorToast {
  ErrorToast._();

  /// 显示错误提示
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: VerticalIconToast(
            icon: const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            text: message,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 显示网络错误
  static void showNetworkError(
    BuildContext context, {
    String? customMessage,
    Duration duration = const Duration(seconds: 3),
  }) {
    showError(
      context,
      customMessage ?? '网络连接失败，请检查网络设置',
      duration: duration,
    );
  }

  /// 显示解析错误
  static void showParseError(
    BuildContext context, {
    String? customMessage,
    Duration duration = const Duration(seconds: 3),
  }) {
    showError(
      context,
      customMessage ?? '数据解析失败，请稍后重试',
      duration: duration,
    );
  }

  /// 显示存储错误
  static void showStorageError(
    BuildContext context, {
    String? customMessage,
    Duration duration = const Duration(seconds: 3),
  }) {
    showError(
      context,
      customMessage ?? '存储操作失败，请重试',
      duration: duration,
    );
  }

  /// 显示验证错误
  static void showValidationError(
    BuildContext context, {
    String? customMessage,
    Duration duration = const Duration(seconds: 3),
  }) {
    showError(
      context,
      customMessage ?? '输入验证失败，请检查输入内容',
      duration: duration,
    );
  }

  /// 显示成功提示
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: VerticalIconToast(
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
            ),
            text: message,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 显示警告提示
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: VerticalIconToast(
            icon: const Icon(
              Icons.warning_amber_outlined,
              color: Colors.orange,
            ),
            text: message,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  /// 根据异常类型显示对应的错误提示
  static void showException(
    BuildContext context,
    AppException exception, {
    Duration duration = const Duration(seconds: 3),
  }) {
    switch (exception.type) {
      case ExceptionType.network:
        showNetworkError(
          context,
          customMessage: exception.message,
          duration: duration,
        );
        break;
      case ExceptionType.storage:
        showStorageError(
          context,
          customMessage: exception.message,
          duration: duration,
        );
        break;
      case ExceptionType.validation:
        showValidationError(
          context,
          customMessage: exception.message,
          duration: duration,
        );
        break;
      case ExceptionType.authentication:
        showError(
          context,
          exception.message,
          duration: duration,
        );
        break;
      case ExceptionType.permission:
        showError(
          context,
          exception.message,
          duration: duration,
        );
        break;
      case ExceptionType.unknown:
        showError(
          context,
          exception.message,
          duration: duration,
        );
        break;
    }
  }
}
