import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';

/// 库节目下拉菜单
///
/// 显示节目操作选项的纵向列表菜单。
/// 包含：查看详情、拷贝链接、取消关注、移除下载。
class LibraryDropdown extends StatelessWidget {
  /// 菜单项选中时的回调函数
  final VoidCallback? onItemSelected;

  /// 查看详情回调
  final VoidCallback? onViewDetails;

  /// 节目 RSS URL
  final String? rssUrl;

  /// 拷贝链接成功回调
  final VoidCallback? onCopyLinkSuccess;

  /// 是否有已下载的剧集
  final bool hasDownloadedEpisodes;

  /// 移除下载回调
  final VoidCallback? onRemoveDownloads;

  /// 取消关注回调
  final VoidCallback? onUnfollow;

  const LibraryDropdown({
    super.key,
    this.onItemSelected,
    this.onViewDetails,
    this.rssUrl,
    this.onCopyLinkSuccess,
    this.hasDownloadedEpisodes = false,
    this.onRemoveDownloads,
    this.onUnfollow,
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
            DropdownItem(
              icon: Icon(LucideIcons.info),
              text: '查看详情',
              onPressed: () {
                onViewDetails?.call();
                _handleItemSelected();
              },
            ),

            DropdownItem(
              icon: Icon(LucideIcons.copy),
              text: '拷贝链接',
              onPressed: () {
                _handleCopyLink();
                _handleItemSelected();
              },
            ),

            // DropdownItem(
            //   icon: Icon(LucideIcons.share2),
            //   text: '分享',
            //   onPressed: () => _handleItemSelected(),
            // ),
            SizedBox(height: 2),
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: const Color(0xFFE0E0E0),
            ),
            SizedBox(height: 2),

            DropdownItem(
              icon: Icon(LucideIcons.circleMinus),
              text: '取消关注',
              onPressed: () {
                _handleUnfollow(context);
                _handleItemSelected();
              },
            ),
            if (hasDownloadedEpisodes)
              DropdownItem(
                icon: Icon(LucideIcons.trash2),
                text: '移除下载',
                onPressed: () {
                  _handleRemoveDownloads();
                  _handleItemSelected();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleItemSelected() {
    onItemSelected?.call();
  }

  void _handleCopyLink() {
    if (rssUrl != null && rssUrl!.trim().isNotEmpty) {
      Clipboard.setData(ClipboardData(text: rssUrl!));
      onCopyLinkSuccess?.call();
    }
  }

  void _handleUnfollow(BuildContext context) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black54,
      builder: (dialogContext) => Material(
        color: Colors.transparent,
        child: Center(
          child: AlertDialog(
            title: Text('取消关注'),
            content: Text('确定要取消关注这个节目吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onUnfollow?.call();
                },
                child: Text('确定'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleRemoveDownloads() {
    onRemoveDownloads?.call();
  }
}
