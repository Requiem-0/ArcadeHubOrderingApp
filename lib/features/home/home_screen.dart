import 'package:flutter/services.dart';
// lib/features/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/brandkit/app_spacing.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/repositories/pos_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../shared/widgets/app_drawer.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    
    // Auto-slide carousel every 4 seconds
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      if (_sliderCtrl.hasClients) {
        final next = (_activeSlideIndex + 1) % 3;
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

  void _updateCountdown() {
    final now = DateTime.now();
    final happyHourStart = DateTime(now.year, now.month, now.day, 16, 0);
    final happyHourEnd = DateTime(now.year, now.month, now.day, 19, 0);

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
                color: colors.scaffold,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo & Title
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [colors.primaryRed, colors.deepRed],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colors.primaryRed.withValues(alpha: 0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.sports_esports_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
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

                  // 1. Featured Zones Slider (Hero Discovery)
                  SizedBox(
                    height: 280, // Reduced hero height
                    child: PageView.builder(
                      controller: _sliderCtrl,
                      clipBehavior: Clip.none,
                      onPageChanged: (i) =>
                          setState(() => _activeSlideIndex = i),
                      itemCount: kArcadeExperiences.length,
                      itemBuilder: (context, i) {
                        final exp = kArcadeExperiences[i];
                        return _FeaturedZoneCard(
                          exp: exp,
                          pageController: _sliderCtrl,
                          index: i,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(kArcadeExperiences.length, (i) {
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

                  AppSpacing.gapV32,

                  // 2. Discount Promo Card
                  PromoTicketCard(
                    title: 'App-Exclusive',
                    subtitle: 'Apply 10% off to any purchase from the app. Valid 10 AM - 4 PM today.',
                    discountValue: '10%',
                    discountType: 'OFF',
                    remainingTime: _remainingTime,
                    countLabel: _countLabel,
                  ),

                  AppSpacing.gapV24,

                  // 2. Explore the Hub (Tightened Grid)
                  _SectionHeader(
                    title: 'Explore the Hub',
                  ),
                  const SizedBox(height: 20),

                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: const _RotatingBentoGrid(),
                  ),

                  AppSpacing.gapV16,


                  // 4. Bundle Deals Section (Filtered by Category 'Bundle')
                  _SectionHeader(
                    title: 'Bundle Deals',
                  ),
                  const SizedBox(height: 24),

                  ref.watch(bundleProductsProvider).when(
                        loading: () => _BundleSkeleton(),
                        error: (_, __) => _buildNoBundlesPlaceholder(colors),
                        data: (bundleProducts) {
                          if (bundleProducts.isEmpty) {
                            return _buildNoBundlesPlaceholder(colors);
                          }

                          return SizedBox(
                            height: 220,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: AppSpacing.pagePadding,
                              itemCount: bundleProducts.length,
                              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                              itemBuilder: (context, index) {
                                return _BundleCard(product: bundleProducts[index]);
                              },
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildNoBundlesPlaceholder(AppThemeColors colors) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: colors.cardShadow,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                color: colors.primaryRed,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Bundles Available',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'There are currently no active bundle deals. Check back soon for new combo offers!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: colors.textPrimary,
          letterSpacing: -0.5,
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
                    right: widget.isLarge ? -15 : -10,
                    bottom: widget.isLarge ? -15 : -10,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Icon(
                        exp.iconData,
                        size: widget.isLarge ? 110 : 64,
                        color: fgColor.withValues(alpha: colors.isDark ? 0.05 : 0.12),
                      ),
                    ),
                  ),
                  // Foreground content
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.all(widget.isLarge ? AppSpacing.md : 10),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(exp.iconData, color: fgColor, size: 24),
        const SizedBox(height: 4),
        Text(
          exp.name,
          style: GoogleFonts.dmSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _FeaturedZoneCard extends StatelessWidget {
  final ArcadeExperience exp;
  final PageController pageController;
  final int index;

  const _FeaturedZoneCard({
    required this.exp,
    required this.pageController,
    required this.index,
  });

  String _getZoneImage(String id) {
    switch (id) {
      case 'playroom': return 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=2071&auto=format&fit=crop';
      case 'partyroom': return 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1974&auto=format&fit=crop';
      case 'sportsbar': return 'https://images.unsplash.com/photo-1575444758702-4a6b9222336e?q=80&w=2070&auto=format&fit=crop';
      case 'rooftop': return 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?q=80&w=1974&auto=format&fit=crop';
      case 'area51': return 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?q=80&w=2070&auto=format&fit=crop';
      case 'easyroom': return 'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?q=80&w=2070&auto=format&fit=crop';
      default: return 'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=2071&auto=format&fit=crop';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
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
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors.cardElevated,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: fgColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                  boxShadow: colors.isDark
                      ? [
                          BoxShadow(
                            color: fgColor.withValues(alpha: 0.15),
                            blurRadius: 30,
                            spreadRadius: 2,
                            offset: const Offset(0, 15),
                          ),
                        ]
                      : colors.cardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Parallax Photographic Background
                    Image.network(
                      _getZoneImage(exp.id),
                      fit: BoxFit.cover,
                      alignment: Alignment(pageOffset * 0.8, 0),
                    ),
                    
                    // Gradient overlay to make text readable (Wonderous style)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Bar (Tag and Icon)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: fgColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  exp.featureTag.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: fgColor,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: fgColor.withValues(alpha: 0.4)),
                                ),
                                child: Icon(
                                  exp.iconData,
                                  color: fgColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                          
                          const Spacer(),
                          
                          // Bottom Info
                          Text(
                            exp.name,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            exp.tagline,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: Colors.white70,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
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
          padding: AppSpacing.pagePadding,
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
              clipper: _TicketClipper(holeRadius: 16),
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
                        width: 105,
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
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
                                fontSize: 36,
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.local_activity_rounded, size: 14, color: widget.brandColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    widget.title.toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.5,
                                      color: widget.brandColor,
                                    ),
                                  ),
                                ],
                              ),
                              AppSpacing.gapV8,
                              Text(
                                widget.subtitle,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: colors.textSecondary,
                                  height: 1.4,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              AppSpacing.gapV16,
                              
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
                                  Text(
                                    widget.countLabel.toUpperCase(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textMuted,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDuration(widget.remainingTime),
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: colors.textPrimary,
                                      letterSpacing: 1,
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


/// Bundle Deal Skeleton Loader (shown while POS data loads)
class _BundleSkeleton extends StatefulWidget {
  @override
  State<_BundleSkeleton> createState() => _BundleSkeletonState();
}

class _BundleSkeletonState extends State<_BundleSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
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
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: 220,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pagePadding,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, __) => Container(
            width: 310,
            decoration: BoxDecoration(
              color: colors.card.withValues(alpha: _anim.value),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.border),
            ),
          ),
        ),
      ),
    );
  }
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
              width: 310,
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
                          ref.read(cartProvider.notifier).add(product.id);
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
