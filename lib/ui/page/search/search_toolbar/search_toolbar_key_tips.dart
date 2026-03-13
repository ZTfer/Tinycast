import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class SearchToolbarKeyTips extends StatelessWidget {
  const SearchToolbarKeyTips({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.arrowUpDown, size: 12, color: Colors.grey[600]),
        SizedBox(width: 2),
        Text(
          '使用上下键切换',
          style: TextStyle(
            fontSize: 10,
            height: 14 / 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
