import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';

/// 跨平台窗口模糊效果工具类
///
/// 封装 flutter_acrylic 包的常用功能，提供统一的窗口效果管理
/// 支持 macOS、Windows、Linux 三平台
class AcrylicWindowUtils {
  /// 初始化窗口系统
  ///
  /// 必须在应用启动时调用，建议在 main() 函数中调用
  static Future<void> initialize() async {
    await Window.initialize();
  }

  /// 应用毛玻璃/亚克力效果到窗口
  ///
  /// macOS: 使用 sidebar 材质
  /// Windows: 使用 acrylic 效果
  /// Linux: 使用 transparent 效果
  static Future<void> applyFrostedGlassEffect() async {
    await Window.setEffect(
      effect: _getFrostedEffect(),
      color: Platform.isMacOS ? Colors.transparent : const Color(0x80222222),
      dark: true,
    );
  }

  /// 应用侧边栏毛玻璃效果
  ///
  /// macOS: 使用 windowBackground 材质
  /// Windows/Linux: 使用 transparent 效果
  static Future<void> applySidebarFrostedEffect() async {
    await Window.setEffect(
      effect: Platform.isMacOS
          ? WindowEffect.windowBackground
          : WindowEffect.transparent,
      color: Colors.transparent,
    );
  }

  /// 移除窗口毛玻璃效果
  static Future<void> removeFrostedGlassEffect() async {
    await Window.setEffect(
      effect: WindowEffect.disabled,
    );
  }

  /// 设置窗口背景为透明
  static Future<void> setTransparentBackground() async {
    await Window.setEffect(
      effect: WindowEffect.transparent,
      color: Colors.transparent,
    );
  }

  /// 启用全尺寸内容视图
  ///
  /// 允许内容绘制到标题栏区域
  /// 仅 macOS 有效
  static Future<void> enableFullSizeContent() async {
    if (Platform.isMacOS) {
      await Window.enableFullSizeContentView();
      await Window.makeTitlebarTransparent();
    }
  }

  /// 禁用全尺寸内容视图
  static Future<void> disableFullSizeContent() async {
    if (Platform.isMacOS) {
      await Window.disableFullSizeContentView();
      await Window.makeTitlebarOpaque();
    }
  }

  /// 配置窗口为透明标题栏样式
  static Future<void> configureTransparentWindow() async {
    await applyFrostedGlassEffect();
    await enableFullSizeContent();
  }

  /// 根据平台获取最佳毛玻璃效果
  static WindowEffect _getFrostedEffect() {
    if (Platform.isWindows) {
      return WindowEffect.acrylic;
    }
    return WindowEffect.sidebar;
  }
}

/// macOS 标题栏安全区域组件
///
/// 确保内容不会被系统标题栏遮挡
/// 当启用全尺寸内容视图时应当在顶层使用此组件
/// 仅 macOS 平台有效，其他平台直接返回 child
class AcrylicTitlebarSafeArea extends StatelessWidget {
  final Widget child;

  const AcrylicTitlebarSafeArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return TitlebarSafeArea(child: child);
    }
    return child;
  }
}
