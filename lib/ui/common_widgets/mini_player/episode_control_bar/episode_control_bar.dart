import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_control_bar/episode_control_button.dart';
import 'package:tinycast/ui/common_widgets/mini_player/speed_dropdown/speed_dropdown.dart';

class EpisodeControlBar extends StatefulWidget {
  const EpisodeControlBar({super.key});

  @override
  State<EpisodeControlBar> createState() => _EpisodeControlBarState();
}

class _EpisodeControlBarState extends State<EpisodeControlBar> {
  final GlobalKey _speedButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;
  static OverlayEntry? _currentDropdownOverlay;

  void _showDropdown() {
    if (_currentDropdownOverlay != null) {
      _currentDropdownOverlay?.remove();
      _currentDropdownOverlay = null;
    }

    final RenderBox renderBox =
        _speedButtonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 110.0;
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
              child: SpeedDropdown(onItemSelected: _hideDropdown),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 播放速度控制按钮
          EpisodeControlButton(
            icon: const Icon(LucideIcons.gauge, size: 16),
            onPressed: _showDropdown,
            key: _speedButtonKey,
          ),
          Row(
            spacing: 40,
            children: [
              // 后退15秒按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipBack, size: 20),
                onPressed: () {},
              ),
              // 播放/暂停按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.play, size: 24),
                onPressed: () {},
              ),
              // 前进15秒按钮
              EpisodeControlButton(
                icon: const Icon(LucideIcons.skipForward, size: 20),
                onPressed: () {},
              ),
            ],
          ),
          // 音量控制按钮
          EpisodeControlButton(
            icon: const Icon(LucideIcons.volume2, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
