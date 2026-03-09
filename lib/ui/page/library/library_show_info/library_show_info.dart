import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/library/library_list_item/library_show_more_button.dart';
import 'package:tinycast/ui/page/library/library_show_dropdown/library_show_dropdown.dart';

class LibraryShowInfo extends StatefulWidget {
  final String showName;
  final String timeAgo;

  const LibraryShowInfo({
    super.key,
    required this.showName,
    required this.timeAgo,
  });

  @override
  State<LibraryShowInfo> createState() => _LibraryShowInfoState();
}

class _LibraryShowInfoState extends State<LibraryShowInfo> {
  final GlobalKey _moreButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown() {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox renderBox =
        _moreButtonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 150.0;
    const double estimatedMenuHeight = 230.0;

    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight - 4;
    }

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _hideDropdown,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: LibraryShowDropdown(onItemSelected: _hideDropdown),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
    _currentDropdownOverlay = _dropdownOverlay;
  }

  void _hideDropdown() {
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  void dispose() {
    if (_currentDropdownOverlay == _dropdownOverlay) {
      _currentDropdownOverlay = null;
    }

    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.showName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            LibraryShowMoreButton(
              key: _moreButtonKey,
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: _showDropdown,
            ),
          ],
        ),
        Text(
          widget.timeAgo,
          style: const TextStyle(fontSize: 10, color: Color(0xD9000000)),
        ),
      ],
    );
  }
}
