import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/app_exception.dart';
import 'package:tinycast/core/utils/app_constants.dart';
import 'package:tinycast/core/utils/html_rss_extractor.dart';
import 'package:tinycast/core/utils/itunes_info_dto.dart';
import 'package:tinycast/data/services/rss_parser_service.dart';
import 'package:tinycast/data/services/itunes_search_service.dart';
import 'package:tinycast/data/datasources/local_podcast_datasource.dart';

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
      final msg = e.message.toLowerCase();
      // 更精确地检测 HTML 相关错误（排除 captcha 挑战）
      final isHtmlError = (msg.contains('html') && !msg.contains('captcha')) ||
                          msg.contains('html 页面') ||
                          msg.contains('网页');
      if (isHtmlError) {
        Logger.warning('📄 [REMOTE] RSS URL 返回了 HTML 内容，尝试从页面提取真实 RSS 链接: $rssUrl');
        return await _tryExtractRssFromHtmlPage(rssUrl);
      }
      Logger.error('❌ [REMOTE] 获取播客数据失败: ${e.message}');
      rethrow;
    } catch (e, stackTrace) {
      final errorMsg = e.toString().toLowerCase();
      // 检测 XML 解析失败，内容可能是 HTML
      final isXmlParseError = errorMsg.contains('xmlexception') || 
                              errorMsg.contains('xmltagexception') ||
                              errorMsg.contains('xml');
      if (isXmlParseError) {
        Logger.warning('📄 [REMOTE] XML 解析失败，内容可能是 HTML，尝试从页面提取: $rssUrl');
        return await _tryExtractRssFromHtmlPage(rssUrl);
      }
      Logger.error('❌ [REMOTE] 获取播客数据失败', error: e, stackTrace: stackTrace);
      throw AppException.unknown(
        '获取播客数据失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Map<String, dynamic>> _tryExtractRssFromHtmlPage(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.plain,
          headers: {
            'Accept': 'text/html, application/xhtml+xml, application/xml, */*',
            'User-Agent': 'TinyCast/${AppConstants.appVersion}',
          },
        ),
      );

      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw AppException.network('无法访问该页面，状态码: ${response.statusCode}');
      }

      final htmlContent = _getHtmlContent(response);
      if (htmlContent.isEmpty) throw AppException.validation('页面内容为空');

      final rssUrl = _extractRssLinkFromHtml(htmlContent, url);
      if (rssUrl == null || rssUrl.isEmpty) {
        throw AppException.validation('未能在页面中找到 RSS 订阅链接');
      }

      Logger.info('从 HTML 页面提取到 RSS 链接: $rssUrl');
      return await getPodcastFromRss(rssUrl);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.validation('无法从网页中提取 RSS 链接', originalError: e);
    }
  }

  String? _extractRssLinkFromHtml(String htmlContent, String baseUrl) {
    return HtmlRssExtractor.extractRssLink(htmlContent, baseUrl);
  }

  String _getHtmlContent(dio.Response response) {
    final data = response.data;
    if (data is String) return data;
    if (data == null) return '';
    return data.toString();
  }

  Future<void>? getITunesSearchFuture() {
    return _currentITunesSearchFuture;
  }

  Future<void> _asyncITunesSearch(Podcast podcast, String rssUrl) async {
    final searchService = _itunesSearchService;
    final localDataSource = _localDataSource;
    if (searchService == null || localDataSource == null) return;

    try {
      Logger.info('🎧 开始异步 iTunes 搜索: ${podcast.title}');

      ITunesSearchResult? match;

      final results = await searchService.searchPodcastOnITunes(
        term: podcast.title,
        limit: 5,
      );

      if (results.isNotEmpty) {
        match = _findBestMatch(results, rssUrl, podcast.websiteUrl, podcast.title);
      }

      if (match == null) {
        Logger.info('🔍 关键词搜索未找到匹配，尝试通过 feedUrl 查找');
        match = await searchService.lookupByFeedUrl(rssUrl);
      }

      if (match == null || match.collectionId == null) {
        Logger.info('⚠️ iTunes 搜索未找到匹配: ${podcast.title}');
        return;
      }

      final podcastModel = await localDataSource.getPodcastByRssUrl(rssUrl);
      if (podcastModel == null) {
        Logger.warning('❌ 无法获取播客模型进行 iTunes 信息更新');
        return;
      }

      podcastModel.itunesId = match.collectionId;
      podcastModel.itunesArtworkUrl = match.artworkUrl600;
      podcastModel.itunesPrimaryGenreName = match.primaryGenreName;
      podcastModel.itunesGenres = match.genres;
      podcastModel.itunesGenreIds = match.genreIds;
      podcastModel.itunesCollectionViewUrl = match.collectionViewUrl;
      podcastModel.itunesCountry = match.country;
      podcastModel.itunesReleaseDate = match.releaseDate;
      podcastModel.itunesCollectionExplicitness = match.collectionExplicitness;
      podcastModel.itunesContentAdvisoryRating = match.contentAdvisoryRating;

      await localDataSource.updateFullITunesInfo(
        podcastModel.id,
        ITunesInfoDTO(
          itunesId: match.collectionId,
          itunesArtworkUrl600: match.artworkUrl600,
          itunesPrimaryGenreName: match.primaryGenreName,
          itunesGenres: match.genres,
          itunesGenreIds: match.genreIds,
          itunesCollectionViewUrl: match.collectionViewUrl,
          itunesCountry: match.country,
          itunesReleaseDate: match.releaseDate,
          itunesCollectionExplicitness: match.collectionExplicitness,
          itunesContentAdvisoryRating: match.contentAdvisoryRating,
        ),
      );

      await localDataSource.updateEpisodesPodcastITunesId(
        podcastModel.id,
        match.collectionId,
      );

      Logger.info(
        '✅ 成功更新完整 iTunes 信息: itunesId=${match.collectionId}, '
        'artworkUrl=${match.artworkUrl600}, '
        'genre=${match.primaryGenreName}, '
        'country=${match.country}',
      );
    } catch (e, stackTrace) {
      Logger.error(
        '❌ 异步 iTunes 搜索失败: ${podcast.title}',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 从搜索结果中找到最佳匹配的播客
  ///
  /// 匹配优先级：
  /// 1. feedUrl 完全相同
  /// 2. websiteUrl 域名相同
  /// 3. 标题完全相同
  ///
  /// 不返回「第一个结果」作兜底：关键词搜索的首条结果常是同名或相关播客，
  /// 直接采用会把错误的 iTunes ID 写进数据库，后续同步与元数据都会错位。
  ITunesSearchResult? _findBestMatch(
    List<ITunesSearchResult> results,
    String rssUrl,
    String? websiteUrl,
    String podcastTitle,
  ) {
    // 优先匹配 feedUrl 相同
    for (final result in results) {
      if (result.feedUrl != null &&
          _normalizeUrl(result.feedUrl!) == _normalizeUrl(rssUrl)) {
        Logger.info('通过 feedUrl 匹配到播客: ${result.collectionName}');
        return result;
      }
    }

    // 匹配 websiteUrl 域名
    if (websiteUrl != null && websiteUrl.isNotEmpty) {
      final websiteDomain = _extractDomain(websiteUrl);
      for (final result in results) {
        if (result.website != null && result.website!.isNotEmpty) {
          final resultDomain = _extractDomain(result.website!);
          if (websiteDomain == resultDomain) {
            Logger.info('通过 websiteUrl 域名匹配到播客: ${result.collectionName}');
            return result;
          }
        }
      }
    }

    // 标题匹配
    for (final result in results) {
      if (result.collectionName.toLowerCase() ==
          podcastTitle.toLowerCase()) {
        Logger.info('通过标题匹配到播客: ${result.collectionName}');
        return result;
      }
    }

    return null;
  }

  String _normalizeUrl(String url) {
    return url
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'https?://'), '')
        .replaceAll(RegExp(r'/$'), '');
  }

  String _extractDomain(String url) {
    try {
      final normalized = _normalizeUrl(url);
      final parts = normalized.split('/');
      return parts.first;
    } catch (_) {
      return '';
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

      final isValid = response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
      
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
