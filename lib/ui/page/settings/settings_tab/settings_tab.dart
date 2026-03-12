import 'package:flutter/material.dart';
import 'package:tinycast/ui/page/settings/settings_tab/settings_tab_button.dart';

class SettingsTab extends StatelessWidget {
  final String currentPage;
  final ValueChanged<String> onPageChanged;

  const SettingsTab({
    super.key,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SettingsTabButton(
          icon: Icons.settings,
          label: '通用',
          state: currentPage == 'generalSettings'
              ? SettingsTabButtonState.iconActive
              : SettingsTabButtonState.defaultState,
          onPressed: () => onPageChanged('generalSettings'),
        ),
        SettingsTabButton(
          icon: Icons.play_circle,
          label: '播放',
          state: currentPage == 'playSettings'
              ? SettingsTabButtonState.iconActive
              : SettingsTabButtonState.defaultState,
          onPressed: () => onPageChanged('playSettings'),
        ),
      ],
    );
  }
}
