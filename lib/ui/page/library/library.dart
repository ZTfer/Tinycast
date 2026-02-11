import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/page/library/library_list_item.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const LibraryListItem(),
            _buildDivider(),
            const LibraryListItem(),
            _buildDivider(),
            const LibraryListItem(),
            _buildDivider(),
            const LibraryListItem(),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: const Color(0xFFE0E0E0));
  }
}
