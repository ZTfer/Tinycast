import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_control_bar/episode_control_bar.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_info.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_progress.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF), // 背景色
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 自适应高度
        children: [
          // 播放信息（封面、标题、播客名）
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: EpisodeInfo(),
          ),
          // 播放控制栏（上一曲、播放/暂停、下一曲）
          const EpisodeControlBar(),
          // 播放进度条（拖动调整播放位置）
          EpisodeProgress(
            position: const Duration(minutes: 3, seconds: 42),
            duration: const Duration(minutes: 45, seconds: 30),
            onSeek: (position) {
              // TODO: 接入实际的播放器 seek 逻辑
            },
          ),
        ],
      ),
    );
  }
}
