import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/home/body.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/mini_player.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MiniPlayer(),
        const SizedBox(height: 8),
        Expanded(child: Body()),
      ],
    );
  }
}
