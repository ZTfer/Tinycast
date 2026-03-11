import 'package:flutter/widgets.dart';
import 'remove_played_downloads.dart';
import 'download_when_favorite.dart';

class DownloadSettings extends StatelessWidget {
  const DownloadSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [const DownloadWhenFavorite(), const RemovePlayedDownloads()],
    );
  }
}
