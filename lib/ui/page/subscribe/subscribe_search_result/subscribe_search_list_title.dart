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
        // Todo: 如果结果只有一条，不展示全部关注按钮，如果结果大于1条，展示全部关注按钮
          Text(
            '全部关注',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
      ],
    );
  }
}
