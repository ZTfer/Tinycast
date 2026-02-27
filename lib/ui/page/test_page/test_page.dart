import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_episode_dropdown/queue_episode_dropdown_item.dart';

// 用于测试的页面，不用于实际生产，测试写出来的widget样式是否正确的页面，不用于实际生产
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
// 这里放一个row组件，里面放一个queue_episode_dropdown_item组件
    return Row(
      children: [
        QueueEpisodeDropdownItem(
          icon: Icon(LucideIcons.copy),
          text: '拷贝链接',
          onPressed: () {},
        ),
      ],
    );
  }
}