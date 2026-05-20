import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App-wide color tokens and typography for the dark PhysiqueLab theme.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color primary = Color(0xFFCC0000);
  static const Color primaryLight = Color(0xFFFF4444);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);
  static const Color textCaption = Color(0xFF777777);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  static const Color macroProtein = Color(0xFFCC0000);
  static const Color macroFat = Color(0xFFF59E0B);
  static const Color macroCarbs = Color(0xFF3B82F6);
}

class AppSpacing {
  AppSpacing._();

  static const double horizontal = 16;
  static const double vertical = 20;
  static const double cardRadius = 16;
  static const double buttonRadius = 12;
}

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get display => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get subheading => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textCaption,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 0.5,
      );

  static TextStyle get error => GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.error,
      );
}
