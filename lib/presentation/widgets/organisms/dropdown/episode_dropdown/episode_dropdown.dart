import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/organisms/dropdown/episode_dropdown/episode_dropdown_item.dart';

/// 剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class EpisodeDropdown extends StatelessWidget {
  /// 菜单项选中时的回调函数
  final VoidCallback? onItemSelected;

  /// 当前 episode 的收藏状态，默认值 false
  final bool isFavorite;

  /// 收藏切换回调，默认值 null
  final VoidCallback? onToggleFavorite;

  /// episode 的链接地址
  final String? link;

  /// 拷贝链接成功后的回调（用于显示 Toast）
  final VoidCallback? onShowCopySuccessToast;

  const EpisodeDropdown({
    super.key,
    this.onItemSelected,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.link,
    this.onShowCopySuccessToast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.copy),
              text: '拷贝链接',
              onPressed: () => _handleCopyLink(context),
            ),
            EpisodeDropdownItem(
              icon: Icon(isFavorite ? LucideIcons.starOff : LucideIcons.star),
              text: isFavorite ? '取消收藏' : '收藏',
              onPressed: () => onToggleFavorite ?? _handleItemSelected(),
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.share2),
              text: '分享',
              onPressed: () => _handleItemSelected(),
            ),

            // 分割线
            SizedBox(height: 2),
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: const Color(0xFFE0E0E0),
            ),
            SizedBox(height: 2),

            EpisodeDropdownItem(
              icon: Icon(LucideIcons.listStart),
              text: '插播',
              onPressed: () => _handleItemSelected(),
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.listEnd),
              text: '添加到队列',
              onPressed: () => _handleItemSelected(),
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.circleCheck),
              text: '标记为已播放',
              onPressed: () => _handleItemSelected(),
            ),

            // 分割线
            SizedBox(height: 2),
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: const Color(0xFFE0E0E0),
            ),
            SizedBox(height: 2),

            EpisodeDropdownItem(
              icon: Icon(LucideIcons.trash2),
              text: '移除下载',
              onPressed: () => _handleItemSelected(),
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.x),
              text: '从待播清单移除',
              onPressed: () => _handleItemSelected(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemSelected() {
    onItemSelected?.call();
  }

  void _handleCopyLink(BuildContext context) {
    if (link == null || link!.isEmpty) {
      _handleItemSelected();
      return;
    }
    Clipboard.setData(ClipboardData(text: link!));
    onShowCopySuccessToast?.call();
    _handleItemSelected();
  }
}
