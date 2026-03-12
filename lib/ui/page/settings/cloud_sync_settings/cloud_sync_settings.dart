import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/cloud_sync_settings/cloud_login_info/cloud_login_info.dart';

class CloudSyncSettings extends StatelessWidget {
  const CloudSyncSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
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
        const CloudLoginInfo(),
      ],
    );
  }
}
