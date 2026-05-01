import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/core/providers/auth_provider.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/cloud_login_info/cloud_login_info.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/social_login_button_group.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_success_page.dart';

class CloudSyncSettings extends ConsumerWidget {
  const CloudSyncSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              authState.when(
                data: (user) {
                  if (user != null) {
                    return const LoginSuccessPage();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: [CloudLoginInfo(), SocialLoginButtonGroup()],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => const Text('加载失败'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
