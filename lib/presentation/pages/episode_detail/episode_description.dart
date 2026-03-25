import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class EpisodeDescription extends StatelessWidget {
  final String? description;

  const EpisodeDescription({
    super.key,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final htmlContent = description ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: HtmlWidget(
        htmlContent,
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color(0xFF999999),
          height: 16 / 12,
        ),
      ),
    );
  }
}
