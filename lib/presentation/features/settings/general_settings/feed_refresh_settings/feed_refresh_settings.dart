import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/settings/widgets/settings_dropdown_button.dart';
import 'package:tinycast/presentation/features/settings/general_settings/feed_refresh_settings/feed_refresh_settings_dropdown.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/checkbox/label_checkbox.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

class FeedRefreshSettings extends ConsumerWidget {
  const FeedRefreshSettings({super.key});

  String _getIntervalLabel(FeedRefreshInterval interval) {
    return switch (interval) {
      FeedRefreshInterval.manual => '手动',
      FeedRefreshInterval.hourly => '每 1 小时',
      FeedRefreshInterval.every3h => '每 3 小时',
      FeedRefreshInterval.every6h => '每 6 小时',
      FeedRefreshInterval.every12h => '每 12 小时',
      FeedRefreshInterval.daily => '每 24 小时',
    };
  }

  void _showDropdown(
    BuildContext context,
    GlobalKey buttonKey,
    FeedRefreshInterval selectedInterval,
    ValueChanged<FeedRefreshInterval> onIntervalSelected,
  ) {
    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 160.0;
    const double estimatedMenuHeight = 240.0;

    double left = offset.dx;
    double top = offset.dy + size.height + 4;

    if (left + estimatedMenuWidth > screenSize.width) {
      left = screenSize.width - estimatedMenuWidth - 8;
    }

    if (top + estimatedMenuHeight > screenSize.height) {
      top = offset.dy - estimatedMenuHeight + 140;
    }

    OverlayEntry? dropdownOverlay;
    dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                dropdownOverlay?.remove();
              },
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: FeedRefreshSettingsDropdown(
                selectedInterval: selectedInterval,
                onIntervalSelected: (interval) {
                  onIntervalSelected(interval);
                  dropdownOverlay?.remove();
                },
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(dropdownOverlay);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settings = settingsState.value ?? const AppSettings();
    final buttonKey = GlobalKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsDropdownButton(
          key: buttonKey,
          label: _getIntervalLabel(settings.feedRefreshInterval),
          onPressed: () {
            _showDropdown(
              context,
              buttonKey,
              settings.feedRefreshInterval,
              (interval) {
                ref.read(settingsProvider.notifier).updateFeedRefreshInterval(interval);
              },
            );
          },
        ),
        const SizedBox(height: 12.0),
        LabelCheckbox(
          value: !settings.refreshOnCellular,
          label: '仅 WiFi 刷新',
          onChanged: (bool newValue) {
            ref.read(settingsProvider.notifier).updateRefreshOnCellular(!newValue);
          },
        ),
        const SizedBox(height: 12.0),
        LabelCheckbox(
          value: settings.notifyOnNewEpisodes,
          label: '刷新通知',
          onChanged: (bool newValue) {
            ref.read(settingsProvider.notifier).updateNotifyOnNewEpisodes(newValue);
          },
        ),
        const SizedBox(height: 12.0),
        LabelCheckbox(
          value: settings.backgroundRefreshEnabled,
          label: '后台刷新',
          onChanged: (bool newValue) {
            ref.read(settingsProvider.notifier).updateBackgroundRefreshEnabled(newValue);
          },
        ),
      ],
    );
  }
}
