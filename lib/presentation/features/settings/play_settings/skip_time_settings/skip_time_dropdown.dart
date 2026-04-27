import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';

/// 跳过时间下拉菜单
///
/// 显示快进/快退时间选项的纵向列表菜单。
/// 包含：10秒、15秒、30秒、45秒、60秒。
class SkipTimeDropdown extends StatelessWidget {
  /// 当前选中的时间（秒）
  final int selectedTime;

  /// 选项被选中时的回调，传递新选择的时间值
  final ValueChanged<int>? onItemSelected;

  const SkipTimeDropdown({
    super.key,
    required this.selectedTime,
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
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 2,
          children: [
            DropdownItem(
              icon: selectedTime == 10
                  ? const Icon(LucideIcons.check)
                  : null,
              text: '10 秒',
              onPressed: () => _handleItemSelected(10),
            ),
            DropdownItem(
              icon: selectedTime == 15
                  ? const Icon(LucideIcons.check)
                  : null,
              text: '15 秒',
              onPressed: () => _handleItemSelected(15),
            ),
            DropdownItem(
              icon: selectedTime == 30
                  ? const Icon(LucideIcons.check)
                  : null,
              text: '30 秒',
              onPressed: () => _handleItemSelected(30),
            ),
            DropdownItem(
              icon: selectedTime == 45
                  ? const Icon(LucideIcons.check)
                  : null,
              text: '45 秒',
              onPressed: () => _handleItemSelected(45),
            ),
            DropdownItem(
              icon: selectedTime == 60
                  ? const Icon(LucideIcons.check)
                  : null,
              text: '60 秒',
              onPressed: () => _handleItemSelected(60),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemSelected(int time) {
    onItemSelected?.call(time);
  }
}
