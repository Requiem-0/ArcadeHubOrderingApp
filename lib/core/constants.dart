// lib/core/constants.dart
// Single source of truth for Arcade Hub app-wide constants

class AppConstants {
  AppConstants._();

  // ── Branding & Business ────────────────────────────────────────
  static const String appName = 'Arcade Hub';
  static const String appLocation = 'Lakeside, Pokhara, Nepal';
  static const String appTagline = 'Gaming, Food, Drinks & Entertainment';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = 'NPR';
  static const String whatsappNumber = '+9779805855494';
  static const String whatsappFormatted = '+977 9805855494';

  // ── API ───────────────────────────────────────────────────────
  static const String baseUrl = 'https://api.arcadehub.com/v1';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // ── Business Rules ────────────────────────────────────────────
  static const double vatRate = 0.13; // 13% VAT

  // App Discount Config (X% OFF during A -> B hours)
  // Set these via API/Config. Using null to denote unconfigured.
  static const double? discountPercentage = null; // e.g. 10.0
  static const int? discountStartHour = null; // e.g. 17 (5:00 PM)
  static const int? discountEndHour = null;   // e.g. 20 (8:00 PM)

  // PS5 Rental Config (Legacy, should be driven by ServiceModel)
  static const double? ps5BasePriceNPR = null;
  static const String? ps5StartTime = null;
  static const String? ps5EndTime = null;
  static const double? ps5LateFeePerHourNPR = null;

  // ── UI ────────────────────────────────────────────────────────
  static const double bottomNavHeight = 76.0;
  static const double pageHorizontalPadding = 20.0;

  static bool isDiscountActiveNow() {
    if (discountStartHour == null || discountEndHour == null) return false;
    final nowHour = DateTime.now().hour;
    return nowHour >= discountStartHour! && nowHour < discountEndHour!;
  }
}
