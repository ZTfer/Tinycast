import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_add_button.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_info.dart';

class SubscribeSearchListItem extends StatelessWidget {
  /// 剧集标题
  final String title;

  /// 播客名称
  final String podcastName;

  /// 添加按钮点击回调
  final VoidCallback onAddPressed;

  const SubscribeSearchListItem({
    super.key,
    required this.title,
    required this.podcastName,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SubscribeEpisodeInfo(title: title, podcastName: podcastName),
          ),
          SubscribeEpisodeAddButton(onPressed: onAddPressed),
        ],
      ),
    );
  }
}
