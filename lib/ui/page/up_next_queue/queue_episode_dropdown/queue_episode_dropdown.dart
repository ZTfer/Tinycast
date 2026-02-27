import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/page/up_next_queue/queue_episode_dropdown/queue_episode_dropdown_item.dart';

/// 队列剧集下拉菜单
///
/// 显示剧集操作选项的纵向列表菜单。
/// 包含：拷贝链接、收藏、分享、插播、标记为已播放、移除下载、从待播清单移除。
class QueueEpisodeDropdown extends StatelessWidget {
  const QueueEpisodeDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: Colors.grey.shade300, // 边框颜色
          width: 0.5, // 边框宽度
          style: BorderStyle.solid, // 实线
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.copy),
            text: '拷贝链接',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.heart),
            text: '收藏',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.share2),
            text: '分享',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.listStart),
            text: '插播',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.checkCircle),
            text: '标记为已播放',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.trash2),
            text: '移除下载',
            onPressed: () {},
          ),
          QueueEpisodeDropdownItem(
            icon: Icon(LucideIcons.x),
            text: '从待播清单移除',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
