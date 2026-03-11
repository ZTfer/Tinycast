import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/settings/general_settings/auto_download_settings/auto_download_dropdown/auto_download_dropdown_item.dart';

/// 队列剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class AutoDownloadDropdown extends StatelessWidget {
  final VoidCallback? onItemSelected;

  const AutoDownloadDropdown({super.key, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 110,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300, // 边框颜色
          width: 0.5, // 边框宽度
          style: BorderStyle.solid, // 实线
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
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '关闭',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              icon: Icon(LucideIcons.check),
              text: '每个节目最新单集',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '每个节目最新 2 集',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '每个节目最新 3 集',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '每个节目最新 5 集',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '每个节目最新 10 集',
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

            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '过去 24 小时',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '过去 7 天',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '过去 14 天',
              onPressed: () => _handleItemSelected(),
            ),
            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '过去 30 天',
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

            AutoDownloadDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '所有单集',
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
}
