import 'package:flutter/widgets.dart';

class LibraryEmptyButton extends StatefulWidget {
  final String label;

  final VoidCallback onPressed;

  final Widget? icon;

  final double width;

  final double fontSize;

  final double horizontalPadding;

  final double verticalPadding;

  final double borderRadius;

  const LibraryEmptyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.width = 120,
    this.fontSize = 12,
    this.horizontalPadding = 16,
    this.verticalPadding = 8,
    this.borderRadius = 16,
  });

  @override
  State<LibraryEmptyButton> createState() => _LibraryEmptyButtonState();
}

class _LibraryEmptyButtonState extends State<LibraryEmptyButton> {
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
        child: SizedBox(
          width: widget.width,
          child: AnimatedContainer(
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _getContentColor(),
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.normal,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFDADADA);
    if (_isHovering) return const Color(0xFFE1E1E1);
    return const Color(0xFFEEEEEE);
  }

  Color _getContentColor() {
    return const Color(0xFF000000);
  }
}
