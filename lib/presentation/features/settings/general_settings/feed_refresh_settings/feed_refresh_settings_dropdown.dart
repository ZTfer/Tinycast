import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

class FeedRefreshSettingsDropdown extends StatelessWidget {
  final FeedRefreshInterval selectedInterval;
  final ValueChanged<FeedRefreshInterval> onIntervalSelected;
  final VoidCallback? onItemSelected;

  const FeedRefreshSettingsDropdown({
    super.key,
    required this.selectedInterval,
    required this.onIntervalSelected,
    this.onItemSelected,
  });

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 0.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.manual
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.manual),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.manual),
            ),
            const SizedBox(height: 2),
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.hourly
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.hourly),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.hourly),
            ),
            const SizedBox(height: 2),
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.every3h
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.every3h),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.every3h),
            ),
            const SizedBox(height: 2),
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.every6h
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.every6h),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.every6h),
            ),
            const SizedBox(height: 2),
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.every12h
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.every12h),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.every12h),
            ),
            const SizedBox(height: 2),
            DropdownItem(
              icon: selectedInterval == FeedRefreshInterval.daily
                  ? const Icon(LucideIcons.check)
                  : null,
              text: _getIntervalLabel(FeedRefreshInterval.daily),
              onPressed: () => _handleItemSelected(FeedRefreshInterval.daily),
            ),
          ],
        ),
      ),
    );
  }

  void _handleItemSelected(FeedRefreshInterval interval) {
    onIntervalSelected(interval);
    onItemSelected?.call();
  }
}
