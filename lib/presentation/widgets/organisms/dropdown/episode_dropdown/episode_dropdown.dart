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

  /// 插播回调（添加到队列最前面）
  final VoidCallback? onInsertToFront;

  /// 添加到队列回调（添加到队列最后面）
  final VoidCallback? onAddToQueue;

  /// 标记为已播放回调
  final VoidCallback? onMarkAsPlayed;

  /// 当前 episode 的下载状态，默认值 false
  final bool isDownloaded;

  /// 下载切换回调，默认值 null
  final VoidCallback? onToggleDownload;

  const EpisodeDropdown({
    super.key,
    this.onItemSelected,
    this.isFavorite = false,
    this.onToggleFavorite,
    this.link,
    this.onShowCopySuccessToast,
    this.onInsertToFront,
    this.onAddToQueue,
    this.onMarkAsPlayed,
    this.isDownloaded = false,
    this.onToggleDownload,
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
              onPressed: () {
                if (onToggleFavorite != null) {
                  onToggleFavorite!();
                } else {
                  _handleItemSelected();
                }
              },
            ),
            /*
            // 桌面端暂时不需要分享功能，因为复制链接即可
              EpisodeDropdownItem(
                icon: Icon(LucideIcons.share2),
                text: '分享',
                onPressed: () => _handleItemSelected(),
              ),
            */
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
              onPressed: () {
                onInsertToFront?.call();
                _handleItemSelected();
              },
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.listEnd),
              text: '添加到队列',
              onPressed: () {
                onAddToQueue?.call();
                _handleItemSelected();
              },
            ),
            EpisodeDropdownItem(
              icon: Icon(LucideIcons.circleCheck),
              text: '标记为已播放',
              onPressed: () {
                onMarkAsPlayed?.call();
                _handleItemSelected();
              },
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
              icon: Icon(
                isDownloaded ? LucideIcons.trash2 : LucideIcons.arrowDown,
              ),
              text: isDownloaded ? '移除下载' : '下载',
              onPressed: () {
                onToggleDownload?.call();
                _handleItemSelected();
              },
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
    if (link == null || link!.trim().isEmpty) {
      _handleItemSelected();
      return;
    }

    Clipboard.setData(ClipboardData(text: link!));
    onShowCopySuccessToast?.call();
    _handleItemSelected();
  }
}
