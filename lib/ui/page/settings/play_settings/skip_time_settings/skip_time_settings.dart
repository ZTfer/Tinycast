import 'package:flutter/material.dart';
import 'package:tinycast/ui/page/settings/play_settings/skip_time_settings/skip_time_dropdown.dart';
import 'package:tinycast/ui/page/settings/settings_dropdown/settings_dropdown_button.dart';

class SkipTimeSettings extends StatefulWidget {
  const SkipTimeSettings({super.key});

  @override
  State<SkipTimeSettings> createState() => _SkipTimeSettingsState();
}

class _SkipTimeSettingsState extends State<SkipTimeSettings> {
  final GlobalKey _forwardButtonKey = GlobalKey();
  final GlobalKey _rewindButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown(GlobalKey buttonKey) {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 150.0;
    const double estimatedMenuHeight = 200.0;

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
              child: SkipTimeDropdown(onItemSelected: _hideDropdown),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            SettingsDropdownButton(
              key: _forwardButtonKey,
              label: '30 秒',
              onPressed: () => _showDropdown(_forwardButtonKey),
            ),
            const Text(
              '快进',
              style: TextStyle(
                color: Color(0xD9000000),
                fontSize: 14,
                height: 16 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SettingsDropdownButton(
              key: _rewindButtonKey,
              label: '15 秒',
              onPressed: () => _showDropdown(_rewindButtonKey),
            ),
            const Text(
              '快退',
              style: TextStyle(
                color: Color(0xD9000000),
                fontSize: 14,
                height: 16 / 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
