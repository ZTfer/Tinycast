import 'package:flutter/widgets.dart';

/// 按钮组件
///
/// 包含图标和文字的按钮组件。
/// 支持悬停（Hover）和点击（Press）状态的视觉反馈。

class LoginButton extends StatefulWidget {
  /// 按钮显示的文字
  final String text;

  /// 按钮显示的图标（可选），可以是 Icon、Image、SvgPicture 等
  final Widget? icon;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 文字样式，可选。未提供时使用默认样式。
  final TextStyle? labelStyle;

  /// 文字大小，默认 12
  final double fontSize;

  /// 水平内边距，默认 16
  final double horizontalPadding;

  /// 垂直内边距，默认 6
  final double verticalPadding;

  /// 圆角大小，默认 16
  final double borderRadius;

  const LoginButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.labelStyle,
    this.fontSize = 12,
    this.horizontalPadding = 16,
    this.verticalPadding = 6,
    this.borderRadius = 16,
  });

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
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
          padding: EdgeInsets.symmetric(
            horizontal: widget.horizontalPadding,
            vertical: widget.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                SizedBox(
                  width: widget.fontSize,
                  height: widget.fontSize,
                  child: widget.icon,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.text,
                textAlign: TextAlign.center,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      color: _getContentColor(),
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                      height: 1.5,
                    ),
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

  /// 获取内容颜色（文字）
  ///
  /// 根据当前状态返回对应的内容颜色。
  /// 目前所有状态都返回黑色 (0xFF000000)。
  Color _getContentColor() {
    return const Color(0xFF000000);
  }
}
