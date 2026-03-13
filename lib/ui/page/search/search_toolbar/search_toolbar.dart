import 'package:flutter/widgets.dart';
import 'search_toolbar_key_tips.dart';
import 'search_toolbar_delete_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchToolbar extends StatelessWidget {
  const SearchToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SearchToolbarKeyTips(),
        SearchToolbarDeleteButton(
          icon: Icon(LucideIcons.trash2, size: 10, color: Color(0x80000000)),
          label: '删除',
          onPressed: () {},
        ),
      ],
    );
  }
}
