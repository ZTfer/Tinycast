import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/cloud_login_info/cloud_login_info.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/login/login_button/social_login_button_group.dart';

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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [CloudLoginInfo(), SocialLoginButtonGroup()],
        ),
      ],
    );
  }
}
