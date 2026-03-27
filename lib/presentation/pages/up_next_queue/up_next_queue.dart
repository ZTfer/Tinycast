import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_empty_page/queue_empty_page.dart';
import 'package:tinycast/presentation/pages/episode_detail/episode_detail.dart';
import 'package:tinycast/presentation/widgets/molecules/episode_item/episode_item.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/providers/unplayed_episodes_provider.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';

/// 待播放队列页面
///
/// 显示用户待播放的节目列表。
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。

class UpNextQueue extends ConsumerStatefulWidget {
  const UpNextQueue({super.key});

  @override
  ConsumerState<UpNextQueue> createState() => _UpNextQueueState();
}

class _UpNextQueueState extends ConsumerState<UpNextQueue> {
  /// 当前选中的 episode，为 null 时显示列表
  Episode? _selectedEpisode;

  /// 当前选中 episode 对应的 podcast
  Podcast? _selectedPodcast;

  /// 选中 episode，在页面内显示详情
  Future<void> _selectEpisode(Episode episode) async {
    final useCase = ref.read(getPodcastByIdUseCaseProvider);
    final podcast = await useCase(episode.podcastId);

    if (podcast != null) {
      setState(() {
        _selectedEpisode = episode;
        _selectedPodcast = podcast;
      });
    }
  }

  /// 返回列表
  void _backToList() {
    setState(() {
      _selectedEpisode = null;
      _selectedPodcast = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedEpisode != null && _selectedPodcast != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: _backToList,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '返回',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: EpisodeDetail(
              episode: _selectedEpisode,
              podcast: _selectedPodcast,
            ),
          ),
        ],
      );
    }

    final episodes = ref.watch(unplayedEpisodesProvider);
    final isLoading = ref.watch(unplayedEpisodesLoadingProvider);

    if (isLoading) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (episodes.isEmpty) {
      return const QueueEmptyPage();
    }

    return ListView.builder(
      itemCount: episodes.length,
      itemBuilder: (context, index) {
        final episode = episodes[index];
        final isLast = index == episodes.length - 1;

        return EpisodeItem(
          episode: episode,
          showDivider: !isLast,
          onPlayPressed: () {
            ref.read(playbackProvider.notifier).playEpisode(episode);
          },
          onEpisodeTap: () => _selectEpisode(episode),
        );
      },
    );
  }
}
