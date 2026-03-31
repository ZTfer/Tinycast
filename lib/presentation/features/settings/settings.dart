import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/settings/settings_tab/settings_tab.dart';
import 'package:tinycast/presentation/features/settings/general_settings/general_settings.dart';
import 'package:tinycast/presentation/features/settings/play_settings/play_settings.dart';
import 'package:tinycast/presentation/features/settings/cloud_sync_settings/cloud_sync_settings.dart';
import 'package:tinycast/presentation/features/settings/cache_settings/cache_settings.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String _currentPage = 'generalSettings';

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
            padding: const EdgeInsets.only(
              top: 24,
              bottom: 24,
              left: 12,
              right: 12,
            ),
            alignment: Alignment.topLeft,
            child: _buildCurrentPage(),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'generalSettings':
        return const GeneralSettings();
      case 'playSettings':
        return const PlaySettings();
      case 'cloudSyncSettings':
        return const CloudSyncSettings();
      case 'cacheSettings':
        return const CacheSettings();
      default:
        return const SizedBox.shrink();
    }
  }
}
