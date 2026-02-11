import 'package:flutter/widgets.dart';
import 'queue_item.dart';

class UpNextQueue extends StatelessWidget {
  const UpNextQueue({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // queue item info
          const QueueItem(),
          const QueueItem(),
          const QueueItem(),
          const QueueItem(),
          const QueueItem(),
        ],
      ),
    );
  }
}
