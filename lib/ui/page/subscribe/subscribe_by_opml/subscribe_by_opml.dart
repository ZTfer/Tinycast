import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_by_opml/opml_import_form.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_by_opml/subscribe_by_opml_label.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_search_result/subscribe_search_result.dart';

class SubscribeByOpml extends StatelessWidget {
  const SubscribeByOpml({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubscribeByOpmlLabel(),
        const SizedBox(height: 12.0),
        const OpmlImportForm(),
        Expanded(child: const SubscribeSearchResult()),
      ],
    );
  }
}
