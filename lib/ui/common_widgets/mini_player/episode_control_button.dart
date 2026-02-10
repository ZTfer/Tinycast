import 'package:flutter/widgets.dart';

/// 播放集控制按钮
///
/// 用于迷你播放器或播放详情页的控制栏按钮（如播放、暂停、上一曲、下一曲）。
/// 参照 HomeToolbarButton 实现，支持悬停（Hover）和点击（Press）状态的视觉反馈。
class EpisodeControlButton extends StatefulWidget {
  /// 按钮显示的图标
  final Widget icon;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 构造函数
  const EpisodeControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<EpisodeControlButton> createState() => _EpisodeControlButtonState();
}

class _EpisodeControlButtonState extends State<EpisodeControlButton> {
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
          padding: const EdgeInsets.all(8.0), // 稍微调大一点点击区域
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(50.0), // 圆形背景通常适合控制按钮
          ),
          child: IconTheme(
            data: IconThemeData(
              color: _getContentColor(),
              size: 24, // 默认大小，会被外部传入的 icon size 覆盖
            ),
            child: widget.icon,
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
    return const Color(0xFF000000);
  }
}
