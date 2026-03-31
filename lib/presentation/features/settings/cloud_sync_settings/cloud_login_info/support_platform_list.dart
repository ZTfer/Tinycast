import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupportPlatformList extends StatelessWidget {
  const SupportPlatformList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        SvgPicture.asset('assets/icons/logo_apple.svg', width: 24, height: 24),
        SvgPicture.asset(
          'assets/icons/logo_android.svg',
          width: 24,
          height: 24,
        ),
        SvgPicture.asset(
          'assets/icons/logo_windows.svg',
          width: 24,
          height: 24,
        ),
        SvgPicture.asset('assets/icons/logo_linux.svg', width: 24, height: 24),
      ],
    );
  }
}
