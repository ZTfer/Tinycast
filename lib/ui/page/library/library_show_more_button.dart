import 'package:flutter/widgets.dart';

class LibraryShowMoreButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final double iconSize;

  const LibraryShowMoreButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 12,
  });

  @override
  State<LibraryShowMoreButton> createState() => _LibraryShowMoreButtonState();
}

class _LibraryShowMoreButtonState extends State<LibraryShowMoreButton> {
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
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(50.0),
          ),
          child: IconTheme(
            data: IconThemeData(
              color: _getContentColor(),
              size: widget.iconSize,
            ),
            child: widget.icon,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }

  Color _getContentColor() {
    return const Color(0xD9000000);
  }
}
