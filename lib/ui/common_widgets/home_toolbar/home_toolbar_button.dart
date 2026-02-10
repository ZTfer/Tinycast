import 'package:flutter/widgets.dart';

/// 主页工具栏按钮
///
/// 一个自定义的 StatefulWidget，用于在主页工具栏上显示图标和可选的文本标签。
/// 支持悬停（Hover）、点击（Press）和选中（Selected）状态的视觉反馈。
class HomeToolbarButton extends StatefulWidget {
  /// 按钮显示的图标
  final Widget icon;

  /// 按钮下方的文本标签（可选）
  final String? label;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 按钮是否处于选中状态
  ///
  /// 选中状态下，按钮会显示特定的背景色和图标颜色。
  final bool isSelected;

  /// 构造函数
  const HomeToolbarButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.isSelected = false,
  });

  @override
  State<HomeToolbarButton> createState() => _HomeToolbarButtonState();
}

class _HomeToolbarButtonState extends State<HomeToolbarButton> {
  // 记录鼠标是否悬停在按钮上
  bool _isHovering = false;
  // 记录按钮是否正在被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 使用 MouseRegion 监听鼠标进入和退出事件，以处理悬停状态
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // 鼠标悬停时显示手型光标
      // 使用 GestureDetector 监听点击相关的事件
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        // 使用 AnimatedContainer 实现背景颜色的平滑过渡动画
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(), // 根据当前状态获取背景颜色
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 最小化高度以适应内容
            children: [
              // 图标部分
              // 使用 DefaultTextStyle 和 IconTheme 统一设置子组件的样式
              DefaultTextStyle(
                style: TextStyle(
                  color: _getContentColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: IconTheme(
                  data: IconThemeData(color: _getContentColor(), size: 24),
                  child: widget.icon,
                ),
              ),
              // 如果提供了标签，则显示文本
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: _getContentColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  ///
  /// 根据按钮的当前状态（按下、悬停、选中）返回对应的颜色。
  /// 优先级：按下 > 悬停 > 选中 > 默认（透明）。
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0); // 按下时的深灰色
    if (_isHovering) return const Color(0xFFF5F5F5); // 悬停时的浅灰色
    if (widget.isSelected) {
      return const Color(0xFFE3F2FD); // 选中时的浅蓝色
    }
    return const Color(0x00000000); // 默认透明背景
  }

  /// 获取内容（图标和文本）颜色
  ///
  /// 根据按钮的选中状态返回对应的颜色。
  Color _getContentColor() {
    if (widget.isSelected) return const Color(0xFF2196F3); // 选中时的蓝色
    return const Color(0xFF000000); // 默认黑色
  }
}
