import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/subscribe/atom_widgets/opml_import.dart';
import 'package:tinycast/ui/page/subscribe/item_widgets/subscribe_by_opml_label.dart';

class SubscribeByOpml extends StatelessWidget {
  const SubscribeByOpml({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SubscribeByOpmlLabel(),
        SizedBox(height: 12.0),
        OpmlImport(),
      ],
    );
  }
}
