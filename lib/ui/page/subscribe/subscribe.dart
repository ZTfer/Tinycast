import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/item_widgets/subscribe_action_bar.dart';
import 'package:tinycast/ui/page/subscribe/item_widgets/subscribe_by_opml.dart';
import 'package:tinycast/ui/page/subscribe/item_widgets/subscribe_by_rss.dart';

class Subscribe extends StatelessWidget {
  const Subscribe({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SubscribeByRss(),
        SizedBox(height: 24.0),
        SubscribeByOpml(),
        SizedBox(height: 24.0),
        SubscribeActionBar(),
      ],
    );
  }
}
