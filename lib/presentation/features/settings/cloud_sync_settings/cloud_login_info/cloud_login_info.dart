import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/cloud_login_info/support_platform_list.dart';

class CloudLoginInfo extends StatelessWidget {
  const CloudLoginInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const Text(
          '登录账号',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Text(
          '登录账号后同步节目、播放进度，支持平台：',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0x4D000000),
          ),
        ),
        const SizedBox(height: 8),
        const SupportPlatformList(),
      ],
    );
  }
}
