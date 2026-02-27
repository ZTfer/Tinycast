import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/up_next_queue/atom_widgets/queue_more_button.dart';
// import 'package:tinycast/ui/page/up_next_queue/item_widgets/queue_episode_dropdown.dart';

/// Queue 控制栏组件
///
/// 用于待播放队列列表项中的操作区域。
/// 包含播放按钮（带时长）和更多选项图标。
class QueueControlBar extends StatelessWidget {
  /// 节目时长（如 "32 min"）
  final String duration;

  const QueueControlBar({super.key, required this.duration});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListPlayButton(
          icon: const Icon(LucideIcons.play),
          label: duration,
          onPressed: () {},
          iconSize: 10,
          fontSize: 10,
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
        ),
        Spacer(),
        QueueMoreButton(
          icon: const Icon(LucideIcons.moreHorizontal),
          onPressed: () {},
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
        // QueueEpisodeDropdown(
        //   icon: const Icon(LucideIcons.moreHorizontal),
        //   onSelected: (value) => {},
        // ),
      ],
    );
  }
}
