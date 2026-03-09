import 'package:flutter/widgets.dart';

class SubscribeSearchListTitle extends StatelessWidget {
  const SubscribeSearchListTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '搜索结果',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        // Todo：后期变为一个按钮，点击后执行批量关注操作
        Text(
          '全部关注',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
