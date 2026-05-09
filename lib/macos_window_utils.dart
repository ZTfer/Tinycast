import 'package:macos_window_utils/macos_window_utils.dart';
import 'package:macos_window_utils/widgets/transparent_macos_sidebar.dart';
import 'package:flutter/material.dart';

/// macOS 窗口工具类
///
/// 封装 macos_window_utils 包的常用功能，提供统一的 macOS 窗口效果管理
class MacosWindowUtils {
  /// 初始化 macOS 窗口系统
  ///
  /// 必须在应用启动时调用，建议在 main() 函数中调用
  /// [enableWindowDelegate] 是否启用窗口代理，用于监听窗口事件
  static Future<void> initialize({bool enableWindowDelegate = true}) async {
    await WindowManipulator.initialize(
      enableWindowDelegate: enableWindowDelegate,
    );
  }

  /// 应用毛玻璃效果到窗口
  ///
  /// 设置窗口的 NSVisualEffectView 材质为 HUD 毛玻璃效果
  /// 这是 macOS 原生的半透明模糊背景效果
  static Future<void> applyFrostedGlassEffect() async {
    await WindowManipulator.setMaterial(NSVisualEffectViewMaterial.sidebar);
  }

  /// 应用侧边栏毛玻璃效果
  ///
  /// 设置窗口材质为背景色，侧边栏使用 TransparentMacOSSidebar 包裹
  /// 适用于主窗口有侧边栏的场景
  static Future<void> applySidebarFrostedEffect() async {
    await WindowManipulator.setMaterial(
      NSVisualEffectViewMaterial.windowBackground,
    );
  }

  /// 移除窗口毛玻璃效果
  ///
  /// 恢复窗口默认背景颜色
  static Future<void> removeFrostedGlassEffect() async {
    await WindowManipulator.setWindowBackgroundColorToDefaultColor();
  }

  /// 设置窗口背景为透明
  ///
  /// 使窗口背景完全透明，配合毛玻璃效果使用
  static Future<void> setTransparentBackground() async {
    await WindowManipulator.setWindowBackgroundColorToClear();
  }

  /// 启用全尺寸内容视图
  ///
  /// 允许 Flutter 内容绘制到标题栏区域
  /// 通常与 makeTitlebarTransparent() 配合使用
  static Future<void> enableFullSizeContent() async {
    await WindowManipulator.enableFullSizeContentView();
    await WindowManipulator.makeTitlebarTransparent();
  }

  /// 禁用全尺寸内容视图
  ///
  /// 恢复默认的窗口内容视图行为
  static Future<void> disableFullSizeContent() async {
    await WindowManipulator.disableFullSizeContentView();
    await WindowManipulator.makeTitlebarOpaque();
  }

  /// 配置窗口为透明标题栏样式
  ///
  /// 结合毛玻璃效果和透明标题栏，创建现代化的 macOS 窗口外观
  static Future<void> configureTransparentWindow() async {
    await applyFrostedGlassEffect();
    await enableFullSizeContent();
  }

  /// 窗口居中显示
  static Future<void> centerWindow() async {
    await WindowManipulator.centerWindow();
  }
}

/// macOS 毛玻璃侧边栏组件
///
/// 包装侧边栏 Widget 以应用 macOS 原生毛玻璃效果
/// 当窗口使用 applySidebarFrostedEffect() 时应当使用此组件包裹侧边栏
class MacosFrostedSidebar extends StatelessWidget {
  final Widget child;

  const MacosFrostedSidebar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TransparentMacOSSidebar(child: child);
  }
}

/// macOS 标题栏安全区域组件
///
/// 确保内容不会被系统标题栏遮挡
/// 当启用全尺寸内容视图时应当在顶层使用此组件
class MacosTitlebarSafeArea extends StatelessWidget {
  final Widget child;

  const MacosTitlebarSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(child: child);
  }
}
