import 'package:flutter/widgets.dart';

class SubscribeEpisodeInfo extends StatelessWidget {
  /// 剧集标题
  final String title;

  /// 播客名称
  final String podcastName;

  const SubscribeEpisodeInfo({
    super.key,
    required this.title,
    required this.podcastName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 40,
            height: 40,
            color: const Color(0xFFE0E0E0),
            child: const Center(
              child: Text('Cover', style: TextStyle(fontSize: 8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                podcastName,
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
