import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_tabbar/subscribe_tabbar_button.dart';

class SubscribeTabbar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const SubscribeTabbar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Row(
            children: [
              _buildTabbarButton(
                icon: LucideIcons.listMusic,
                label: 'RSS',
                state: currentPage == 'rss'
                    ? SubscribeTabbarButtonState.iconActive
                    : SubscribeTabbarButtonState.defaultState,
                onPressed: () => onPageChanged('rss'),
              ),
              _buildTabbarButton(
                icon: LucideIcons.layoutGrid,
                label: 'OPML',
                state: currentPage == 'opml'
                    ? SubscribeTabbarButtonState.iconActive
                    : SubscribeTabbarButtonState.defaultState,
                onPressed: () => onPageChanged('opml'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabbarButton({
    required IconData icon,
    String? label,
    SubscribeTabbarButtonState state = SubscribeTabbarButtonState.defaultState,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SubscribeTabbarButton(
        icon: icon,
        label: label,
        state: state,
        onPressed: onPressed,
      ),
    );
  }
}
