import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/home/mobile_body.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/mini_player.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(child: MobileBody()),
      ],
    );
  }
}
