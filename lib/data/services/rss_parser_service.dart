import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:xml/xml.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';
import '../../core/utils/parse_error_handler.dart';

/// RSS 解析器服务
///
/// 负责解析 RSS 订阅源，提取播客元数据和节目列表
/// 支持 RSS 2.0 和 Atom 格式
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
  }

  /// 解析 RSS 订阅源
  ///
  /// [rssUrl] RSS 订阅源 URL
  /// 返回包含 Podcast 和 Episode 列表的 Map
  /// 抛出 AppException 当解析失败时
  Future<Map<String, dynamic>> parseRssFeed(String rssUrl) async {
    // 验证 RSS URL
    ParseErrorHandler.validateRssFeed(rssUrl);

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

        // 使用 ParseErrorHandler 安全解析 XML
        final document = ParseErrorHandler.parseXmlSafely(xmlContent);
        Logger.debug('XML 解析成功');

        final podcast = extractPodcastMetadata(document, rssUrl);
        final episodes = extractEpisodes(document, podcast.id);

        Logger.info('RSS 解析完成: ${podcast.title}, ${episodes.length} 个节目');

        return {'podcast': podcast, 'episodes': episodes};
      } on dio.DioException catch (e, stackTrace) {
        Logger.warning(
          'RSS 解析失败 (尝试 ${retryCount + 1}/$_maxRetryCount): ${e.message}',
        );
        lastException = NetworkErrorHandler.handleDioException(e);
      } on XmlException catch (e, stackTrace) {
        Logger.error('XML 解析错误', error: e, stackTrace: stackTrace);
        lastException = ParseErrorHandler.handleXmlException(e);
        break;
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

  /// 提取播客元数据
  ///
  /// [xml] XML 文档对象
  /// [rssUrl] RSS 订阅源 URL
  /// 返回 Podcast 实体
  Podcast extractPodcastMetadata(XmlDocument xml, String rssUrl) {
    try {
      final root = xml.rootElement;

      String title = '';
      String author = '';
      String description = '';
      String artworkUrl = '';
      String? subtitle;
      String? websiteUrl;
      String? language;
      String? copyright;
      List<String>? categories;
      List<String>? keywords;
      bool isExplicit = false;
      String? ownerName;
      String? ownerEmail;

      final isRss = root.localName == 'rss';
      final isAtom = root.localName == 'feed';

      if (isRss) {
        final channel = root.findElements('channel').firstOrNull;
        if (channel == null) {
          throw AppException.validation('RSS 格式无效：缺少 channel 元素');
        }

        title = _getElementText(channel, 'title') ?? '未知播客';
        description = _getElementText(channel, 'description') ?? '';
        language = _getElementText(channel, 'language');
        copyright = _getElementText(channel, 'copyright');

        final link = _getElementText(channel, 'link');
        websiteUrl = link;

        author =
            _getElementText(channel, 'itunes:author') ??
            _getElementText(channel, 'author') ??
            title;

        subtitle = _getElementText(channel, 'itunes:subtitle');

        final explicit = _getElementText(channel, 'itunes:explicit');
        isExplicit =
            explicit?.toLowerCase() == 'true' ||
            explicit?.toLowerCase() == 'yes';

        ownerName = _getElementText(channel, 'itunes:owner') != null
            ? _getElementText(
                        channel,
                        'itunes:owner',
                      )?.contains('itunes:name') ==
                      true
                  ? _getElementText(channel, 'itunes:name')
                  : null
            : null;
        ownerEmail = _getElementText(channel, 'itunes:email');

        final imageElement = channel.findElements('itunes:image').firstOrNull;
        if (imageElement != null) {
          artworkUrl = imageElement.getAttribute('href') ?? '';
        }

        if (artworkUrl.isEmpty) {
          final rssImage = channel.findElements('image').firstOrNull;
          if (rssImage != null) {
            artworkUrl = _getElementText(rssImage, 'url') ?? '';
          }
        }

        if (artworkUrl.isEmpty) {
          final podcastImage = channel
              .findElements('podcast:image')
              .firstOrNull;
          if (podcastImage != null) {
            artworkUrl = podcastImage.getAttribute('href') ?? '';
          }
        }

        categories = channel
            .findElements('itunes:category')
            .map((e) => e.getAttribute('text') ?? '')
            .where((text) => text.isNotEmpty)
            .toList();

        keywords = _getElementText(
          channel,
          'itunes:keywords',
        )?.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
      } else if (isAtom) {
        title = _getElementText(root, 'title') ?? '未知播客';
        description = _getElementText(root, 'subtitle') ?? '';
        author = _getElementText(root, 'author')?.contains('name') == true
            ? _getElementText(root, 'name') ?? title
            : title;

        final linkElement = root.findElements('link').firstOrNull;
        websiteUrl =
            linkElement?.getAttribute('href') ?? linkElement?.innerText;

        final icon = _getElementText(root, 'icon');
        final logo = _getElementText(root, 'logo');
        artworkUrl = icon ?? logo ?? '';

        language = root.getAttribute('xml:lang');

        final rights = _getElementText(root, 'rights');
        copyright = rights;
      } else {
        throw AppException.validation('不支持的 RSS 格式');
      }

      if (artworkUrl.isEmpty) {
        artworkUrl = 'https://via.placeholder.com/300x300?text=No+Image';
      }

      if (description.isEmpty) {
        description = subtitle ?? '暂无描述';
      }

      final now = DateTime.now();

      return Podcast(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        subtitle: subtitle,
        author: author,
        description: description,
        artworkUrl: artworkUrl,
        rssUrl: rssUrl,
        websiteUrl: websiteUrl,
        language: language,
        copyright: copyright,
        categories: categories,
        keywords: keywords,
        isExplicit: isExplicit,
        ownerName: ownerName,
        ownerEmail: ownerEmail,
        lastUpdated: now,
        episodeCount: 0,
        isSubscribed: false,
        subscribedAt: null,
        createdAt: now,
      );
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      Logger.error('提取播客元数据失败', error: e, stackTrace: stackTrace);
      throw AppException.validation(
        '提取播客元数据失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 提取节目列表
  ///
  /// [xml] XML 文档对象
  /// [podcastId] 播客 ID
  /// 返回 Episode 实体列表
  List<Episode> extractEpisodes(XmlDocument xml, int podcastId) {
    try {
      final root = xml.rootElement;
      final List<Episode> episodes = [];

      final isRss = root.localName == 'rss';
      final isAtom = root.localName == 'feed';

      if (isRss) {
        final channel = root.findElements('channel').firstOrNull;
        if (channel == null) {
          throw AppException.validation('RSS 格式无效：缺少 channel 元素');
        }

        final items = channel.findElements('item');
        for (var i = 0; i < items.length; i++) {
          final item = items.elementAt(i);
          try {
            final episode = _parseRssItem(item, podcastId, i);
            episodes.add(episode);
          } catch (e) {
            Logger.warning('解析节目失败 (索引 $i): $e');
            continue;
          }
        }
      } else if (isAtom) {
        final entries = root.findElements('entry');
        for (var i = 0; i < entries.length; i++) {
          final entry = entries.elementAt(i);
          try {
            final episode = _parseAtomEntry(entry, podcastId, i);
            episodes.add(episode);
          } catch (e) {
            Logger.warning('解析节目失败 (索引 $i): $e');
            continue;
          }
        }
      }

      Logger.info('成功提取 ${episodes.length} 个节目');
      return episodes;
    } catch (e, stackTrace) {
      if (e is AppException) {
        rethrow;
      }
      Logger.error('提取节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.validation(
        '提取节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 解析 RSS item 元素
  Episode _parseRssItem(XmlElement item, int podcastId, int index) {
    final title = _getElementText(item, 'title') ?? '节目 $index';
    final description =
        _getElementText(item, 'description') ??
        _getElementText(item, 'itunes:summary') ??
        _getElementText(item, 'content:encoded') ??
        '';
    final link = _getElementText(item, 'link');
    final guid = _getElementText(item, 'guid');
    final author =
        _getElementText(item, 'itunes:author') ??
        _getElementText(item, 'author');

    final pubDateText = _getElementText(item, 'pubDate');
    final pubDate = _parseDateTime(pubDateText) ?? DateTime.now();

    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure == null) {
      throw AppException.validation('节目缺少音频文件: $title');
    }

    final audioUrl = enclosure.getAttribute('url') ?? '';
    if (audioUrl.isEmpty) {
      throw AppException.validation('节目音频 URL 为空: $title');
    }

    final audioType = enclosure.getAttribute('type') ?? 'audio/mpeg';

    final durationText = _getElementText(item, 'itunes:duration');
    final duration = _parseDuration(durationText);

    final imageElement = item.findElements('itunes:image').firstOrNull;
    String? artworkUrl;
    if (imageElement != null) {
      artworkUrl = imageElement.getAttribute('href');
    }

    if (artworkUrl == null || artworkUrl.isEmpty) {
      final enclosureUrl = enclosure.getAttribute('url');
      if (enclosureUrl != null) {
        artworkUrl = enclosureUrl.substring(0, enclosureUrl.lastIndexOf('/'));
      }
    }

    final explicit = _getElementText(item, 'itunes:explicit');
    final isExplicit =
        explicit?.toLowerCase() == 'true' || explicit?.toLowerCase() == 'yes';

    final now = DateTime.now();

    return Episode(
      id: DateTime.now().millisecondsSinceEpoch + index,
      podcastId: podcastId,
      title: title,
      description: description,
      link: link,
      guid: guid,
      author: author,
      pubDate: pubDate,
      audioUrl: audioUrl,
      audioType: audioType,
      duration: duration,
      artworkUrl: artworkUrl,
      isExplicit: isExplicit,
      isPlayed: false,
      isDownloaded: false,
      downloadedPath: null,
      downloadProgress: 0.0,
      playProgress: 0.0,
      lastPlayedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 解析 Atom entry 元素
  Episode _parseAtomEntry(XmlElement entry, int podcastId, int index) {
    final title = _getElementText(entry, 'title') ?? '节目 $index';
    final description =
        _getElementText(entry, 'summary') ??
        _getElementText(entry, 'content') ??
        '';
    final linkElement = entry.findElements('link').firstOrNull;
    final link = linkElement?.getAttribute('href') ?? linkElement?.innerText;

    final id = _getElementText(entry, 'id');
    final author = _getElementText(entry, 'author')?.contains('name') == true
        ? _getElementText(entry, 'name')
        : null;

    final pubDateText =
        _getElementText(entry, 'published') ??
        _getElementText(entry, 'updated');
    final pubDate = _parseDateTime(pubDateText) ?? DateTime.now();

    final enclosure = entry.findElements('enclosure').firstOrNull;
    String audioUrl = '';
    String audioType = 'audio/mpeg';

    if (enclosure != null) {
      audioUrl = enclosure.getAttribute('url') ?? '';
      audioType = enclosure.getAttribute('type') ?? 'audio/mpeg';
    } else {
      final linkWithRelEnclosure = entry
          .findElements('link')
          .where((e) => e.getAttribute('rel') == 'enclosure')
          .firstOrNull;
      if (linkWithRelEnclosure != null) {
        audioUrl = linkWithRelEnclosure.getAttribute('href') ?? '';
        audioType = linkWithRelEnclosure.getAttribute('type') ?? 'audio/mpeg';
      }
    }

    if (audioUrl.isEmpty) {
      throw AppException.validation('节目缺少音频文件: $title');
    }

    final now = DateTime.now();

    return Episode(
      id: DateTime.now().millisecondsSinceEpoch + index,
      podcastId: podcastId,
      title: title,
      description: description,
      link: link,
      guid: id,
      author: author,
      pubDate: pubDate,
      audioUrl: audioUrl,
      audioType: audioType,
      duration: null,
      artworkUrl: null,
      isExplicit: false,
      isPlayed: false,
      isDownloaded: false,
      downloadedPath: null,
      downloadProgress: 0.0,
      playProgress: 0.0,
      lastPlayedAt: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 获取元素的文本内容
  String? _getElementText(XmlElement parent, String tagName) {
    final element = parent.findElements(tagName).firstOrNull;
    return element?.innerText.trim();
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

  /// 解析时长（秒）
  int? _parseDuration(String? durationString) {
    if (durationString == null || durationString.isEmpty) {
      return null;
    }

    try {
      if (durationString.contains(':')) {
        final parts = durationString.split(':');
        if (parts.length == 3) {
          final hours = int.parse(parts[0]);
          final minutes = int.parse(parts[1]);
          final seconds = int.parse(parts[2]);
          return hours * 3600 + minutes * 60 + seconds;
        } else if (parts.length == 2) {
          final minutes = int.parse(parts[0]);
          final seconds = int.parse(parts[1]);
          return minutes * 60 + seconds;
        }
      } else {
        return int.parse(durationString);
      }
    } catch (e) {
      Logger.debug('解析时长失败: $durationString');
      return null;
    }

    return null;
  }
}
