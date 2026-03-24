import 'package:flutter/widgets.dart';

class EpisodeDescription extends StatelessWidget {
  const EpisodeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        '播客描述文字',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color(0xFF999999),
          height: 16 / 12,
        ),
      ),
    );
  }
}
