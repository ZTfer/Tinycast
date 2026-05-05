import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/queue_play_pause_button.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/horizontal_more_button.dart';
import 'package:tinycast/presentation/widgets/organisms/dropdown/episode_dropdown.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/favorite_provider.dart';
import 'package:tinycast/presentation/providers/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/providers/download_provider.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/download_status_icon.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/domain/entities/episode.dart';

class EpisodeControlBar extends ConsumerStatefulWidget {
  final int episodeId;
  final Episode episode;
  final String duration;
  final VoidCallback? onPlayPressed;
  final String? link;
  final bool isDownloaded;
  final bool showRemoveFromQueue;
  final VoidCallback? onRemoveFromQueue;

  const EpisodeControlBar({
    super.key,
    required this.episodeId,
    required this.episode,
    required this.duration,
    this.onPlayPressed,
    this.link,
    required this.isDownloaded,
    this.showRemoveFromQueue = false,
    this.onRemoveFromQueue,
  });

  @override
  ConsumerState<EpisodeControlBar> createState() => _EpisodeControlBarState();
}

/// [EpisodeControlBar] 的状态类
///
/// 管理下拉菜单的显示和隐藏状态。
class _EpisodeControlBarState extends ConsumerState<EpisodeControlBar> {
  /// 更多按钮的 GlobalKey，用于获取按钮的位置和大小
  final GlobalKey _moreButtonKey = GlobalKey();

  /// 下拉菜单的 OverlayEntry，用于控制菜单的显示和移除
  OverlayEntry? _dropdownOverlay;

  /// 全局当前显示的下拉菜单，用于确保同一时间只显示一个菜单
  static OverlayEntry? _currentDropdownOverlay;

  /// 动态检查当前 episode 是否已下载
  bool _isDownloaded() {
    final downloadedEpisodes = ref.read(downloadedEpisodesProvider);
    return downloadedEpisodes.any((e) => e.id == widget.episodeId);
  }

  /// 显示下拉菜单
  void _showDropdown() {
    /// 如果已有下拉菜单显示，先关闭它（包括当前按钮的菜单）
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    /// 获取更多按钮的 RenderBox
    final RenderBox renderBox =
        _moreButtonKey.currentContext?.findRenderObject() as RenderBox;

    /// 获取按钮在全局坐标系中的偏移量
    final Offset offset = renderBox.localToGlobal(Offset.zero);

    /// 获取按钮的尺寸
    final Size size = renderBox.size;

    /// 获取屏幕尺寸
    final Size screenSize = MediaQuery.of(context).size;

    /// 计算菜单的预估宽度（用于边界检测）
    const double estimatedMenuWidth = 150.0;
    const double estimatedMenuHeight = 230.0;

    /// 计算菜单位置
    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    /// 如果菜单超出右边界，向左调整
    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    /// 如果菜单超出下边界，向上显示
    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    /// 创建下拉菜单的 OverlayEntry
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          /// 覆盖整个屏幕的透明层，用于捕获点击空白处
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),

          /// 下拉菜单，定位在按钮下方
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              /// 阻止事件冒泡，点击菜单内部不关闭
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: EpisodeDropdown(
                onItemSelected: _hideDropdown,
                isFavorite: ref
                    .read(favoriteProvider)
                    .isEpisodeFavorite(widget.episodeId),
                isDownloaded: _isDownloaded(),
                showRemoveFromQueue: widget.showRemoveFromQueue,
                onRemoveFromQueue: widget.onRemoveFromQueue,
                onToggleFavorite: _handleToggleFavorite,
                onToggleDownload: _isDownloaded()
                    ? _handleRemoveDownload
                    : _handleDownload,
                link: widget.link,
                onShowCopySuccessToast: _showCopySuccessToast,
                onInsertToFront: _handleInsertToFront,
                onAddToQueue: _handleAddToQueue,
                onMarkAsPlayed: _handleMarkAsPlayed,
              ),
            ),
          ),
        ],
      ),
    );

    /// 将 OverlayEntry 插入到 Overlay 中
    Overlay.of(context).insert(_dropdownOverlay!);

    /// 更新全局当前显示的下拉菜单
    _currentDropdownOverlay = _dropdownOverlay;
  }

  /// 隐藏下拉菜单
  ///
  /// 移除 OverlayEntry 并清空引用。
  void _hideDropdown() {
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  /// 显示拷贝成功 Toast
  void _showCopySuccessToast() {
    ToastUtils.showCopySuccessToast(context);
  }

  Future<void> _handleToggleFavorite() async {
    Logger.info(
      '❤️ [EPISODE-CONTROL-BAR] 用户点击收藏切换, episodeId: ${widget.episodeId}',
    );
    if (!mounted) return;
    try {
      final isFav = await ref
          .read(favoriteProvider.notifier)
          .checkIsFavorite(widget.episode);
      final successMessage = isFav ? '已取消收藏' : '已收藏';
      await ref
          .read(favoriteProvider.notifier)
          .toggleFavorite(widget.episode);
      ref.read(favoriteEpisodesNotifierProvider.notifier).refresh();
      _hideDropdown();

      if (!isFav) {
        final settings = ref.read(settingsProvider);
        if (settings.value?.downloadOnFavorite == true) {
          final downloadedEpisodes = ref.read(downloadedEpisodesProvider);
          final alreadyDownloaded = downloadedEpisodes.any(
            (e) => e.id == widget.episodeId,
          );

          if (alreadyDownloaded) {
            Logger.info(
              '⬇️ [EPISODE-CONTROL-BAR] 收藏时下载已启用，但 episodeId: ${widget.episodeId} 已下载，仅执行收藏',
            );
          } else {
            Logger.info(
              '⬇️ [EPISODE-CONTROL-BAR] 收藏时下载已启用，开始下载 episodeId: ${widget.episodeId}',
            );
            AudioDownloadService.instance.downloadEpisodeById(
              widget.episodeId,
            );
          }
        }
      }

      if (mounted) {
        ToastUtils.showSuccessToast(context, message: successMessage);
      }
    } catch (e) {
      Logger.error('❤️ [EPISODE-CONTROL-BAR] 收藏切换失败', error: e);
      _hideDropdown();
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '操作失败');
      }
    }
  }

  /// 处理插播操作（添加到队列最前面）
  Future<void> _handleInsertToFront() async {
    Logger.info(
      '📋 [EPISODE-CONTROL-BAR] 用户点击插播, episodeId: ${widget.episodeId}',
    );
    if (!mounted) return;
    try {
      await ref
          .read(queueNotifierProvider.notifier)
          .insertToQueueFront(widget.episode);
      Logger.info('📋 [EPISODE-CONTROL-BAR] 插播成功');
      if (mounted) {
        ToastUtils.showSuccessToast(context, message: '已插播到队列最前');
      }
    } catch (e) {
      Logger.error('📋 [EPISODE-CONTROL-BAR] 插播失败', error: e);
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '插播失败');
      }
    }
  }

  /// 处理添加到队列操作（添加到队列最后面）
  Future<void> _handleAddToQueue() async {
    Logger.info(
      '📋 [EPISODE-CONTROL-BAR] 用户点击添加到队列, episodeId: ${widget.episodeId}',
    );
    if (!mounted) return;
    try {
      await ref
          .read(queueNotifierProvider.notifier)
          .addToQueue(widget.episode);
      Logger.info('📋 [EPISODE-CONTROL-BAR] 添加到队列成功');
      if (mounted) {
        ToastUtils.showSuccessToast(context, message: '已添加到队列末尾');
      }
    } catch (e) {
      Logger.error('📋 [EPISODE-CONTROL-BAR] 添加到队列失败', error: e);
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '添加失败');
      }
    }
  }

  Future<void> _handleMarkAsPlayed() async {
    Logger.info(
      '✅ [EPISODE-CONTROL-BAR] 用户点击标记为已播放, episodeId: ${widget.episodeId}',
    );
    if (!mounted) return;
    try {
      final podcastRepository = ref.read(podcastRepositoryProvider);
      await podcastRepository.updateIsPlayed(widget.episodeId, true);
      Logger.info('✅ [EPISODE-CONTROL-BAR] 成功更新 episode isPlayed');

      final playHistoryRepository = ref.read(playHistoryRepositoryProvider);
      await playHistoryRepository.updateOrCreatePlayHistoryAsCompleted(
        widget.episodeId,
        episodeGuid: widget.episode.guid,
        episodeITunesId: widget.episode.itunesId,
        podcastGuid: null,
        podcastITunesId: widget.episode.podcastITunesId,
      );
      Logger.info('✅ [EPISODE-CONTROL-BAR] 成功更新 PlayHistory 状态');

      await ref
          .read(queueNotifierProvider.notifier)
          .removeFromQueueByEpisodeId(widget.episode);
      Logger.info('✅ [EPISODE-CONTROL-BAR] 已从 queue 移除');

      ref.invalidate(completedHistoriesProvider);
      Logger.info('✅ [EPISODE-CONTROL-BAR] 已刷新 History Provider');

      ref.invalidate(unplayedEpisodesNotifierProvider);
      Logger.info('✅ [EPISODE-CONTROL-BAR] 已刷新 Unplayed Episodes Provider');

      if (mounted) {
        ToastUtils.showSuccessToast(context, message: '已标记为已播放');
      }
    } catch (e) {
      Logger.error('✅ [EPISODE-CONTROL-BAR] 标记已播放失败', error: e);
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '标记失败');
      }
    }
  }

  Future<void> _handleDownload() async {
    if (!mounted) return;
    try {
      AudioDownloadService.instance.downloadEpisodeById(widget.episodeId);
    } catch (e) {
      Logger.error('下载启动失败', error: e);
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '下载启动失败');
      }
    }
  }

  Future<void> _handleRemoveDownload() async {
    if (!mounted) return;
    try {
      await AudioDownloadService.instance.deleteDownloadedEpisode(
        widget.episodeId.toString(),
      );

      ref.invalidate(downloadedEpisodesNotifierProvider);
      ref.read(queueNotifierProvider.notifier).refresh();
      ref.read(unplayedEpisodesNotifierProvider.notifier).refresh();

      if (mounted) {
        ToastUtils.showSuccessToast(context, message: '已移除下载');
      }
    } catch (e) {
      Logger.error('移除下载失败', error: e);
      if (mounted) {
        ToastUtils.showErrorToast(context, message: '移除下载失败');
      }
    }
  }

  /// 组件销毁时的清理工作
  ///
  /// 移除下拉菜单的 OverlayEntry，防止内存泄漏。
  @override
  void dispose() {
    /// 如果销毁的是当前全局菜单，清空全局引用
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前播放状态
    final playerState = ref.watch(playbackProvider);
    final currentEpisodeId = playerState.currentEpisode?.id;
    final isCurrentEpisode = currentEpisodeId == widget.episodeId;

    // 获取下载状态和进度
    final downloadState = ref.watch(downloadNotifierProvider);
    final episodeIdStr = widget.episodeId.toString();
    final downloadStatus = downloadState.episodeStatuses[episodeIdStr];
    final isDownloading =
        downloadStatus == DownloadStatus.downloading ||
        downloadStatus == DownloadStatus.queued;
    final downloadProgress = downloadState.episodeProgress[episodeIdStr];

    // 动态从已下载列表获取，不依赖 widget.isDownloaded
    final downloadedEpisodes = ref.watch(downloadedEpisodesProvider);
    final isActuallyDownloaded = downloadedEpisodes.any(
      (e) => e.id == widget.episodeId,
    );

    // 监听下载完成事件，刷新所有相关 provider 以同步 isDownloaded 状态
    ref.listen<DownloadState>(downloadNotifierProvider, (prev, next) {
      if (prev == null) return;
      final prevStatus = prev.episodeStatuses[episodeIdStr];
      final nextStatus = next.episodeStatuses[episodeIdStr];

      final wasInProgress =
          prevStatus == DownloadStatus.downloading ||
          prevStatus == DownloadStatus.queued ||
          prevStatus == null;

      final nowCompleted = nextStatus == DownloadStatus.completed;

      if (wasInProgress && nowCompleted && !isActuallyDownloaded) {
        ref.invalidate(downloadedEpisodesNotifierProvider);
        ref.read(queueNotifierProvider.notifier).refresh();
        ref.read(unplayedEpisodesNotifierProvider.notifier).refresh();
      }
    });

    // 处理播放/暂停切换
    void handlePlayPause() {
      Logger.info('▶️ [PLAY-PAUSE] handlePlayPause called');
      Logger.info('▶️ [PLAY-PAUSE] episodeId: ${widget.episodeId}');
      Logger.info('▶️ [PLAY-PAUSE] isCurrentEpisode: $isCurrentEpisode');
      Logger.info('▶️ [PLAY-PAUSE] playerState.currentEpisode?.id: ${playerState.currentEpisode?.id}');
      Logger.info('▶️ [PLAY-PAUSE] isPlaying: ${playerState.isPlaying}');
      
      // 只有当 episode 匹配且音频已加载时才切换播放/暂停
      final isAudioLoaded = playerState.currentEpisode != null && playerState.isPlaying;
      Logger.info('▶️ [PLAY-PAUSE] isAudioLoaded: $isAudioLoaded');
      
      if (isCurrentEpisode && isAudioLoaded) {
        // 当前音频正在播放，切换暂停
        Logger.info('▶️ [PLAY-PAUSE] Pausing current episode');
        ref.read(playbackProvider.notifier).togglePlayPause();
      } else if (isCurrentEpisode) {
        // episode 匹配但音频未播放，尝试继续播放
        Logger.info('▶️ [PLAY-PAUSE] Resuming current episode');
        ref.read(playbackProvider.notifier).play();
      } else {
        // 播放新音频
        Logger.info('▶️ [PLAY-PAUSE] Playing new episode');
        widget.onPlayPressed?.call();
      }
    }

    // 是否展示下载图标（已下载 或 正在下载）
    final showDownloadIcon = isActuallyDownloaded || isDownloading;

    return Row(
      /// 主轴尺寸最小，根据内容自适应
      mainAxisSize: MainAxisSize.min,

      /// 子组件列表
      children: [
        /// 播放按钮（带时长）
        QueuePlayPauseButton(
          /// 节目 ID
          episodeId: widget.episodeId,

          /// 节目时长标签
          label: widget.duration,

          /// 点击回调
          onPressed: handlePlayPause,
        ),

        /// 占位符，将播放按钮和更多按钮分开
        const Spacer(),

        /// 下载状态图标（已下载时展示箭头，下载中时展示进度圆环）
        if (showDownloadIcon)
          DownloadStatusIcon(
            progress: isDownloading ? downloadProgress : null,
            isIndeterminate: isDownloading && downloadProgress == null,
          ),
        if (showDownloadIcon) const SizedBox(width: 4.0),

        /// 更多选项按钮
        HorizontalMoreButton(
          /// 绑定 GlobalKey，用于获取位置
          key: _moreButtonKey,

          /// 更多图标
          icon: const Icon(LucideIcons.ellipsisVertical),

          /// 点击时显示下拉菜单
          onPressed: _showDropdown,

          /// 图标大小 12
          iconSize: 12,

          /// 内容颜色（85% 不透明度的黑色）
          contentColor: const Color(0xD9000000),
        ),
      ],
    );
  }
}
