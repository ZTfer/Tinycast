import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';

/// 队列剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class LibraryDropdown extends StatelessWidget {
  /// 菜单项选中时的回调函数
  final VoidCallback? onItemSelected;

  const LibraryDropdown({super.key, this.onItemSelected});

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
              onPressed: () => _handleItemSelected(),
            ),

            DropdownItem(
              icon: Icon(LucideIcons.copy),
              text: '拷贝链接',
              onPressed: () => _handleItemSelected(),
            ),
            DropdownItem(
              icon: Icon(LucideIcons.share2),
              text: '分享',
              onPressed: () => _handleItemSelected(),
            ),
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
              onPressed: () => _handleItemSelected(),
            ),
            DropdownItem(
              icon: Icon(LucideIcons.trash2),
              text: '移除下载',
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
