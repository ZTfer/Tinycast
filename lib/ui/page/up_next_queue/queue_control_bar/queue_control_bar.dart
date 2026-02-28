import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_control_bar/queue_more_button.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_episode_dropdown/queue_episode_dropdown.dart';

/// Queue 控制栏组件
///
/// 用于待播放队列列表项中的操作区域。
/// 包含播放按钮（带时长）和更多选项图标。
class QueueControlBar extends StatefulWidget {
  /// 节目时长（如 "32 min"）
  final String duration;

  const QueueControlBar({super.key, required this.duration});

  @override
  State<QueueControlBar> createState() => _QueueControlBarState();
}

class _QueueControlBarState extends State<QueueControlBar> {
  final GlobalKey _moreButtonKey = GlobalKey();
  OverlayEntry? _dropdownOverlay;

  void _showDropdown() {
    final RenderBox renderBox =
        _moreButtonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _dropdownOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 4,
        child: GestureDetector(
          onTap: _hideDropdown,
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: const QueueEpisodeDropdown(),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _hideDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  void dispose() {
    _dropdownOverlay?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListPlayButton(
          icon: const Icon(LucideIcons.play),
          label: widget.duration,
          onPressed: () {},
          iconSize: 10,
          fontSize: 10,
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
        ),
        const Spacer(),
        QueueMoreButton(
          key: _moreButtonKey,
          icon: const Icon(LucideIcons.moreHorizontal),
          onPressed: _showDropdown,
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
      ],
    );
  }
}
