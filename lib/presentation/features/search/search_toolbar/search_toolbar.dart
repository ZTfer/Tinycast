import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'search_toolbar_key_tips.dart';
import 'search_toolbar_delete_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../search_provider.dart';

class SearchToolbar extends ConsumerWidget {
  const SearchToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              onPressed: () {
                ref.read(searchProvider.notifier).clearHistory();
              },
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
