import 'package:flutter/widgets.dart';
import 'navbar_button.dart';
import 'navbar_large_title.dart';

class Navbar extends StatelessWidget {
  final String title;
  final IconData? actionIcon;
  final VoidCallback? onActionTap;

  const Navbar({
    super.key,
    required this.title,
    this.actionIcon,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        // padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
        decoration: BoxDecoration(
          // color: const Color(0xFFFFFFFF),
          // borderRadius: BorderRadius.circular(24.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NavbarLargeTitle(title: title),
            NavbarButton(icon: actionIcon, onPressed: onActionTap),
          ],
        ),
      ),
    );
  }
}
