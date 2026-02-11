import 'package:flutter/widgets.dart';

class LibraryShowInfo extends StatelessWidget {
  final String showName;

  const LibraryShowInfo({super.key, required this.showName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              showName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF000000),
              ),
            ),
            Text(
              '􀍠',
              style: TextStyle(fontSize: 12, color: Color(0xD9000000)),
            ),
          ],
        ),
        Text(
          '1 h ago',
          style: TextStyle(fontSize: 9.75, color: Color(0xD9000000)),
        ),
      ],
    );
  }
}
