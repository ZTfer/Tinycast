import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/services/supabase_auth_service.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/cloud_login_info/cloud_login_info.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/social_login_button_group.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_success_page.dart';

class CloudSyncSettings extends ConsumerWidget {
  const CloudSyncSettings({super.key});

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await SupabaseAuthService().signInWithGoogle();
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, message: 'Google 登录失败，请重试');
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    try {
      await SupabaseAuthService().signOut();
      if (context.mounted) {
        ToastUtils.showSuccessToast(context, message: '已退出登录');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, message: '退出登录失败，请重试');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConfigured = ref.watch(supabaseConfiguredProvider);
    final authState = ref.watch(authStateProvider);

    return Row(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 2,
          children: [
            Image.asset(
              'assets/images/image_cloud_sync.png',
              width: 120,
              height: 80,
            ),
            Text('Cloud Sync'),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                if (!isConfigured)
                  const Text(
                    '未配置 Supabase。请通过 --dart-define=SUPABASE_URL 与 '
                    '--dart-define=SUPABASE_ANON_KEY 注入凭据后重启应用。',
                  )
                else
                  authState.when(
                    data: (user) {
                      if (user != null) {
                        return LoginSuccessPage(
                          user: user,
                          onSignOut: () => _handleSignOut(context),
                        );
                      }
                      return _buildLoginSection(context);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('加载失败: $error'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        CloudLoginInfo(),
        SocialLoginButtonGroup(onGoogleLogin: () => _handleSignIn(context)),
      ],
    );
  }
}
