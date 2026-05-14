import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/utils/html_tag_remove_utils.dart';
import 'package:tinycast/core/utils/time_formatter.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_control_bar.dart';

/// Queue 节目信息组件
///
/// 用于显示待播放队列列表项中的节目文本信息。
/// 包含发布时间、节目标题、节目描述和操作栏。
class EpisodeInfo extends ConsumerStatefulWidget {
  /// Episode 对象
  final Episode episode;

  /// 节目时长字符串
  final String duration;

  /// 播放按钮点击回调
  final VoidCallback? onPlayPressed;

  /// 点击标题回调（用于打开详情页）
  final VoidCallback? onTap;

  /// 是否显示'从待播清单移除'菜单项，默认值 false
  final bool showRemoveFromQueue;

  /// 从队列移除回调
  final VoidCallback? onRemoveFromQueue;

  const EpisodeInfo({
    super.key,
    required this.episode,
    required this.duration,
    this.onPlayPressed,
    this.onTap,
    this.showRemoveFromQueue = false,
    this.onRemoveFromQueue,
  });

  @override
  ConsumerState<EpisodeInfo> createState() => _EpisodeInfoState();
}

class _EpisodeInfoState extends ConsumerState<EpisodeInfo> {
  bool _isHovering = false;

  void _handleTap() {
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = TimeFormatter.formatTimeAgo(widget.episode.pubDate);
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );

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
        // 节目标题（带 hover 下划线效果，点击打开详情窗口）
        MouseRegion(
          onEnter: (_) => setState(() => _isHovering = true),
          onExit: (_) => setState(() => _isHovering = false),
          child: GestureDetector(
            onTap: _handleTap,
            child: Text(
              widget.episode.title,
              style: theme.episodeItemTitle.copyWith(
                decoration: _isHovering
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: theme.labelPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 节目描述
        Text(
          HtmlTagRemoveUtils.getListItemSummary(
            widget.episode.description,
            maxLength: 80,
          ),
          style: theme.episodeItemDescription,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        // 操作栏
        EpisodeControlBar(
          episodeId: widget.episode.id,
          episode: widget.episode,
          duration: widget.duration,
          onPlayPressed: widget.onPlayPressed,
          link: widget.episode.link,
          isDownloaded: widget.episode.isDownloaded,
          showRemoveFromQueue: widget.showRemoveFromQueue,
          onRemoveFromQueue: widget.onRemoveFromQueue,
        ),
      ],
    );
  }
}
