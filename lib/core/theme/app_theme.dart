import 'package:flutter/material.dart';
import 'theme_data.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static AppThemeData get light => const AppThemeData(mode: AppThemeMode.light);
  static AppThemeData get dark => const AppThemeData(mode: AppThemeMode.dark);

  static AppThemeData fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static ThemeData toThemeData(AppThemeData appTheme) => ThemeData(
        useMaterial3: false,
        brightness:
            appTheme.mode == AppThemeMode.light ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: appTheme.backgroundPrimary,
        colorScheme: ColorScheme(
          brightness: appTheme.mode == AppThemeMode.light
              ? Brightness.light
              : Brightness.dark,
          primary: appTheme.brandPrimary,
          onPrimary: appTheme.backgroundPrimary,
          primaryContainer: appTheme.brandSecondary,
          secondary: appTheme.brandSecondary,
          onSecondary: appTheme.labelPrimary,
          secondaryContainer: appTheme.backgroundSecondary,
          tertiary: appTheme.brandBlue,
          onTertiary: appTheme.backgroundPrimary,
          surface: appTheme.backgroundPrimary,
          onSurface: appTheme.labelPrimary,
          surfaceContainerHighest: appTheme.backgroundSecondary,
          onSurfaceVariant: appTheme.labelSecondary,
          error: AppColors.brandPrimaryLight,
          onError: appTheme.backgroundPrimary,
          outline: AppColors.gray30Light,
          outlineVariant: AppColors.labelQuaternaryLight,
          shadow: const Color(0xFF000000),
          scrim: const Color(0x48000000),
          inverseSurface: appTheme.backgroundSecondary,
          onInverseSurface: appTheme.labelPrimary,
          inversePrimary: appTheme.brandPrimary,
          surfaceTint: appTheme.brandPrimary,
        ),
        textTheme: TextTheme(
          displayLarge: appTheme.h1,
          displayMedium: appTheme.h2,
          displaySmall: appTheme.h3,
          headlineMedium: appTheme.bodyLarge,
          headlineSmall: appTheme.bodyMedium,
          titleLarge: appTheme.h3,
          titleMedium: appTheme.bodyLarge,
          titleSmall: appTheme.bodyMedium,
          bodyLarge: appTheme.bodyLarge,
          bodyMedium: appTheme.bodyMedium,
          bodySmall: appTheme.bodySmall,
          labelLarge: appTheme.button,
          labelMedium: appTheme.bodySmall,
          labelSmall: appTheme.caption,
        ),
        cardTheme: CardThemeData(
          color: appTheme.backgroundTertiary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusMd),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: appTheme.brandPrimary,
            foregroundColor: appTheme.backgroundPrimary,
            padding: EdgeInsets.symmetric(
              horizontal: appTheme.spacingLg,
              vertical: appTheme.spacingSm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
            ),
            textStyle: appTheme.button,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: appTheme.brandPrimary,
            textStyle: appTheme.bodyMedium,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: appTheme.brandPrimary,
            side: BorderSide(color: appTheme.gray30),
            padding: EdgeInsets.symmetric(
              horizontal: appTheme.spacingLg,
              vertical: appTheme.spacingSm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
            ),
            textStyle: appTheme.bodyMedium,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appTheme.backgroundSecondary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
            borderSide: BorderSide(color: appTheme.gray30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
            borderSide: BorderSide(color: appTheme.gray30),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
            borderSide: BorderSide(color: appTheme.brandPrimary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: appTheme.spacingMd,
            vertical: appTheme.spacingSm,
          ),
          hintStyle: appTheme.bodySmall,
        ),
        dividerTheme: DividerThemeData(
          color: appTheme.gray30,
          thickness: 1,
          space: 1,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: appTheme.backgroundTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusLg),
          ),
          elevation: 8,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: appTheme.backgroundSecondary,
          contentTextStyle: appTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: appTheme.backgroundSecondary,
          labelStyle: appTheme.bodyMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(appTheme.borderRadiusSm),
          ),
        ),
        iconTheme: IconThemeData(
          color: appTheme.labelSecondary,
          size: 24,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: appTheme.backgroundPrimary,
          foregroundColor: appTheme.labelPrimary,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: appTheme.labelPrimary, size: 24),
          titleTextStyle: appTheme.h3,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: appTheme.backgroundPrimary,
          selectedItemColor: appTheme.labelPrimary,
          unselectedItemColor: appTheme.labelSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: appTheme.caption,
          unselectedLabelStyle: appTheme.caption,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: appTheme.brandPrimary,
          foregroundColor: appTheme.backgroundPrimary,
          elevation: 4,
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return appTheme.brandPrimary;
            }
            return appTheme.gray30;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const Color.fromARGB(128, 98, 0, 238);
            }
            return const Color.fromARGB(77, 0, 0, 0);
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return appTheme.brandPrimary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(appTheme.backgroundPrimary),
          side: BorderSide(color: appTheme.gray30),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return appTheme.brandPrimary;
            }
            return Colors.transparent;
          }),
        ),
      );
}
