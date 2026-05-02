import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/dialogs/toast/vertical_icon_toast.dart';

class ToastUtils {
  ToastUtils._();

  static void showOverlayToast(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.check,
    double iconSize = 36.0,
    double textSize = 12.0,
    Duration duration = const Duration(seconds: 2),
    double verticalPosition = 0.3,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry toastEntry;
    toastEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * verticalPosition,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: VerticalIconToast(
              icon: Icon(icon, size: iconSize),
              text: message,
              textSize: textSize,
            ),
          ),
        ),
      ),
    );

    overlay.insert(toastEntry);

    Future.delayed(duration, () {
      if (toastEntry.mounted) {
        toastEntry.remove();
      }
    });
  }

  static void showSuccessToast(
    BuildContext context, {
    String message = '操作成功',
  }) {
    showOverlayToast(
      context,
      message: message,
      icon: LucideIcons.check,
    );
  }

  static void showErrorToast(
    BuildContext context, {
    String message = '操作失败',
  }) {
    showOverlayToast(
      context,
      message: message,
      icon: LucideIcons.x,
    );
  }

  static void showCopySuccessToast(BuildContext context) {
    showOverlayToast(
      context,
      message: '链接已复制',
      icon: LucideIcons.check,
    );
  }
}
