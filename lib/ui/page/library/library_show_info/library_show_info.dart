import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/library/library_list_item/library_show_more_button.dart';

class LibraryShowInfo extends StatelessWidget {
  final String showName;
  final String timeAgo;

  const LibraryShowInfo({
    super.key,
    required this.showName,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            LibraryShowMoreButton(
              icon: const Icon(LucideIcons.ellipsisVertical),
              onPressed: () {},
            ),
          ],
        ),
        Text(
          timeAgo,
          style: TextStyle(fontSize: 9.75, color: Color(0xD9000000)),
        ),
      ],
    );
  }
}
