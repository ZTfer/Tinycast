import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_search_result/subscribe_search_list_item.dart';

class SubscribeSearchList extends StatelessWidget {
  const SubscribeSearchList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return SubscribeSearchListItem(
          title: '剧集 $index',
          podcastName: '播客 $index',
          onAddPressed: () {},
        );
      },
    );
  }
}