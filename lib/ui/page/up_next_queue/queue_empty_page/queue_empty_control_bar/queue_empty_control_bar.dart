import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_empty_page/queue_empty_control_bar/queue_empty_button.dart';



class QueueEmptyControlBar extends StatelessWidget {
  const QueueEmptyControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        QueueEmptyButton(
          icon: Icon(LucideIcons.rss),
          label: 'RSS 订阅',
          onPressed: () {
            debugPrint('RSS 订阅 pressed');
          },
        ),
        QueueEmptyButton(
          icon: Icon(LucideIcons.import),
          label: '导入节目',
          onPressed: () {
            debugPrint('导入节目 pressed');
          },
        ),
      ],
    );
  }
}


