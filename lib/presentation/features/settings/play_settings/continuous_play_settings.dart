import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/radio/label_radio.dart';

/// 连续播放设置组件
///
/// 提供单集结束后的播放行为选择：
/// - 单集结束后继续播放：自动播放下一集
/// - 单集结束后停止：切换到下一集并暂停
///
/// 与 SettingsProvider 集成，实现设置的读取和保存。
class ContinuousPlaySettings extends ConsumerWidget {
  const ContinuousPlaySettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 从 SettingsProvider 读取当前设置
    final settingsState = ref.watch(settingsProvider);
    final continuousPlay = settingsState.value?.continuousPlay ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4.0),
        LabelRadio(
          value: continuousPlay,
          label: '单集结束后继续播放',
          onChanged: (bool newValue) {
            if (newValue) {
              // 保存连续播放设置
              ref.read(settingsProvider.notifier).updateContinuousPlay(true);
            }
          },
        ),
        const SizedBox(height: 4.0),
        LabelRadio(
          value: !continuousPlay,
          label: '单集结束后停止',
          onChanged: (bool newValue) {
            if (newValue) {
              // 保存连续播放设置
              ref.read(settingsProvider.notifier).updateContinuousPlay(false);
            }
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
