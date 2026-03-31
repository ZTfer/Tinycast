import 'package:flutter/material.dart';
import 'package:tinycast/presentation/widgets/organisms/home_toolbar/home_toolbar.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/mini_player.dart';
import 'package:tinycast/presentation/features/home/body.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
