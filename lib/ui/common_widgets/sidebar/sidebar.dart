import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/sidebar/sidebar_button.dart';

class Sidebar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;

  const Sidebar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 15),
          Expanded(
            child: Column(
              children: [
                _buildMenuButton(
                  icon: LucideIcons.listMusic,
                  state: currentPage == 'queue'
                      ? SidebarButtonState.iconActive
                      : SidebarButtonState.defaultState,
                  onPressed: () => onPageChanged('queue'),
                ),
                _buildMenuButton(
                  icon: LucideIcons.layoutGrid,
                  state: currentPage == 'library'
                      ? SidebarButtonState.iconActive
                      : SidebarButtonState.defaultState,
                  onPressed: () => onPageChanged('library'),
                ),
                _buildMenuButton(
                  icon: LucideIcons.star,
                  state: currentPage == 'favorite'
                      ? SidebarButtonState.iconActive
                      : SidebarButtonState.defaultState,
                  onPressed: () => onPageChanged('favorite'),
                ),
                _buildMenuButton(
                  icon: LucideIcons.download,
                  state: currentPage == 'downloads'
                      ? SidebarButtonState.iconActive
                      : SidebarButtonState.defaultState,
                  onPressed: () => onPageChanged('downloads'),
                ),
                _buildMenuButton(
                  icon: LucideIcons.plus,
                  onPressed: () => onPageChanged('subscribe'),
                ),
              ],
            ),
          ),
          _buildMenuButton(icon: LucideIcons.settings, onPressed: () {}),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    String? label,
    SidebarButtonState state = SidebarButtonState.defaultState,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SidebarButton(
        icon: icon,
        label: label,
        state: state,
        onPressed: onPressed,
      ),
    );
  }
}
