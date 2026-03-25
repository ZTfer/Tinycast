import 'package:flutter/widgets.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/time_formatter.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_control_bar/queue_control_bar.dart';

/// Queue 节目信息组件
///
/// 用于显示待播放队列列表项中的节目文本信息。
/// 包含发布时间、节目标题、节目描述和操作栏。
class QueueEpisodeInfo extends StatelessWidget {
  /// Episode 对象
  final Episode episode;

  /// 节目时长字符串
  final String duration;

  /// 播放按钮点击回调
  final VoidCallback? onPlayPressed;

  const QueueEpisodeInfo({
    super.key,
    required this.episode,
    required this.duration,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = TimeFormatter.formatTimeAgo(episode.pubDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 发布时间
        Text(
          timeAgo,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF999999),
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        // 节目标题
        Text(
          episode.title,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // 节目描述
        Text(
          HtmlTagRemoveUtils.getListItemSummary(
            episode.description,
            maxLength: 80,
          ),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF333333),
            fontWeight: FontWeight.normal,
            decoration: TextDecoration.none,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // 操作栏
        QueueControlBar(
          episodeId: episode.id,
          duration: duration,
          onPlayPressed: onPlayPressed,
        ),
      ],
    );
  }
}
