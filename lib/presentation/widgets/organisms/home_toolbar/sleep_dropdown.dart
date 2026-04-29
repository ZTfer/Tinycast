import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/providers/settings_provider.dart';
import 'package:tinycast/presentation/widgets/atoms/dropdown_item/dropdown_item.dart';
import 'package:tinycast/domain/entities/app_settings.dart';

class SleepDropdown extends ConsumerWidget {
  final VoidCallback? onItemSelected;

  const SleepDropdown({super.key, this.onItemSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currentSleepTimer = settings.settings.sleepTimer;

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
          spacing: 2,
          children: [
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.off
                  ? Icon(LucideIcons.check)
                  : null,
              text: '关闭',
              onPressed: () {
                ref.read(settingsProvider.notifier).clearSleepTimer();
                onItemSelected?.call();
              },
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min5
                  ? Icon(LucideIcons.check)
                  : null,
              text: '5 分钟',
              onPressed: () => _selectTime(ref, SleepTimerOption.min5),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min10
                  ? Icon(LucideIcons.check)
                  : null,
              text: '10 分钟',
              onPressed: () => _selectTime(ref, SleepTimerOption.min10),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min15
                  ? Icon(LucideIcons.check)
                  : null,
              text: '15 分钟',
              onPressed: () => _selectTime(ref, SleepTimerOption.min15),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min30
                  ? Icon(LucideIcons.check)
                  : null,
              text: '30 分钟',
              onPressed: () => _selectTime(ref, SleepTimerOption.min30),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min45
                  ? Icon(LucideIcons.check)
                  : null,
              text: '45 分钟',
              onPressed: () => _selectTime(ref, SleepTimerOption.min45),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.min60
                  ? Icon(LucideIcons.check)
                  : null,
              text: '1 小时',
              onPressed: () => _selectTime(ref, SleepTimerOption.min60),
            ),
            DropdownItem(
              icon: currentSleepTimer == SleepTimerOption.episodeEnd
                  ? Icon(LucideIcons.check)
                  : null,
              text: '单集结束时',
              onPressed: () {
                ref
                    .read(settingsProvider.notifier)
                    .updateSleepTimer(SleepTimerOption.episodeEnd);
                onItemSelected?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(WidgetRef ref, SleepTimerOption option) {
    final minutes = option.minutes;
    if (minutes == null) return;

    final endTime = DateTime.now().add(Duration(minutes: minutes));
    ref
        .read(settingsProvider.notifier)
        .updateSleepTimer(
          option,
          endTimeMillis: endTime.millisecondsSinceEpoch,
        );
    onItemSelected?.call();
  }
}
