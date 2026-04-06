import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_info.dart';

/// Queue 列表项组件
///
/// 用于显示待播放队列列表中的单个节目项。
/// 使用 Row 布局：左边是封面图，右边是节目信息（EpisodeInfo）。
class EpisodeItem extends StatelessWidget {
  /// Episode 对象
  final Episode episode;

  /// 是否显示分隔线，默认 true
  final bool showDivider;

  /// 是否显示封面图，默认 true
  final bool showCover;

  /// 播放按钮点击回调
  final VoidCallback? onPlayPressed;

  /// 点击节目标题回调（用于打开详情页）
  final VoidCallback? onEpisodeTap;

  const EpisodeItem({
    super.key,
    required this.episode,
    this.showDivider = true,
    this.showCover = true,
    this.onPlayPressed,
    this.onEpisodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 布局：左边封面图（可选），右边节目信息
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左边：封面图（根据 showCover 参数决定是否显示）
                  if (showCover) ...[_buildArtwork(), const SizedBox(width: 8)],
                  // 右边：节目信息（包含标题、描述、操作栏）
                  Expanded(
                    child: QueueEpisodeInfo(
                      episode: episode,
                      duration: _formatDuration(episode.duration),
                      onPlayPressed: onPlayPressed,
                      onTap: onEpisodeTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (showDivider) _buildDivider(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArtwork() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: episode.artworkUrl != null && episode.artworkUrl!.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: episode.artworkUrl!,
              width: 34,
              height: 34,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholderArtwork(),
              errorWidget: (context, url, error) => _buildPlaceholderArtwork(),
              memCacheWidth: 68,
              memCacheHeight: 68,
            )
          : _buildPlaceholderArtwork(),
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
