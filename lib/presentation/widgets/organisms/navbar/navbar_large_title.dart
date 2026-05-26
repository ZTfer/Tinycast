import 'package:flutter/widgets.dart';

class NavbarLargeTitle extends StatelessWidget {
  const NavbarLargeTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Tinycast',
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }
}