import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchResultsEmpty extends StatelessWidget {
  const SearchResultsEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.circleX200,
            size: 36,
            color: Color(0xFFD9D9D9),
          ),
          const SizedBox(height: 12),
          const Text(
            '没有搜索到相关内容，请检查后重试',
            style: TextStyle(
              color: Color(0xFFD9D9D9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
