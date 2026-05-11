import 'package:flutter/widgets.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = '.SF Pro Text';

  static final TextStyle h1Light = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryLight,
    height: 1.2,
    letterSpacing: 0.37,
  );

  static final TextStyle h1Dark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryDark,
    height: 1.2,
    letterSpacing: 0.37,
  );

  static final TextStyle h2Light = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryLight,
    height: 1.2,
    letterSpacing: 0.35,
  );

  static final TextStyle h2Dark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.labelPrimaryDark,
    height: 1.2,
    letterSpacing: 0.35,
  );

  static final TextStyle h3Light = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryLight,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static final TextStyle h3Dark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryDark,
    height: 1.3,
    letterSpacing: 0.35,
  );

  static final TextStyle bodyLargeLight = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryLight,
    height: 1.5,
    letterSpacing: -0.41,
  );

  static final TextStyle bodyLargeDark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryDark,
    height: 1.5,
    letterSpacing: -0.41,
  );

  static final TextStyle bodyMediumLight = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryLight,
    height: 1.4,
    letterSpacing: -0.24,
  );

  static final TextStyle bodyMediumDark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.labelPrimaryDark,
    height: 1.4,
    letterSpacing: -0.24,
  );

  static final TextStyle bodySmallLight = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.labelSecondaryLight,
    height: 1.4,
    letterSpacing: -0.08,
  );

  static final TextStyle bodySmallDark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.labelSecondaryDark,
    height: 1.4,
    letterSpacing: -0.08,
  );

  static final TextStyle captionLight = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.labelTertiaryLight,
    height: 1.3,
    letterSpacing: 0,
  );

  static final TextStyle captionDark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.labelTertiaryDark,
    height: 1.3,
    letterSpacing: 0,
  );

  static final TextStyle buttonLight = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryLight,
    height: 1.3,
    letterSpacing: -0.41,
  );

  static final TextStyle buttonDark = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.labelPrimaryDark,
    height: 1.3,
    letterSpacing: -0.41,
  );
}
