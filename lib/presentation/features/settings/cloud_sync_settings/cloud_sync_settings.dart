import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/core/services/local_account_data_service.dart';
import 'package:tinycast/core/services/supabase_auth_service.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/core/utils/toast_utils.dart';
import 'package:tinycast/data/services/cache_cleanup_service.dart';
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
    final confirmed = await _confirmSignOut(context);
    if (confirmed != true) return;

    try {
      await SupabaseAuthService().signOut();

      // 缓存清理依赖数据库中的下载状态，必须在清空数据库之前执行。
      try {
        await CacheCleanupService.instance.clearAllCache();
      } catch (e, stackTrace) {
        Logger.error(
          '退出登录时清理缓存失败',
          error: e,
          stackTrace: stackTrace,
        );
      }
      await LocalAccountDataService().clearForSignOut();

      if (context.mounted) {
        ToastUtils.showSuccessToast(context, message: '已退出登录并清除本地数据');
      }
    } catch (e) {
      if (context.mounted) {
        ToastUtils.showErrorToast(context, message: '退出登录失败，请重试');
      }
    }
  }

  Future<bool?> _confirmSignOut(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '退出登录会清除本机的播客、节目、收藏、播放历史与下载文件。'
                '云端数据不受影响，重新登录后会同步回来。',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 12,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(false),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        '取消',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(dialogContext).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF000000),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        '退出并清除',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
