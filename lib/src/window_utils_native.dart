import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

class WindowUtils {
  static Future<void> initialize() async {
    await Window.initialize();
  }

  static Future<void> applyFrostedGlassEffect() async {
    if (Platform.isMacOS) {
      await _applyMacOSEffect();
    } else if (Platform.isWindows) {
      await _applyWindowsEffect();
    } else {
      await _applyFallbackEffect();
    }
  }

  static Future<void> _applyMacOSEffect() async {
    await Window.setEffect(
      effect: WindowEffect.sidebar,
      color: Colors.transparent,
      dark: true,
    );
  }

  static Future<void> _applyWindowsEffect() async {
    try {
      await Window.setEffect(
        effect: WindowEffect.acrylic,
        color: const Color(0xCCFEFEFE),
      );
    } catch (e) {
      await Window.setEffect(
        effect: WindowEffect.solid,
        color: const Color(0xFFFEFEFE),
      );
    }
  }

  static Future<void> _applyFallbackEffect() async {
    await Window.setEffect(
      effect: WindowEffect.solid,
      color: const Color(0xFFFEFEFE),
    );
  }

  static Future<void> applySidebarFrostedEffect() async {
    if (Platform.isMacOS) {
      await Window.setEffect(
        effect: WindowEffect.windowBackground,
        color: Colors.transparent,
      );
    } else {
      await Window.setEffect(
        effect: WindowEffect.solid,
        color: const Color(0xFFFEFEFE),
      );
    }
  }

  static Future<void> removeFrostedGlassEffect() async {
    await Window.setEffect(
      effect: WindowEffect.disabled,
    );
  }

  static Future<void> setTransparentBackground() async {
    if (Platform.isMacOS) {
      await Window.setEffect(
        effect: WindowEffect.transparent,
        color: Colors.transparent,
      );
    } else {
      await Window.setEffect(
        effect: WindowEffect.solid,
        color: const Color(0xFFFEFEFE),
      );
    }
  }

  static Future<void> enableFullSizeContent() async {
    if (Platform.isMacOS) {
      await Window.enableFullSizeContentView();
      await Window.makeTitlebarTransparent();
    }
  }

  static Future<void> disableFullSizeContent() async {
    if (Platform.isMacOS) {
      await Window.disableFullSizeContentView();
      await Window.makeTitlebarOpaque();
    }
  }

  static Future<void> configureTransparentWindow() async {
    await applyFrostedGlassEffect();
    await enableFullSizeContent();
  }
}

class TitlebarSafeAreaWrapper extends StatelessWidget {
  final Widget child;

  const TitlebarSafeAreaWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return TitlebarSafeArea(child: child);
    }
    return child;
  }
}
