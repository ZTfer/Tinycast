import 'package:flutter/widgets.dart';

class NavbarLargeTitle extends StatelessWidget {
  final String title;

  const NavbarLargeTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }
}
