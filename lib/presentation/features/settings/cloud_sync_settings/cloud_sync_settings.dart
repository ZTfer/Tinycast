import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/cloud_login_info/cloud_login_info.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/login_widgets/login_button/social_login_button_group.dart';

class CloudSyncSettings extends StatelessWidget {
  const CloudSyncSettings({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: [CloudLoginInfo(), SocialLoginButtonGroup()],
          ),
        ),
      ],
    );
  }
}
