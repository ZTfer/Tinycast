import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/atom_widgets/rss_input.dart';

class SubscribeByRss extends StatelessWidget {
  const SubscribeByRss({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          '通过RSS订阅',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
        SizedBox(height: 12.0),
        RssInput(),
      ],
    );
  }
}
