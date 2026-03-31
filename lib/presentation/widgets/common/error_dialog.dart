import 'package:flutter/material.dart';
import '../../../core/utils/app_exception.dart';

class ErrorDialog extends StatelessWidget {
  final AppException exception;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ErrorDialog({
    super.key,
    required this.exception,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: Row(
        children: [
          Icon(
            _getIconForException(),
            color: _getColorForException(),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getTitle(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exception.message,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            if (exception.statusCode != null) ...[
              const SizedBox(height: 8),
              Text(
                '状态码: ${exception.statusCode}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text(
              '重试',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text(
            '确定',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForException() {
    switch (exception.type) {
      case ExceptionType.network:
        return Icons.wifi_off_outlined;
      case ExceptionType.storage:
        return Icons.storage_outlined;
      case ExceptionType.authentication:
        return Icons.lock_outline;
      case ExceptionType.validation:
        return Icons.error_outline;
      case ExceptionType.permission:
        return Icons.block_outlined;
      case ExceptionType.unknown:
        return Icons.warning_amber_outlined;
    }
  }

  Color _getColorForException() {
    switch (exception.type) {
      case ExceptionType.network:
        return Colors.orange;
      case ExceptionType.storage:
        return Colors.red;
      case ExceptionType.authentication:
        return Colors.purple;
      case ExceptionType.validation:
        return Colors.red;
      case ExceptionType.permission:
        return Colors.amber;
      case ExceptionType.unknown:
        return Colors.grey;
    }
  }

  String _getTitle() {
    switch (exception.type) {
      case ExceptionType.network:
        return '网络错误';
      case ExceptionType.storage:
        return '存储错误';
      case ExceptionType.authentication:
        return '认证错误';
      case ExceptionType.validation:
        return '验证错误';
      case ExceptionType.permission:
        return '权限错误';
      case ExceptionType.unknown:
        return '未知错误';
    }
  }

  static Future<void> show(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        exception: exception,
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}

class NetworkErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const NetworkErrorDialog({
    super.key,
    this.message = '网络连接失败，请检查网络设置',
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.wifi_off_outlined,
            color: Colors.orange,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            '网络错误',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text(
              '重试',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text(
            '确定',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => NetworkErrorDialog(
        message: message ?? '网络连接失败，请检查网络设置',
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}

class ParseErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const ParseErrorDialog({
    super.key,
    this.message = '数据解析失败，请稍后重试',
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            '解析错误',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text(
              '重试',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text(
            '确定',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ParseErrorDialog(
        message: message ?? '数据解析失败，请稍后重试',
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}

class StorageErrorDialog extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const StorageErrorDialog({
    super.key,
    this.message = '存储操作失败，请重试',
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.storage_outlined,
            color: Colors.red,
            size: 24,
          ),
          SizedBox(width: 12),
          Text(
            '存储错误',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            child: const Text(
              '重试',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          child: const Text(
            '确定',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> show(
    BuildContext context, {
    String? message,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => StorageErrorDialog(
        message: message ?? '存储操作失败，请重试',
        onRetry: onRetry,
        onDismiss: onDismiss,
      ),
    );
  }
}
