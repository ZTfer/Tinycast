import 'package:flutter/widgets.dart';
import 'package:tinycast/core/theme/app_theme.dart';
import 'package:tinycast/presentation/features/home/mobile_body.dart';

class MobileHome extends StatelessWidget {
  const MobileHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Container(color: theme.backgroundSecondary, child: MobileBody());
  }
}
