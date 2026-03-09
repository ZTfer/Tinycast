import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class QueueEmptyOpmlImportQuestionLink extends StatelessWidget {
  const QueueEmptyOpmlImportQuestionLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.info, size: 16),
        const SizedBox(width: 6.0),
        Text(
          '通过OPML导入',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
      ],
    );
  }
}
