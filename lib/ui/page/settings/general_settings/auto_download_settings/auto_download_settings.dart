import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/settings_dropdown/settings_dropdown.dart';

class AutoDownloadSettings extends StatelessWidget {
  const AutoDownloadSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SettingsDropdown(),
        const SizedBox(height: 4.0),
        const Text(
          '自动下载最新单集供离线收听',
          style: TextStyle(
            // Todo: 文字颜色后面需要修改
            color: Color.fromARGB(217, 160, 160, 160),
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}