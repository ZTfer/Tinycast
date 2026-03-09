import 'package:flutter/widgets.dart';

class SubscribeSearchListTitle extends StatelessWidget {
  const SubscribeSearchListTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '搜索结果',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(width: 12),
        Text(
          '全部关注',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
