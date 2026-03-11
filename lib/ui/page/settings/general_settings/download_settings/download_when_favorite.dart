import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/checkbox/label_checkbox.dart';

/// 收藏时自动下载
///
/// 当用户收藏了某个节目时，是否自动下载该节目。

class DownloadWhenFavorite extends StatefulWidget {
  const DownloadWhenFavorite({super.key});

  @override
  State<DownloadWhenFavorite> createState() => _DownloadWhenFavoriteState();
}

class _DownloadWhenFavoriteState extends State<DownloadWhenFavorite> {
  /// 自动下载收藏的节目
  bool _autoDownload = false;

  @override
  Widget build(BuildContext context) {
    return LabelCheckbox(
      value: _autoDownload,
      label: '自动下载',
      onChanged: (bool newValue) {
        setState(() {
          _autoDownload = newValue;
        });
      },
    );
  }
}