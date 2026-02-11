import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Library 集数播放按钮
///
/// 用于 Library 列表中每集节目的播放按钮。
/// 参照 EpisodeControlButton 实现，支持悬停（Hover）和点击（Press）状态的视觉反馈。
class LibraryEpisodePlayButton extends StatefulWidget {
  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  const LibraryEpisodePlayButton({super.key, required this.onPressed});

  @override
  State<LibraryEpisodePlayButton> createState() =>
      _LibraryEpisodePlayButtonState();
}

class _LibraryEpisodePlayButtonState extends State<LibraryEpisodePlayButton> {
  /// 记录鼠标是否悬停在按钮上
  bool _isHovering = false;

  /// 记录按钮是否正在被按下
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
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: IconTheme(
            data: const IconThemeData(color: Color(0xD9000000), size: 12),
            child: const Icon(LucideIcons.play),
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  ///
  /// 根据当前状态返回对应的背景颜色：
  /// - 按下状态：深灰色 (0xFFE0E0E0)
  /// - 悬停状态：浅灰色 (0xFFF5F5F5)
  /// - 默认状态：透明 (0x00F5F5F5)
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }
}
