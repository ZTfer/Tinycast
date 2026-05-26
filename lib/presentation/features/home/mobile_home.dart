import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/home/mobile_body.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      backgroundColor: const Color(0xFFF5F5F5),
      child: MobileBody(),
    );
  }
}
