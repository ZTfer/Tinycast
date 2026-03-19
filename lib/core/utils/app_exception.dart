/// 异常类型枚举
enum ExceptionType {
  /// 网络异常
  network,

  /// 存储异常
  storage,

  /// 认证异常
  authentication,

  /// 验证异常
  validation,

  /// 权限异常
  permission,

  /// 未知异常
  unknown,
}

/// 应用异常类
class AppException implements Exception {
  /// 异常消息
  final String message;

  /// 异常类型
  final ExceptionType type;

  /// HTTP 状态码
  final int? statusCode;

  /// 原始错误对象
  final dynamic originalError;

  /// 堆栈跟踪
  final StackTrace? stackTrace;

  /// 构造函数
  AppException({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('AppException: $message');
    if (statusCode != null) {
      buffer.write(' (状态码: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\n原始错误: $originalError');
    }
    return buffer.toString();
  }

  /// 创建网络异常
  factory AppException.network(
    String message, {
    int? statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.network,
      statusCode: statusCode,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// 创建存储异常
  factory AppException.storage(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.storage,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// 创建认证异常
  factory AppException.authentication(
    String message, {
    int? statusCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.authentication,
      statusCode: statusCode,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// 创建验证异常
  factory AppException.validation(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.validation,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// 创建权限异常
  factory AppException.permission(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.permission,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// 创建未知异常
  factory AppException.unknown(
    String message, {
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      message: message,
      type: ExceptionType.unknown,
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }
}
