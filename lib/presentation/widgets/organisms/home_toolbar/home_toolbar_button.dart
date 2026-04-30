import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 主页工具栏按钮
///
/// 一个自定义的 StatefulWidget，用于在主页工具栏上显示图标和可选的文本标签。
/// 支持悬停（Hover）、点击（Press）和选中（Selected）状态的视觉反馈。
class HomeToolbarButton extends StatefulWidget {
  /// 按钮显示的图标
  final Widget icon;

  /// 按钮下方的文本标签（可选）
  final String? label;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 构造函数（接收任意 Widget 作为图标）
  const HomeToolbarButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  /// 构造函数（使用 SVG 资源作为图标）
  HomeToolbarButton.svg({
    super.key,
    required String svgPath,
    double size = 16,
    required this.onPressed,
    this.label,
  }) : icon = SizedBox(
         width: size,
         height: size,
         child: SvgPicture.asset(
           svgPath,
           colorFilter: const ColorFilter.mode(
             Color(0xFF000000),
             BlendMode.srcIn,
           ),
         ),
       );

  @override
  State<HomeToolbarButton> createState() => _HomeToolbarButtonState();
}

class _HomeToolbarButtonState extends State<HomeToolbarButton> {
  // 记录鼠标是否悬停在按钮上
  bool _isHovering = false;
  // 记录按钮是否正在被按下
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 使用 MouseRegion 监听鼠标进入和退出事件，以处理悬停状态
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, // 鼠标悬停时显示手型光标
      // 使用 GestureDetector 监听点击相关的事件
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        // 使用 AnimatedContainer 实现背景颜色的平滑过渡动画
        child: AnimatedContainer(
          // 移入时显示动画(200ms)，移出时立即恢复(0ms)，避免拖泥带水的感觉
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(), // 根据当前状态获取背景颜色
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 最小化高度以适应内容
            children: [
              // 图标部分
              // 使用 DefaultTextStyle 和 IconTheme 统一设置子组件的样式
              DefaultTextStyle(
                style: TextStyle(
                  color: _getContentColor(),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: IconTheme(
                  data: IconThemeData(color: _getContentColor(), size: 24),
                  child: widget.icon,
                ),
              ),
              // 如果提供了标签，则显示文本
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: _getContentColor(),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 获取按钮背景颜色
  ///
  /// 根据按钮的当前状态（按下、悬停）返回对应的颜色。
  /// 优先级：按下 > 悬停 > 默认（透明）。
  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0); // 按下时的深灰色
    if (_isHovering) return const Color(0xFFF5F5F5); // 悬停时的浅灰色
    // 使用与悬停色相同的RGB值但透明度为0，避免插值计算时经过黑色(0x00000000)导致的闪烁问题
    return const Color(0x00F5F5F5);
  }

  /// 获取内容（图标和文本）颜色
  Color _getContentColor() {
    return const Color(0xFF000000); // 默认黑色
  }
}
