import 'package:flutter/widgets.dart';
import 'remove_played_downloads.dart';
import 'download_when_favorite.dart';

class DownloadSettings extends StatelessWidget {
  const DownloadSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '下载：',
          style: TextStyle(
            color: Color(0xD9000000),
            fontSize: 14,
            height: 16 / 14,
          ),
        ),
        const SizedBox(width: 8.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const DownloadWhenFavorite(),
            const RemovePlayedDownloads(),
          ],
        ),
      ],
    );
  }
}
