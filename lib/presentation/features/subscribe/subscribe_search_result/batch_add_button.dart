import 'package:flutter/widgets.dart';

/// 批量添加按钮
///
/// 类似 SearchToolbarDeleteButton 样式，但不包含图标
/// 支持悬停（Hover）和点击（Press）状态的视觉反馈
class BatchAddButton extends StatefulWidget {
  /// 按钮右侧显示的文字
  final String label;

  /// 按钮点击的回调函数
  final VoidCallback? onPressed;

  /// 文字样式，可选。未提供时使用默认样式。
  final TextStyle? labelStyle;

  /// 文字大小，默认 10
  final double fontSize;

  /// 水平内边距，默认 8
  final double horizontalPadding;

  /// 垂直内边距，默认 4
  final double verticalPadding;

  /// 圆角大小，默认 10
  final double borderRadius;

  const BatchAddButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.labelStyle,
    this.fontSize = 10,
    this.horizontalPadding = 8,
    this.verticalPadding = 4,
    this.borderRadius = 10,
  });

  @override
  State<BatchAddButton> createState() => _BatchAddButtonState();
}

class _BatchAddButtonState extends State<BatchAddButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      color: _getContentColor(),
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                      height: 12 / widget.fontSize,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFDADADA);
    if (_isHovering) return const Color(0xFFE1E1E1);
    return const Color(0xFFFFFFFF);
  }

  Color _getContentColor() {
    return const Color(0xFF000000);
  }
}
