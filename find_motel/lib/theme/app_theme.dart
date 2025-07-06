import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
  );

  static final ColorScheme _darkScheme = _lightScheme.copyWith(
    brightness: Brightness.dark,
    surface: const Color(0xFF222222),
    onSurface: Colors.white,
  );

  static ThemeData light() => ThemeData(
        colorScheme: _lightScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: _lightScheme.background,
      );

  static ThemeData dark() => ThemeData(
        colorScheme: _darkScheme,
        useMaterial3: true,
        scaffoldBackgroundColor: _darkScheme.background,
      );
}
