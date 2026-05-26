import 'package:flutter/widgets.dart';

class NavbarButton extends StatelessWidget {
  const NavbarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24.0),
      ),
    );
  }
}
