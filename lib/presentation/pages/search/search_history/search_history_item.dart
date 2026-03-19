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
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _isHovering
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.history, size: 14, color: Color(0x40000000)),

              const SizedBox(width: 6.0),
              Text(
                widget.historyKeyword,
                style: TextStyle(color: Color(0xD9000000), fontSize: 14.0),
              ),
              const Spacer(),
              Icon(
                LucideIcons.cornerDownLeft,
                size: 14,
                color: Color(0x40000000),
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
}
