import 'package:flutter/widgets.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tinycast/ui/common_widgets/buttons/list_play_button.dart';
import 'package:tinycast/ui/page/downloads/atom_widgets/downloads_more_button.dart';

class DownloadsControlBar extends StatelessWidget {
  const DownloadsControlBar({super.key}); 

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
        DownloadsMoreButton(
          icon: const Icon(LucideIcons.moreHorizontal),
          onPressed: () {},
          iconSize: 12,
          contentColor: const Color(0xD9000000),
        ),
      ],
    );
  }
}
