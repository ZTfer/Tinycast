import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_empty_page/queue_empty_page.dart';
import 'package:tinycast/ui/common_widgets/toast/vertical_icon_toast.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

// 用于测试的页面，不用于实际生产，测试写出来的widget样式是否正确的页面，不用于实际生产环境
class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          spacing: 12.0,
          children: [
            QueueEmptyPage(),
            VerticalIconToast(
              icon: Icon(LucideIcons.check, size: 36.0),
              text: '复制成功',
              textSize: 12,
            ),
          ],
        ),
      ),
    );
  }
}
