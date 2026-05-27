import 'package:flutter/widgets.dart';

class NavbarButton extends StatelessWidget {
  final IconData? icon;
  final VoidCallback? onPressed;

  const NavbarButton({super.key, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    if (icon == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Icon(icon, size: 20.0, color: const Color(0xFF000000)),
      ),
    );
  }
}
