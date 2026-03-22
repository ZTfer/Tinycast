import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:tinycast/data/services/image_cache_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_control_bar/queue_control_bar.dart';

/// Queue 列表项组件
///
/// 用于显示待播放队列列表中的单个节目项。
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。
class QueueItem extends StatelessWidget {
  /// Episode 对象
  final Episode episode;

  /// 是否显示分隔线，默认 true
  final bool showDivider;

  /// 播放按钮点击回调
  final VoidCallback? onPlayPressed;

  const QueueItem({
    super.key,
    required this.episode,
    this.showDivider = true,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildArtwork(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextSection(),
                    const SizedBox(height: 6),
                    _buildActionSection(),
                    const SizedBox(height: 12),
                    if (showDivider) _buildDivider(),
                  ],
                ),
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

  /// 构建文本信息区域
  ///
  /// 包含更新时间、节目标题和节目描述。
  Widget _buildTextSection() {
    final timeAgo = _formatTimeAgo(episode.pubDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Text(
          episode.title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          episode.description,
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
    );
  }

  String _formatTimeAgo(DateTime pubDate) {
    final now = DateTime.now();
    final difference = now.difference(pubDate);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'h' : 'h'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'min' : 'min'} ago';
    } else {
      return 'Just now';
    }
  }

  /// 构建操作区域
  ///
  /// 使用 QueueControlBar 组件，包含播放按钮和更多选项。
  Widget _buildActionSection() {
    final durationStr = _formatDuration(episode.duration);
    return QueueControlBar(duration: durationStr, onPlayPressed: onPlayPressed);
  }

  String _formatDuration(int? durationInSeconds) {
    if (durationInSeconds == null || durationInSeconds <= 0) {
      return '';
    }

    final hours = durationInSeconds ~/ 3600;
    final minutes = (durationInSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE0E0E0));
  }
}
