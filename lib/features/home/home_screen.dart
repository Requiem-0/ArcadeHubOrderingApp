import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_breakpoints.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/brandkit/app_spacing.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/brandkit/zone_features.dart';
import '../../core/constants.dart';
import '../../core/repositories/pos_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../features/orders/data/order_model.dart';
import '../../core/repositories/order_repository.dart';
import '../../shared/widgets/app_drawer.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/app_logo.dart';
import 'venue_map/venue_map.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _sliderCtrl = PageController(viewportFraction: 0.88);
  int _activeSlideIndex = 0;
  Timer? _timer;
  Timer? _carouselTimer;
  late Duration _remainingTime;
  late String _countLabel;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    if (_promoConfigured) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    }
    
    // Auto-slide carousel every 4 seconds
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_sliderCtrl.hasClients) {
        final next = (_activeSlideIndex + 1) % kZoneFeatures.length;
        _sliderCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _carouselTimer?.cancel();
    _sliderCtrl.dispose();
    super.dispose();
  }

  /// The promo card mirrors the discount the cart actually applies, so it only
  /// shows once all three values are set in [AppConstants].
  static bool get _promoConfigured =>
      AppConstants.discountPercentage != null &&
      AppConstants.discountStartHour != null &&
      AppConstants.discountEndHour != null;

  static String _hourLabel(int hour) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    return '$h ${hour < 12 ? 'AM' : 'PM'}';
  }

  void _updateCountdown() {
    if (!_promoConfigured) {
      _remainingTime = Duration.zero;
      _countLabel = '';
      return;
    }
    final now = DateTime.now();
    final happyHourStart =
        DateTime(now.year, now.month, now.day, AppConstants.discountStartHour!);
    final happyHourEnd =
        DateTime(now.year, now.month, now.day, AppConstants.discountEndHour!);

    if (now.isBefore(happyHourStart)) {
      _remainingTime = happyHourStart.difference(now);
      _countLabel = 'STARTS IN';
    } else if (now.isBefore(happyHourEnd)) {
      _remainingTime = happyHourEnd.difference(now);
      _countLabel = 'ENDS IN';
    } else {
      final tomorrow = happyHourStart.add(const Duration(days: 1));
      _remainingTime = tomorrow.difference(now);
      _countLabel = 'NEXT IN';
    }
    if (mounted) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Scaffold(
      backgroundColor: colors.scaffold,
      drawerScrimColor: Colors.black.withValues(alpha: 0.75),
      drawer: const ArcadeAppDrawer(),
      body: Builder(
        builder: (innerContext) => SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── App Bar Header ─────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.scaffold,
                  border: Border(
                    bottom: BorderSide(
                      color: colors.borderSubtle,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Title
                    Row(
                      children: [
                        const AppLogoPlate(size: 40, glow: false, animate: true),
                        AppSpacing.gapH12,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARCADE HUB',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              'GAME HOUSE · RESTRO',
                              style: GoogleFonts.dmSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.8,
                                color: colors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Hamburger Drawer Button
                    Tooltip(
                      message: 'Open menu',
                      child: Material(
                        color: colors.cardElevated,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => Scaffold.of(innerContext).openDrawer(),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: colors.border),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: colors.primaryRed,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                AppSpacing.gapV4,
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    width: 12,
                                    height: 2,
                                    margin: const EdgeInsets.only(right: 11),
                                    decoration: BoxDecoration(
                                      color: colors.primaryRed,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                                AppSpacing.gapV4,
                                Container(
                                  width: 18,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: colors.primaryRed,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Main Scroll View ───────────────────────────────────────
              Expanded(
                child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  AppSpacing.gapV16,

                  // 0. Whatever is cooking right now
                  const _ActiveOrderBanner(),

                  // 1. Featured Zones Slider (Hero Discovery)
                  SizedBox(
                    height: 220, // Short enough to scroll past quickly
                    child: PageView.builder(
                      controller: _sliderCtrl,
                      clipBehavior: Clip.none,
                      onPageChanged: (i) =>
                          setState(() => _activeSlideIndex = i),
                      itemCount: kZoneFeatures.length,
                      itemBuilder: (context, i) => _FeaturedZoneCard(
                        feature: kZoneFeatures[i],
                        pageController: _sliderCtrl,
                        index: i,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(kZoneFeatures.length, (i) {
                      final active = i == _activeSlideIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active
                              ? colors.primaryRed
                              : colors.border.withValues(alpha: 0.7),
                        ),
                      );
                    }),
                  ),

                  // 2. Discount promo, only while a discount is configured
                  if (_promoConfigured) ...[
                    AppSpacing.gapV32,
                    PromoTicketCard(
                      title: 'App orders',
                      subtitle:
                          '${_hourLabel(AppConstants.discountStartHour!)}–'
                          '${_hourLabel(AppConstants.discountEndHour!)} daily',
                      discountValue: '${AppConstants.discountPercentage!.round()}%',
                      discountType: 'OFF',
                      remainingTime: _remainingTime,
                      countLabel: _countLabel,
                    ),
                  ],

                  // 3. Menu, straight from the POS catalogue
                  const _MenuSection(),

                  // 4. Bundle deals, hidden until the POS has bundle items
                  ...ref.watch(bundleProductsProvider).maybeWhen(
                        data: (bundleProducts) => bundleProducts.isEmpty
                            ? const <Widget>[]
                            : [
                                AppSpacing.gapV32,
                                _SectionHeader(title: 'Bundles'),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 220,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: context.pagePadding,
                                    itemCount: bundleProducts.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(width: 16),
                                    itemBuilder: (context, index) =>
                                        _BundleCard(product: bundleProducts[index]),
                                  ),
                                ),
                              ],
                        orElse: () => const <Widget>[],
                      ),

                  // 5. Explore the Hub
                  AppSpacing.gapV32,
                  _SectionHeader(
                    title: 'Zones',
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: context.pagePadding,
                    child: const _RotatingBentoGrid(),
                  ),

                  // 6. Venue location
                  AppSpacing.gapV32,
                  _SectionHeader(
                    title: 'Find us',
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: context.pagePadding,
                    child: const VenueMapCard(),
                  ),
                  AppSpacing.gapV32,
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

/// Shows the newest order that is still open, and nothing at all otherwise.
class _ActiveOrderBanner extends ConsumerWidget {
  const _ActiveOrderBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final order = ref.watch(myOrdersProvider).maybeWhen(
          data: (orders) => orders
              .cast<OrderModel?>()
              .firstWhere((o) => o!.status == OrderStatus.pending,
                  orElse: () => null),
          orElse: () => null,
        );
    if (order == null) return const SizedBox.shrink();

    final label = order.invoice != null ? '#${order.invoice}' : '#${order.id}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Material(
        color: colors.primaryRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/order/${order.id}', extra: order),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.primaryRed.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 18, color: colors.primaryRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Order $label · Preparing',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 20, color: colors.primaryRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: context.pagePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colors.primaryRed,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 36),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Horizontal strip of real menu items, with a way into the full menu.
/// Bundles live in their own section and zero-priced items are skipped, so
/// nothing appears here that a customer can't actually order. The whole
/// section disappears while loading or when the catalogue has nothing to show.
class _MenuSection extends ConsumerWidget {
  const _MenuSection();

  static const int _maxItems = 10;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogProvider).maybeWhen(
          data: (products) => products
              .where((p) =>
                  p.effectivePrice > 0 &&
                  !p.category.trim().toLowerCase().startsWith('bundle'))
              .take(_maxItems)
              .toList(),
          orElse: () => const <ProductModel>[],
        );
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSpacing.gapV32,
        _SectionHeader(
          title: 'Menu',
          actionLabel: 'See all',
          onAction: () => context.go('/food-menu'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 184,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: context.pagePadding,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) => _MenuItemCard(product: items[i]),
          ),
        ),
      ],
    );
  }
}

class _MenuItemCard extends ConsumerWidget {
  final ProductModel product;

  const _MenuItemCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final p = product;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/product/${p.id}'),
        child: Container(
          width: 132,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 90,
                  width: double.infinity,
                  child: AppNetworkImage(
                    url: p.imageUrl,
                    height: 90,
                    width: double.infinity,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppConstants.formatPrice(p.effectivePrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: colors.primaryRed,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Add ${p.name} to cart',
                    child: GestureDetector(
                      onTap: () {
                        if (p.variants.isNotEmpty) {
                          context.push('/product/${p.id}');
                          return;
                        }
                        HapticFeedback.lightImpact();
                        ref.read(cartProvider.notifier).add(p.id, p);
                        AppToast.showSuccess(context, 'Added "${p.name}" to cart');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: colors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Feature Grid Tile (3 columns, compact padding)

class _RotatingBentoGrid extends StatefulWidget {
  const _RotatingBentoGrid();

  @override
  State<_RotatingBentoGrid> createState() => _RotatingBentoGridState();
}

class _RotatingBentoGridState extends State<_RotatingBentoGrid> {
  int _offset = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _offset = (_offset + 1) % kArcadeExperiences.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exps = List.generate(kArcadeExperiences.length, (i) {
      return kArcadeExperiences[(i + _offset) % kArcadeExperiences.length];
    });

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: Column(
        key: ValueKey(_offset),
        children: [
          SizedBox(
            height: 180, // Reduced from 220 (~20%)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _FeatureGridItem(exp: exps[0], isLarge: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _FeatureGridItem(exp: exps[1])),
                      const SizedBox(height: 16),
                      Expanded(child: _FeatureGridItem(exp: exps[2])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80, // Reduced from 100 (20%)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _FeatureGridItem(exp: exps[3])),
                const SizedBox(width: 16),
                Expanded(child: _FeatureGridItem(exp: exps[4])),
                const SizedBox(width: 16),
                Expanded(child: _FeatureGridItem(exp: exps[5])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGridItem extends StatefulWidget {
  final ArcadeExperience exp;
  final bool isLarge;

  const _FeatureGridItem({required this.exp, this.isLarge = false});

  @override
  State<_FeatureGridItem> createState() => _FeatureGridItemState();
}

class _FeatureGridItemState extends State<_FeatureGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final exp = widget.exp;
    final fgColor = colors.resolveZoneForeground(exp.color);
    final bgColor = colors.resolveZoneBackground(exp.color);
    final borderColor = colors.resolveZoneBorder(exp.color);

    return Listener(
      onPointerDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onPointerUp: (_) {
        _ctrl.reverse();
        context.push('/experience/${exp.id}');
      },
      onPointerCancel: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colors.isDark ? borderColor : fgColor.withValues(alpha: 0.22),
                  width: 1.2,
                ),
                boxShadow: colors.isDark
                    ? [
                        BoxShadow(
                          color: fgColor.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : colors.cardShadow,
              ),
              child: Stack(
                children: [
                  // Subtle watermark in the background
                  Positioned(
                    right: widget.isLarge ? -15 : -8,
                    bottom: widget.isLarge ? -15 : -8,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        exp.iconData,
                        size: widget.isLarge ? 110 : 52,
                        color: fgColor.withValues(alpha: colors.isDark ? 0.05 : 0.12),
                      ),
                    ),
                  ),
                  // Foreground content
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.isLarge ? AppSpacing.md : 6,
                        vertical: widget.isLarge ? AppSpacing.md : 8,
                      ),
                      child: widget.isLarge
                          ? _buildLargeLayout(exp, fgColor, bgColor, colors)
                          : _buildSmallLayout(exp, fgColor, colors),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLargeLayout(ArcadeExperience exp, Color fgColor, Color bgColor, AppThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: fgColor.withValues(alpha: colors.isDark ? 0.25 : 0.22),
              width: 1.2,
            ),
          ),
          child: Icon(exp.iconData, color: fgColor, size: 34),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exp.name,
              style: GoogleFonts.outfit(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: colors.textPrimary,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              exp.subtitle.split('·').first.trim(),
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout(ArcadeExperience exp, Color fgColor, AppThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Center(
              child: Icon(exp.iconData, color: fgColor, size: 22),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            exp.name,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Carousel card for one [ZoneFeature]. The feature is the headline; the zone
/// it belongs to is named on the card, and tapping opens that zone.
class _FeaturedZoneCard extends StatelessWidget {
  final ZoneFeature feature;
  final PageController pageController;
  final int index;

  const _FeaturedZoneCard({
    required this.feature,
    required this.pageController,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final exp = feature.zone;
    final fgColor = colors.resolveZoneForeground(exp.color);

    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double pageOffset = 0;
        if (pageController.position.haveDimensions) {
          pageOffset = pageController.page! - index;
        } else {
          pageOffset = (pageController.initialPage - index).toDouble();
        }

        // Fade effect for non-active cards
        final opacity = (1 - (pageOffset.abs() * 0.3)).clamp(0.0, 1.0);
        // Slight scale for non-active cards
        final scale = (1 - (pageOffset.abs() * 0.1)).clamp(0.8, 1.0);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: GestureDetector(
              onTap: () => context.push('/experience/${exp.id}'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: colors.isDark
                      ? [
                          BoxShadow(
                            color: fgColor.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 15),
                          ),
                        ]
                      : const [
                          BoxShadow(
                            color: Color(0x30000000),
                            blurRadius: 24,
                            spreadRadius: 0,
                            offset: Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.isDark
                            ? fgColor.withValues(alpha: 0.25)
                            : Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax Photographic Background
                        AppNetworkImage(
                          url: feature.imageUrl,
                          alignment: Alignment(pageOffset * 0.8, 0),
                        ),
                        
                        // Gradient overlay to make text readable (Wonderous style)
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Bar (Tag and Icon)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.55),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: fgColor.withValues(alpha: 0.6)),
                                        ),
                                        child: Text(
                                          exp.name.toUpperCase(),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: fgColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.45),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: fgColor.withValues(alpha: 0.5)),
                                        ),
                                        child: Icon(
                                          feature.iconData,
                                          color: fgColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const Spacer(),
                              
                              // Bottom Info
                              Text(
                                feature.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                feature.line,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.85),
                                  height: 1.3,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    exp.name,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: fgColor,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, size: 18, color: fgColor),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}


class PromoTicketCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String discountValue;
  final String discountType;
  final Duration remainingTime;
  final String countLabel;
  final Color brandColor;

  const PromoTicketCard({
    required this.title,
    required this.subtitle,
    required this.discountValue,
    required this.discountType,
    required this.remainingTime,
    required this.countLabel,
    this.brandColor = AppColors.primaryRedDark,
  });

  @override
  State<PromoTicketCard> createState() => _PromoTicketCardState();
}

class _PromoTicketCardState extends State<PromoTicketCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.1, end: 0.6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Padding(
          padding: context.pagePadding,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: colors.isDark
                  ? [
                      BoxShadow(
                        color: widget.brandColor.withValues(alpha: _glow.value * 0.15),
                        blurRadius: 24,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      )
                    ]
                  : colors.cardShadow,
            ),
            child: ClipPath(
              clipper: _TicketClipper(holeRadius: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors.isDark
                        ? const [
                            Color(0xFF2A2A2A),
                            Color(0xFF1A1A1A),
                          ]
                        : const [
                            Color(0xFFFFFFFF),
                            Color(0xFFF9FAFB),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: widget.brandColor.withValues(alpha: 0.3 + (_glow.value * 0.4)),
                    width: 1.5,
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left Section: The Discount Badge
                      Container(
                        width: 84,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.brandColor.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.discountValue,
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1,
                                color: colors.textPrimary,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.brandColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.discountType.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2.5,
                                  color: widget.brandColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Vertical Perforated Divider
                      CustomPaint(
                        painter: _DashedLinePainter(color: colors.border),
                        size: const Size(1, double.infinity),
                      ),
                      
                      // Right Section: Info & Timer
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_activity_rounded, size: 14, color: widget.brandColor),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      widget.title.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        color: widget.brandColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.5,
                                  color: colors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              
                              // Sleek Timer HUD
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: widget.brandColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: widget.brandColor,
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.countLabel.toUpperCase(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textMuted,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  // The countdown is the point of the card, so
                                  // it shrinks last and only if it has to.
                                  Flexible(
                                    child: Text(
                                      _formatDuration(widget.remainingTime),
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: colors.textPrimary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

class _TicketClipper extends CustomClipper<Path> {
  final double holeRadius;

  _TicketClipper({required this.holeRadius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    // Left hole
    path.addOval(Rect.fromCircle(
      center: Offset(0, size.height / 2),
      radius: holeRadius,
    ));

    // Right hole
    path.addOval(Rect.fromCircle(
      center: Offset(size.width, size.height / 2),
      radius: holeRadius,
    ));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(_TicketClipper oldClipper) => oldClipper.holeRadius != holeRadius;
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const holeRadius = 1.5;
    const holeSpace = 8.0;
    double startY = 10.0;

    while (startY < size.height - 10) {
      canvas.drawCircle(Offset(0, startY), holeRadius, paint);
      startY += holeRadius * 2 + holeSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter oldDelegate) => oldDelegate.color != color;
}


/// Bundle Deal Card
class _BundleCard extends ConsumerStatefulWidget {
  final ProductModel product;

  const _BundleCard({required this.product});

  @override
  ConsumerState<_BundleCard> createState() => _BundleCardState();
}

class _BundleCardState extends ConsumerState<_BundleCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final colors = context.appColors;
    final tag = product.tags.isNotEmpty ? product.tags.first : 'Combo';
    final savePillText = product.tags.firstWhere(
      (t) => t.toUpperCase().contains('SAVE') || t.contains('%'),
      orElse: () => product.originalPrice != null
          ? 'SAVE ${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}%'
          : 'SPECIAL',
    );
    final cardAccentColor = colors.primaryRed;

    return Listener(
      onPointerDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onPointerUp: (_) => _ctrl.reverse(),
      onPointerCancel: (_) => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardAccentColor.withValues(alpha: 0.35)),
                boxShadow: colors.isDark
                    ? [
                        BoxShadow(
                          color: cardAccentColor.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : colors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Tag + Save Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.cardElevated,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: cardAccentColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          '● $tag',
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: cardAccentColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [const Color(0xFFFFD700), colors.primaryRed],
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          savePillText.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0A0A14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB703).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFFFB703).withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_menu_rounded,
                            size: 20,
                            color: Color(0xFFFFB703),
                          ),
                        ),
                      ),
                      AppSpacing.gapH8,
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  // Inclusions / Description
                  Text(
                    product.description,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: colors.textMuted,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Price & CTA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryRed,
                          ),
                          children: [
                            TextSpan(text: 'Rs. ${product.price.toInt()} '),
                            if (product.originalPrice != null)
                              TextSpan(
                                text: 'Rs. ${product.originalPrice!.toInt()}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.textMutedLight,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(cartProvider.notifier).add(product.id, product);
                          AppToast.showSuccess(context, 'Added "${product.name}" to cart');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          backgroundColor: colors.primaryRed,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Grab deal',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
