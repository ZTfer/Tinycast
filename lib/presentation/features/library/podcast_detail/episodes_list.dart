import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/unfollow_podcast_provider.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/features/library/podcast_detail/show_info.dart';

class EpisodesList extends ConsumerWidget {
  final Podcast? podcast;
  final List<Episode> episodes;

  const EpisodesList({super.key, this.podcast, required this.episodes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: episodes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _ShowInfoWithDownloadStatus(podcast: podcast);
        }

        final episodeIndex = index - 1;
        final episode = episodes[episodeIndex];
        final isLast = episodeIndex == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          showCover: false,
          onPlayPressed: () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
          onEpisodeTap: () {
            if (podcast != null) {
              ref
                  .read(navigationProvider.notifier)
                  .showEpisodeDetail(episode, podcast!);
            }
          },
        );
      },
    );
  }
}

class _ShowInfoWithDownloadStatus extends ConsumerStatefulWidget {
  final Podcast? podcast;

  const _ShowInfoWithDownloadStatus({required this.podcast});

  @override
  ConsumerState<_ShowInfoWithDownloadStatus> createState() =>
      _ShowInfoWithDownloadStatusState();
}

class _ShowInfoWithDownloadStatusState
    extends ConsumerState<_ShowInfoWithDownloadStatus> {
  bool _hasDownloads = false;

  @override
  void initState() {
    super.initState();
    _checkDownloads();
  }

  Future<void> _checkDownloads() async {
    if (widget.podcast != null) {
      final hasDownloads = await AudioDownloadService.instance
          .hasDownloadedEpisodesForPodcast(widget.podcast!.id);
      if (mounted) {
        setState(() => _hasDownloads = hasDownloads);
      }
    }
  }

  Future<void> _handleRemoveDownloads() async {
    final podcast = widget.podcast;
    if (podcast == null) return;

    await AudioDownloadService.instance.removeAllDownloadsForPodcast(
      podcast.id,
    );
    ref.invalidate(downloadedEpisodesNotifierProvider);
    if (!mounted) return;
    ToastUtils.showSuccessToast(context, message: '已移除所有下载');
    await _checkDownloads();
  }

  Future<void> _handleUnfollow() async {
    final podcast = widget.podcast;
    if (podcast == null) return;

    try {
      await ref.read(unfollowPodcastProvider)(podcast);
      if (!mounted) return;
      ToastUtils.showSuccessToast(context, message: '已取消关注');
      ref.read(navigationProvider.notifier).goBack();
    } catch (e, stackTrace) {
      Logger.error('❌ [UNFOLLOW] 取消关注失败', error: e, stackTrace: stackTrace);
      if (!mounted) return;
      ToastUtils.showErrorToast(context, message: '取消关注失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final podcast = widget.podcast;

    return ShowInfo(
      title: podcast?.title,
      artworkUrl: podcast?.artworkUrl,
      description: podcast?.description,
      rssUrl: podcast?.rssUrl,
      hasDownloadedEpisodes: _hasDownloads,
      onViewDetails: () {},
      onCopyLinkSuccess: () {
        if (mounted) {
          ToastUtils.showCopySuccessToast(context);
        }
      },
      onRemoveDownloads: _handleRemoveDownloads,
      onUnfollow: _handleUnfollow,
    );
  }
}
