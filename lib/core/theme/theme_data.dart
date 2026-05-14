import 'package:flutter/widgets.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

enum AppThemeMode { light, dark }

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppBorderRadius {
  AppBorderRadius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double full = 9999;
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

class AppThemeData {
  final AppThemeMode mode;

  const AppThemeData({required this.mode});

  Color get backgroundPrimary =>
      mode == AppThemeMode.light
          ? AppColors.backgroundPrimaryLight
          : AppColors.backgroundPrimaryDark;

  Color get backgroundSecondary =>
      mode == AppThemeMode.light
          ? AppColors.backgroundSecondaryLight
          : AppColors.backgroundSecondaryDark;

  Color get backgroundTertiary =>
      mode == AppThemeMode.light
          ? AppColors.backgroundTertiaryLight
          : AppColors.backgroundTertiaryDark;

  Color get labelPrimary =>
      mode == AppThemeMode.light
          ? AppColors.labelPrimaryLight
          : AppColors.labelPrimaryDark;

  Color get labelSecondary =>
      mode == AppThemeMode.light
          ? AppColors.labelSecondaryLight
          : AppColors.labelSecondaryDark;

  Color get labelTertiary =>
      mode == AppThemeMode.light
          ? AppColors.labelTertiaryLight
          : AppColors.labelTertiaryDark;

  Color get labelQuaternary =>
      mode == AppThemeMode.light
          ? AppColors.labelQuaternaryLight
          : AppColors.labelQuaternaryDark;

  Color get brandPrimary =>
      mode == AppThemeMode.light
          ? AppColors.brandPrimaryLight
          : AppColors.brandPrimaryDark;

  Color get brandSecondary =>
      mode == AppThemeMode.light
          ? AppColors.brandSecondaryLight
          : AppColors.brandSecondaryDark;

  Color get brandBlue =>
      mode == AppThemeMode.light
          ? AppColors.brandBlueLight
          : AppColors.brandBlueDark;

  Color get overlayDefault =>
      mode == AppThemeMode.light
          ? AppColors.overlayDefaultLight
          : AppColors.overlayDefaultDark;

  Color get gray30 =>
      mode == AppThemeMode.light
          ? AppColors.gray30Light
          : AppColors.gray30Dark;

  TextStyle get h1 =>
      mode == AppThemeMode.light
          ? AppTextStyles.h1Light
          : AppTextStyles.h1Dark;

  TextStyle get h2 =>
      mode == AppThemeMode.light
          ? AppTextStyles.h2Light
          : AppTextStyles.h2Dark;

  TextStyle get h3 =>
      mode == AppThemeMode.light
          ? AppTextStyles.h3Light
          : AppTextStyles.h3Dark;

  TextStyle get bodyLarge =>
      mode == AppThemeMode.light
          ? AppTextStyles.bodyLargeLight
          : AppTextStyles.bodyLargeDark;

  TextStyle get bodyMedium =>
      mode == AppThemeMode.light
          ? AppTextStyles.bodyMediumLight
          : AppTextStyles.bodyMediumDark;

  TextStyle get bodySmall =>
      mode == AppThemeMode.light
          ? AppTextStyles.bodySmallLight
          : AppTextStyles.bodySmallDark;

  TextStyle get caption =>
      mode == AppThemeMode.light
          ? AppTextStyles.captionLight
          : AppTextStyles.captionDark;

  TextStyle get button =>
      mode == AppThemeMode.light
          ? AppTextStyles.buttonLight
          : AppTextStyles.buttonDark;

  TextStyle get episodeItemTitle =>
      mode == AppThemeMode.light
          ? AppTextStyles.h3DesktopLight
          : AppTextStyles.h3DesktopDark;

  TextStyle get episodeItemDescription =>
      mode == AppThemeMode.light
          ? AppTextStyles.captionLight
          : AppTextStyles.captionDark;

  double get spacingXxs => AppSpacing.xxs;
  double get spacingXs => AppSpacing.xs;
  double get spacingSm => AppSpacing.sm;
  double get spacingMd => AppSpacing.md;
  double get spacingLg => AppSpacing.lg;
  double get spacingXl => AppSpacing.xl;
  double get spacingXxl => AppSpacing.xxl;

  double get borderRadiusXs => AppBorderRadius.xs;
  double get borderRadiusSm => AppBorderRadius.sm;
  double get borderRadiusMd => AppBorderRadius.md;
  double get borderRadiusLg => AppBorderRadius.lg;
  double get borderRadiusXl => AppBorderRadius.xl;
  double get borderRadiusFull => AppBorderRadius.full;

  List<BoxShadow> get shadowSm => AppShadows.sm;
  List<BoxShadow> get shadowMd => AppShadows.md;
  List<BoxShadow> get shadowLg => AppShadows.lg;
}
