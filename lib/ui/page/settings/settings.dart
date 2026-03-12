import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/settings/settings_tab/settings_tab.dart';
import 'package:tinycast/ui/page/settings/general_settings/general_settings.dart';
import 'package:tinycast/ui/page/settings/play_settings/play_settings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _currentPage = 'general';

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingsTab(currentPage: _currentPage, onPageChanged: _navigateToPage),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topLeft,
            child: _buildCurrentPage(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'general':
        return const GeneralSettings();
      case 'playSettings':
        return const PlaySettings();
      default:
        return const SizedBox.shrink();
    }
  }
}
