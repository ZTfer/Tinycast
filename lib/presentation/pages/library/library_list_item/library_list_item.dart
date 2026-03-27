import 'package:flutter/widgets.dart';
import 'package:tinycast/domain/entities/podcast.dart';
import 'package:tinycast/domain/entities/episode.dart';
import 'package:tinycast/presentation/pages/library/library_episode_item/library_episode_item.dart';
import 'package:tinycast/presentation/pages/library/library_episode_item/library_episode_item_skeleton.dart';
import 'package:tinycast/presentation/pages/library/library_show_info/library_show_cover.dart';
import 'package:tinycast/presentation/pages/library/library_show_info/library_show_info.dart';

/// Library 列表项组件
///
/// 用于显示一个节目及其最近更新的集数列表。
/// 每个列表项包含节目封面、节目信息（名称、更新时间）和集数列表。
class LibraryListItem extends StatelessWidget {
  /// 播客对象
  final Podcast podcast;

  /// 最新集数列表
  final List<Episode> episodes;

  /// 是否显示分隔线，默认 true
  final bool showDivider;

  /// 点击播客时的回调
  final VoidCallback? onTap;

  /// 更多按钮的回调
  final VoidCallback? onMorePressed;

  /// 点击标题时的回调
  final VoidCallback? onTitleTap;

  /// 是否正在加载剧集数据
  final bool isLoading;

  const LibraryListItem({
    super.key,
    required this.podcast,
    required this.episodes,
    this.showDivider = true,
    this.onTap,
    this.onMorePressed,
    this.onTitleTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LibraryShowCover(artworkUrl: podcast.artworkUrl),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LibraryShowInfo(
                        showName: podcast.title,
                        timeAgo: _formatTimeAgo(podcast.lastUpdated),
                        onMorePressed: onMorePressed,
                        onTitleTap: onTitleTap,
                      ),
                      const SizedBox(height: 2),
                      Column(spacing: 1, children: _buildEpisodeItems()),
                      const SizedBox(height: 12),
                      if (showDivider) _buildDivider(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE0E0E0));
  }

  /// 构建剧集列表项
  List<Widget> _buildEpisodeItems() {
    // 如果正在加载，显示骨架屏
    if (isLoading) {
      return List.generate(3, (index) => const LibraryEpisodeItemSkeleton());
    }

    // 显示实际剧集数据
    return episodes
        .take(3)
        .map(
          (episode) => LibraryEpisodeItem(
            title: episode.title,
            onTap: () {
              // MARK: Do something，目前没什么用
            },
          ),
        )
        .toList();
  }

  /// 格式化时间为相对时间
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} m ago';
    } else {
      return 'Just now';
    }
  }
}
