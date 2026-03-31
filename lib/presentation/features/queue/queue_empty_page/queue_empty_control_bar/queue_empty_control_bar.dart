import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/features/queue/queue_empty_page/queue_empty_control_bar/queue_empty_button.dart';

class QueueEmptyControlBar extends StatelessWidget {
  const QueueEmptyControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        QueueEmptyButton(
          icon: Icon(LucideIcons.rss, size: 16),
          label: 'RSS 订阅',
          onPressed: () {
            debugPrint('RSS 订阅 pressed');
          },
        ),
        QueueEmptyButton(
          icon: Icon(LucideIcons.import, size: 16),
          label: '导入节目',
          onPressed: () {
            debugPrint('导入节目 pressed');
          },
        ),
      ],
    );
  }
}
