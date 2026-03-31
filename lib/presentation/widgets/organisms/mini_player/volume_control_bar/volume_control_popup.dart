import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/providers/playback_provider.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/volume_control_bar/volume_control_bar.dart';

class VolumeControlPopup extends ConsumerWidget {
  const VolumeControlPopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volume = ref.watch(volumeProvider);

    return VolumeControlBar(
      volume: (volume * 100).round(),
      onVolumeChanged: (value) {
        ref.read(playbackProvider.notifier).setVolume(value / 100.0);
      },
    );
  }
}
