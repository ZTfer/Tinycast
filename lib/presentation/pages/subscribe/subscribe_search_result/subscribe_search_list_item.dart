import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_add_button.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_episode_info.dart';
import 'package:tinycast/domain/entities/podcast.dart';

class SubscribeSearchListItem extends StatelessWidget {
  /// 播客信息
  final Podcast podcast;

  /// 添加按钮点击回调
  final VoidCallback onAddPressed;

  const SubscribeSearchListItem({
    super.key,
    required this.podcast,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: SubscribeEpisodeInfo(podcast: podcast),
          ),
          SubscribeEpisodeAddButton(
            podcast: podcast,
            onPressed: onAddPressed,
          ),
        ],
      ),
    );
  }
}
