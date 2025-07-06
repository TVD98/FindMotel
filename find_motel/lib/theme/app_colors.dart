import 'package:flutter/material.dart';

/// Central place to store all brand colors.
/// Change the values here to update the entire app.
class AppColors {
  // Header line
  static const Color headerLinePrimary = Color(0xFF2D998E);
  static const Color headerLineOnPrimary = Color(0xFFFAFFFD);

  // Primary brand color
  static const Color primary = Color(0xFF248078);
  static const Color onPrimary = Color(0xFFFFFFFF); // #FFFFFF

  // Secondary accent
  static const Color secondary = Color(0xFF4CAF50);
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFFFDA7A); // #FFD47A

  // Neutral / grayscale
  static const Color strokeLight = Color(0xFFD1D1D1); // #D1D1D1
  static const Color elementPrimary = Color(0xFF1F1F1F); // #1F1F1F
  static const Color elementSecondary = Color(0xFF474747); // #474747

  // Text
  static const Color textHint = Color(0xFF504848); // #504848

  // Icon
  static const Color tertiary = Color(0xFF858585); // #858585

  // Highlight colors
  static const Color highlight = Color(0xFFFFD47A); // #FFD47A

  // Product specific background
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF111111);

  // Functional
  static const Color success = Color(0xFF2EB67D);
  static const Color warning = Color(0xFFF0B400);
  static const Color error = Color(0xFFE42A2A);
}
