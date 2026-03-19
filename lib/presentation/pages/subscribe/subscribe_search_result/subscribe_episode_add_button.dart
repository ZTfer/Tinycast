import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SubscribeEpisodeAddButton extends StatefulWidget {
  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 图标大小，默认 16
  final double iconSize;

  /// 水平内边距，默认 4
  final double horizontalPadding;

  /// 垂直内边距，默认 4
  final double verticalPadding;

  /// 圆角大小，默认 16
  final double borderRadius;

  /// 按钮宽度，默认 28
  final double width;

  /// 按钮高度，默认 28
  final double height;

  const SubscribeEpisodeAddButton({
    super.key,
    required this.onPressed,
    this.iconSize = 16,
    this.horizontalPadding = 4,
    this.verticalPadding = 4,
    this.borderRadius = 16,
    this.width = 28,
    this.height = 28,
  });

  @override
  State<SubscribeEpisodeAddButton> createState() =>
      _SubscribeEpisodeAddButtonState();
}

class _SubscribeEpisodeAddButtonState extends State<SubscribeEpisodeAddButton> {
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
        child: SizedBox(
          /// 按钮宽度：28px
          width: widget.width,

          /// 按钮高度：28px
          height: widget.height,
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
            child: Icon(
              /// 默认状态为加号图标
              LucideIcons.plus,
              //Todo: 点击后切换为禁用状态的loading图标
              // LucideIcons.loader,
              //Todo: 执行结束后切换回加号图标
              /// 图标大小：16px
              size: widget.iconSize,
              color: _getContentColor(),
            ),
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  ///
  /// 根据当前状态返回对应的背景颜色：
  /// - 按下状态：浅灰色 (0xFF111111)
  /// - 悬停状态：浅灰色 (0xFF1C1C1C)
  /// - 默认状态：浅灰色 (0xFF1F1F1F)
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFF000000);
    if (_isHovering) return const Color(0xFF111111);
    return const Color(0xFF222222);
  }

  /// 获取内容颜色（图标）
  ///
  /// 根据当前状态返回对应的内容颜色。
  /// 目前所有状态都返回白色 (0xFFFFFFFF)。
  Color _getContentColor() {
    return const Color(0xFFFFFFFF);
  }
}
