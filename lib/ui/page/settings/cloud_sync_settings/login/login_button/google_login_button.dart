import 'package:flutter/widgets.dart';
import 'login_button.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class GoogleLoginButton extends StatelessWidget {
  const GoogleLoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LoginButton(
      text: 'Google 登录',
      icon: Image.asset('assets/icons/logo_google.png', width: 16, height: 16),
      onPressed: () {},
    );
  }
}
