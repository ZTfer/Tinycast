import 'package:flutter/widgets.dart';
import 'package:tinycast/ui/common_widgets/home_toolbar/home_toolbar.dart';
import 'package:tinycast/ui/common_widgets/mini_player/mini_player.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: [
          HomeToolbar(),
          MiniPlayer(),
          Expanded(child: Center(child: Text('Hello, non-Material App!'))),
        ],
      ),
    );
  }
}
