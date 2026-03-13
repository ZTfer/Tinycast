import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchHistoryItem extends StatefulWidget {
  final String historyKeyword;
  final VoidCallback? onPressed;

  const SearchHistoryItem({
    super.key,
    required this.historyKeyword,
    this.onPressed,
  });

  @override
  State<SearchHistoryItem> createState() => _SearchHistoryItemState();
}

class _SearchHistoryItemState extends State<SearchHistoryItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: widget.onPressed != null
            ? (_) => setState(() => _isPressed = true)
            : null,
        onTapUp: widget.onPressed != null
            ? (_) => setState(() => _isPressed = false)
            : null,
        onTapCancel: widget.onPressed != null
            ? () => setState(() => _isPressed = false)
            : null,
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(color: _getContentColor(), size: 12.0),
                child: const Icon(LucideIcons.history),
              ),
              const SizedBox(width: 6.0),
              Text(
                widget.historyKeyword,
                style: TextStyle(color: _getContentColor(), fontSize: 12.0),
              ),
              const Spacer(),
              IconTheme(
                data: IconThemeData(color: _getContentColor(), size: 12.0),
                child: const Icon(LucideIcons.cornerDownLeft),
              ),
            ],
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
    if (widget.onPressed != null) {
      return const Color(0xD9000000);
    }
    return const Color(0x40000000);
  }
}
