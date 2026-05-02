import 'dart:async';
import 'package:dio/dio.dart' as dio;
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../services/rss_parser_service.dart';
import '../services/itunes_search_service.dart';
import 'local_podcast_datasource.dart';

class RemotePodcastDataSource {
  final RssParserService _rssParserService;
  final dio.Dio _dio;
  final ITunesSearchService? _itunesSearchService;
  final LocalPodcastDataSource? _localDataSource;

  Future<void>? _currentITunesSearchFuture;

  RemotePodcastDataSource({
    RssParserService? rssParserService,
    dio.Dio? dioInstance,
    ITunesSearchService? itunesSearchService,
    LocalPodcastDataSource? localDataSource,
  }) : _rssParserService = rssParserService ?? RssParserService(),
       _dio = dioInstance ?? dio.Dio(),
       _itunesSearchService = itunesSearchService,
       _localDataSource = localDataSource {
    _dio.options.connectTimeout = Duration(milliseconds: AppConstants.defaultTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: AppConstants.defaultTimeout);
  }

  Future<Map<String, dynamic>> getPodcastFromRss(String rssUrl) async {
    try {
      Logger.info('从 RSS 获取播客数据: $rssUrl');

      final result = await _rssParserService.parseRssFeed(rssUrl);
      final podcast = result['podcast'] as Podcast;
      final episodes = result['episodes'] as List<Episode>;

      Logger.info('成功获取播客: ${podcast.title}, ${episodes.length} 个节目');

      if (_itunesSearchService != null && _localDataSource != null) {
        _currentITunesSearchFuture = _asyncITunesSearch(podcast, rssUrl);
      }

      return {
        'podcast': podcast,
        'episodes': episodes,
      };
    } on AppException catch (e) {
      Logger.error('获取播客数据失败: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      Logger.error('获取播客数据失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取播客数据失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void>? getITunesSearchFuture() {
    return _currentITunesSearchFuture;
  }

  Future<void> _asyncITunesSearch(Podcast podcast, String rssUrl) async {
    final searchService = _itunesSearchService;
    final localDataSource = _localDataSource;
    if (searchService == null || localDataSource == null) return;

    try {
      Logger.info('开始异步 iTunes 搜索: ${podcast.title}');

      final results = await searchService.searchPodcastOnITunes(
        term: podcast.title,
        limit: 1,
      );

      if (results.isEmpty) {
        Logger.info('iTunes 搜索无结果: ${podcast.title}');
        return;
      }

      final firstResult = results.first;

      final podcastModel = await localDataSource.getPodcastByRssUrl(rssUrl);
      if (podcastModel == null) {
        Logger.warning('无法获取播客模型进行 iTunes 信息更新');
        return;
      }

      podcastModel.appleId = firstResult.collectionId;
      podcastModel.itunesArtworkUrl = firstResult.artworkUrl600;

      await localDataSource.updateITunesInfo(
        podcastModel.id,
        firstResult.collectionId,
        firstResult.artworkUrl600,
      );

      Logger.info(
        '成功更新 iTunes 信息: appleId=${firstResult.collectionId}, artworkUrl=${firstResult.artworkUrl600}',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '异步 iTunes 搜索失败: ${podcast.title}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> validateRssUrl(String rssUrl) async {
    try {
      Logger.info('验证 RSS URL 可访问性: $rssUrl');

      final response = await _dio.head(
        rssUrl,
        options: dio.Options(
          headers: {
            'Accept': 'application/rss+xml, application/xml, text/xml, */*',
            'User-Agent': 'TinyCast/${AppConstants.appVersion}',
          },
        ),
      );

      final isValid = response.statusCode == 200;
      
      if (isValid) {
        Logger.info('RSS URL 验证成功: $rssUrl');
      } else {
        Logger.warning('RSS URL 验证失败，状态码: ${response.statusCode}');
      }

      return isValid;
    } on dio.DioException catch (e) {
      Logger.warning('RSS URL 验证失败: ${e.message}');
      
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        throw AppException.network(
          '连接超时，请检查网络连接',
          originalError: e,
        );
      } else if (e.type == dio.DioExceptionType.connectionError) {
        throw AppException.network(
          '无法连接到服务器',
          originalError: e,
        );
      } else if (e.response?.statusCode != null) {
        throw AppException.network(
          '请求失败，状态码: ${e.response?.statusCode}',
          statusCode: e.response?.statusCode,
          originalError: e,
        );
      }
      
      throw AppException.network(
        '验证 RSS URL 失败',
        originalError: e,
      );
    } catch (e, stackTrace) {
      Logger.error('验证 RSS URL 失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '验证 RSS URL 失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
}
