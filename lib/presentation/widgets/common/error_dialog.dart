import 'package:flutter/material.dart';
import 'package:tinycast/core/utils/app_exception.dart';

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
