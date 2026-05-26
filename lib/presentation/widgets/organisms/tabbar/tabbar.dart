import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/core/router/app_routes.dart';
import 'package:tinycast/core/utils/logger.dart';
import 'package:tinycast/presentation/widgets/organisms/tabbar/tabbar_item.dart';

class TabBar extends StatelessWidget {
  final String currentPage;
  final Function(String) onPageChanged;
  final Color backgroundColor;

  const TabBar({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 60.0,
        color: backgroundColor,
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton(
                    icon: LucideIcons.listMusic,
                    label: 'Queue',
                    route: AppRoutes.queue,
                    state: currentPage == AppRoutes.queue
                        ? TabBarItemState.active
                        : TabBarItemState.defaultState,
                    onPressed: () => onPageChanged(AppRoutes.queue),
                  ),
                  _buildTabButton(
                    icon: LucideIcons.layoutGrid,
                    label: 'Library',
                    route: AppRoutes.library,
                    state: currentPage == AppRoutes.library
                        ? TabBarItemState.active
                        : TabBarItemState.defaultState,
                    onPressed: () => onPageChanged(AppRoutes.library),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, thickness: 0.5, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    String? route,
    TabBarItemState state = TabBarItemState.defaultState,
    required VoidCallback onPressed,
  }) {
    return TabBarItem(
      icon: icon,
      label: label,
      state: state,
      onPressed: () {
        Logger.info('📋 [TABBAR] Button clicked: $label');
        if (route != null) {
          Logger.info('📋 [TABBAR] Route: $route');
          Logger.info('📋 [TABBAR] Current page: $currentPage');
        }
        onPressed();
      },
    );
  }
}
