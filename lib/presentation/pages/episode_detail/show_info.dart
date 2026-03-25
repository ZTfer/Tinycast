import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ShowInfo extends StatelessWidget {
  const ShowInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/images/image_placeholder.svg',
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 4),
        const Text(
          '播客标题文字',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF999999),
            height: 16 / 12,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(LucideIcons.chevronRight, size: 12),
      ],
    );
  }
}
