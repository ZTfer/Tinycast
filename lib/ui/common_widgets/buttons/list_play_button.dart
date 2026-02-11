import 'package:flutter/widgets.dart';

/// 列表播放按钮
///
/// 包含左侧图标和右侧文字的按钮组件。
/// 支持悬停（Hover）和点击（Press）状态的视觉反馈，
/// 参照 [EpisodeControlButton] 实现交互逻辑。
class ListPlayButton extends StatefulWidget {
  /// 按钮左侧显示的图标
  final Widget icon;

  /// 按钮右侧显示的文字
  final String label;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 文字样式，可选。未提供时使用默认样式。
  final TextStyle? labelStyle;

  /// 图标与文字之间的间距，默认 6.0
  final double spacing;

  /// 图标大小，默认 10
  final double iconSize;

  /// 文字大小，默认 10
  final double fontSize;

  /// 水平内边距，默认 8
  final double horizontalPadding;

  /// 垂直内边距，默认 4
  final double verticalPadding;

  /// 圆角大小，默认 10
  final double borderRadius;

  const ListPlayButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.labelStyle,
    this.spacing = 6.0,
    this.iconSize = 10,
    this.fontSize = 10,
    this.horizontalPadding = 8,
    this.verticalPadding = 4,
    this.borderRadius = 10,
  });

  @override
  State<ListPlayButton> createState() => _ListPlayButtonState();
}

class _ListPlayButtonState extends State<ListPlayButton> {
  // 记录鼠标是否悬停在按钮上
  bool _isHovering = false;
  // 记录按钮是否正在被按下
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
            children: [
              IconTheme(
                data: IconThemeData(
                  color: _getContentColor(),
                  size: widget.iconSize,
                ),
                child: widget.icon,
              ),
              SizedBox(width: widget.spacing),
              Text(
                widget.label,
                style:
                    widget.labelStyle ??
                    TextStyle(
                      color: _getContentColor(),
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }

  /// 获取内容颜色（图标 + 文字）
  Color _getContentColor() {
    return const Color(0xFF000000);
  }
}
