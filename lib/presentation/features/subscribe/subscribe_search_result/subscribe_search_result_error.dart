import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons_200.dart';

class SubscribeSearchResultError extends StatelessWidget {
  const SubscribeSearchResultError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons200.circleX,
            size: 36,
            color: Color(0xFFD9D9D9),
          ),
          const SizedBox(height: 12),
          const Text(
            '没有搜索到相关内容，请检查后重试',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
