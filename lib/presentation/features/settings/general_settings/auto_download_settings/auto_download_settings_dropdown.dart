import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';

/// 自动下载设置下拉菜单
///
/// 提供自动下载选项选择，包含：
/// - 按节目集数：关闭、最新 1/2/3/5/10 集
/// - 按时间范围：过去 24 小时、7 天、14 天、30 天
/// - 其他选项：所有单集
class AutoDownloadSettingsDropdown extends StatelessWidget {
  final VoidCallback? onItemSelected;

  const AutoDownloadSettingsDropdown({super.key, this.onItemSelected});

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 235),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '关闭',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: Icon(LucideIcons.check),
                  text: '每个节目最新 1 集',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '每个节目最新 2 集',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '每个节目最新 3 集',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '每个节目最新 5 集',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '每个节目最新 10 集',
                  onPressed: () => _handleItemSelected(),
                ),

                // 分割线
                const SizedBox(height: 2),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 2),

                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '过去 24 小时',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '过去 7 天',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '过去 14 天',
                  onPressed: () => _handleItemSelected(),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '过去 30 天',
                  onPressed: () => _handleItemSelected(),
                ),

                // 分割线
                const SizedBox(height: 2),
                const Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0xFFE0E0E0),
                ),
                const SizedBox(height: 2),

                DropdownItem(
                  // icon: Icon(LucideIcons.check),
                  text: '所有单集',
                  onPressed: () => _handleItemSelected(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleItemSelected() {
    onItemSelected?.call();
  }
}
