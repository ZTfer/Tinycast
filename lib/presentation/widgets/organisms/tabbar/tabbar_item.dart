import 'package:flutter/widgets.dart';

/// TabBar 按钮的状态枚举
enum TabBarItemState { active, defaultState }

/// TabBar 按钮组件
///
/// 用于在移动端底部 TabBar 中显示可点击的标签按钮，支持图标和文字显示。
/// 包含选中和默认状态的视觉反馈。
class TabBarItem extends StatelessWidget {
  /// 按钮显示的图标
  final IconData icon;

  /// 按钮显示的文字标签（选填）
  final String? label;

  /// 按钮的当前状态
  final TabBarItemState state;

  /// 按钮点击时的回调函数
  final VoidCallback onPressed;

  const TabBarItem({
    super.key,
    required this.icon,
    this.label,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _getContentColor(), size: 18),
            if (label != null) ...[
              const SizedBox(height: 0),
              Text(
                label!,
                style: TextStyle(color: _getContentColor(), fontSize: 8),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 根据按钮状态获取内容颜色（图标和文字）
  Color _getContentColor() {
    if (state == TabBarItemState.active) {
      return const Color(0xFF000000);
    }
    return const Color(0xD9000000);
  }

  /// 根据按钮状态获取背景色
  Color _getBackgroundColor() {
    if (state == TabBarItemState.active) {
      return const Color(0xFFEEEEEE);
    }
    return const Color(0x00000000);
  }
}
