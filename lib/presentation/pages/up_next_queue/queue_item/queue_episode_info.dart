import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/time_formatter.dart';
import 'package:tinycast/data/services/image_cache_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_control_bar/queue_control_bar.dart';

/// Queue 节目信息组件
///
/// 用于显示待播放队列列表项中的节目信息。
/// 包含封面图、发布时间、节目标题、节目描述和操作栏。
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildArtwork(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 发布时间
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 9.75,
                  color: Color(0xD9000000),
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              // 节目标题
              Text(
                episode.title,
                style: const TextStyle(
                  fontSize: 12,
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
                  fontSize: 9.75,
                  color: Color(0xD9000000),
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
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: FutureBuilder<File?>(
        future: episode.artworkUrl != null
            ? ImageCacheService.instance.getCachedImage(episode.artworkUrl!)
            : Future.value(null),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderArtwork(),
            );
          }

          if (episode.artworkUrl != null) {
            return Image.network(
              episode.artworkUrl!,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholderArtwork(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildPlaceholderArtwork();
              },
            );
          }

          return _buildPlaceholderArtwork();
        },
      ),
    );
  }

  Widget _buildPlaceholderArtwork() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SvgPicture.asset(
        'assets/images/image_placeholder.svg',
        width: 34,
        height: 34,
        fit: BoxFit.cover,
      ),
    );
  }
}
