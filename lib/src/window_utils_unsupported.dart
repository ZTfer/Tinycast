import 'package:flutter/material.dart';

class WindowUtils {
  static Future<void> initialize() async {}

  static Future<void> applyFrostedGlassEffect() async {}

  static Future<void> applySidebarFrostedEffect() async {}

  static Future<void> removeFrostedGlassEffect() async {}

  static Future<void> setTransparentBackground() async {}

  static Future<void> enableFullSizeContent() async {}

  static Future<void> disableFullSizeContent() async {}

  static Future<void> configureTransparentWindow() async {}
}

class TitlebarSafeAreaWrapper extends StatelessWidget {
  final Widget child;

  const TitlebarSafeAreaWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
