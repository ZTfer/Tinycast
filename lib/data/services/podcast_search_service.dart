import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:html/parser.dart' as html_parser;
import '../../core/utils/logger.dart';
import '../../core/utils/app_exception.dart';
import '../../core/utils/app_constants.dart';
import '../../core/utils/network_error_handler.dart';
import 'rss_parser_service.dart';

/// 播客搜索服务
///
/// 负责从域名或 URL 搜索和解析播客信息
/// 支持从 XML 文件直接解析，或从 HTML 页面查找 RSS 链接
class PodcastSearchService {
  /// Dio 实例
  final dio.Dio _dio;

  /// RSS 解析服务
  final RssParserService _rssParserService;

  /// 最大重试次数
  final int _maxRetryCount;

  /// 构造函数
  PodcastSearchService({
    dio.Dio? dioInstance,
    RssParserService? rssParserService,
    int maxRetryCount = AppConstants.maxRetryCount,
    int timeout = AppConstants.defaultTimeout,
  }) : _dio = dioInstance ?? dio.Dio(),
       _rssParserService = rssParserService ?? RssParserService(),
       _maxRetryCount = maxRetryCount {
    _dio.options.connectTimeout = Duration(milliseconds: timeout);
    _dio.options.receiveTimeout = Duration(milliseconds: timeout);
    _dio.options.sendTimeout = Duration(milliseconds: timeout);
  }

  /// 搜索播客
  ///
  /// [url] 输入的 URL 或域名
  /// 返回包含 Podcast 和 Episode 列表的 Map
  /// 抛出 AppException 当搜索失败时
  Future<Map<String, dynamic>> searchPodcast(String url) async {
    final normalizedUrl = _normalizeUrl(url);
    Logger.info('开始搜索播客: $normalizedUrl');

    if (_isXmlFile(normalizedUrl)) {
      return await _parseXmlFile(normalizedUrl);
    } else {
      return await _searchFromHtml(normalizedUrl);
    }
  }

  /// 标准化 URL
  ///
  /// 如果 URL 不包含协议，自动添加 https:// 前缀
  String _normalizeUrl(String url) {
    final trimmedUrl = url.trim();
    if (trimmedUrl.isEmpty) {
      throw AppException.validation('URL 不能为空');
    }

    if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
      return trimmedUrl;
    }

    return 'https://$trimmedUrl';
  }

  /// 检查是否为 XML 文件
  ///
  /// 通过检查 URL 是否包含 .xml 扩展名来判断
  bool _isXmlFile(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();
    return path.endsWith('.xml') || path.contains('.xml?');
  }

  /// 从 XML 文件解析播客信息
  ///
  /// [xmlUrl] XML 文件 URL
  /// 返回包含 Podcast 和 Episode 列表的 Map
  Future<Map<String, dynamic>> _parseXmlFile(String xmlUrl) async {
    try {
      return await _rssParserService.parseRssFeed(xmlUrl);
    } on AppException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('html') || msg.contains('xmlexception') || msg.contains('xmltagexception')) {
        Logger.warning('XML URL 返回了非 XML 内容，尝试作为网页处理: $xmlUrl');
        return await _searchFromHtml(xmlUrl);
      }
      Logger.error('解析 XML 文件失败: $xmlUrl', error: e);
      rethrow;
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('xmlexception') || errorMsg.contains('xmltagexception')) {
        Logger.warning('XML 解析失败，内容可能是 HTML，尝试作为网页处理: $xmlUrl');
        return await _searchFromHtml(xmlUrl);
      }
      Logger.error('解析 XML 文件失败: $xmlUrl', error: e);
      throw AppException.validation('无法解析 RSS 文件', originalError: e);
    }
  }

  /// 从 HTML 页面搜索播客
  ///
  /// [url] 页面 URL
  /// 返回包含 Podcast 和 Episode 列表的 Map
  Future<Map<String, dynamic>> _searchFromHtml(String url) async {
    String? rssUrl;

    try {
      rssUrl = await _findRssLinkInHtml(url);
      if (rssUrl == null || rssUrl.isEmpty) {
        throw AppException.validation('未找到 RSS 订阅链接');
      }

      Logger.info('找到 RSS 链接: $rssUrl');
      return await _parseXmlFile(rssUrl);
    } catch (e) {
      Logger.error('从 HTML 页面搜索播客失败: $url', error: e);
      if (e is AppException) {
        rethrow;
      }
      throw AppException.validation('未找到有效的播客 RSS 链接', originalError: e);
    }
  }

  /// 在 HTML 页面中查找 RSS 链接
  ///
  /// [url] 页面 URL
  /// 返回找到的 RSS 链接，如果未找到则返回 null
  Future<String?> _findRssLinkInHtml(String url) async {
    int retryCount = 0;
    AppException? lastException;

    while (retryCount <= _maxRetryCount) {
      try {
        Logger.debug('获取 HTML 页面: $url (尝试 ${retryCount + 1}/$_maxRetryCount)');

        final response = await _dio.get(
          url,
          options: dio.Options(
            headers: {
              'Accept':
                  'text/html, application/xhtml+xml, application/xml, */*',
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

        final htmlContent = response.data as String;
        if (htmlContent.isEmpty) {
          throw AppException.validation('页面内容为空');
        }

        final rssUrl = _extractRssLinkFromHtml(htmlContent, url);
        if (rssUrl != null && rssUrl.isNotEmpty) {
          return rssUrl;
        }

        return null;
      } on dio.DioException catch (e) {
        Logger.warning(
          '获取 HTML 页面失败 (尝试 ${retryCount + 1}/$_maxRetryCount): ${e.message}',
        );
        lastException = NetworkErrorHandler.handleDioException(e);
      } on AppException catch (e) {
        Logger.error('获取 HTML 页面错误: ${e.message}');
        lastException = e;
        break;
      } catch (e, stackTrace) {
        Logger.error('未知错误', error: e, stackTrace: stackTrace);
        lastException = AppException.unknown(
          '获取 HTML 页面失败',
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
        AppException.network('获取 HTML 页面失败，已重试 $_maxRetryCount 次');
  }

  /// 从 HTML 内容中提取 RSS 链接
  ///
  /// [htmlContent] HTML 内容
  /// [baseUrl] 基础 URL，用于解析相对路径
  /// 返回找到的 RSS 链接，如果未找到则返回 null
  String? _extractRssLinkFromHtml(String htmlContent, String baseUrl) {
    try {
      final document = html_parser.parse(htmlContent);

      final rssUrl =
          _findRssLinkInHead(document) ?? _findXmlLinkInHref(document);

      if (rssUrl == null || rssUrl.isEmpty) {
        return null;
      }

      return _resolveUrl(rssUrl, baseUrl);
    } catch (e, stackTrace) {
      Logger.error('解析 HTML 失败', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  /// 在 HTML head 中查找 type="application/rss+xml" 的 link 标签
  ///
  /// [document] HTML 文档对象
  /// 返回找到的 RSS 链接，如果未找到则返回 null
  String? _findRssLinkInHead(dynamic document) {
    final linkElements = document.querySelectorAll(
      'link[type="application/rss+xml"]',
    );

    for (final link in linkElements) {
      final href = link.attributes['href'];
      if (href != null && href.isNotEmpty) {
        Logger.debug('找到 RSS link 标签: $href');
        return href;
      }
    }

    return null;
  }

  /// 在 href 属性中查找包含 .xml 的链接
  ///
  /// [document] HTML 文档对象
  /// 返回找到的 XML 链接，如果未找到则返回 null
  String? _findXmlLinkInHref(dynamic document) {
    final anchors = document.querySelectorAll('a[href]');

    for (final anchor in anchors) {
      final href = anchor.attributes['href'];
      if (href != null && href.toLowerCase().contains('.xml')) {
        Logger.debug('找到 .xml 链接: $href');
        return href;
      }
    }

    return null;
  }

  /// 解析 URL（处理相对路径）
  ///
  /// [url] 要解析的 URL
  /// [baseUrl] 基础 URL
  /// 返回解析后的绝对 URL
  String _resolveUrl(String url, String baseUrl) {
    try {
      final uri = Uri.parse(url);
      if (uri.hasScheme) {
        return url;
      }

      final baseUri = Uri.parse(baseUrl);
      final resolvedUri = baseUri.resolveUri(uri);
      return resolvedUri.toString();
    } catch (e) {
      Logger.warning('解析 URL 失败: $url, 基础 URL: $baseUrl');
      return url;
    }
  }
}
