import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/core/theme/theme_data.dart';

class HomeToolbarButton extends StatefulWidget {
  final Widget? icon;
  final String? svgPath;
  final double svgSize;
  final String? label;
  final VoidCallback onPressed;

  const HomeToolbarButton({
    super.key,
    this.icon,
    required this.onPressed,
    this.label,
    this.svgPath,
    this.svgSize = 16,
  });

  HomeToolbarButton.svg({
    super.key,
    required String svgPath,
    double size = 16,
    required VoidCallback onPressed,
    String? label,
  }) : icon = null,
       svgPath = svgPath,
       svgSize = size,
       label = label,
       onPressed = onPressed;

  @override
  State<HomeToolbarButton> createState() => _HomeToolbarButtonState();
}

class _HomeToolbarButtonState extends State<HomeToolbarButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    final contentColor = _getContentColor(theme);

    Widget iconWidget;
    if (widget.svgPath != null) {
      iconWidget = SizedBox(
        width: widget.svgSize,
        height: widget.svgSize,
        child: SvgPicture.asset(
          widget.svgPath!,
          colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
        ),
      );
    } else {
      iconWidget = widget.icon!;
    }

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
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(theme),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextStyle(
                style: TextStyle(
                  color: contentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                child: IconTheme(
                  data: IconThemeData(color: contentColor, size: 24),
                  child: iconWidget,
                ),
              ),
              if (widget.label != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.label!,
                  style: TextStyle(
                    color: contentColor,
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

  Color _getBackgroundColor(AppThemeData theme) {
    if (_isPressed) return theme.homeToolbarButtonPressedBackground;
    if (_isHovering) return theme.homeToolbarButtonHoverBackground;
    return theme.homeToolbarButtonDefaultBackground;
  }

  Color _getContentColor(AppThemeData theme) {
    return theme.homeToolbarButtonContentColor;
  }
}
