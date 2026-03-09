import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/downloads/downloads_control_bar/downloads_control_bar.dart';

/// Downloads 列表项组件
///
/// 用于显示已下载列表中的单个节目项。
/// 每个列表项包含节目封面、文本信息（时间、标题、描述）和操作区域（播放按钮、更多选项）。
class DownloadsItem extends StatelessWidget {
  /// 更新时间（如 "1 h ago"）
  final String timeAgo;

  /// 节目标题
  final String title;

  /// 节目描述
  final String description;

  /// 节目时长（如 "32 min"）
  final String duration;

  /// 是否显示分隔线，默认 true
  final bool showDivider;

  const DownloadsItem({
    super.key,
    required this.timeAgo,
    required this.title,
    required this.description,
    required this.duration,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 节目封面（占位符）
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 文本信息区域
                    _buildTextSection(),
                    const SizedBox(height: 6),

                    /// 操作区域（播放按钮、更多选项）
                    _buildActionSection(),
                  ],
                ),
              ),
            ],
          ),
        ),

        /// 分隔线
        if (showDivider) _buildDivider(),
      ],
    );
  }

  /// 构建文本信息区域
  ///
  /// 包含更新时间、节目标题和节目描述。
  Widget _buildTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          timeAgo,
          style: const TextStyle(
            fontSize: 9.75,
            color: Color(0xD9000000),
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF000000),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(
            fontSize: 9.75,
            color: Color(0xD9000000),
            fontWeight: FontWeight.normal,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建操作区域
  ///
  /// 使用 FavoriteControlBar 组件，包含播放按钮、收藏按钮和更多选项。
  Widget _buildActionSection() {
    return const DownloadsControlBar();
  }

  /// 构建分隔线
  ///
  /// 用于分隔不同的列表项，默认显示。
  Widget _buildDivider() {
    return Container(height: 0.5, color: const Color(0xFFE0E0E0));
  }
}
