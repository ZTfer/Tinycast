import 'package:intl/intl.dart';

/// 时间格式化工具类
///
/// 提供通用的时间展示规则，用于将 DateTime 转换为友好的相对时间字符串
class TimeFormatter {
  TimeFormatter._();

  /// 将 pubDate 格式化为相对时间字符串
  ///
  /// 规则：
  /// 1. 小于60秒，展示"xx秒前"
  /// 2. 小于60分，展示"xx分前"
  /// 3. 小于24小时，展示"xx小时前"
  /// 4. 小于7天，展示"xx天前"
  /// 5. 大于等于7天，展示具体年月日，格式为"年/月/日"
  ///
  /// [pubDate] 发布时间
  /// [now] 当前时间（可选，用于测试）
  static String formatTimeAgo(DateTime pubDate, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = currentTime.difference(pubDate);

    // 1. 小于60秒
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}秒前';
    }

    // 2. 小于60分
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    }

    // 3. 小于24小时
    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }

    // 4. 小于7天
    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }

    // 5. 大于等于7天，展示具体年月日
    return DateFormat('yyyy/MM/dd').format(pubDate);
  }
}
