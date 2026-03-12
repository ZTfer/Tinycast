import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupportPlatformList extends StatelessWidget {
  const SupportPlatformList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/images/icon_apple.svg', width: 24, height: 24),
        SvgPicture.asset(
          'assets/images/icon_android.svg',
          width: 24,
          height: 24,
        ),
        SvgPicture.asset(
          'assets/images/icon_windows.svg',
          width: 24,
          height: 24,
        ),
        SvgPicture.asset('assets/images/icon_linux.svg', width: 24, height: 24),
      ],
    );
  }
}
