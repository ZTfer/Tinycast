import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

/// HTML Tag Remove Utils
///
/// 提供 HTML 标签移除相关的处理功能，专为列表页展示优化
class HtmlTagRemoveUtils {
  HtmlTagRemoveUtils._();

  /// 专为列表页设计的简介处理函数
  ///
  /// [html] 原始 HTML 简介
  /// [maxLength] 最大字符数限制 (超过此长度会截断并加 ...)
  /// 返回：纯净的单行文本，适合列表展示
  static String getListItemSummary(String html, {int maxLength = 60}) {
    if (html.isEmpty) return '';

    try {
      // 1. 解析 HTML
      final document = html_parser.parse(html);

      // 2. 移除干扰节点 (script, style, iframe 等)
      _removeNodes(document, ['script', 'style', 'iframe', 'svg', 'noscript']);

      // 3. 提取纯文本 (自动处理实体解码，如 &nbsp; -> 空格)
      // .text 属性会自动把所有块级元素的内容连起来，中间带空格
      String text = document.body?.text ?? '';

      // 4. 清洗空白字符
      // 将换行符、制表符统一替换为单个空格
      text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

      // 5. 智能截断 (处理 Emoji 和中文边界)
      if (text.length > maxLength) {
        // 尝试在空格处截断，避免切断单词
        int cutIndex = text.lastIndexOf(' ', maxLength);

        // 如果前面没有空格，或者空格太靠前，就直接在 maxLength 处截断
        if (cutIndex == -1 || cutIndex < maxLength * 0.8) {
          cutIndex = maxLength;
        }

        // 二次检查：避免截断在 Emoji 或特殊字符中间
        // Dart 中 String 是 UTF-16 序列，Emoji 通常占 2 个 code unit
        while (cutIndex > 0 &&
            text.codeUnitAt(cutIndex - 1) >= 0xD800 &&
            text.codeUnitAt(cutIndex - 1) <= 0xDBFF) {
          cutIndex--;
        }

        text = '${text.substring(0, cutIndex).trim()}...';
      }

      return text;
    } catch (e) {
      // 容错：如果解析失败，降级使用简单的正则方案，保证不崩溃
      return _fallbackStripHtml(html, maxLength);
    }
  }

  /// 过滤 HTML 标签，返回纯文本（兼容旧接口）
  ///
  /// [html] 包含 HTML 标签的字符串
  /// 返回去除所有 HTML 标签后的纯文本
  static String stripHtml(String html) {
    return getListItemSummary(html, maxLength: 10000);
  }

  // 辅助：移除节点
  static void _removeNodes(dom.Node node, List<String> tagNames) {
    if (node is dom.Element) {
      final children = List<dom.Node>.from(node.nodes);
      for (final child in children) {
        if (child is dom.Element &&
            tagNames.contains(child.localName?.toLowerCase())) {
          child.remove();
        } else {
          _removeNodes(child, tagNames);
        }
      }
    }
  }

  // 降级方案 (仅在解析出错时使用)
  static String _fallbackStripHtml(String html, int maxLength) {
    var text = html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (text.length > maxLength) {
      text = '${text.substring(0, maxLength)}...';
    }
    return text;
  }
}
