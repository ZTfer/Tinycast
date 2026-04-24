import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';

/// 缓存清理选项枚举
enum CleanupOption { all, played, recent5, recent10 }

/// 缓存清理设置下拉菜单
///
/// 提供缓存清理选项选择，包含：
/// - 清理所有：清理所有音频和图片缓存
/// - 清理已播放：仅清理已播放的节目
/// - 保留最近5集：保留最近5集，删除其余
/// - 保留最近10集：保留最近10集，删除其余
class CacheCleanupSettingsDropdown extends StatelessWidget {
  final CleanupOption selectedOption;
  final ValueChanged<CleanupOption> onOptionSelected;
  final VoidCallback? onItemSelected;

  const CacheCleanupSettingsDropdown({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
    this.onItemSelected,
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 235),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownItem(
                  icon: selectedOption == CleanupOption.all
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '清理所有',
                  onPressed: () => _handleItemSelected(CleanupOption.all),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedOption == CleanupOption.played
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '清理已播放',
                  onPressed: () => _handleItemSelected(CleanupOption.played),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedOption == CleanupOption.recent5
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '保留最近5集',
                  onPressed: () => _handleItemSelected(CleanupOption.recent5),
                ),
                const SizedBox(height: 2),
                DropdownItem(
                  icon: selectedOption == CleanupOption.recent10
                      ? const Icon(LucideIcons.check)
                      : null,
                  text: '保留最近10集',
                  onPressed: () => _handleItemSelected(CleanupOption.recent10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleItemSelected(CleanupOption option) {
    onOptionSelected(option);
    onItemSelected?.call();
  }
}
