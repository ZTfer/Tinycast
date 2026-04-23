import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/atoms/checkbox/label_checkbox.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';

class RemovePlayedDownloads extends ConsumerWidget {
  const RemovePlayedDownloads({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider).settings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LabelCheckbox(
          value: settings.removePlayedDownloads,
          label: '自动删除已播放的下载',
          onChanged: (bool newValue) {
            ref.read(settingsProvider.notifier).updateRemovePlayedDownloads(newValue);
          },
        ),
        const SizedBox(height: 4.0),
        Row(
          children: const [
            SizedBox(width: 20.0),
            Text(
              '播放完24小时后移除下载',
              style: TextStyle(
                // Todo: 文字颜色后面需要修改
                color: Color(0x99000000),
                fontSize: 12,
                height: 16 / 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
