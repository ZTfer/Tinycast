import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_episode_item/library_episode_item.dart';
import 'package:tinycast/ui/page/library/library_show_info/library_show_cover.dart';
import 'package:tinycast/ui/page/library/library_show_info/library_show_info.dart';

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

  /// 是否显示分隔线，默认 true
  final bool showDivider;

  const LibraryListItem({
    super.key,
    required this.showName,
    required this.timeAgo,
    required this.episodeTitles,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LibraryShowCover(),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LibraryShowInfo(showName: showName, timeAgo: timeAgo),
                    const SizedBox(height: 2),
                    Column(
                      spacing: 1,
                      children: episodeTitles
                          .map((title) => LibraryEpisodeItem(title: title))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (showDivider) _buildDivider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建分隔线
  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE0E0E0));
  }
}
