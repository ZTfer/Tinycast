import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/general/download_settings/download_settings.dart';

class General extends StatelessWidget {
  const General({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const DownloadSettings(),
      ],
    );
  }
}