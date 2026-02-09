import 'package:flutter/material.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/home_toolbar_button.dart';

class HomeToolbar extends StatelessWidget {
  const HomeToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HomeToolbarButton(
            icon: const Icon(Icons.home),
            label: 'Home',
            isSelected: true,
            onPressed: () {
              debugPrint('Home pressed');
            },
          ),
          const SizedBox(width: 8),
          HomeToolbarButton(
            icon: const Icon(Icons.search),
            label: 'Search',
            onPressed: () {
              debugPrint('Search pressed');
            },
          ),
          const SizedBox(width: 8),
          HomeToolbarButton(
            icon: const Icon(Icons.settings),
            label: 'Settings',
            onPressed: () {
              debugPrint('Settings pressed');
            },
          ),
        ],
      ),
    );
  }
}
