import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/home/body.dart';
import 'package:tinycast/presentation/providers/navigation_provider.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/mini_player.dart';
import 'package:tinycast/presentation/widgets/organisms/tabbar/tabbar.dart';

class MobileHome extends ConsumerWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationState = ref.watch(navigationProvider);

    return Column(
      children: [
        MiniPlayer(),
        const SizedBox(height: 8),
        Expanded(
          child: Body(
            currentPage: navigationState.currentPage,
            onPageChanged: (page) {
              ref.read(navigationProvider.notifier).navigateToPage(page);
            },
          ),
        ),
        TabBar(
          currentPage: navigationState.currentPage,
          onPageChanged: (page) {
            ref.read(navigationProvider.notifier).navigateToPage(page);
          },
        ),
      ],
    );
  }
}
