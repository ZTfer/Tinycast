import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/organisms/sidebar/sidebar_button.dart';
import 'package:tinycast/core/router/app_router.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/core/utils/logger.dart';

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
      width: 56.5,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              const SizedBox(height: 15),
              Expanded(
                child: Column(
                  children: [
                    _buildMenuButton(
                      icon: LucideIcons.listMusic,
                      // label: 'Queue',
                      route: AppRoutes.queue,
                      state: currentPage == AppRoutes.queue
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.queue),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.layoutGrid,
                      // label: 'Library',
                      route: AppRoutes.library,
                      state: currentPage == AppRoutes.library
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.library),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.history,
                      // label: 'History',
                      route: AppRoutes.favorite,
                      state: currentPage == AppRoutes.favorite
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.favorite),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.star,
                      // label: 'Favorite',
                      route: AppRoutes.favorite,
                      state: currentPage == AppRoutes.favorite
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.favorite),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.download,
                      // label: 'Downloads',
                      route: AppRoutes.downloads,
                      state: currentPage == AppRoutes.downloads
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.downloads),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.plus,
                      // label: 'Subscribe',
                      route: AppRoutes.subscribe,
                      state: currentPage == AppRoutes.subscribe
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.subscribe),
                    ),
                    _buildMenuButton(
                      icon: LucideIcons.flaskConical,
                      // label: 'Test Page',
                      route: AppRoutes.testPage,
                      state: currentPage == AppRoutes.testPage
                          ? SidebarButtonState.iconActive
                          : SidebarButtonState.defaultState,
                      onPressed: () => onPageChanged(AppRoutes.testPage),
                    ),
                  ],
                ),
              ),
              _buildMenuButton(
                icon: LucideIcons.settings,
                // label: 'Settings',
                route: AppRoutes.settings,
                state: currentPage == AppRoutes.settings
                    ? SidebarButtonState.iconActive
                    : SidebarButtonState.defaultState,
                onPressed: () => AppRouter.openSettingsWindow(),
              ),
              const SizedBox(height: 10),
            ],
          ),
          VerticalDivider(
            width: 0.5,
            thickness: 0.5,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    String? label,
    String? route,
    SidebarButtonState state = SidebarButtonState.defaultState,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: SidebarButton(
        icon: icon,
        label: label,
        state: state,
        onPressed: () {
          Logger.info('📋 [SIDEBAR] Button clicked: ${label ?? 'Unknown'}');
          if (route != null) {
            Logger.info('📋 [SIDEBAR] Route: $route');
            Logger.info('📋 [SIDEBAR] Current page: $currentPage');
          }
          onPressed();
        },
      ),
    );
  }
}
