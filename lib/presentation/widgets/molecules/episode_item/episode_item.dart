import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/artwork_image/artwork_image.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_info.dart';

/// Episode 项组件
///
/// 用于显示单个节目项。
/// 使用 Row 布局：左边是封面图，右边是节目信息（EpisodeInfo）。
class EpisodeItem extends ConsumerWidget {
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

  /// 是否显示'从待播清单移除'菜单项，默认值 false
  final bool showRemoveFromQueue;

  /// 从队列移除回调
  final VoidCallback? onRemoveFromQueue;

  /// 是否使用 Podcast 封面图，默认 true（使用 Podcast 封面图）
  final bool usePodcastArtwork;

  const EpisodeItem({
    super.key,
    required this.episode,
    this.showDivider = true,
    this.showCover = true,
    this.onPlayPressed,
    this.onEpisodeTap,
    this.showRemoveFromQueue = false,
    this.onRemoveFromQueue,
    this.usePodcastArtwork = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  if (showCover) ...[
                    _buildArtwork(context, ref),
                    const SizedBox(width: 8),
                  ],
                  // 右边：节目信息（包含标题、描述、操作栏）
                  Expanded(
                    child: EpisodeInfo(
                      episode: episode,
                      duration: _formatDuration(episode.duration),
                      onPlayPressed: onPlayPressed,
                      onTap: onEpisodeTap,
                      showRemoveFromQueue: showRemoveFromQueue,
                      onRemoveFromQueue: onRemoveFromQueue,
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

  Widget _buildArtwork(BuildContext context, WidgetRef ref) {
    if (usePodcastArtwork) {
      // 使用 Podcast 封面图
      final podcastState = ref.watch(podcastByIdProvider(episode.podcastId));
      return podcastState.when(
        data: (podcast) {
          if (podcast == null) {
            return _buildEpisodeArtwork();
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 34,
              height: 34,
              child: ArtworkImage.fromPodcast(
                podcast,
                width: 34,
                height: 34,
                fit: BoxFit.cover,
                placeholder: _buildPlaceholderArtwork(),
                errorWidget: _buildPlaceholderArtwork(),
              ),
            ),
          );
        },
        loading: () => _buildPlaceholderArtwork(),
        error: (_, _) => _buildPlaceholderArtwork(),
      );
    } else {
      // 使用 Episode 封面图
      return _buildEpisodeArtwork();
    }
  }

  Widget _buildEpisodeArtwork() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 34,
        height: 34,
        child: ArtworkImage.fromEpisode(
          episode,
          width: 34,
          height: 34,
          fit: BoxFit.cover,
          placeholder: _buildPlaceholderArtwork(),
          errorWidget: _buildPlaceholderArtwork(),
        ),
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
