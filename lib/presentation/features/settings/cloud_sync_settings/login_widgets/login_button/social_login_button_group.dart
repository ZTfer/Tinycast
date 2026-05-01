import 'package:flutter/widgets.dart';
// import 'apple_login_button.dart';
import 'google_login_button.dart';

class SocialLoginButtonGroup extends StatelessWidget {
  const SocialLoginButtonGroup({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        const Expanded(child: GoogleLoginButton()),
        // const Expanded(child: AppleLoginButton()),
      ],
    );
  }
}
