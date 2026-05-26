import 'package:flutter/widgets.dart';

/// TabBar 按钮的状态枚举
enum TabBarItemState { active, defaultState }

/// TabBar 按钮组件
///
/// 用于在移动端底部 TabBar 中显示可点击的标签按钮，支持图标和文字显示。
/// 包含按下和选中状态的视觉反馈。
class TabBarItem extends StatefulWidget {
  /// 按钮显示的图标
  final IconData icon;

  /// 按钮显示的文字标签
  final String label;

  /// 按钮的当前状态
  final TabBarItemState state;

  /// 按钮点击时的回调函数
  final VoidCallback onPressed;

  const TabBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.state,
    required this.onPressed,
  });

  @override
  State<TabBarItem> createState() => _TabBarItemState();
}

class _TabBarItemState extends State<TabBarItem> {
  /// 按钮是否被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, color: _getIconColor(), size: 24),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(color: _getTextColor(), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据按钮状态获取背景色
  ///
  /// 优先级：按下 > 选中 > 默认
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (widget.state == TabBarItemState.active) {
      return const Color(0xFFEEEEEE);
    }
    return const Color(0x00000000);
  }

  /// 根据按钮状态获取图标颜色
  Color _getIconColor() {
    if (widget.state == TabBarItemState.active) {
      return const Color(0xFF000000);
    }
    return const Color(0xD9000000);
  }

  /// 根据按钮状态获取文字颜色
  Color _getTextColor() {
    if (widget.state == TabBarItemState.active) {
      return const Color(0xFF000000);
    }
    return const Color(0xD9000000);
  }
}
