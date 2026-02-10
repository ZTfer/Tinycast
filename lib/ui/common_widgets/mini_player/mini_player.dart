import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_control_bar.dart';
import 'package:tinycast/ui/common_widgets/mini_player/episode_info.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE), // 顶部边框，与主内容区分
            width: 1.0,
          ),
        ),
        color: Color(0xFFFFFFFF), // 背景色
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 自适应高度
        children: const [
          // 播放信息（封面、标题、播客名）
          Padding(padding: EdgeInsets.only(top: 8.0), child: EpisodeInfo()),

          // 播放控制栏（上一曲、播放/暂停、下一曲）
          EpisodeControlBar(),
        ],
      ),
    );
  }
}
