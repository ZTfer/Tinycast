import 'package:flutter/widgets.dart';

/// 侧边栏按钮的状态枚举
enum SidebarButtonState { iconActive, defaultState }

/// 侧边栏按钮组件
///
/// 用于在侧边栏中显示可点击的菜单按钮，支持图标和文字显示。
/// 包含悬停、按下和选中状态的视觉反馈。
class SidebarButton extends StatefulWidget {
  /// 按钮显示的图标
  final IconData icon;

  /// 按钮显示的文字标签
  final String? label;

  /// 按钮的当前状态
  final SidebarButtonState state;

  /// 按钮点击时的回调函数
  final VoidCallback onPressed;

  const SidebarButton({
    super.key,
    required this.icon,
    this.label,
    required this.state,
    required this.onPressed,
  });

  @override
  State<SidebarButton> createState() => _SidebarButtonState();
}

class _SidebarButtonState extends State<SidebarButton> {
  /// 鼠标是否悬停在按钮上
  bool _isHovering = false;

  /// 按钮是否被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    /// 使用 MouseRegion 监听鼠标悬停事件
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        /// 监听按钮按下事件
        onTapDown: (_) => setState(() => _isPressed = true),

        /// 监听按钮抬起事件
        onTapUp: (_) => setState(() => _isPressed = false),

        /// 监听按钮取消点击事件
        onTapCancel: () => setState(() => _isPressed = false),

        /// 监听按钮点击事件，触发回调
        onTap: widget.onPressed,
        child: AnimatedContainer(
          /// 悬停时显示动画效果
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,

          /// 固定按钮宽度
          width: 32.0,

          /// 内边距
          padding: const EdgeInsets.all(8.0),

          /// 容器装饰样式
          decoration: BoxDecoration(
            /// 背景色根据状态变化
            color: _getBackgroundColor(),

            /// 圆角
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            /// 主轴尺寸：最小，根据内容自适应
            mainAxisSize: MainAxisSize.min,
            children: [
              /// 图标部分
              IconTheme(
                data: IconThemeData(color: const Color(0xFF000000), size: 16),
                child: Icon(widget.icon),
              ),

              /// 文字标签部分
              if (widget.label != null) ...[
                const SizedBox(width: 6),
                Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Color(0xD9000000),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 根据按钮状态获取背景色
  ///
  /// 优先级：按下 > 悬停 > 选中 > 默认
  Color _getBackgroundColor() {
    /// 按下状态：深灰色
    if (_isPressed) return const Color(0xFFE0E0E0);

    /// 悬停状态：浅灰色
    if (_isHovering) return const Color(0xFFF5F5F5);

    /// 选中状态：中等灰色
    if (widget.state == SidebarButtonState.iconActive) {
      return const Color(0xFFEEEEEE);
    }

    /// 默认状态：透明
    return const Color(0x00F5F5F5);
  }
}
