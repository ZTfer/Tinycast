import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_empty_page/queue_empty_page.dart';

// 用于测试的页面，不用于实际生产，测试写出来的widget样式是否正确的页面，不用于实际生产
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(spacing: 12.0, children: [QueueEmptyPage()]),
      ),
    );
  }
}
