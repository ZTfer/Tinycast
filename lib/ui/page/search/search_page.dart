import 'package:flutter/material.dart';
import 'search_toolbar/search_toolbar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          SearchToolbar(),
        ],
      ),
    );
  }
}
