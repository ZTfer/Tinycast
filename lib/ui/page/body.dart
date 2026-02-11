import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/sidebar/sidebar.dart';
import 'package:tinycast/ui/page/up_next_queue/up_next_queue.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: const UpNextQueue(),
            ),
          ),
        ],
      ),
    );
  }
}
