import 'package:flutter/material.dart';

class AppColors {
  AppColors._();
  // Backgrounds
  static const Color background = Color(0xFF0D0D1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFF25253D);
  // Rambahaur (ex-PRO) — golden yellow
  static const Color rambahaur = Color(0xFFFFCC00);
  static const Color rambahaurDark = Color(0xFFCC9900);
  // Shaam Bahadur (ex-CON) — striking magenta
  static const Color shaamBahadur = Color(0xFFFF0055);
  static const Color shaamBahadurDark = Color(0xFFCC0044);
  // Legacy agent colors
  static const Color agentA = Color(0xFFFFCC00);
  static const Color agentB = Color(0xFFFF0055);
  static const Color agentOptimist = Color(0xFF00E676);
  static const Color agentPessimist = Color(0xFFFF5252);
  static const Color agentEngineer = Color(0xFF448AFF);
  static const Color agentEconomist = Color(0xFFFFAB00);
  // UI accents
  static const Color cyan = Color(0xFF00E5FF);
  static const Color purple = Color(0xFF7C4DFF);
  static const Color pink = Color(0xFFFF4081);
  static const Color amber = Color(0xFFFFAB00);
  static const Color green = Color(0xFF00E676);
  // Card styling
  static const Color cardBackground = Color(0xFF1A1A2E);
  static const Color cardBorder = Color(0xFF2A2A4A);
  static Color glassBackground = const Color(0xFF1A1A2E);
  static Color glassBorder = const Color(0xFF2A2A4A);
  static Color glassShadow = Colors.black.withValues(alpha: 0.3);
  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textMuted = Color(0xFF6B6B80);
  // States
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFAB00);
  static const Color error = Color(0xFFFF5252);
}
