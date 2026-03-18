import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'app_exception.dart';
import 'app_constants.dart';
import 'logger.dart';

class NetworkHelper {
  NetworkHelper._();

  static const String _defaultBaseUrl = '';
  static int _timeout = AppConstants.defaultTimeout;
  static int _maxRetryCount = AppConstants.maxRetryCount;
  static Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static void setBaseUrl(String baseUrl) {
    Logger.info('Base URL set to: $baseUrl');
  }

  static void setTimeout(int timeoutMs) {
    _timeout = timeoutMs;
    Logger.info('Timeout set to: ${timeoutMs}ms');
  }

  static void setMaxRetryCount(int count) {
    _maxRetryCount = count;
    Logger.info('Max retry count set to: $count');
  }

  static void setDefaultHeaders(Map<String, String> headers) {
    _defaultHeaders = {..._defaultHeaders, ...headers};
    Logger.info('Default headers updated');
  }

  static Future<http.Response> get(
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

  static Future<http.Response> post(
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

  static Future<http.Response> put(
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

  static Future<http.Response> delete(
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

  static Future<http.Response> patch(
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

  static Future<http.Response> downloadFile(
    String url,
    String savePath, {
    void Function(int bytes, int total)? onProgress,
  }) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw AppException.network(
          'Failed to download file',
          statusCode: response.statusCode,
        );
      }

      final contentLength = response.contentLength ?? 0;
      final file = File(savePath);
      final sink = file.openWrite();

      int downloadedBytes = 0;
      await response.stream
          .listen(
            (chunk) {
              sink.add(chunk);
              downloadedBytes += chunk.length;
              if (onProgress != null && contentLength > 0) {
                onProgress(downloadedBytes, contentLength);
              }
            },
            onDone: () => sink.close(),
            onError: (error) {
              sink.close();
              throw AppException.network(
                'Error downloading file',
                originalError: error,
              );
            },
          )
          .asFuture();

      return http.Response('Downloaded', response.statusCode);
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

  static Future<http.Response> uploadFile(
    String endpoint,
    File file, {
    String? fieldName,
    Map<String, String>? fields,
    Map<String, String>? headers,
    int? timeout,
  }) async {
    try {
      final uri = _buildUri(endpoint);
      final request = http.MultipartRequest('POST', uri);

      if (headers != null) {
        request.headers.addAll(headers);
      }

      if (fields != null) {
        request.fields.addAll(fields);
      }

      final multipartFile = await http.MultipartFile.fromPath(
        fieldName ?? 'file',
        file.path,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(
        Duration(milliseconds: timeout ?? _timeout),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 400) {
        throw _handleErrorResponse(response);
      }

      Logger.info('File uploaded successfully to: $endpoint');
      return response;
    } on TimeoutException catch (e, stackTrace) {
      Logger.error('Upload timeout', error: e, stackTrace: stackTrace);
      throw AppException.network(
        'Upload timeout',
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

  static Future<http.Response> _request({
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

        http.Response response;
        final requestTimeout = Duration(milliseconds: timeout ?? _timeout);

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http
                .get(uri, headers: mergedHeaders)
                .timeout(requestTimeout);
            break;
          case 'POST':
            response = await http
                .post(uri, headers: mergedHeaders, body: _encodeBody(body))
                .timeout(requestTimeout);
            break;
          case 'PUT':
            response = await http
                .put(uri, headers: mergedHeaders, body: _encodeBody(body))
                .timeout(requestTimeout);
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: mergedHeaders, body: _encodeBody(body))
                .timeout(requestTimeout);
            break;
          case 'PATCH':
            response = await http
                .patch(uri, headers: mergedHeaders, body: _encodeBody(body))
                .timeout(requestTimeout);
            break;
          default:
            throw AppException.validation('Unsupported HTTP method: $method');
        }

        if (response.statusCode >= 400) {
          throw _handleErrorResponse(response);
        }

        Logger.info('$method $uri - ${response.statusCode}');
        return response;
      } on TimeoutException catch (e, stackTrace) {
        Logger.warning('Request timeout (attempt ${retryCount + 1})');
        lastException = AppException.network(
          'Request timeout',
          originalError: e,
          stackTrace: stackTrace,
        );
      } on SocketException catch (e, stackTrace) {
        Logger.warning('Network error (attempt ${retryCount + 1})');
        lastException = AppException.network(
          'Network connection failed',
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

  static Uri _buildUri(
    String endpoint, [
    Map<String, dynamic>? queryParameters,
  ]) {
    final url = endpoint.startsWith('http')
        ? endpoint
        : _defaultBaseUrl + endpoint;
    return Uri.parse(url).replace(queryParameters: queryParameters);
  }

  static dynamic _encodeBody(dynamic body) {
    if (body == null) return null;
    if (body is String) return body;
    if (body is Map || body is List) return jsonEncode(body);
    return body.toString();
  }

  static AppException _handleErrorResponse(http.Response response) {
    final statusCode = response.statusCode;
    String message = 'Request failed with status $statusCode';

    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('message')) {
        message = body['message'] as String;
      } else if (body is Map && body.containsKey('error')) {
        message = body['error'] as String;
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

  static T _parseResponse<T>(
    http.Response response,
    T Function(dynamic) parser,
  ) {
    try {
      final body = jsonDecode(response.body);
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

  static bool isNetworkError(Object error) {
    return error is AppException && error.type == ExceptionType.network;
  }

  static bool isAuthError(Object error) {
    return error is AppException && error.type == ExceptionType.authentication;
  }
}
