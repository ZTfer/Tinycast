import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

/// 自动下载设置下拉菜单
///
/// 提供自动下载选项选择，包含：
/// - 按节目集数：关闭、最新 1/2/3/5/10 集
/// - 按时间范围：过去 24 小时、7 天、14 天、30 天
/// - 其他选项：所有单集
class AutoDownloadSettingsDropdown extends StatelessWidget {
  final AutoDownloadPolicy selectedPolicy;
  final ValueChanged<AutoDownloadPolicy> onPolicySelected;
  final VoidCallback? onItemSelected;

  const AutoDownloadSettingsDropdown({
    super.key,
    required this.selectedPolicy,
    required this.onPolicySelected,
    this.onItemSelected,
  });

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
                  icon: selectedPolicy == AutoDownloadPolicy.off
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '关闭',
                  onPressed: () => _handleItemSelected(AutoDownloadPolicy.off),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.latest1
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '最新 1 集',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.latest1),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.latest2
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '最新 2 集',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.latest2),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.latest3
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '最新 3 集',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.latest3),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.latest5
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '最新 5 集',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.latest5),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.latest10
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '最新 10 集',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.latest10),
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
                  icon: selectedPolicy == AutoDownloadPolicy.past24h
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '过去 24 小时',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.past24h),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.past7d
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '过去 7 天',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.past7d),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.past14d
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '过去 14 天',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.past14d),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedPolicy == AutoDownloadPolicy.past30d
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '过去 30 天',
                  onPressed: () =>
                      _handleItemSelected(AutoDownloadPolicy.past30d),
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
                  icon: selectedPolicy == AutoDownloadPolicy.all
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '所有单集',
                  onPressed: () => _handleItemSelected(AutoDownloadPolicy.all),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleItemSelected(AutoDownloadPolicy policy) {
    onPolicySelected(policy);
    onItemSelected?.call();
  }
}
