// lib/core/brandkit/app_spacing.dart
import 'package:flutter/material.dart';

/// Standard 8pt spacing system for Arcade Hub UI layout consistency.
class AppSpacing {
  AppSpacing._();

  // Spacing values
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;

  // Horizontal SizedBoxes
  static const SizedBox gapH4 = SizedBox(width: xxs);
  static const SizedBox gapH8 = SizedBox(width: xs);
  static const SizedBox gapH12 = SizedBox(width: sm);
  static const SizedBox gapH16 = SizedBox(width: md);
  static const SizedBox gapH24 = SizedBox(width: lg);
  static const SizedBox gapH32 = SizedBox(width: xl);

  // Vertical SizedBoxes
  static const SizedBox gapV4 = SizedBox(height: xxs);
  static const SizedBox gapV8 = SizedBox(height: xs);
  static const SizedBox gapV12 = SizedBox(height: sm);
  static const SizedBox gapV16 = SizedBox(height: md);
  static const SizedBox gapV24 = SizedBox(height: lg);
  static const SizedBox gapV32 = SizedBox(height: xl);

  // Standard Edge Padding
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: lg);
}
