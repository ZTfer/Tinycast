import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'episodes_list.dart';

/// 播客详情页面
///
/// 显示播客的完整信息和节目列表，支持播放、下载、收藏等操作。
class PodcastDetail extends ConsumerStatefulWidget {
  final int podcastId;

  const PodcastDetail({super.key, required this.podcastId});

  @override
  ConsumerState<PodcastDetail> createState() => _PodcastDetailState();
}

class _PodcastDetailState extends ConsumerState<PodcastDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 检查 Widget 是否仍然 mounted
    if (!mounted) return;
    
    await ref.read(podcastProvider.notifier).loadPodcastById(widget.podcastId);
    
    // 再次检查 Widget 是否仍然 mounted
    if (!mounted) return;
    
    await ref
        .read(podcastProvider.notifier)
        .loadEpisodesByPodcastId(widget.podcastId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(podcastProvider);
    final podcast = state.podcast;
    final episodes = state.episodes;

    if (state.status == PodcastStatus.loading) {
      return const Center(child: Text('加载中...'));
    }

    if (state.status == PodcastStatus.error) {
      return Center(child: Text('加载失败: ${state.errorMessage}'));
    }

    if (podcast == null) {
      return const Center(child: Text('播客不存在'));
    }

    if (episodes != null) {
      return EpisodesList(podcast: podcast, episodes: episodes);
    }

    return const SizedBox();
  }
}
