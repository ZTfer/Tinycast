import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tinycast/core/theme/app_colors.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/presentation/providers/podcast_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/list_play_button.dart';
import 'package:tinycast/core/utils/error_toast.dart';
import 'package:tinycast/core/utils/app_exception.dart';

/// 播客详情页面
///
/// 显示播客的完整信息和节目列表，支持播放、下载、收藏等操作。
class PodcastDetailPage extends ConsumerStatefulWidget {
  /// 播客ID
  final int podcastId;

  const PodcastDetailPage({super.key, required this.podcastId});

  @override
  ConsumerState<PodcastDetailPage> createState() => _PodcastDetailPageState();
}

class _PodcastDetailPageState extends ConsumerState<PodcastDetailPage> {
  /// 每页显示的节目数量
  static const int _pageSize = 20;

  /// 当前页码
  int _currentPage = 1;

  /// 是否正在加载更多
  bool _isLoadingMore = false;

  /// 是否还有更多数据
  bool _hasMore = true;

  /// 滚动控制器
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载数据
  Future<void> _loadData() async {
    // 重置状态
    setState(() {
      _currentPage = 1;
      _hasMore = true;
      _isLoadingMore = false;
    });

    // 加载播客详情
    await ref.read(podcastProvider.notifier).loadPodcastById(widget.podcastId);

    // 加载节目列表
    await ref
        .read(podcastProvider.notifier)
        .loadEpisodesByPodcastId(widget.podcastId);
  }

  /// 滚动监听
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEpisodes();
    }
  }

  /// 加载更多节目
  Future<void> _loadMoreEpisodes() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      // 这里应该调用分页加载的API
      // 暂时模拟加载更多
      await Future.delayed(const Duration(seconds: 1));

      final episodes = ref.read(episodesProvider);
      if (episodes != null && episodes.length < _currentPage * _pageSize) {
        setState(() {
          _hasMore = false;
        });
      } else {
        setState(() {
          _currentPage++;
        });
      }
    } catch (e) {
      // 处理错误
      AppException exception;
      if (e is AppException) {
        exception = e;
      } else {
        exception = AppException.unknown(
          '加载更多节目失败：${e.toString()}',
          originalError: e,
        );
      }

      // 显示错误提示
      if (mounted) {
        ErrorToast.showException(context, exception);
      }
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  /// 格式化时长
  String _formatDuration(int? duration) {
    if (duration == null) return '';
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// 格式化发布时间
  String _formatPubDate(DateTime pubDate) {
    final now = DateTime.now();
    final difference = now.difference(pubDate);

    if (difference.inDays > 7) {
      return DateFormat('yyyy-MM-dd').format(pubDate);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  /// 应用透明度到颜色
  Color _withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  @override
  Widget build(BuildContext context) {
    final podcastState = ref.watch(podcastStateProvider);
    final podcast = ref.watch(currentPodcastProvider);
    final episodes = ref.watch(episodesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(podcastState, podcast, episodes),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Podcast Details'),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // 分享功能
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'subscribe':
                // 订阅/取消订阅
                break;
              case 'settings':
                // 设置
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'subscribe', child: Text('Subscribe')),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  /// 构建页面主体
  Widget _buildBody(
    PodcastState podcastState,
    Podcast? podcast,
    List<Episode>? episodes,
  ) {
    if (podcastState.status == PodcastStatus.loading && podcast == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (podcastState.status == PodcastStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              podcastState.errorMessage ?? 'Failed to load podcast',
              style: const TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (podcast == null) {
      return const Center(child: Text('Podcast not found'));
    }

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 播客信息头部
        SliverToBoxAdapter(child: _buildPodcastHeader(podcast)),

        // 节目列表
        if (episodes != null && episodes.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == episodes.length) {
                return _buildLoadMoreIndicator();
              }
              return _buildEpisodeItem(episodes[index]);
            }, childCount: episodes.length + 1),
          )
        else
          SliverToBoxAdapter(child: _buildEmptyState()),
      ],
    );
  }

  /// 构建播客信息头部
  Widget _buildPodcastHeader(Podcast podcast) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 播客封面
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  podcast.artworkUrl,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.podcasts,
                        size: 48,
                        color: AppColors.onSurfaceVariant,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 播客标题
                    Text(
                      podcast.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 播客作者
                    Text(
                      podcast.author,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 播客统计信息
                    Row(
                      children: [
                        Icon(
                          Icons.podcasts,
                          size: 14,
                          color: _withOpacity(AppColors.onSurfaceVariant, 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${podcast.episodeCount} episodes',
                          style: TextStyle(
                            fontSize: 12,
                            color: _withOpacity(
                              AppColors.onSurfaceVariant,
                              0.7,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.update,
                          size: 14,
                          color: _withOpacity(AppColors.onSurfaceVariant, 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatPubDate(podcast.lastUpdated),
                          style: TextStyle(
                            fontSize: 12,
                            color: _withOpacity(
                              AppColors.onSurfaceVariant,
                              0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 播客描述
          Text(
            podcast.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurface,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          // 操作按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // 播放最新节目
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Latest'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // 订阅/取消订阅
                },
                icon: Icon(
                  podcast.isSubscribed
                      ? Icons.subscriptions
                      : Icons.subscriptions_outlined,
                  color: podcast.isSubscribed
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: () {
                  // 下载所有节目
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 分隔线
          Container(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          // 节目标题
          const Text(
            'Episodes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建节目列表项
  Widget _buildEpisodeItem(Episode episode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 节目封面（可选）
              if (episode.artworkUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    episode.artworkUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.podcasts,
                    size: 24,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 发布时间
                    Text(
                      _formatPubDate(episode.pubDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: _withOpacity(AppColors.onSurfaceVariant, 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 节目标题
                    Text(
                      episode.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 节目描述
                    Text(
                      episode.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: _withOpacity(AppColors.onSurfaceVariant, 0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 节目信息和操作
                    Row(
                      children: [
                        // 时长
                        if (episode.duration != null)
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 12,
                                color: _withOpacity(
                                  AppColors.onSurfaceVariant,
                                  0.7,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                _formatDuration(episode.duration),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _withOpacity(
                                    AppColors.onSurfaceVariant,
                                    0.7,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        // 播放进度
                        if (episode.playProgress > 0)
                          Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${(episode.playProgress * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        // 操作按钮
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 播放按钮
                              ListPlayButton(
                                icon: const Icon(Icons.play_arrow, size: 10),
                                label: 'Play',
                                onPressed: () {
                                  // 播放节目
                                },
                              ),
                              const SizedBox(width: 8),
                              // 下载按钮
                              if (!episode.isDownloaded)
                                IconButton(
                                  onPressed: () {
                                    // 下载节目
                                  },
                                  icon: Icon(
                                    Icons.download,
                                    size: 18,
                                    color: _withOpacity(
                                      AppColors.onSurfaceVariant,
                                      0.7,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              // 收藏按钮
                              IconButton(
                                onPressed: () {
                                  // 收藏/取消收藏
                                },
                                icon: Icon(
                                  episode.isPlayed
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 18,
                                  color: episode.isPlayed
                                      ? AppColors.primary
                                      : _withOpacity(
                                          AppColors.onSurfaceVariant,
                                          0.7,
                                        ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              // 更多选项
                              PopupMenuButton<String>(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: _withOpacity(
                                    AppColors.onSurfaceVariant,
                                    0.7,
                                  ),
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onSelected: (value) {
                                  switch (value) {
                                    case 'play':
                                      // 播放
                                      break;
                                    case 'download':
                                      // 下载
                                      break;
                                    case 'favorite':
                                      // 收藏
                                      break;
                                    case 'share':
                                      // 分享
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'play',
                                    child: Row(
                                      children: [
                                        Icon(Icons.play_arrow, size: 18),
                                        SizedBox(width: 8),
                                        Text('Play'),
                                      ],
                                    ),
                                  ),
                                  if (!episode.isDownloaded)
                                    const PopupMenuItem(
                                      value: 'download',
                                      child: Row(
                                        children: [
                                          Icon(Icons.download, size: 18),
                                          SizedBox(width: 8),
                                          Text('Download'),
                                        ],
                                      ),
                                    ),
                                  const PopupMenuItem(
                                    value: 'favorite',
                                    child: Row(
                                      children: [
                                        Icon(Icons.favorite, size: 18),
                                        SizedBox(width: 8),
                                        Text('Favorite'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'share',
                                    child: Row(
                                      children: [
                                        Icon(Icons.share, size: 18),
                                        SizedBox(width: 8),
                                        Text('Share'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 分隔线
          Container(height: 0.5, color: AppColors.outlineVariant),
        ],
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator() {
    if (!_hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more episodes',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ),
      );
    }

    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox.shrink();
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.podcasts,
              size: 64,
              color: _withOpacity(AppColors.onSurfaceVariant, 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No episodes available',
              style: TextStyle(
                fontSize: 16,
                color: _withOpacity(AppColors.onSurfaceVariant, 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
