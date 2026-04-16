import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light theme primary palette
  static const Color primary = Color(0xFF6C3FC5);
  static const Color primaryLight = Color(0xFF9B6EF3);
  static const Color primaryDark = Color(0xFF4A25A0);
  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentGreen = Color(0xFF6BCB77);
  static const Color accentBlue = Color(0xFF4D96FF);
  static const Color accentOrange = Color(0xFFFF9A3C);
  static const Color accentCyan = Color(0xFF00D4FF);

  // Background & surface
  static const Color background = Color(0xFFF5F0FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EAFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF1A1033);
  static const Color textSecondary = Color(0xFF6B5E8A);
  static const Color textLight = Color(0xFFFFFFFF);

  // Crystal colors
  static const Color crystalRed = Color(0xFFFF4757);
  static const Color crystalBlue = Color(0xFF2F80ED);
  static const Color crystalGreen = Color(0xFF27AE60);
  static const Color crystalYellow = Color(0xFFF2C94C);
  static const Color crystalPurple = Color(0xFF9B51E0);
  static const Color crystalCyan = Color(0xFF00BCD4);
  static const Color crystalOrange = Color(0xFFFF6B35);

  // Gradients
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C3FC5), Color(0xFFFF6B9D), Color(0xFF4D96FF)],
  );

  static const LinearGradient menuGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF7B4FD6), Color(0xFF4A25A0)],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF9B6EF3), Color(0xFF6C3FC5)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFF9A3C)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.nunitoTextTheme().copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        titleTextStyle: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class AppConstants {
  static const int gridSize = 8;
  static const int numCrystalTypes = 6;
  static const Duration swapDuration = Duration(milliseconds: 200);
  static const Duration popDuration = Duration(milliseconds: 300);
  static const Duration fallDuration = Duration(milliseconds: 250);
  static const double cellSize = 44.0;
  static const double cellSpacing = 3.0;
  static const String appName = 'CrystalPopperz';
  static const String developerName = 'Alvonso';
  static const String devEmail = 'bitvavo2fa@gmail.com';
}
