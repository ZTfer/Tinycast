import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_control_bar/queue_control_bar.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_item/queue_episode_info.dart';

/// Queue 列表项组件
///
/// 用于显示待播放队列列表中的单个节目项。
/// 每个列表项包含节目信息（QueueEpisodeInfo）和操作区域（QueueControlBar）。
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 节目信息区域
              QueueEpisodeInfo(episode: episode),
              const SizedBox(height: 6),
              // 操作区域
              _buildActionSection(),
              const SizedBox(height: 12),
              if (showDivider) _buildDivider(),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建操作区域
  ///
  /// 使用 QueueControlBar 组件，包含播放按钮和更多选项。
  Widget _buildActionSection() {
    final durationStr = _formatDuration(episode.duration);
    return QueueControlBar(
      episodeId: episode.id,
      duration: durationStr,
      onPlayPressed: onPlayPressed,
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
