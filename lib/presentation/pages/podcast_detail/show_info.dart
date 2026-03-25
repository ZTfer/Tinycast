import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '播客标题文字',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),

                Text('更多按钮'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              '播客描述文字',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ],
    );
  }
}
