import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/services/supabase_auth_service.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'login_button.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class GoogleLoginButton extends ConsumerWidget {
  const GoogleLoginButton({super.key});

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await SupabaseAuthService().signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
          context,
          message: '登录失败，请重试',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoginButton(
      text: 'Google 登录',
      icon: Image.asset('assets/icons/logo_google.png', width: 20, height: 20),
      onPressed: () => _handleSignIn(context),
    );
  }
}
