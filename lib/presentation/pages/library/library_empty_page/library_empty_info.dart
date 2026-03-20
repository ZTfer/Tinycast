import 'package:flutter/material.dart';

class LibraryEmptyInfo extends StatelessWidget {
  const LibraryEmptyInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        SizedBox(
          width: 120,
          height: 120,
          child: Icon(
            Icons.podcasts_outlined,
            size: 120,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 24),
        const Text('还没有订阅任何播客'),
        const Text('点击下方按钮订阅你喜欢的播客'),
      ],
    );
  }
}
