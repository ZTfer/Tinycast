import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/data/services/audio_download_service.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/features/downloads/downloaded_episodes_provider.dart';
import 'package:tinycast/presentation/providers/download_provider.dart';
import 'package:tinycast/presentation/providers/favorite_episodes_provider.dart';
import 'package:tinycast/presentation/providers/play_history_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/providers/queue_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';

typedef UnfollowPodcast = Future<void> Function(Podcast podcast);

/// 统一的退订流程：清理播放历史、队列、下载文件与数据库记录，
/// 最后刷新所有受影响的内存状态。
final unfollowPodcastProvider = Provider<UnfollowPodcast>((ref) {
  return (podcast) async {
    Logger.info('🚫 [UNFOLLOW] 开始取消关注: ${podcast.title} (id: ${podcast.id})');

    await ref.read(playHistoryRepositoryProvider).removeByPodcastId(podcast.id);
    await ref
        .read(queueRepositoryProvider)
        .removeFromQueueByPodcast(
          podcast.id,
          podcastITunesId: podcast.itunesId,
        );
    await AudioDownloadService.instance.unfollowPodcast(podcast.id);
    await ref.read(podcastProvider.notifier).unsubscribe(podcast.id);

    ref.read(queueNotifierProvider.notifier).removeByPodcastId(podcast.id);
    ref.read(completedHistoriesProvider.notifier).removeByPodcastId(
      podcast.id,
    );
    ref.invalidate(queueNotifierProvider);
    ref.invalidate(completedHistoriesProvider);
    ref.invalidate(favoriteEpisodesNotifierProvider);
    ref.invalidate(downloadedEpisodesNotifierProvider);
    ref.invalidate(unplayedEpisodesNotifierProvider);

    await ref.read(podcastProvider.notifier).loadSubscribedPodcasts();
    ref.read(downloadNotifierProvider.notifier).manualRefresh();

    Logger.info('✅ [UNFOLLOW] 取消关注完成: ${podcast.title}');
  };
});
