import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'app_exception.dart';
import 'app_constants.dart';
import 'logger.dart';

/// 网络请求工具类
class NetworkHelper {
  NetworkHelper._();

  /// Dio 实例
  static final dio.Dio _dio = dio.Dio();

  /// 默认基础 URL
  static const String _defaultBaseUrl = '';

  /// 请求超时时间（毫秒）
  static int _timeout = AppConstants.defaultTimeout;

  /// 最大重试次数
  static int _maxRetryCount = AppConstants.maxRetryCount;

  /// 默认请求头
  static Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// 设置基础 URL
  static void setBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
    Logger.info('Base URL set to: $baseUrl');
  }

  /// 设置请求超时时间（毫秒）
  static void setTimeout(int timeoutMs) {
    _timeout = timeoutMs;
    _dio.options.connectTimeout = Duration(milliseconds: timeoutMs);
    _dio.options.receiveTimeout = Duration(milliseconds: timeoutMs);
    Logger.info('Timeout set to: ${timeoutMs}ms');
  }

  /// 设置最大重试次数
  static void setMaxRetryCount(int count) {
    _maxRetryCount = count;
    Logger.info('Max retry count set to: $count');
  }

  /// 设置默认请求头
  static void setDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders = {..._defaultHeaders, ...headers};
    _dio.options.headers.addAll(_defaultHeaders);
    Logger.info('Default headers updated');
  }

  /// 发送 GET 请求
  static Future<dio.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    return _request(
      method: 'GET',
      endpoint: endpoint,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// 发送 POST 请求
  static Future<dio.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    return _request(
      method: 'POST',
      endpoint: endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// 发送 PUT 请求
  static Future<dio.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    return _request(
      method: 'PUT',
      endpoint: endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// 发送 DELETE 请求
  static Future<dio.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    return _request(
      method: 'DELETE',
      endpoint: endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// 发送 PATCH 请求
  static Future<dio.Response> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    return _request(
      method: 'PATCH',
      endpoint: endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      timeout: timeout,
    );
  }

  /// 发送 GET 请求并解析 JSON 响应
  static Future<T> getJson<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    int? timeout,
    required T Function(dynamic) parser,
  }) async {
    final response = await get(
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      timeout: timeout,
    );
    return _parseResponse<T>(response, parser);
  }

  /// 发送 POST 请求并解析 JSON 响应
  static Future<T> postJson<T>(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
    required T Function(dynamic) parser,
  }) async {
    final response = await post(
      endpoint,
      headers: headers,
      body: body,
      queryParameters: queryParameters,
      timeout: timeout,
    );
    return _parseResponse<T>(response, parser);
  }

  /// 下载文件
  static Future<dio.Response> downloadFile(
    String url,
    String savePath, {
    void Function(int bytes, int total)? onProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onProgress,
      );

      Logger.info('File downloaded successfully to: $savePath');
      return dio.Response(
        requestOptions: dio.RequestOptions(path: url),
        statusCode: 200,
        data: 'Downloaded',
      );
    } on dio.DioException catch (e, stackTrace) {
      Logger.error('Error downloading file', error: e, stackTrace: stackTrace);
      throw AppException.network(
        'Failed to download file',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('Error downloading file', error: e, stackTrace: stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException.network(
        'Failed to download file',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 上传文件
  static Future<dio.Response> uploadFile(
    String endpoint,
    File file, {
    String? fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    int? timeout,
  }) async {
    try {
      final formData = dio.FormData.fromMap({...?fields});
      final multipartFile = await dio.MultipartFile.fromFile(file.path);
      formData.files.add(MapEntry(fieldName ?? 'file', multipartFile));

      final response = await _dio.post(
        endpoint,
        data: formData,
        options: dio.Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode != null && response.statusCode! >= 400) {
        throw _handleErrorResponse(response);
      }

      Logger.info('File uploaded successfully to: $endpoint');
      return response;
    } on dio.DioException catch (e, stackTrace) {
      Logger.error('Error uploading file', error: e, stackTrace: stackTrace);
      throw AppException.network(
        'Failed to upload file',
        originalError: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      Logger.error('Error uploading file', error: e, stackTrace: stackTrace);
      if (e is AppException) {
        rethrow;
      }
      throw AppException.network(
        'Failed to upload file',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 内部请求方法（支持重试）
  static Future<dio.Response> _request({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    dynamic body,
    Map<String, dynamic>? queryParameters,
    int? timeout,
  }) async {
    int retryCount = 0;
    AppException? lastException;

    while (retryCount <= _maxRetryCount) {
      try {
        final uri = _buildUri(endpoint, queryParameters);
        final mergedHeaders = {..._defaultHeaders, ...?headers};

        Logger.debug('$method $uri');

        dio.Response response;
        final requestTimeout = Duration(milliseconds: timeout ?? _timeout);

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _dio.get(
              endpoint,
              queryParameters: queryParameters,
              options: dio.Options(
                headers: mergedHeaders,
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );
            break;
          case 'POST':
            response = await _dio.post(
              endpoint,
              data: _encodeBody(body),
              queryParameters: queryParameters,
              options: dio.Options(
                headers: mergedHeaders,
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );
            break;
          case 'PUT':
            response = await _dio.put(
              endpoint,
              data: _encodeBody(body),
              queryParameters: queryParameters,
              options: dio.Options(
                headers: mergedHeaders,
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );
            break;
          case 'DELETE':
            response = await _dio.delete(
              endpoint,
              data: _encodeBody(body),
              queryParameters: queryParameters,
              options: dio.Options(
                headers: mergedHeaders,
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );
            break;
          case 'PATCH':
            response = await _dio.patch(
              endpoint,
              data: _encodeBody(body),
              queryParameters: queryParameters,
              options: dio.Options(
                headers: mergedHeaders,
                sendTimeout: requestTimeout,
                receiveTimeout: requestTimeout,
              ),
            );
            break;
          default:
            throw AppException.validation('Unsupported HTTP method: $method');
        }

        if (response.statusCode != null && response.statusCode! >= 400) {
          throw _handleErrorResponse(response);
        }

        Logger.info('$method $uri - ${response.statusCode}');
        return response;
      } on dio.DioException catch (e, stackTrace) {
        Logger.warning(
          'Request error (attempt ${retryCount + 1}): ${e.message}',
        );
        lastException = AppException.network(
          'Request failed: ${e.message}',
          originalError: e,
          stackTrace: stackTrace,
        );
      } catch (e, stackTrace) {
        if (e is AppException) {
          rethrow;
        }
        Logger.error(
          'Request error (attempt ${retryCount + 1})',
          error: e,
          stackTrace: stackTrace,
        );
        lastException = AppException.network(
          'Request failed',
          originalError: e,
          stackTrace: stackTrace,
        );
      }

      retryCount++;
      if (retryCount <= _maxRetryCount) {
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    throw lastException ??
        AppException.network('Request failed after $_maxRetryCount retries');
  }

  /// 构建 URI（支持查询参数）
  static Uri _buildUri(
    String endpoint, [
    Map<String, dynamic>? queryParameters,
  ]) {
    final url = endpoint.startsWith('http')
        ? endpoint
        : _defaultBaseUrl + endpoint;
    return Uri.parse(url).replace(queryParameters: queryParameters);
  }

  /// 编码请求体
  static dynamic _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is Map || body is List) return jsonEncode(body);
    return body.toString();
  }

  /// 处理错误响应
  static AppException _handleErrorResponse(dio.Response response) {
    final statusCode = response.statusCode ?? 500;
    String message = 'Request failed with status $statusCode';

    try {
      final data = response.data;
      if (data is Map && data.containsKey('message')) {
        message = data['message'] as String;
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'] as String;
      }
    } catch (e) {
      Logger.debug('Failed to parse error response');
    }

    if (statusCode >= 400 && statusCode < 500) {
      if (statusCode == 401 || statusCode == 403) {
        return AppException.authentication(
          message,
          originalError: null,
          stackTrace: null,
        );
      }
      return AppException.validation(
        message,
        originalError: null,
        stackTrace: null,
      );
    } else {
      return AppException.network(
        message,
        statusCode: statusCode,
        originalError: null,
        stackTrace: null,
      );
    }
  }

  /// 解析响应
  static T _parseResponse<T>(
    dio.Response response,
    T Function(dynamic) parser,
  ) {
    try {
      final body = response.data;
      return parser(body);
    } catch (e, stackTrace) {
      Logger.error(
        'Failed to parse response',
        error: e,
        stackTrace: stackTrace,
      );
      throw AppException.validation(
        'Failed to parse response',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 检查是否为网络错误
  static bool isNetworkError(Object error) {
    return error is AppException && error.type == ExceptionType.network;
  }

  /// 检查是否为认证错误
  static bool isAuthError(Object error) {
    return error is AppException && error.type == ExceptionType.authentication;
  }
}
