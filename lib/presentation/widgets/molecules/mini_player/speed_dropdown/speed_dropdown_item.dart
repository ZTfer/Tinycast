import 'package:flutter/material.dart';

class SpeedDropdownItem extends StatefulWidget {
  /// 按钮显示的图标（可选）
  final Widget? icon;

  /// 按钮显示的文字
  final String text;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 图标大小，默认 12
  final double iconSize;

  /// 内容颜色，默认 0xD9000000
  final Color contentColor;

  const SpeedDropdownItem({
    super.key,
    this.icon,
    required this.text,
    required this.onPressed,
    this.iconSize = 12,
    this.contentColor = const Color(0xD9000000),
  });

  @override
  State<SpeedDropdownItem> createState() => _SpeedDropdownItemState();
}

/// [SpeedDropdownItem] 的状态类
///
/// 管理按钮的交互状态，包括悬停和按下状态。
class _SpeedDropdownItemState extends State<SpeedDropdownItem> {
  /// 记录鼠标是否悬停在按钮上
  bool _isHovering = false;

  /// 记录按钮是否正在被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      /// 鼠标进入区域时，设置悬停状态为 true
      onEnter: (_) => setState(() => _isHovering = true),

      /// 鼠标离开区域时，设置悬停状态为 false
      onExit: (_) => setState(() => _isHovering = false),

      /// 设置鼠标指针样式为点击手势
      cursor: SystemMouseCursors.click,

      /// 手势检测器，用于处理点击事件
      child: GestureDetector(
        /// 按下时设置按下状态为 true
        onTapDown: (_) => setState(() => _isPressed = true),

        /// 抬起时设置按下状态为 false
        onTapUp: (_) => setState(() => _isPressed = false),

        /// 取消点击时设置按下状态为 false
        onTapCancel: () => setState(() => _isPressed = false),

        /// 点击时执行回调函数
        onTap: widget.onPressed,

        /// 动画容器，用于背景色过渡动画
        child: AnimatedContainer(
          /// 悬停时有 200ms 的动画时长，否则无动画
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,

          /// 内边距：水平 12，垂直 8
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),

          /// 背景装饰
          decoration: BoxDecoration(
            /// 根据状态动态获取背景颜色
            color: _getBackgroundColor(),

            /// 圆角半径 8
            borderRadius: BorderRadius.circular(6.0),
          ),

          /// 子组件：横向排列的图标和文字
          child: Row(
            /// 主轴尺寸最小，根据内容自适应
            mainAxisSize: MainAxisSize.min,

            /// 子组件列表
            children: [
              /// 图标或占位符
              if (widget.icon != null)
                /// 图标主题，统一设置图标颜色和大小
                IconTheme(
                  data: IconThemeData(
                    /// 根据状态动态获取内容颜色
                    color: _getContentColor(),

                    /// 使用配置的图标大小
                    size: widget.iconSize,
                  ),

                  /// 显示的图标
                  child: widget.icon!,
                )
              else
                /// 图标占位符，保持图标大小的空位置
                SizedBox(width: widget.iconSize, height: widget.iconSize),

              /// 图标和文字之间的间距 6
              const SizedBox(width: 6.0),

              /// 文字标签
              Text(
                /// 显示的文字内容
                widget.text,

                /// 文字样式
                style: TextStyle(
                  /// 根据状态动态获取内容颜色
                  color: _getContentColor(),
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,

                  /// 字体大小 14
                  fontSize: 12.0,
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
  /// 根据当前的交互状态返回对应的背景颜色：
  /// - 按下状态：深灰色 0xFFE0E0E0
  /// - 悬停状态：浅灰色 0xFFF5F5F5
  /// - 默认状态：透明 0x00F5F5F5
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }

  /// 获取内容颜色
  ///
  /// 返回配置的内容颜色，用于图标和文字的颜色。
  Color _getContentColor() {
    return widget.contentColor;
  }
}
