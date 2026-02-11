import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LibraryEpisodePlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const LibraryEpisodePlayButton({super.key, required this.onPressed});

  @override
  State<LibraryEpisodePlayButton> createState() =>
      _LibraryEpisodePlayButtonState();
}

class _LibraryEpisodePlayButtonState extends State<LibraryEpisodePlayButton> {
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
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: IconTheme(
            data: const IconThemeData(color: Color(0xD9000000), size: 12),
            child: const Icon(LucideIcons.play),
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
}
