import 'package:flutter/widgets.dart';

class CloudSyncSettings extends StatelessWidget {
  const CloudSyncSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/images/image_cloud_sync.png', // 路径需与 pubspec.yaml 中一致
          width: 120,
          height: 80,
        ),
        Text('云同步'),
      ],
    );
  }
}
