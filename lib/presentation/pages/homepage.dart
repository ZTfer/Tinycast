import 'package:flutter/material.dart';
import 'package:tinycast/presentation/widgets/molecules/home_toolbar/home_toolbar.dart';
import 'package:tinycast/presentation/widgets/molecules/mini_player/mini_player.dart';
import 'package:tinycast/presentation/pages/body.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          const HomeToolbar(),
          const MiniPlayer(),
          const SizedBox(height: 12),
          Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade300),
          const Expanded(child: Body()),
        ],
      ),
    );
  }
}
