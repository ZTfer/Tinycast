import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginSuccessPage extends StatelessWidget {
  final User user;
  final VoidCallback onSignOut;

  const LoginSuccessPage({
    super.key,
    required this.user,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(fontSize: 12, color: Color(0x4D000000)),
        ),
        const SizedBox(height: 8),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: onSignOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
