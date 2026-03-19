import 'package:xml/xml.dart';
import 'app_exception.dart';
import 'logger.dart';

/// 解析错误处理工具类
class ParseErrorHandler {
  ParseErrorHandler._();

  /// 处理 XML 解析异常
  static AppException handleXmlException(XmlException e) {
    Logger.error('XML 解析错误', error: e);

    return AppException.validation('XML 解析失败: ${e.message}', originalError: e);
  }

  /// 处理 JSON 解析异常
  static AppException handleJsonException(dynamic e) {
    Logger.error('JSON 解析错误', error: e);

    return AppException.validation(
      'JSON 解析失败: ${e.toString()}',
      originalError: e,
    );
  }

  /// 处理格式异常
  static AppException handleFormatException(FormatException e) {
    Logger.error('格式错误', error: e);

    return AppException.validation('数据格式错误: ${e.message}', originalError: e);
  }

  /// 验证 RSS 订阅源格式
  static void validateRssFeed(String rssUrl) {
    if (rssUrl.isEmpty) {
      throw AppException.validation('RSS 订阅源 URL 不能为空');
    }

    if (!rssUrl.startsWith('http://') && !rssUrl.startsWith('https://')) {
      throw AppException.validation('RSS 订阅源 URL 必须以 http:// 或 https:// 开头');
    }

    final uri = Uri.tryParse(rssUrl);
    if (uri == null || !uri.hasAbsolutePath) {
      throw AppException.validation('RSS 订阅源 URL 格式无效');
    }
  }

  /// 验证播客数据
  static void validatePodcastData(Map<String, dynamic> data) {
    if (data['title'] == null || data['title'].toString().isEmpty) {
      throw AppException.validation('播客标题不能为空');
    }

    if (data['rssUrl'] == null || data['rssUrl'].toString().isEmpty) {
      throw AppException.validation('RSS 订阅源 URL 不能为空');
    }

    if (data['artworkUrl'] == null || data['artworkUrl'].toString().isEmpty) {
      throw AppException.validation('播客封面 URL 不能为空');
    }
  }

  /// 验证节目数据
  static void validateEpisodeData(Map<String, dynamic> data) {
    if (data['title'] == null || data['title'].toString().isEmpty) {
      throw AppException.validation('节目标题不能为空');
    }

    if (data['audioUrl'] == null || data['audioUrl'].toString().isEmpty) {
      throw AppException.validation('节目音频 URL 不能为空');
    }

    if (data['podcastId'] == null) {
      throw AppException.validation('节目必须关联到播客');
    }
  }

  /// 安全解析 XML 文档
  static XmlDocument parseXmlSafely(String xmlContent) {
    try {
      if (xmlContent.isEmpty) {
        throw AppException.validation('XML 内容为空');
      }

      return XmlDocument.parse(xmlContent);
    } on XmlException catch (e) {
      throw handleXmlException(e);
    } catch (e) {
      Logger.error('XML 解析失败', error: e);
      throw AppException.validation(
        'XML 解析失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 安全解析 JSON 字符串
  static Map<String, dynamic> parseJsonSafely(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        throw AppException.validation('JSON 内容为空');
      }

      // 这里需要导入 dart:convert
      // final json = jsonDecode(jsonString) as Map<String, dynamic>;
      // return json;
      throw UnimplementedError('JSON 解析功能需要导入 dart:convert');
    } on FormatException catch (e) {
      throw handleFormatException(e);
    } catch (e) {
      Logger.error('JSON 解析失败', error: e);
      throw AppException.validation(
        'JSON 解析失败: ${e.toString()}',
        originalError: e,
      );
    }
  }

  /// 提取必需的 XML 元素文本
  static String? getRequiredElementText(XmlElement parent, String tagName) {
    final element = parent.findElements(tagName).firstOrNull;
    final text = element?.innerText.trim();

    if (text == null || text.isEmpty) {
      throw AppException.validation('缺少必需的元素: $tagName');
    }

    return text;
  }

  /// 提取可选的 XML 元素文本
  static String? getOptionalElementText(XmlElement parent, String tagName) {
    final element = parent.findElements(tagName).firstOrNull;
    return element?.innerText.trim();
  }

  /// 验证必需的 XML 元素存在
  static void validateRequiredElement(XmlElement parent, String tagName) {
    if (parent.findElements(tagName).firstOrNull == null) {
      throw AppException.validation('缺少必需的元素: $tagName');
    }
  }
}
