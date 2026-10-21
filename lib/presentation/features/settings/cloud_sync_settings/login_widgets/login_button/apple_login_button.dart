import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/login_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppleLoginButton extends StatelessWidget {
  const AppleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      text: 'Apple 登录',
      icon: SvgPicture.asset(
        'assets/icons/logo_apple.svg',
        width: 20,
        height: 20,
      ),
      onPressed: () {},
    );
  }
}
