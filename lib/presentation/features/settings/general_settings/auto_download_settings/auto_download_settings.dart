import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tinycast/presentation/features/settings/widgets/settings_dropdown_button.dart';
import 'package:tinycast/presentation/features/settings/general_settings/auto_download_settings/auto_download_settings_dropdown.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

class AutoDownloadSettings extends ConsumerWidget {
  const AutoDownloadSettings({super.key});

  String _getPolicyLabel(AutoDownloadPolicy policy) {
    return switch (policy) {
      AutoDownloadPolicy.off => '关闭',
      AutoDownloadPolicy.latest1 => '最新 1 集',
      AutoDownloadPolicy.latest2 => '最新 2 集',
      AutoDownloadPolicy.latest3 => '最新 3 集',
      AutoDownloadPolicy.latest5 => '最新 5 集',
      AutoDownloadPolicy.latest10 => '最新 10 集',
      AutoDownloadPolicy.past24h => '过去 24 小时',
      AutoDownloadPolicy.past7d => '过去 7 天',
      AutoDownloadPolicy.past14d => '过去 14 天',
      AutoDownloadPolicy.past30d => '过去 30 天',
      AutoDownloadPolicy.all => '所有单集',
    };
  }

  void _showDropdown(
    BuildContext context,
    GlobalKey buttonKey,
    AutoDownloadPolicy selectedPolicy,
    ValueChanged<AutoDownloadPolicy> onPolicySelected,
  ) {
    final RenderBox renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final Size screenSize = MediaQuery.of(context).size;

    const double estimatedMenuWidth = 200.0;
    const double estimatedMenuHeight = 220.0;

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
              child: AutoDownloadSettingsDropdown(
                selectedPolicy: selectedPolicy,
                onPolicySelected: (policy) {
                  onPolicySelected(policy);
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
    final settings = ref.watch(settingsProvider).settings;
    final buttonKey = GlobalKey();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SettingsDropdownButton(
          key: buttonKey,
          label: '每个节目${_getPolicyLabel(settings.autoDownloadPolicy)}',
          onPressed: () {
            _showDropdown(
              context,
              buttonKey,
              settings.autoDownloadPolicy,
              (policy) {
                ref.read(settingsProvider.notifier).updateAutoDownloadPolicy(policy);
              },
            );
          },
        ),
        const SizedBox(height: 4.0),
        const Text(
          '自动下载最新单集供离线收听',
          style: TextStyle(
            color: Color.fromARGB(217, 160, 160, 160),
            fontSize: 12,
            height: 16 / 12,
          ),
        ),
      ],
    );
  }
}
