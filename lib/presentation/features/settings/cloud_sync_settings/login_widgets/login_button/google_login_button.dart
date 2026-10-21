import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/login_button.dart';

class GoogleLoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleLoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      text: 'Google 登录',
      icon: Image.asset('assets/icons/logo_google.png', width: 20, height: 20),
      onPressed: onPressed,
    );
  }
}
