import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchResultsShowItem extends StatefulWidget {
  /// 播客名称
  final String podcastName;

  /// 播客简介
  final String podcastDescription;

  /// 播客ID
  final String podcastId;

  /// 是否被选中
  final bool isSelected;

  /// 鼠标悬停回调
  final void Function(bool isHovering)? onHover;

  /// 按钮点击的回调函数
  final VoidCallback? onPressed;

  const SearchResultsShowItem({
    super.key,
    required this.podcastName,
    required this.podcastDescription,
    required this.podcastId,
    this.isSelected = false,
    this.onHover,
    this.onPressed,
  });

  @override
  State<SearchResultsShowItem> createState() => _SearchResultsShowItemState();
}

class _SearchResultsShowItemState extends State<SearchResultsShowItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        widget.onHover?.call(true);
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        widget.onHover?.call(false);
      },
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: _isHovering || widget.isSelected
              ? const Duration(milliseconds: 200)
              : Duration.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        width: 24,
                        height: 24,
                        color: const Color(0xFFE0E0E0),
                        child: const Center(
                          child: Text('Cover', style: TextStyle(fontSize: 8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.podcastName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                              height: 16 / 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '节目',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            widget.podcastDescription,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888888),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.cornerDownLeft,
                size: 14,
                color: const Color(0x40000000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (_isPressed) return const Color(0xFFE0E0E0);
    if (_isHovering || widget.isSelected) return const Color(0xFFF5F5F5);
    return const Color(0x00F5F5F5);
  }
}
