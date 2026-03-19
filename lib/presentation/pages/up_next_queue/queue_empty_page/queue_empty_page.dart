import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_empty_page/queue_empty_info.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_empty_page/queue_empty_control_bar/queue_empty_control_bar.dart';
import 'package:tinycast/presentation/pages/up_next_queue/queue_empty_page/queue_empty_question_link.dart';

class QueueEmptyPage extends StatelessWidget {
  const QueueEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 18.0,
      children: [
        QueueEmptyInfo(),
        QueueEmptyControlBar(),
        QueueEmptyOpmlImportQuestionLink(),
      ],
    );
  }
}
