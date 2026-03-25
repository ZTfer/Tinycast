import 'package:flutter/widgets.dart';
import 'show_info.dart';
import 'episodes_list.dart';

/// 播客详情页面
///
/// 显示播客的完整信息和节目列表，支持播放、下载、收藏等操作。

class PodcastDetail extends StatelessWidget {
  const PodcastDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShowInfo(),
        EpisodesList(),
      ],
    );
  }
}
