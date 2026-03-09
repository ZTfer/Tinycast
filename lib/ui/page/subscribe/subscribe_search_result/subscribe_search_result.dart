import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_search_result/subscribe_search_list.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_search_result/subscribe_search_list_title.dart';

class SubscribeSearchResult extends StatelessWidget {
  const SubscribeSearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SubscribeSearchListTitle(),
        const SizedBox(height: 120),
        Expanded(child: const SubscribeSearchList()),
      ],
    );
  }
}
