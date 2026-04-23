import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/atoms/checkbox/label_checkbox.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';

/// 收藏时自动下载
///
/// 当用户收藏了某个节目时，是否自动下载该节目。

class DownloadWhenFavorite extends ConsumerWidget {
  const DownloadWhenFavorite({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).settings;

    return LabelCheckbox(
      value: settings.downloadOnFavorite,
      label: '收藏时下载',
      onChanged: (bool newValue) {
        ref.read(settingsProvider.notifier).updateDownloadOnFavorite(newValue);
      },
    );
  }
}
