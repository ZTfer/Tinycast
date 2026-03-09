import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/ui/page/subscribe/subscribe_by_opml/opml_import_question_button.dart';

class SubscribeByOpmlLabel extends StatelessWidget {
  const SubscribeByOpmlLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '通过OPML导入',
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(width: 6.0),
        OpmlImportQuestionButton(
          icon: const Icon(LucideIcons.helpCircle),
          onPressed: () {},
        ),
      ],
    );
  }
}
