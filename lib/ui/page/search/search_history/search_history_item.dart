import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchHistoryItem extends StatelessWidget {
  final String historyKeyword;

  const SearchHistoryItem({super.key, required this.historyKeyword});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(LucideIcons.history, size: 14, color: Color(0x40000000)),
          SizedBox(width: 8),
          Text(
            historyKeyword,
            style: TextStyle(
              fontSize: 14,
              height: 18 / 14,
              color: Color(0xFF000000),
            ),
          ),
          Spacer(),
          Icon(LucideIcons.cornerDownLeft, size: 14, color: Color(0x40000000)),
        ],
      ),
    );
  }
}
