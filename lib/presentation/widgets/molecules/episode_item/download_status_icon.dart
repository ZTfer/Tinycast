import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class DownloadStatusIcon extends StatelessWidget {
  const DownloadStatusIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xFFE5E5E5),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: const Icon(LucideIcons.arrowDown, size: 10.0),
    );
  }
}
