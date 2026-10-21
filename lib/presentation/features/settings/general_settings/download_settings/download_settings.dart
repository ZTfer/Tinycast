import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/general_settings/download_settings/remove_played_downloads.dart';
import 'package:tinycast/presentation/features/settings/general_settings/download_settings/download_when_favorite.dart';

class DownloadSettings extends StatelessWidget {
  const DownloadSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4.0),
        const DownloadWhenFavorite(),
        const SizedBox(height: 4.0),
        const RemovePlayedDownloads(),
        const SizedBox(height: 12.0),
      ],
    );
  }
}
