import 'package:flutter/widgets.dart';

enum SubscribeTabButtonState { iconActive, defaultState }

class SubscribeTabButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final SubscribeTabButtonState state;
  final VoidCallback onPressed;

  const SubscribeTabButton({
    super.key,
    required this.icon,
    this.label,
    required this.state,
    required this.onPressed,
  });

  @override
  State<SubscribeTabButton> createState() => _SubscribeTabButtonState();
}

class _SubscribeTabButtonState extends State<SubscribeTabButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isIconActive = widget.state == SubscribeTabButtonState.iconActive;
    final width = isIconActive ? 32.0 : 116.0;

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
          width: width,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: const Color(0xFF000000), size: 16),
                child: Icon(widget.icon),
              ),
              if (!isIconActive && widget.label != null) ...[
                const SizedBox(height: 6),
                Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Color(0xD9000000),
                    fontSize: 12,
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
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering) return const Color(0xFFF5F5F5);
    if (widget.state == SubscribeTabButtonState.iconActive) {
      return const Color(0xFFEEEEEE);
    }
    return const Color(0x00F5F5F5);
  }
}
