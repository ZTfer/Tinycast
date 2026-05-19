import 'package:flutter/material.dart';
import 'package:tinycast/presentation/widgets/organisms/home_toolbar/home_toolbar.dart';
import 'package:tinycast/presentation/widgets/organisms/mini_player/mini_player.dart';
import 'package:tinycast/presentation/features/home/body.dart';
import 'package:tinycast/core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.fromBrightness(
      MediaQuery.platformBrightnessOf(context),
    );
    return Container(
      color: const Color(0x00000000),
      child: Column(
        children: [
          HomeToolbar(),
          MiniPlayer(),
          const SizedBox(height: 12),
          if (theme.dividerVisible)
            Divider(
              height: theme.dividerHeight,
              thickness: theme.dividerThickness,
              color: theme.dividerColor,
            ),
          Expanded(child: Body()),
        ],
      ),
    );
  }
}
