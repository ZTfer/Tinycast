import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/sleep_dropdown/sleep_dropdown_item.dart';

/// 队列剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class SleepDropdown extends StatelessWidget {
  final VoidCallback? onItemSelected;

  const SleepDropdown({super.key, this.onItemSelected});

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
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '关闭',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              icon: Icon(LucideIcons.check),
              text: '5 分钟',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '10 分钟',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '15 分钟',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '30 分钟',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '45 分钟',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '1 小时',
              onPressed: () => _handleItemSelected(),
            ),
            SleepDropdownItem(
              // icon: Icon(LucideIcons.check),
              text: '单集结束时',
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
