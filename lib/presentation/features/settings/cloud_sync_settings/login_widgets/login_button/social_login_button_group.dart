import 'package:flutter/widgets.dart';
// import 'apple_login_button.dart';
import 'google_login_button.dart';

class SocialLoginButtonGroup extends StatelessWidget {
  final VoidCallback onGoogleLogin;

  const SocialLoginButtonGroup({super.key, required this.onGoogleLogin});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        Expanded(child: GoogleLoginButton(onPressed: onGoogleLogin)),
        // const Expanded(child: AppleLoginButton()),
      ],
    );
  }
}
