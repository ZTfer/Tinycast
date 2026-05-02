import 'dart:async';
import 'package:dio/dio.dart' as dio;
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';

/// iTunes 播客搜索结果
class ITunesSearchResult {
  final String collectionId;
  final String collectionName;
  final String artworkUrl600;
  final String? feedUrl;
  final String? website;
  final String? description;

  ITunesSearchResult({
    required this.collectionId,
    required this.collectionName,
    required this.artworkUrl600,
    this.feedUrl,
    this.website,
    this.description,
  });

  factory ITunesSearchResult.fromJson(Map<String, dynamic> json) {
    return ITunesSearchResult(
      collectionId: json['collectionId']?.toString() ?? '',
      collectionName: json['collectionName'] ?? '',
      artworkUrl600: json['artworkUrl600'] ?? '',
      feedUrl: json['feedUrl'],
      website: json['website'],
      description: json['description'],
    );
  }
}

/// iTunes 搜索服务
///
/// 负责搜索 iTunes 播客数据库，获取 Apple Podcast ID 和封面图信息
class ITunesSearchService {
  /// Dio 实例
  final dio.Dio _dio;

  /// 最大重试次数
  final int _maxRetryCount;

  /// 构造函数
  ITunesSearchService({
    dio.Dio? dioInstance,
    int maxRetryCount = AppConstants.maxRetryCount,
    int timeout = AppConstants.defaultTimeout,
  }) : _dio = dioInstance ?? dio.Dio(),
       _maxRetryCount = maxRetryCount {
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    _dio.options.sendTimeout = Duration(milliseconds: timeout);
  }

  /// 搜索播客
  ///
  /// [term] 搜索关键词
  /// [limit] 返回结果数量限制，默认 5
  /// 返回搜索结果列表，如果搜索失败则返回空列表
  Future<List<ITunesSearchResult>> searchPodcastOnITunes({
    required String term,
    int limit = 5,
  }) async {
    Logger.info('开始搜索 iTunes 播客: $term');

    // 优先尝试美国区
    try {
      final results = await _searchWithCountry(
        term: term,
        limit: limit,
        country: 'us',
      );
      if (results.isNotEmpty) {
        Logger.info('美国区搜索成功，找到 ${results.length} 个结果');
        return results;
      }
    } catch (e) {
      Logger.warning('美国区搜索失败，尝试中国区: $e');
    }

    // 美国区失败或无结果，尝试中国区
    try {
      final results = await _searchWithCountry(
        term: term,
        limit: limit,
        country: 'cn',
      );
      if (results.isNotEmpty) {
        Logger.info('中国区搜索成功，找到 ${results.length} 个结果');
        return results;
      }
    } catch (e) {
      Logger.warning('中国区搜索也失败: $e');
    }

    Logger.info('iTunes 搜索未找到结果: $term');
    return [];
  }

  /// 执行带指定区域的搜索
  Future<List<ITunesSearchResult>> _searchWithCountry({
    required String term,
    required int limit,
    required String country,
  }) async {
    int retryCount = 0;
    AppException? lastException;

    final url = 'https://itunes.apple.com/search?'
        'term=${Uri.encodeComponent(term)}'
        '&entity=podcast'
        '&limit=$limit'
        '&country=$country';

    Logger.info('请求 iTunes API: $url');

    while (retryCount <= _maxRetryCount) {
      try {
        final response = await _dio.get(
          url,
          options: dio.Options(
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'TinyCast/${AppConstants.appVersion}',
            },
          ),
        );

        if (response.statusCode != 200) {
          throw AppException.network(
            '请求失败，状态码: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }

        final data = response.data;
        final resultCount = data['resultCount'] ?? 0;

        if (resultCount == 0) {
          Logger.info('iTunes 搜索无结果 ($country)');
          return [];
        }

        final results = (data['results'] as List)
            .map((json) => ITunesSearchResult.fromJson(json))
            .toList();

        return results;
      } on dio.DioException catch (e) {
        Logger.warning(
          'iTunes 搜索失败 (尝试 ${retryCount + 1}/$_maxRetryCount): ${e.message}',
        );
        lastException = NetworkErrorHandler.handleDioException(e);
      } on AppException catch (e) {
        Logger.error('iTunes 搜索错误: ${e.message}');
        lastException = e;
        break;
      } catch (e, stackTrace) {
        Logger.error('未知错误', error: e, stackTrace: stackTrace);
        lastException = AppException.unknown(
          'iTunes 搜索失败',
          originalError: e,
          stackTrace: stackTrace,
        );
        break;
      }

      retryCount++;
      if (retryCount <= _maxRetryCount) {
        await Future.delayed(Duration(seconds: retryCount));
      }
    }

    throw lastException ??
        AppException.network('iTunes 搜索失败，已重试 $_maxRetryCount 次');
  }
}
