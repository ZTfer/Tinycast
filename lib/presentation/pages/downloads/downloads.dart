import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/pages/downloads/downloads_list_item/downloads_list_item.dart';

class Downloads extends StatelessWidget {
  const Downloads({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          DownloadsItem(
            timeAgo: '1 h ago',
            title: '标题文字标题文字',
            description:
                '介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍文字介绍',
            duration: '32 min',
          ),
          DownloadsItem(
            timeAgo: '2 h ago',
            title: '更新标题更新标题',
            description: '这是一个更新的介绍文本，用于说明最近的变化和进展。这是一个更新的介绍文本，用于说明最近的变化和进展。',
            duration: '45 min',
          ),
          DownloadsItem(
            timeAgo: '3 h ago',
            title: '新功能介绍新功能',
            description:
                '这个模块介绍了我们的新功能，帮助用户更好地使用我们的产品。这是一个关于新功能的详细介绍，充满了亮点和好处。',
            duration: '1 h',
          ),
          DownloadsItem(
            timeAgo: '4 h ago',
            title: '用户反馈总结',
            description: '我们收到了很多用户的反馈，以下是总结和建议。这是一个关于用户反馈的详细总结，帮助我们改进产品。',
            duration: '30 min',
          ),
          DownloadsItem(
            timeAgo: '5 h ago',
            title: '产品更新日志',
            description: '本次更新包括多个重要修复和性能提升，确保用户体验更佳。产品更新日志详细列出了所有的变更和修复。',
            duration: '1.5 h',
          ),
          DownloadsItem(
            timeAgo: '6 h ago',
            title: '即将发布的功能预览',
            description: '我们即将发布的新功能将极大提升用户体验，敬请期待！这是对即将到来的功能的预览，激动人心的变化即将来临。',
            duration: '2 h',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}
