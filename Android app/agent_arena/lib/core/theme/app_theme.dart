import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkGlassmorphism {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.rambahaur,
        secondary: AppColors.purple,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          headlineMedium: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          labelLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.cardBorder),
        ),
        elevation: 8,
        shadowColor: AppColors.glassShadow,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.rambahaur,
          foregroundColor: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.rambahaur, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.rambahaur,
        foregroundColor: AppColors.background,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
    );
  }
}
