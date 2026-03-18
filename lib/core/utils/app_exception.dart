enum ExceptionType {
  network,
  storage,
  authentication,
  validation,
  permission,
  unknown,
}

class AppException implements Exception {
  final String message;
  final ExceptionType type;
  final int? statusCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

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
      buffer.write(' (Status: $statusCode)');
    }
    if (originalError != null) {
      buffer.write('\nOriginal Error: $originalError');
    }
    return buffer.toString();
  }

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
