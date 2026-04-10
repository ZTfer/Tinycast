import 'package:flutter/widgets.dart';
import 'package:tinycast/presentation/features/favorite/favorite_empty_page/favorite_empty_info.dart';

class FavoriteEmptyPage extends StatelessWidget {
  const FavoriteEmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 18.0,
      children: [
        FavoriteEmptyInfo(),
      ],
    );
  }
}
