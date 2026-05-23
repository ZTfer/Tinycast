import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';
import '../../domain/entities/podcast.dart';
import '../../domain/entities/episode.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';

/// RSS 解析器服务
///
/// 负责解析 RSS 订阅源，提取播客元数据和节目列表
/// 使用 XML 库直接解析以完全掌控数据提取过程
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
            responseType: dio.ResponseType.plain,
            headers: {
              'Accept': 'application/rss+xml, application/xml, text/xml, */*',
              'User-Agent': 'TinyCast/${AppConstants.appVersion}',
            },
          ),
        );

        if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
          throw AppException.network(
            '请求失败，状态码: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        }

        final contentType = response.headers.value('content-type')?.toLowerCase() ?? '';
        final xmlContent = _getXmlContent(response);
        
        Logger.info('📡 [RSS] 响应 Content-Type: $contentType, 内容长度: ${xmlContent.length} 字符');
        
        if (xmlContent.isEmpty) {
          throw AppException.validation('RSS 内容为空');
        }

        final isCaptchaChallenge = _isCaptchaChallenge(response, xmlContent);
        if (isCaptchaChallenge) {
          Logger.warning('🛡️ [RSS] 检测到反爬虫验证挑战 (SG-Captcha): $rssUrl');
          throw AppException.network(
            '该网站启用了反机器人验证（安全网关），当前网络环境无法直接访问其 RSS 源。\n'
            '建议尝试：\n'
            '1. 切换网络（如手机热点）后重试\n'
            '2. 稍等片刻后再试\n'
            '3. 使用该播客的其他 RSS 订阅地址',
            statusCode: response.statusCode,
          );
        }

        if (_isHtmlResponse(contentType, xmlContent)) {
          Logger.warning('📄 [RSS] 检测到 HTML 响应，将触发 HTML 提取 RSS 逻辑');
          throw AppException.validation(
            '服务器返回了 HTML 页面而非 RSS 数据，该 URL 可能需要通过网页查找订阅链接',
          );
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

  /// 从 Dio 响应中提取 XML 内容字符串
  String _getXmlContent(dio.Response response) {
    final data = response.data;
    if (data is String) return data;
    if (data == null) return '';
    return data.toString();
  }

  /// 从 RSS 内容提取播客元数据
  Podcast _extractPodcastFromRss(String xmlContent, String rssUrl) {
    try {
      final document = XmlDocument.parse(xmlContent);
      final channel = document.findAllElements('channel').first;

      final now = DateTime.now();

      return Podcast(
        id: now.millisecondsSinceEpoch,
        title: _getElementText(channel, 'title') ?? '未知播客',
        subtitle: _getITunesElementText(channel, 'subtitle'),
        author: _getITunesElementText(channel, 'author') ??
            _getDublinCoreElementText(channel, 'creator') ??
            _getElementText(channel, 'title') ??
            '未知',
        description: _getElementText(channel, 'description') ??
            _getITunesElementText(channel, 'summary') ??
            '暂无描述',
        artworkUrl: _getITunesImageHref(channel) ??
            _getElementText(channel, 'image', 'url') ??
            'https://via.placeholder.com/300x300?text=No+Image',
        rssUrl: rssUrl,
        websiteUrl: _getElementText(channel, 'link'),
        language: _getElementText(channel, 'language'),
        copyright: _getElementText(channel, 'copyright') ??
            _getDublinCoreElementText(channel, 'rights'),
        categories: _extractITunesCategories(channel),
        keywords: _extractITunesKeywordsList(channel),
        isExplicit: _parseExplicit(_getITunesElementText(channel, 'explicit')),
        ownerName: _getITunesElementText(channel, 'owner', 'name'),
        ownerEmail: _getITunesElementText(channel, 'owner', 'email'),
        lastUpdated: _parseDateTime(
          _getElementText(channel, 'lastBuildDate'),
        ) ??
            now,
        episodeCount: channel.findAllElements('item').length,
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
      final document = XmlDocument.parse(xmlContent);
      final channel = document.findAllElements('channel').first;
      final itemsList = channel.findAllElements('item').toList();
      final List<Episode> episodes = [];
      final now = DateTime.now();
      int guidMissingCount = 0;

      for (var i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];

        try {
          final enclosure = item.getElement('enclosure');
          final rawGuid = _getElementText(item, 'guid');
          final guid = (rawGuid != null && rawGuid.isNotEmpty) ? rawGuid : null;
          
          if (guid == null) {
            guidMissingCount++;
            Logger.warning('⚠️ [RSS] 节目索引 $i 缺少 GUID，将使用 audioUrl 作为备选标识');
          }
          
          final fallbackGuid = guid ?? _generateGuidFromAudioUrl(enclosure?.getAttribute('url'), i);
          
          episodes.add(
            Episode(
              id: now.millisecondsSinceEpoch + i,
              podcastId: podcastId,
              title: _getElementText(item, 'title') ?? '节目 $i',
              description: _getElementText(item, 'description') ??
                  _getITunesElementText(item, 'summary') ??
                  '',
              link: _getElementText(item, 'link') ?? '',
              guid: fallbackGuid,
              author: _getElementText(item, 'author') ??
                  _getITunesElementText(item, 'author') ??
                  _getDublinCoreElementText(item, 'creator'),
              pubDate: _parseDateTime(_getElementText(item, 'pubDate')) ?? now,
              audioUrl: enclosure?.getAttribute('url') ?? '',
              audioType: enclosure?.getAttribute('type') ?? 'audio/mpeg',
              duration: _parseDuration(_getITunesElementText(item, 'duration')),
              artworkUrl: _getITunesImageHref(item),
              isExplicit: _parseExplicit(
                _getITunesElementText(item, 'explicit'),
              ),
              isPlayed: false,
              isDownloaded: false,
              downloadedPath: null,
              downloadProgress: 0.0,
              playProgress: 0.0,
              lastPlayedAt: null,
              createdAt: now,
              updatedAt: now,
              itunesId: _getITunesElementText(item, 'id'),
              itunesArtworkUrl: _getITunesImageHref(item),
            ),
          );
        } catch (e, stackTrace) {
          Logger.warning('⚠️ [RSS] 解析节目失败 (索引 $i): $e');
          Logger.error('解析详情', error: e, stackTrace: stackTrace);
          continue;
        }
      }

      if (guidMissingCount > 0) {
        Logger.warning('⚠️ [RSS] 共 ${itemsList.length} 个节目中，$guidMissingCount 个缺少 GUID');
      }
      Logger.info('✅ [RSS] 成功提取 ${episodes.length} 个节目（含 ${guidMissingCount} 个自动生成 GUID）');
      return episodes;
    } catch (e, stackTrace) {
      Logger.error('❌ [RSS] 提取节目列表失败', error: e, stackTrace: stackTrace);
      throw AppException.validation(
        '提取节目列表失败',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// 当 GUID 缺失时，从 audioUrl 生成一个稳定的标识符
  String _generateGuidFromAudioUrl(String? audioUrl, int index) {
    if (audioUrl != null && audioUrl.isNotEmpty) {
      return 'auto_guid:$audioUrl';
    }
    return 'auto_guid:index_$index';
  }

  /// 获取元素文本内容
  String? _getElementText(XmlElement parent, String tagName, [String? subTag]) {
    try {
      if (subTag != null) {
        final element = parent.getElement(tagName);
        return element?.getElement(subTag)?.innerText;
      }
      return parent.getElement(tagName)?.innerText;
    } catch (e) {
      return null;
    }
  }

  /// 获取 iTunes 命名空间元素文本
  String? _getITunesElementText(XmlElement parent, String tagName, [String? subTag]) {
    try {
      final element = parent.getElement(tagName, namespace: 'itunes');
      if (element == null) {
        return parent.getElement('itunes:$tagName')?.innerText;
      }
      if (subTag != null) {
        return element.getElement(subTag)?.innerText;
      }
      return element.innerText;
    } catch (e) {
      return null;
    }
  }

  /// 获取 Dublin Core 命名空间元素文本
  String? _getDublinCoreElementText(XmlElement parent, String tagName) {
    try {
      return parent.getElement(tagName, namespace: 'dc')?.innerText ??
          parent.getElement('dc:$tagName')?.innerText;
    } catch (e) {
      return null;
    }
  }

  /// 获取 iTunes 图片 URL
  String? _getITunesImageHref(XmlElement parent) {
    try {
      return parent.getElement('image', namespace: 'itunes')?.getAttribute('href') ??
          parent.getElement('itunes:image')?.getAttribute('href');
    } catch (e) {
      return null;
    }
  }

  /// 提取 iTunes 分类
  List<String> _extractITunesCategories(XmlElement channel) {
    try {
      final categories = <String>[];
      for (final element in channel.findAllElements('category', namespace: 'itunes')) {
        final cat = element.getAttribute('text');
        if (cat != null && cat.isNotEmpty) {
          categories.add(cat);
        }
      }
      return categories;
    } catch (e) {
      return [];
    }
  }

  /// 提取 iTunes 关键词
  List<String>? _extractITunesKeywordsList(XmlElement channel) {
    try {
      final keywords = channel.getElement('keywords', namespace: 'itunes')?.innerText ??
          channel.getElement('itunes:keywords')?.innerText;
      if (keywords == null) return null;
      return keywords.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
    } catch (e) {
      return null;
    }
  }

  /// 解析显式标志
  bool _parseExplicit(String? value) {
    if (value == null) return false;
    return value.toLowerCase() == 'yes' || value.toLowerCase() == 'true' || value == '1';
  }

  /// 解析时长（秒）
  int? _parseDuration(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final parts = value.split(':');
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
      return int.parse(value);
    } catch (e) {
      return null;
    }
  }

  /// 解析日期时间
  ///
  /// 支持 RSS 标准格式 (RFC 822) 和 ISO 8601 格式
  /// RSS 格式示例: "Mon, 06 Sep 2021 04:00:00 GMT"
  DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return null;
    }

    // 尝试解析 RSS 标准格式 (RFC 822)
    final rfc822Format = DateFormat('EEE, dd MMM yyyy HH:mm:ss', 'en_US');
    try {
      final timeZoneRegex = RegExp(r'\s+([+-]\d{2}:?\d{2}|[A-Z]{2,4})\s*$');
      final cleanedDate = dateTimeString.replaceFirst(timeZoneRegex, '');
      return rfc822Format.parse(cleanedDate, true);
    } catch (e) {
      // 继续尝试其他格式
    }

    // 尝试 ISO 8601 格式
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      Logger.debug('解析日期时间失败: $dateTimeString');
      return null;
    }
  }

  bool _isHtmlResponse(String contentType, String content) {
    // 优先检查 Content-Type
    if (contentType.contains('text/html') || contentType.contains('application/xhtml')) {
      return true;
    }
    
    // 如果 Content-Type 是 XML 类型，直接认为是 XML 内容
    if (contentType.contains('application/xml') || contentType.contains('text/xml') || contentType.contains('application/rss+xml') || contentType.contains('application/atom+xml')) {
      return false;
    }
    
    final trimmed = content.trimLeft();
    
    // 如果以 XML 声明开头，认为是 XML 内容
    if (trimmed.startsWith('<?xml') || trimmed.startsWith('<?XML')) {
      return false;
    }
    
    // 检查是否是 HTML 内容
    if (trimmed.startsWith('<!DOCTYPE html') || trimmed.startsWith('<html') || trimmed.startsWith('<HTML')) {
      return true;
    }
    if (trimmed.startsWith('<head') || trimmed.startsWith('<HEAD')) {
      return true;
    }
    
    // 如果 Content-Type 不确定，但内容看起来像 HTML 标签结构
    if (trimmed.contains('<!DOCTYPE') && trimmed.contains('<html')) {
      return true;
    }
    
    return false;
  }

  bool _isCaptchaChallenge(dio.Response response, String content) {
    final hasCaptchaHeader = response.headers.value('sg-captcha') != null;
    if (hasCaptchaHeader) {
      return true;
    }
    final challengePattern = RegExp(r'sgcaptcha|sg-captcha|captcha.*challenge|well-known.*challenge', caseSensitive: false);
    if (challengePattern.hasMatch(content)) {
      return true;
    }
    final metaRefreshPattern = RegExp("meta\\s+http-equiv=['\"]refresh['\"]", caseSensitive: false);
    if (metaRefreshPattern.hasMatch(content) && content.length < 500) {
      return true;
    }
    return false;
  }
}
