import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.indigoPrimary,
      primary: AppColors.indigoPrimary,
      secondary: AppColors.amberAccent,
      surface: AppColors.surfaceLight,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.indigoPrimary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.amberAccent,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.indigoPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceLight,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: AppColors.indigoPrimary.withOpacity(0.08),
      selectedColor: AppColors.amberAccent,
    ),
    textTheme: _buildTextTheme(base.textTheme),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.indigoPrimary,
      primary: AppColors.indigoLight,
      secondary: AppColors.amberAccent,
      surface: AppColors.surfaceDark,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.indigoDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.amberAccent,
      foregroundColor: AppColors.indigoPrimary,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceDark,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: _buildTextTheme(base.textTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.copyWith(
    displayLarge: base.displayLarge?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
    headlineSmall: base.headlineSmall?.copyWith(fontFamily: 'Sora', fontWeight: FontWeight.w700),
    titleLarge: base.titleLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w600),
    bodyLarge: base.bodyLarge?.copyWith(fontFamily: 'Inter'),
    bodyMedium: base.bodyMedium?.copyWith(fontFamily: 'Inter'),
    labelLarge: base.labelLarge?.copyWith(fontFamily: 'Inter', fontWeight: FontWeight.w600),
  );
}
