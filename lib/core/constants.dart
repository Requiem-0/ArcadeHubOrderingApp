// lib/core/constants.dart
// Single source of truth for Arcade Hub app-wide constants

abstract final class AppConstants {
  static String appName = 'Arcade Hub';
  static String currency = 'NPR';

  static const String appLocation = 'Lakeside, Pokhara, Nepal';
  static const String appTagline = 'Gaming, Food, Drinks & Entertainment';
  static const String appVersion = '1.0.0';
  static const String currencySymbol = 'NPR';
  static const String whatsappNumber = '+9779805855494';
  static const String whatsappFormatted = '+977 9805855494';

  // One bool, three things switch: API host, image host, business id.
  // `true` for prod builds, `false` for dev/demo. Touches [apiBaseUrl],
  // [imageHostUrl], and [businessId] in one shot.
  static const bool useProd = false;

  /// Beta business to test stuff for the app. Pointed at POS demo business
  /// that carries active VAT (13% exclusive) and discount rules.
  static const String devBusinessId = '6a8a87631d9c3a6661f3bb12';

  /// Arcade Hub Pvt Ltd — the actual customer prod business ID on RebuzzPOS.
  static const String prodBusinessId = '65db0f54d0199c9b3dc7ab15';

  /// The business `_id` on the rebuzzpos POS backend. Every product/category/popularity
  /// call is scoped to this id via the `/api/businesses/{id}/products/*` endpoints.
  static const String businessId =
      useProd ? prodBusinessId : devBusinessId;

  /// Dynamic getter alias for compatibility across repositories
  static String get activeBusinessId => businessId;

  /// JSON API base URL. ApiClient reads from this.
  static const String apiBaseUrl = useProd
      ? 'https://api.order.rebuzzpos.com/api'
      : 'https://api.beta.order.rebuzzpos.com/api';

  static const String baseUrl = apiBaseUrl;

  /// Host that serves product and business-logo images — a *different*
  /// subdomain from the API host (images on `*.rebuzzpos.com`, JSON on
  /// `*.order.rebuzzpos.com`).
  static const String imageHostUrl = useProd
      ? 'https://appapi.rebuzzpos.com'
      : 'https://api.beta.rebuzzpos.com';

  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // ── Business Rules ────────────────────────────────────────────
  static const double vatRate = 0.13; // 13% VAT

  // App Discount Config (X% OFF during A -> B hours)
  static const double? discountPercentage = null;
  static const int? discountStartHour = null;
  static const int? discountEndHour = null;

  // ── UI ────────────────────────────────────────────────────────
  static const double bottomNavHeight = 76.0;
  static const double pageHorizontalPadding = 20.0;

  /// Format a price value for display (e.g. "NPR 500").
  static String formatPrice(double price) =>
      '$currency ${price.toStringAsFixed(0)}';

  /// Overwrite the mutable branding fields from API-loaded values.
  static void applyBranding({
    String? appName,
    String? currency,
  }) {
    final n = appName?.trim();
    if (n != null && n.isNotEmpty) AppConstants.appName = n;
    final c = currency?.trim();
    if (c != null && c.isNotEmpty) AppConstants.currency = c;
  }

  /// Build an absolute image URL from whatever the API returned.
  /// Returns null for null/empty input. Pass-through if already absolute.
  static String? resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return '$imageHostUrl/$cleaned';
  }

  static bool isDiscountActiveNow() {
    if (discountStartHour == null || discountEndHour == null) return false;
    final nowHour = DateTime.now().hour;
    return nowHour >= discountStartHour! && nowHour < discountEndHour!;
  }
}
