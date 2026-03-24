import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/time_formatter.dart';
import 'package:tinycast/data/services/image_cache_service.dart';
import 'package:tinycast/domain/entities/episode.dart';

/// Queue 节目信息组件
///
/// 用于显示待播放队列列表项中的节目信息。
/// 包含封面图、发布时间、节目标题和节目描述。
class QueueEpisodeInfo extends StatelessWidget {
  /// Episode 对象
  final Episode episode;

  const QueueEpisodeInfo({
    super.key,
    required this.episode,
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
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFFD9D9D9),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
