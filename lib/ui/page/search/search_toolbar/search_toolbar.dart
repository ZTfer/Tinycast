import 'package:flutter/widgets.dart';
import 'search_toolbar_key_tips.dart';
import 'search_toolbar_delete_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchToolbar extends StatelessWidget {
  const SearchToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8.0,
      children: [
        _buildDivider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SearchToolbarKeyTips(),
            SearchToolbarDeleteButton(
              icon: Icon(
                LucideIcons.trash2,
                size: 10,
                color: Color(0x80000000),
              ),
              label: '清空记录',
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }
}

/// 构建分隔线
Widget _buildDivider() {
  return Container(height: 0.5, color: const Color(0xFFE0E0E0));
}
