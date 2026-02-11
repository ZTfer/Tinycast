import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/up_next_queue/atom_widgets/queue_more_button.dart';

class QueueControlBar extends StatelessWidget {
  const QueueControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListPlayButton(
          icon: const Icon(LucideIcons.play),
          label: 'Play',
          onPressed: () {},
        ),
        Spacer(),
        QueueMoreButton(
          icon: const Icon(LucideIcons.moreHorizontal),
          onPressed: () {},
        ),
      ],
    );
  }
}
