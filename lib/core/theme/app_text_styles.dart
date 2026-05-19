import 'package:flutter/widgets.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const List<String> fontFamilyFallback = [
    'PingFang SC',       // macOS 简体中文
    'PingFang TC',       // macOS 繁体中文
    'Hiragino Sans',     // macOS 日文
    'Microsoft YaHei',   // Windows 中文
    'Microsoft JhengHei',// Windows 繁体
    'Yu Gothic',         // Windows 日文
    'Noto Sans CJK SC',  // Linux 中文
    'Noto Sans CJK TC',  // Linux 繁体
    'Noto Sans CJK JP',  // Linux 日文
    'Noto Sans SC',      // Android 中文
    'Noto Sans TC',      // Android 繁体
    'Noto Sans JP',      // Android 日文
    'Noto Sans KR',      // Android/iOS 韩文
    'Noto Sans Thai',    // 泰语
    'Noto Sans Arabic',  // 阿拉伯语
    'Noto Sans Devanagari', // 印地语
    'Roboto',            // 默认西文字体 (Android/Linux)
    'SF Pro',            // Apple 西文字体 (iOS/macOS)
    'Helvetica Neue',    // macOS 旧版本
    'Segoe UI',          // Windows
    'sans-serif',        // 系统默认
  ];

  static const TextStyle h1Light = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryLight,
    height: 1.2,
    letterSpacing: 0.37,
  );

  static const TextStyle h1Dark = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryDark,
    height: 1.2,
    letterSpacing: 0.37,
  );

  static const TextStyle h2Light = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryLight,
    height: 1.2,
    letterSpacing: 0.35,
  );

  static const TextStyle h2Dark = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryDark,
    height: 1.2,
    letterSpacing: 0.35,
  );

  static const TextStyle h3Light = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryLight,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static const TextStyle h3Dark = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryDark,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static const TextStyle h3DesktopLight = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.labelPrimaryLight,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static const TextStyle h3DesktopDark = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.labelPrimaryDark,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static const TextStyle bodyLargeLight = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryLight,
    height: 1.5,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyLargeDark = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryDark,
    height: 1.5,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyMediumLight = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryLight,
    height: 1.4,
    letterSpacing: -0.24,
  );

  static const TextStyle bodyMediumDark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryDark,
    height: 1.4,
    letterSpacing: -0.24,
  );

  static const TextStyle bodySmallLight = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.labelSecondaryLight,
    height: 1.4,
    letterSpacing: -0.08,
  );

  static const TextStyle bodySmallDark = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.labelSecondaryDark,
    height: 1.4,
    letterSpacing: -0.08,
  );

  static const TextStyle captionLight = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.labelTertiaryLight,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle captionDark = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.labelTertiaryDark,
    height: 1.3,
    letterSpacing: 0,
  );

  static const TextStyle buttonLight = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryLight,
    height: 1.3,
    letterSpacing: -0.41,
  );

  static const TextStyle buttonDark = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryDark,
    height: 1.3,
    letterSpacing: -0.41,
  );
}
