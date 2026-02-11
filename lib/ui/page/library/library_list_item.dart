import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_episode_item.dart';
import 'package:tinycast/ui/page/library/library_show_cover.dart';
import 'package:tinycast/ui/page/library/library_show_info.dart';

/// Library 列表项组件
///
/// 用于显示一个节目及其最近更新的集数列表。
/// 每个列表项包含节目封面、节目信息（名称、更新时间）和集数列表。
class LibraryListItem extends StatelessWidget {
  /// 节目名称
  final String showName;

  /// 更新时间（如 "1 h ago"）
  final String timeAgo;

  /// 集数标题列表
  final List<String> episodeTitles;

  const LibraryListItem({
    super.key,
    required this.showName,
    required this.timeAgo,
    required this.episodeTitles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 节目封面（占位符）
        const LibraryShowCover(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 节目信息（名称、时间、更多按钮）
              LibraryShowInfo(showName: showName, timeAgo: timeAgo),
              const SizedBox(height: 2),

              /// 集数列表
              Column(
                spacing: 1,
                children: episodeTitles
                    .map((title) => LibraryEpisodeItem(title: title))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
