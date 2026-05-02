import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';

/// iTunes 播客搜索结果
///
/// 包含 iTunes Search API 返回的完整播客信息
class ITunesSearchResult {
  /// iTunes 播客 ID (collectionId)
  final String? collectionId;

  /// 播客名称
  final String collectionName;

  /// 600x600 封面图 URL
  final String? artworkUrl600;

  /// RSS 源地址
  final String? feedUrl;

  /// 官网地址
  final String? website;

  /// 播客描述
  final String? description;

  /// 主要流派名称 (如 "Design", "Technology")
  final String? primaryGenreName;

  /// 流派列表 (如 ["Design", "Arts", "Podcasts"])
  final List<String>? genres;

  /// 流派 ID 列表 (如 ["1402", "1301", "26"])
  final List<String>? genreIds;

  /// iTunes 详情页链接
  final String? collectionViewUrl;

  /// 国家代码 (如 "USA", "CHN")
  final String? country;

  /// 发布日期
  final DateTime? releaseDate;

  /// 播客成人内容标识 (如 "notExplicit", "explicit")
  final String? collectionExplicitness;

  /// 内容分级评级 (如 "Clean", "Explicit")
  final String? contentAdvisoryRating;

  ITunesSearchResult({
    this.collectionId,
    required this.collectionName,
    this.artworkUrl600,
    this.feedUrl,
    this.website,
    this.description,
    this.primaryGenreName,
    this.genres,
    this.genreIds,
    this.collectionViewUrl,
    this.country,
    this.releaseDate,
    this.collectionExplicitness,
    this.contentAdvisoryRating,
  });

  factory ITunesSearchResult.fromJson(Map<String, dynamic> json) {
    DateTime? releaseDate;
    try {
      if (json['releaseDate'] != null) {
        releaseDate = DateTime.parse(json['releaseDate']);
      }
    } catch (_) {}

    return ITunesSearchResult(
      collectionId: json['collectionId']?.toString(),
      collectionName: json['collectionName'] ?? '',
      artworkUrl600: json['artworkUrl600'],
      feedUrl: json['feedUrl'],
      website: json['website'],
      description: json['description'],
      primaryGenreName: json['primaryGenreName'],
      genres: json['genres'] != null
          ? List<String>.from(json['genres'])
          : null,
      genreIds: json['genreIds'] != null
          ? List<String>.from(json['genreIds'].map((e) => e.toString()))
          : null,
      collectionViewUrl: json['collectionViewUrl'],
      country: json['country'],
      releaseDate: releaseDate,
      collectionExplicitness: json['collectionExplicitness'],
      contentAdvisoryRating: json['contentAdvisoryRating'],
    );
  }
}

/// iTunes 搜索服务
///
/// 负责搜索 iTunes 播客数据库，获取 iTunes ID 和完整元数据信息
class ITunesSearchService {
  /// Dio 实例
  final dio.Dio _dio;

  /// 最大重试次数
  final int _maxRetryCount;

  /// 国家代码列表（按优先级排序）
  ///
  /// 搜索时会按此列表顺序依次尝试各国家区域，直到找到结果为止。
  final List<String> _countries;

  /// 构造函数
  ///
  /// [dioInstance] 自定义 Dio 实例，用于网络请求
  /// [maxRetryCount] 最大重试次数，默认为 AppConstants.maxRetryCount
  /// [timeout] 超时时间（毫秒），默认为 AppConstants.defaultTimeout
  /// [countries] 国家代码列表，按优先级排序，默认为 AppConstants.itunesSearchCountries
  ITunesSearchService({
    dio.Dio? dioInstance,
    int maxRetryCount = AppConstants.maxRetryCount,
    int timeout = AppConstants.defaultTimeout,
    List<String> countries = AppConstants.itunesSearchCountries,
  }) : _dio = dioInstance ?? dio.Dio(),
       _maxRetryCount = maxRetryCount,
       _countries = countries {
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    _dio.options.sendTimeout = Duration(milliseconds: timeout);
  }

  /// 通过 RSS feedUrl 精确查找播客
  ///
  /// [feedUrl] RSS 源地址
  /// 返回匹配的播客结果，如果查找失败则返回 null
  Future<ITunesSearchResult?> lookupByFeedUrl(String feedUrl) async {
    final url = 'https://itunes.apple.com/search'
        '?feedUrl=${Uri.encodeComponent(feedUrl)}'
        '&media=podcast'
        '&entity=podcast'
        '&limit=1';

    Logger.info('🔍 通过 feedUrl 查找 iTunes 播客: $url');

    for (final country in _countries) {
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

        if (response.statusCode != 200) continue;

        Map<String, dynamic> data;
        try {
          if (response.data is String) {
            data = jsonDecode(response.data as String);
          } else {
            data = response.data as Map<String, dynamic>;
          }
        } catch (e) {
          Logger.warning('⚠️ JSON 解析失败 ($country): $e');
          continue;
        }
        final resultCount = data['resultCount'] ?? 0;

        if (resultCount > 0) {
          final results = (data['results'] as List)
              .map((json) => ITunesSearchResult.fromJson(json))
              .toList();
          if (results.isNotEmpty && results.first.collectionId != null) {
            Logger.info('✅ 通过 feedUrl 找到播客 ($country): ${results.first.collectionName}');
            return results.first;
          }
        }
      } catch (e) {
        Logger.warning('❌ 通过 feedUrl 查找失败 ($country): $e');
      }
    }

    Logger.info('⚠️ 通过 feedUrl 未找到播客: $feedUrl');
    return null;
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
    Logger.info('🔍 开始搜索 iTunes 播客: $term');

    for (final country in _countries) {
      try {
        final results = await _searchWithCountry(
          term: term,
          limit: limit,
          country: country,
        );
        if (results.isNotEmpty) {
          Logger.info('✅ $country 区搜索成功，找到 ${results.length} 个结果');
          return results;
        }
      } catch (e) {
        Logger.warning('⚠️ $country 区搜索失败，尝试下一个区域: $e');
      }
    }

    Logger.info('❌ iTunes 搜索未找到结果: $term');
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
        '&media=podcast'
        '&entity=podcast'
        '&limit=$limit'
        '&country=$country';

    Logger.info('📡 请求 iTunes API: $url');

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

        Map<String, dynamic> data;
        try {
          if (response.data is String) {
            data = jsonDecode(response.data as String);
          } else {
            data = response.data as Map<String, dynamic>;
          }
        } catch (e) {
          throw AppException.validation(
            'JSON 解析失败',
            originalError: e,
          );
        }
        final resultCount = data['resultCount'] ?? 0;

        if (resultCount == 0) {
          Logger.info('⚠️ iTunes 搜索无结果 ($country)');
          return [];
        }

        final results = (data['results'] as List)
            .map((json) => ITunesSearchResult.fromJson(json))
            .toList();

        return results;
      } on dio.DioException catch (e) {
        Logger.warning(
          '❌ iTunes 搜索失败 (尝试 ${retryCount + 1}/$_maxRetryCount): ${e.message}',
        );
        lastException = NetworkErrorHandler.handleDioException(e);
      } on AppException catch (e) {
        Logger.error('❌ iTunes 搜索错误: ${e.message}');
        lastException = e;
        break;
      } catch (e, stackTrace) {
        Logger.error('❌ 未知错误', error: e, stackTrace: stackTrace);
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
        AppException.network('❌ iTunes 搜索失败，已重试 $_maxRetryCount 次');
  }
}
