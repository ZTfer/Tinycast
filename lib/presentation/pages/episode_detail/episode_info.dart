import 'package:flutter/widgets.dart';

class EpisodeInfo extends StatelessWidget {
  const EpisodeInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          '1天前111',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: Color(0xFF999999),
            height: 16 / 12,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Episode Title Episode Title Episode Title Episode Title Episode Title Episode Title Episode Title Episode Title',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}
