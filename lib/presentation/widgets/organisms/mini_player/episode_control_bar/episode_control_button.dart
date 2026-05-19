import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/theme/theme_data.dart';

/// 播放集控制按钮
///
/// 用于迷你播放器或播放详情页的控制栏按钮（如播放、暂停、上一曲、下一曲）。
/// 参照 HomeToolbarButton 实现，支持悬停（Hover）和点击（Press）状态的视觉反馈。
class EpisodeControlButton extends StatefulWidget {
  /// 按钮显示的图标
  final Widget icon;

  /// 按钮点击的回调函数
  final VoidCallback onPressed;

  /// 构造函数（接收任意 Widget 作为图标）
  const EpisodeControlButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  /// 构造函数（使用 SVG 资源作为图标）
  EpisodeControlButton.svg({
    super.key,
    required String svgPath,
    double size = 24,
    required this.onPressed,
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
  State<EpisodeControlButton> createState() => _EpisodeControlButtonState();
}

class _EpisodeControlButtonState extends State<EpisodeControlButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
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
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(theme),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: _getContentColor(theme),
              size: 24,
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(AppThemeData theme) {
    if (_isPressed) return theme.episodeControlButtonPressedBackground;
    if (_isHovering) return theme.episodeControlButtonHoverBackground;
    return theme.episodeControlButtonDefaultBackground;
  }

  Color _getContentColor(AppThemeData theme) {
    return theme.episodeControlButtonContentColor;
  }
}
