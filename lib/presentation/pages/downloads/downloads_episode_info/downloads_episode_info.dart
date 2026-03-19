import 'package:flutter/widgets.dart';

class DownloadsEpisodeInfo extends StatelessWidget {
  const DownloadsEpisodeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 通常左对齐更合适
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 封面图占位
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 40,
              height: 40,
              color: const Color(0xFFE0E0E0), // 灰色占位背景
              child: const Center(
                child: Text('Cover', style: TextStyle(fontSize: 8)),
              ),
              // 如果有真实图片，可以使用:
              // child: Image.network('url', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          // 标题和播客名称
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // 紧凑排列
              crossAxisAlignment: CrossAxisAlignment.start, // 左对齐
              children: const [
                Text(
                  'Episode Title',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2),
                Text(
                  'Podcast Name',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
