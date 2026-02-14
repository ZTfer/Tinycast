import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/buttons/secondary_button.dart';
import 'package:tinycast/ui/common_widgets/buttons/primary_button.dart';

class SubscribeActionBar extends StatelessWidget {
  const SubscribeActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SecondaryButton(
          label: '取消',
          onPressed: () {
            debugPrint('Follow pressed');
          },
        ),
        const SizedBox(width: 8),
        PrimaryButton(
          label: '订阅',
          onPressed: () {
            debugPrint('Subscribe pressed');
          },
        ),
      ],
    );
  }
}