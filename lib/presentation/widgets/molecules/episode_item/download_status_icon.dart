import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DownloadStatusIcon extends StatelessWidget {
  const DownloadStatusIcon({super.key, this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    if (progress != null) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 1.5,
          color: Color(0xFF999999),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Icon(LucideIcons.arrowDown, size: 8.0),
    );
  }
}
