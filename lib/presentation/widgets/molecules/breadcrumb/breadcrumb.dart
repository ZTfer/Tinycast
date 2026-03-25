import 'package:flutter/widgets.dart';
import 'breadcrumb_item.dart';

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items,
    );
  }
}
