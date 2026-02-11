import 'package:flutter/widgets.dart';

class LibraryShowInfo extends StatelessWidget {
  final String showName;
  final String timeAgo;

  const LibraryShowInfo({
    super.key,
    required this.showName,
    required this.timeAgo,
  });

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
          timeAgo,
          style: TextStyle(fontSize: 9.75, color: Color(0xD9000000)),
        ),
      ],
    );
  }
}
