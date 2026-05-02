import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tinycast/presentation/dialogs/toast/vertical_icon_toast.dart';

/// 工具类：提供全局 Toast 提示功能
///
/// 使用 Overlay 机制在屏幕上方居中显示短暂的图标+文字提示，
/// 不依赖 ScaffoldMessenger，可在任意上下文使用。
class ToastUtils {
  /// 私有构造函数，防止实例化
  ToastUtils._();

  /// 显示一个带图标的覆盖层 Toast
  ///
  /// [context] 用于获取 Overlay 和 MediaQuery
  /// [message] 提示文字内容
  /// [icon] 图标，默认对勾 (LucideIcons.check)
  /// [iconSize] 图标大小，默认 36.0
  /// [textSize] 文字大小，默认 12.0
  /// [duration] 显示持续时间，默认 1 秒
  /// [verticalPosition] 垂直位置比例（相对于屏幕高度），默认 0.3（即屏幕顶部 30% 处）
  static void showOverlayToast(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.check,
    double iconSize = 36.0,
    double textSize = 12.0,
    Duration duration = const Duration(seconds: 1),
    double verticalPosition = 0.3,
  }) {
    // 获取当前上下文的 Overlay，若不存在则无法显示 Toast
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // 声明 OverlayEntry，使用 late 以便在闭包中能引用自身
    late OverlayEntry toastEntry;
    toastEntry = OverlayEntry(
      builder: (context) => Positioned(
        // 根据 verticalPosition 计算 Toast 的顶部位置
        top: MediaQuery.of(context).size.height * verticalPosition,
        left: 0,
        right: 0,
        child: Center(
          // 使用 Material(color: transparent) 使得 Toast 能正常渲染在 Overlay 上
          // 但不会带任何背景色或阴影
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

    // 将 Toast 插入到 Overlay 中，立即显示
    overlay.insert(toastEntry);

    // 在指定时长后自动移除 Toast
    Future.delayed(duration, () {
      // 检查 mounted 确保 ToastEntry 仍然存在于 Overlay 中
      if (toastEntry.mounted) {
        toastEntry.remove();
      }
    });
  }

  /// 显示成功提示 Toast
  ///
  /// [context] 上下文
  /// [message] 提示文字，默认 "操作成功"
  static void showSuccessToast(
    BuildContext context, {
    String message = '操作成功',
  }) {
    showOverlayToast(context, message: message, icon: LucideIcons.check);
  }

  /// 显示错误提示 Toast
  ///
  /// [context] 上下文
  /// [message] 提示文字，默认 "操作失败"
  static void showErrorToast(BuildContext context, {String message = '操作失败'}) {
    showOverlayToast(context, message: message, icon: LucideIcons.x);
  }

  /// 显示"链接已复制"成功提示
  ///
  /// [context] 上下文
  static void showCopySuccessToast(BuildContext context) {
    showOverlayToast(context, message: '链接已复制', icon: LucideIcons.check);
  }
}
