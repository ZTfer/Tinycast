import 'package:flutter/widgets.dart';

/// 剧集项骨架屏组件
///
/// 用于在加载剧集数据时显示占位符，提供更好的用户体验
class LibraryEpisodeItemSkeleton extends StatefulWidget {
  const LibraryEpisodeItemSkeleton({super.key});

  @override
  State<LibraryEpisodeItemSkeleton> createState() =>
      _LibraryEpisodeItemSkeletonState();
}

class _LibraryEpisodeItemSkeletonState
    extends State<LibraryEpisodeItemSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 标题骨架
            Expanded(
              child: Container(
                height: 11,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(0, 0, 0, 0.1 * _animation.value),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // 播放按钮骨架
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.1 * _animation.value),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}
