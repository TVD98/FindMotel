import 'package:find_motel/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyle {
  static TextStyle quicksand = GoogleFonts.quicksand();
}

class AppFontWeight {
  static const FontWeight regular= FontWeight.w200;
  static const FontWeight medium = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w800;
}

class AppTextStyle extends TextStyle {

  static TextStyle title = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementSecondary,
    fontWeight: AppFontWeight.medium,
    fontSize: 18,
  );
  
  static TextStyle heading2 = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 28,
    letterSpacing: -0.2
  );
  static TextStyle heading3 = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 24,
    letterSpacing: -0.1
  );
  static TextStyle heading4 = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 20,
  );
  static TextStyle heading5 = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 18,
  );
  static TextStyle subtitle = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementSecondary,
    fontWeight: AppFontWeight.bold,
    fontSize: 14,
    letterSpacing: 0.15
  );
   static TextStyle body = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementSecondary,
    fontWeight: AppFontWeight.regular,
    fontSize: 14,
    letterSpacing: 0.25
  );
  static TextStyle smallBody =  AppFontStyle.quicksand.copyWith(
    color: AppColors.elementSecondary,
    fontWeight: AppFontWeight.regular,
    fontSize: 12,
    letterSpacing: 0.25
  );
  static TextStyle label = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 16,
    letterSpacing: 0.5
  );
  static TextStyle smallLabel = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementPrimary,
    fontWeight: AppFontWeight.semiBold,
    fontSize: 14,
    letterSpacing: 0.5
  );
 
  static TextStyle caption = AppFontStyle.quicksand.copyWith(
    color: AppColors.elementSecondary,
    fontWeight: AppFontWeight.regular,
    fontSize: 10,
    letterSpacing: 0.4
  );
}
