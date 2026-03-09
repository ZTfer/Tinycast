import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/favorite/favorite_control_bar/favorite_more_button.dart';
import 'package:tinycast/ui/page/favorite/favorite_control_bar/favorite_action_button.dart';

class FavoriteControlBar extends StatelessWidget {
  const FavoriteControlBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListPlayButton(
          icon: const Icon(LucideIcons.play),
          label: 'Play',
          onPressed: () {},
          iconSize: 10,
          fontSize: 10,
          horizontalPadding: 8,
          verticalPadding: 4,
          borderRadius: 10,
        ),
        Spacer(),
        FavoriteActionButton(
          icon: const Icon(LucideIcons.star),
          onPressed: () {},
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
        FavoriteMoreButton(
          icon: const Icon(LucideIcons.ellipsisVertical),
          onPressed: () {},
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
      ],
    );
  }
}
