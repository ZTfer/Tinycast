import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';


class SearchHistoryItem extends StatelessWidget {
  const SearchHistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(LucideIcons.history, size: 14, color: Color(0xFF000000)),
          SizedBox(width: 8),
          Text(
            '关键词',
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(width: 8),
          Icon(LucideIcons.cornerDownLeft, size: 14, color: Color(0xFF000000)),
        ],
      ),
    );
  }
}