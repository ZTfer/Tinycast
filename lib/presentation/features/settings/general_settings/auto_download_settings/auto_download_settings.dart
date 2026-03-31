import 'package:flutter/material.dart';
import 'package:tinycast/presentation/features/settings/settings_dropdown/settings_dropdown_button.dart';
import 'package:tinycast/presentation/features/settings/general_settings/auto_download_settings/auto_download_settings_dropdown.dart';

class AutoDownloadSettings extends StatefulWidget {
  const AutoDownloadSettings({super.key});

  @override
  State<AutoDownloadSettings> createState() => _AutoDownloadSettingsState();
}

class _AutoDownloadSettingsState extends State<AutoDownloadSettings> {
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown() {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 200.0;
    const double estimatedMenuHeight = 400.0;

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
              child: AutoDownloadSettingsDropdown(
                onItemSelected: _hideDropdown,
              ),
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
        SettingsDropdownButton(
          key: _buttonKey,
          label: '每个节目最新 3 集',
          onPressed: _showDropdown,
        ),
        const SizedBox(height: 4.0),
        const Text(
          '自动下载最新单集供离线收听',
          style: TextStyle(
            color: Color.fromARGB(217, 160, 160, 160),
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}
