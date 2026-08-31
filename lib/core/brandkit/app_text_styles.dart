// lib/core/brandkit/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system for Arcade Hub.
/// Heading: DM Serif Display | Body: DM Sans | Mono: JetBrains Mono
class AppTextStyles {
  AppTextStyles._();

  // ── Display / Heading ─────────────────────────────────────────
  static TextStyle display(Color color) => GoogleFonts.dmSerifDisplay(
        fontSize: 40,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.1,
      );

  static TextStyle headingXL(Color color) => GoogleFonts.dmSerifDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.2,
      );

  static TextStyle headingL(Color color) => GoogleFonts.dmSerifDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.25,
      );

  static TextStyle headingM(Color color) => GoogleFonts.dmSerifDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  static TextStyle headingS(Color color) => GoogleFonts.dmSerifDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.3,
      );

  // ── Body ─────────────────────────────────────────────────────
  static TextStyle bodyXL(Color color) => GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyL(Color color) => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyM(Color color) => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyS(Color color) => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyXS(Color color) => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.4,
      );

  // ── Labels / Caps ────────────────────────────────────────────
  static TextStyle label(Color color) => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 1.2,
        height: 1.3,
      );

  static TextStyle labelM(Color color) => GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.3,
      );

  // ── Semibold helpers ─────────────────────────────────────────
  static TextStyle semibold(Color color, {double size = 15}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle bold(Color color, {double size = 15}) =>
      GoogleFonts.dmSans(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.4,
      );

  // ── Mono ─────────────────────────────────────────────────────
  static TextStyle mono(Color color, {double size = 13}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.5,
      );

  static TextStyle monoBold(Color color, {double size = 14}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.5,
      );
}
