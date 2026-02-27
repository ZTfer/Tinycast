import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_episode_dropdown/queue_episode_dropdown.dart';
import 'package:tinycast/ui/common_widgets/mini_player/speed_dropdown/speed_dropdown.dart';

// 用于测试的页面，不用于实际生产，测试写出来的widget样式是否正确的页面，不用于实际生产
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 12.0,
        children: [QueueEpisodeDropdown(), SpeedDropdown()],
      ),
    );
  }
}
