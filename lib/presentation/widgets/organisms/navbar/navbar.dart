import 'package:flutter/widgets.dart';
import 'navbar_button.dart';
import 'navbar_large_title.dart';

class Navbar extends StatelessWidget {
  final String title;

  const Navbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        decoration: BoxDecoration(
          // color: const Color(0xFFFFFFFF),
          // borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavbarLargeTitle(title: title),
            NavbarButton(),
          ],
        ),
      ),
    );
  }
}
