import 'dart:async';
import 'dart:io';
import 'package:dio/io.dart';
import 'package:dio/dio.dart' as dio;
import 'package:rss_dart/dart_rss.dart';
import 'package:rss_dart/domain/rss_itunes_category.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';

/// RSS 解析器服务
///
/// 负责解析 RSS 订阅源，提取播客元数据和节目列表
/// 支持 RSS 1.0、RSS 2.0 和 Atom 格式
class RssParserService {
  /// Dio 实例
  final dio.Dio _dio;

  /// 最大重试次数
  final int _maxRetryCount;

  /// 构造函数
  RssParserService({
    dio.Dio? dioInstance,
    int maxRetryCount = AppConstants.maxRetryCount,
    int timeout = AppConstants.defaultTimeout,
  }) : _dio = dioInstance ?? dio.Dio(),
       _maxRetryCount = maxRetryCount {
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    _dio.options.sendTimeout = Duration(milliseconds: timeout);

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) => 'DIRECT';
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );
  }

  /// 解析 RSS 订阅源
  ///
  /// [rssUrl] RSS 订阅源 URL
  /// 返回包含 Podcast 和 Episode 列表的 Map
  /// 抛出 AppException 当解析失败时
  Future<Map<String, dynamic>> parseRssFeed(String rssUrl) async {
    int retryCount = 0;
    AppException? lastException;

    while (retryCount <= _maxRetryCount) {
      try {
        Logger.info('开始解析 RSS 订阅源: $rssUrl');

        final response = await _dio.get(
          rssUrl,
          options: dio.Options(
            headers: {
              'Accept': 'application/rss+xml, application/xml, text/xml, */*',
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

        final xmlContent = response.data as String;
        if (xmlContent.isEmpty) {
          throw AppException.validation('RSS 内容为空');
        }

        final podcast = _extractPodcastFromRss(xmlContent, rssUrl);
        final episodes = _extractEpisodesFromRss(xmlContent, podcast.id);

        Logger.info('RSS 解析完成: ${podcast.title}, ${episodes.length} 个节目');

        return {'podcast': podcast, 'episodes': episodes};
      } on dio.DioException catch (e) {
        Logger.warning(
          'RSS 解析失败 (尝试 ${retryCount + 1}/$_maxRetryCount): ${e.message}',
        );
        lastException = NetworkErrorHandler.handleDioException(e);
      } on AppException catch (e) {
        Logger.error('RSS 解析错误: ${e.message}');
        lastException = e;
        break;
      } catch (e, stackTrace) {
        Logger.error('未知错误', error: e, stackTrace: stackTrace);
        lastException = AppException.unknown(
          'RSS 解析失败',
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
        AppException.network('RSS 解析失败，已重试 $_maxRetryCount 次');
  }

  /// 从 RSS 内容提取播客元数据
  Podcast _extractPodcastFromRss(String xmlContent, String rssUrl) {
    try {
      final rssFeed = RssFeed.parse(xmlContent);

      final now = DateTime.now();

      return Podcast(
        id: now.millisecondsSinceEpoch,
        title: rssFeed.title ?? '未知播客',
        subtitle: rssFeed.itunes?.subtitle,
        author:
            rssFeed.itunes?.author ??
            rssFeed.dc?.creator ??
            rssFeed.title ??
            '未知',
        description: rssFeed.description ?? rssFeed.itunes?.summary ?? '暂无描述',
        artworkUrl:
            rssFeed.itunes?.image?.href ??
            rssFeed.image?.url ??
            'https://via.placeholder.com/300x300?text=No+Image',
        rssUrl: rssUrl,
        websiteUrl: rssFeed.link,
        language: rssFeed.language,
        copyright: rssFeed.dc?.rights,
        categories:
            rssFeed.itunes?.categories
                .whereType<RssItunesCategory>()
                .map((cat) => cat.category)
                .whereType<String>()
                .toList() ??
            [],
        keywords: rssFeed.itunes?.keywords ?? [],
        isExplicit: rssFeed.itunes?.explicit ?? false,
        ownerName: rssFeed.itunes?.owner?.name,
        ownerEmail: rssFeed.itunes?.owner?.email,
        lastUpdated: _parseDateTime(rssFeed.lastBuildDate) ?? now,
        episodeCount: rssFeed.items.length,
        isSubscribed: false,
        subscribedAt: null,
        createdAt: now,
      );
    } catch (e, stackTrace) {
      Logger.error('提取播客元数据失败', error: e, stackTrace: stackTrace);
      throw AppException.validation(
        '提取播客元数据失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 从 RSS 内容提取节目列表
  List<Episode> _extractEpisodesFromRss(String xmlContent, int podcastId) {
    try {
      final rssFeed = RssFeed.parse(xmlContent);
      final List<Episode> episodes = [];
      final now = DateTime.now();

      for (var i = 0; i < rssFeed.items.length; i++) {
        final item = rssFeed.items[i];

        try {
          episodes.add(
            Episode(
              id: now.millisecondsSinceEpoch + i,
              podcastId: podcastId,
              title: item.title ?? '节目 $i',
              description:
                  item.description ??
                  item.content?.value ??
                  item.itunes?.summary ??
                  '',
              link: item.link,
              guid: item.guid,
              author: item.author ?? item.dc?.creator,
              pubDate: _parseDateTime(item.pubDate) ?? now,
              audioUrl: item.enclosure?.url ?? '',
              audioType: item.enclosure?.type ?? 'audio/mpeg',
              duration: item.itunes?.duration?.inSeconds,
              artworkUrl: item.itunes?.image?.href,
              isExplicit: item.itunes?.explicit ?? false,
              isPlayed: false,
              isDownloaded: false,
              downloadedPath: null,
              downloadProgress: 0.0,
              playProgress: 0.0,
              lastPlayedAt: null,
              createdAt: now,
              updatedAt: now,
            ),
          );
        } catch (e) {
          Logger.warning('解析节目失败 (索引 $i): $e');
          continue;
        }
      }

      Logger.info('成功提取 ${episodes.length} 个节目');
      return episodes;
    } catch (e, stackTrace) {
      Logger.error('提取节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.validation(
        '提取节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 解析日期时间
  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      Logger.debug('解析日期时间失败: $dateTimeString');
      return null;
    }
  }
}
