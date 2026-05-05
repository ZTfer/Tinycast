import 'package:html/parser.dart' as html_parser;
import 'logger.dart';

class HtmlRssExtractor {
  HtmlRssExtractor._();

  static String? extractRssLink(String htmlContent, String baseUrl) {
    try {
      final document = html_parser.parse(htmlContent);

      final rssUrl = _findRssLinkInHead(document) ?? _findXmlLinkInHref(document);

      if (rssUrl == null || rssUrl.isEmpty) {
        return null;
      }

      return _resolveUrl(rssUrl, baseUrl);
    } catch (e, stackTrace) {
      Logger.error('解析 HTML 失败', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  static String? _findRssLinkInHead(dynamic document) {
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

  static String? _findXmlLinkInHref(dynamic document) {
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

  static String _resolveUrl(String url, String baseUrl) {
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
