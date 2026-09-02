// lib/core/brandkit/app_theme_colors.dart
import 'package:flutter/material.dart';

/// Idiomatic ThemeExtension providing semantic colors for Arcade Hub.
/// Guarantees 100% byte-for-byte fidelity with shipping Dark Mode
/// while providing an elevated, WCAG-compliant Light Mode.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  final Color scaffold;
  final Color surface;
  final Color surfaceElevated;
  final Color card;
  final Color cardElevated;
  final Color border;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color primaryRed;
  final Color primaryRedDark;
  final Color deepRed;
  final Color redGlow;
  final List<BoxShadow> cardShadow;
  final bool isDark;

  const AppThemeColors({
    required this.scaffold,
    required this.surface,
    required this.surfaceElevated,
    required this.card,
    required this.cardElevated,
    required this.border,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryRed,
    required this.primaryRedDark,
    required this.deepRed,
    required this.redGlow,
    required this.cardShadow,
    required this.isDark,
  });

  // ── Exact Frozen Shipping Dark Tokens ─────────────────────────
  static const dark = AppThemeColors(
    scaffold: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    surfaceElevated: Color(0xFF1A1A1A),
    card: Color(0xFF1A1A1A),
    cardElevated: Color(0xFF212121),
    border: Color(0xFF2A2A2A),
    borderSubtle: Color(0xFF222222),
    textPrimary: Color(0xFFF0F0F0),
    textSecondary: Color(0xFFB0B0B0),
    textMuted: Color(0xFF888888),
    primaryRed: Color(0xFFCC0000),
    primaryRedDark: Color(0xFFFF1A1A),
    deepRed: Color(0xFF990000),
    redGlow: Color(0x33CC0000),
    cardShadow: [],
    isDark: true,
  );

  // ── Elevated Light Mode Palette ───────────────────────────────
  static const light = AppThemeColors(
    scaffold: Color(0xFFD8D8DC),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFE8E8EC),
    card: Color(0xFFFFFFFF),
    cardElevated: Color(0xFFFFFFFF),
    border: Color(0xFFC4C4C8),
    borderSubtle: Color(0xFFCECED2),
    textPrimary: Color(0xFF1C1C1E),
    textSecondary: Color(0xFF3A3A3C),
    textMuted: Color(0xFF7C7C82),
    primaryRed: Color(0xFFD32F2F),
    primaryRedDark: Color(0xFFCC0000),
    deepRed: Color(0xFFB71C1C),
    redGlow: Color(0x1AD32F2F),
    cardShadow: [
      BoxShadow(
        color: Color(0x140F172A),
        blurRadius: 16,
        spreadRadius: -2,
        offset: Offset(0, 6),
      ),
      BoxShadow(
        color: Color(0x0A0F172A),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
    isDark: false,
  );

  /// Resolves zone colors with WCAG AA compliance for light backgrounds
  Color resolveZoneForeground(Color darkZoneColor) {
    if (isDark) return darkZoneColor;
    // Map light background foregrounds to high-contrast rich tones
    final hex = darkZoneColor.toARGB32() & 0x00FFFFFF;
    switch (hex) {
      case 0xFACC15: // Play Room (Yellow 400)
      case 0xFFD700: // Gold
      case 0xEAB308:
        return const Color(0xFFB45309); // Amber 800
      case 0x4ADE80: // Sports Bar (Green 400)
      case 0x4CAF50: // Neon Green
      case 0x10B981:
      case 0x22C55E:
        return const Color(0xFF047857); // Emerald 700 / Deep Green
      case 0x3B82F6: // Easy Room (Blue 500)
      case 0x38BDF8: // Neon Sky / Cyan
      case 0x00E5FF:
      case 0x2563EB:
        return const Color(0xFF1D4ED8); // Blue 700
      case 0xA855F7: // Area 51 (Purple 500)
      case 0x9D4EDD: // Neon Purple
      case 0x9333EA:
        return const Color(0xFF7E22CE); // Purple 700
      case 0xEF4444: // Party Room (Red 500)
      case 0xFFFF3B5C: // Pink / Red
      case 0xFFFF1A1A:
      case 0xDC2626:
        return const Color(0xFFDC2626); // Red 600
      case 0xF8FAFC: // Rooftop Restro (Silver / White)
      case 0xFFFFFF:
      case 0xE2E8F0:
        return const Color(0xFF1E293B); // Slate 800
      default:
        return darkZoneColor;
    }
  }

  /// Resolves zone container background tint
  Color resolveZoneBackground(Color darkZoneColor) {
    if (isDark) {
      return darkZoneColor.withValues(alpha: 0.14);
    }
    final fg = resolveZoneForeground(darkZoneColor);
    return fg.withValues(alpha: 0.12);
  }

  /// Resolves zone border tint
  Color resolveZoneBorder(Color darkZoneColor) {
    if (isDark) {
      return darkZoneColor.withValues(alpha: 0.25);
    }
    final fg = resolveZoneForeground(darkZoneColor);
    return fg.withValues(alpha: 0.35);
  }

  @override
  AppThemeColors copyWith({
    Color? scaffold,
    Color? surface,
    Color? surfaceElevated,
    Color? card,
    Color? cardElevated,
    Color? border,
    Color? borderSubtle,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? primaryRed,
    Color? primaryRedDark,
    Color? deepRed,
    Color? redGlow,
    List<BoxShadow>? cardShadow,
    bool? isDark,
  }) {
    return AppThemeColors(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      card: card ?? this.card,
      cardElevated: cardElevated ?? this.cardElevated,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryRed: primaryRed ?? this.primaryRed,
      primaryRedDark: primaryRedDark ?? this.primaryRedDark,
      deepRed: deepRed ?? this.deepRed,
      redGlow: redGlow ?? this.redGlow,
      cardShadow: cardShadow ?? this.cardShadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) return this;
    return AppThemeColors(
      scaffold: Color.lerp(scaffold, other.scaffold, t) ?? scaffold,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t) ?? surfaceElevated,
      card: Color.lerp(card, other.card, t) ?? card,
      cardElevated: Color.lerp(cardElevated, other.cardElevated, t) ?? cardElevated,
      border: Color.lerp(border, other.border, t) ?? border,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t) ?? borderSubtle,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      primaryRed: Color.lerp(primaryRed, other.primaryRed, t) ?? primaryRed,
      primaryRedDark: Color.lerp(primaryRedDark, other.primaryRedDark, t) ?? primaryRedDark,
      deepRed: Color.lerp(deepRed, other.deepRed, t) ?? deepRed,
      redGlow: Color.lerp(redGlow, other.redGlow, t) ?? redGlow,
      cardShadow: t < 0.5 ? cardShadow : other.cardShadow,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

/// Ergonomic extension for BuildContext
extension AppThemeContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.dark;
  bool get isDarkMode => appColors.isDark;
}
