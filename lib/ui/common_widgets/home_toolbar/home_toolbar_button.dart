import 'package:flutter/widgets.dart';

class HomeToolbarButton extends StatefulWidget {
  final Widget icon;
  final String? label;
  final VoidCallback onPressed;
  final bool isSelected;

  const HomeToolbarButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.isSelected = false,
  });

  @override
  State<HomeToolbarButton> createState() => _HomeToolbarButtonState();
}

class _HomeToolbarButtonState extends State<HomeToolbarButton> {
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon wrapper to control size/color if needed,
              // but for now we assume the widget passed is styled or we just display it.
              // If we want to enforce color:
              // IconTheme(data: IconThemeData(color: _getContentColor()), child: widget.icon),
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

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0); // Darker grey for press
    if (_isHovering) return const Color(0xFFF5F5F5); // Light grey for hover
    if (widget.isSelected) {
      return const Color(0xFFE3F2FD); // Light blue for selected
    }
    return const Color(0x00000000); // Transparent
  }

  Color _getContentColor() {
    if (widget.isSelected) return const Color(0xFF2196F3); // Blue for selected
    return const Color(0xFF000000); // Black normally
  }
}
