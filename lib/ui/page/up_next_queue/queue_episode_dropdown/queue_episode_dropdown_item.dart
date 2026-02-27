import 'package:flutter/widgets.dart';

/// 队列更多操作按钮
///
/// 用于待播放队列列表项中的图标+文字按钮（如更多选项、删除等）。
/// 参照 [EpisodeControlButton] 实现，支持悬停和点击状态的视觉反馈。
class QueueEpisodeDropdownItem extends StatefulWidget {
  /// 按钮显示的图标
  final Widget icon;

  /// 按钮显示的文字
  final String text;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 图标大小，默认 12
  final double iconSize;

  /// 内容颜色，默认 0xD9000000
  final Color contentColor;

  const QueueEpisodeDropdownItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.iconSize = 12,
    this.contentColor = const Color(0xD9000000),
  });

  @override
  State<QueueEpisodeDropdownItem> createState() =>
      _QueueEpisodeDropdownItemState();
}

class _QueueEpisodeDropdownItemState extends State<QueueEpisodeDropdownItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8.0),
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
              const SizedBox(width: 8.0),
              Text(
                widget.text,
                style: TextStyle(color: _getContentColor(), fontSize: 14.0),
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

  /// 获取内容颜色
  Color _getContentColor() {
    return widget.contentColor;
  }
}
