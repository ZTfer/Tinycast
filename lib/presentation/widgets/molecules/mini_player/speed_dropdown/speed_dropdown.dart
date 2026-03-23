import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/molecules/mini_player/speed_dropdown/speed_dropdown_item.dart';

/// 队列剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class SpeedDropdown extends StatelessWidget {
  final VoidCallback? onItemSelected;
  final double currentSpeed;
  final Function(double)? onSpeedChanged;

  const SpeedDropdown({
    super.key,
    this.onItemSelected,
    this.currentSpeed = 1.0,
    this.onSpeedChanged,
  });

  static const List<double> _speedOptions = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
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
          children: _speedOptions.map((speed) {
            return SpeedDropdownItem(
              icon: currentSpeed == speed ? Icon(LucideIcons.check) : null,
              text: '${speed}x',
              onPressed: () {
                onSpeedChanged?.call(speed);
                onItemSelected?.call();
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
