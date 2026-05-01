import 'package:flutter/widgets.dart';

class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [Text('您的账户：'), Text('用户名'), Text('your@example.com')],
    );
  }
}
