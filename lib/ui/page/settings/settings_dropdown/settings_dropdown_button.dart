import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 按钮组件
///
/// 包含文字和图标的按钮组件。
/// 支持悬停（Hover）和点击（Press）状态的视觉反馈。

class SettingsDropdownButton extends StatefulWidget {
  /// 按钮显示的文字
  final String label;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  const SettingsDropdownButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  State<SettingsDropdownButton> createState() =>
      _SettingsDropdownButtonState();
}

class _SettingsDropdownButtonState
    extends State<SettingsDropdownButton> {
  // 记录鼠标是否悬停在按钮上
  bool _isHovering = false;
  // 记录按钮是否正在被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      /// 鼠标进入时设置悬停状态
      onEnter: (_) => setState(() => _isHovering = true),

      /// 鼠标离开时取消悬停状态
      onExit: (_) => setState(() => _isHovering = false),

      /// 设置鼠标样式为点击手势
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        /// 按下时设置按下状态
        onTapDown: (_) => setState(() => _isPressed = true),

        /// 抬起时取消按下状态
        onTapUp: (_) => setState(() => _isPressed = false),

        /// 取消点击时取消按下状态
        onTapCancel: () => setState(() => _isPressed = false),

        /// 触发点击回调
        onTap: widget.onPressed,
        child: AnimatedContainer(
          /// 悬停时使用 200ms 动画，离开时立即切换（避免闪烁）
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Color(0xD9000000),
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  height: 16 / 14,
                ),
              ),
              const SizedBox(width: 6.0),
              Icon(
                LucideIcons.chevronDown,
                size: 14,
                color: const Color(0xD9000000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  ///
  /// 根据当前状态返回对应的背景颜色：
  /// - 按下状态：浅灰色 (0xFFDADADA)
  /// - 悬停状态：浅灰色 (0xFFE1E1E1)
  /// - 默认状态：浅灰色 (0xFFEEEEEE)
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFDADADA);
    if (_isHovering) return const Color(0xFFE1E1E1);
    return const Color(0xFFEEEEEE);
  }
}
