import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/history/history_empty_page/history_empty_info.dart';

class HistoryEmptyPage extends StatelessWidget {
  const HistoryEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 18.0,
      children: const [
        HistoryEmptyInfo(),
      ],
    );
  }
}
