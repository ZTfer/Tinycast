import 'package:flutter/material.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_search_list.dart';
import 'package:tinycast/presentation/pages/subscribe/subscribe_search_result/subscribe_search_list_title.dart';

class SubscribeSearchResult extends StatelessWidget {
  const SubscribeSearchResult({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const SubscribeSearchListTitle(),
        const SizedBox(height: 12),
        Expanded(child: const SubscribeSearchList()),
      ],
    );
  }
}
