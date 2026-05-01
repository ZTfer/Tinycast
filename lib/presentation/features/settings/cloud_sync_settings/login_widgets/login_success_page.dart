import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/services/supabase_auth_service.dart';
import 'package:tinycast/core/utils/toast_utils.dart';

class LoginSuccessPage extends ConsumerWidget {
  const LoginSuccessPage({super.key});

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await SupabaseAuthService().signOut();
      if (context.mounted) {
        ToastUtils.showSuccessToast(
          context,
          message: '已退出登录',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(
          context,
          message: '退出登录失败，请重试',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Column(
        children: [Text('未找到用户信息')],
      );
    }

    final email = user.email ?? '未绑定邮箱';
    final displayName = user.userMetadata?['name'] as String? ?? email;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        const Text(
          '您的账户：',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Text(
          displayName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          email,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _handleSignOut(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('退出登录'),
        ),
      ],
    );
  }
}
