// lib/core/brandkit/app_colors.dart
import 'package:flutter/material.dart';

/// Arcade Hub color palette — black & red dark-first design.
class AppColors {
  AppColors._();

  // ── Reds ──────────────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFCC0000);
  static const Color primaryRedDark = Color(0xFFFF1A1A);
  static const Color deepRed = Color(0xFF990000);
  static const Color deepRedDark = Color(0xFFCC0000);
  static const Color redGlow = Color(0x33CC0000);
  static const Color redGlowDark = Color(0x33FF1A1A);

  // ── Blacks / Darks ────────────────────────────────────────────
  static const Color scaffoldLight = Color(0xFF0D0D0D);
  static const Color scaffoldDark = Color(0xFF0A0A0A);
  static const Color surfaceLight = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF141414);
  static const Color cardLight = Color(0xFF212121);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color borderLight = Color(0xFF2A2A2A);
  static const Color borderDark = Color(0xFF222222);

  // ── Text ──────────────────────────────────────────────────────
  static const Color textLight = Color(0xFFF0F0F0);
  static const Color textDark = Color(0xFFFAFAFA);
  static const Color textMutedLight = Color(0xFF888888);
  static const Color textMutedDark = Color(0xFF666666);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF4444);
  static const Color success = Color(0xFF4CAF50);
  static const Color successMuted = Color(0xFF2E7D32);
  static const Color pending = Color(0xFFFF9800);

  // ── Utility ───────────────────────────────────────────────────
  static const Color shadow = Color(0x66000000);
  static const Color overlay = Color(0xB8000000);
  static const Color transparent = Colors.transparent;

  // ── Theme Aliases for New Layouts ──────────────────────────────
  static const Color neonPurple = primaryRedDark;
  static const Color neonCyan = primaryRedDark;
  static const Color neonPink = primaryRed;
  static const Color neonGreen = Color(0xFF4CAF50);
  static const Color neonOrange = Color(0xFFFF9800);
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color bgDark = scaffoldDark;
  static const Color bgDark2 = surfaceDark;
  static const Color cardBg = cardLight;
  static const Color cardBg2 = surfaceLight;
  static const Color strokeBorder = borderLight;
}
