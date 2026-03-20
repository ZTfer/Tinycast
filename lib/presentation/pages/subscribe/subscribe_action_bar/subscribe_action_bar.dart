import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/secondary_button.dart';
import 'package:tinycast/presentation/widgets/atoms/buttons/primary_button.dart';
import 'package:tinycast/presentation/providers/podcast_search_provider.dart';

/// 订阅操作栏组件
///
/// 包含取消和订阅两个按钮的操作栏。
/// 使用 Row 横向排列，居中对齐。
class SubscribeActionBar extends ConsumerWidget {
  /// 搜索回调函数
  final VoidCallback? onSearch;

  const SubscribeActionBar({
    super.key,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(podcastSearchProvider);
    final isLoading = searchState.status == PodcastSearchStatus.loading;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SecondaryButton(
          label: '取消',
          onPressed: () {
            debugPrint('Follow pressed');
            ref.read(podcastSearchProvider.notifier).reset();
          },
        ),
        const SizedBox(width: 12),
        PrimaryButton(
          label: '搜索',
          onPressed: isLoading ? () {} : () {
            debugPrint('Subscribe pressed');
            onSearch?.call();
          },
        ),
      ],
    );
  }
}
