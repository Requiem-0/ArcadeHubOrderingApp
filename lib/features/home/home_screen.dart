import 'package:flutter/services.dart';
// lib/features/home/home_screen.dart
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_spacing.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../shared/widgets/app_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
      if (_sliderCtrl.hasClients) {
        int nextPage = _sliderCtrl.page!.round() + 1;
        if (nextPage >= kArcadeExperiences.length) {
          _sliderCtrl.animateToPage(
            0,
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        } else {
          _sliderCtrl.nextPage(
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastOutSlowIn,
          );
        }
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
    final start = DateTime(now.year, now.month, now.day, 10);
    final end = DateTime(now.year, now.month, now.day, 16);
    DateTime target;
    if (now.isBefore(start)) {
      target = start;
      _countLabel = 'starts in';
    } else if (now.isBefore(end)) {
      target = end;
      _countLabel = 'ends in';
    } else {
      target = start.add(const Duration(days: 1));
      _countLabel = 'starts in';
    }
    setState(() {
      _remainingTime = target.difference(now);
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldDark,
      drawer: const ArcadeAppDrawer(),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar Header ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              color: AppColors.scaffoldDark,
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
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryRedDark, AppColors.deepRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRedDark.withValues(alpha: 0.4),
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
                              color: AppColors.textLight,
                            ),
                          ),
                          Text(
                            'GAME HOUSE · RESTRO',
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.8,
                              color: AppColors.textMutedLight,
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
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 18,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRedDark,
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
                                    color: AppColors.primaryRedDark,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              AppSpacing.gapV4,
                              Container(
                                width: 18,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryRedDark,
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
                              ? AppColors.primaryRedDark
                              : AppColors.borderLight.withValues(alpha: 0.5),
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
                        error: (_, __) => _buildNoBundlesPlaceholder(),
                        data: (bundleProducts) {
                          if (bundleProducts.isEmpty) {
                            return _buildNoBundlesPlaceholder();
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
    );
  }

  Widget _buildNoBundlesPlaceholder() {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: AppColors.primaryRedDark,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No Bundles Available',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'There are currently no active bundle deals. Check back soon for new combo offers!',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: AppColors.textMutedLight,
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
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
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
    final exp = widget.exp;
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;

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
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: color.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                        size: widget.isLarge ? 110 : 70,
                        color: color.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  // Foreground content
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: widget.isLarge
                          ? _buildLargeLayout(exp, color)
                          : _buildSmallLayout(exp, color),
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

  Widget _buildLargeLayout(ArcadeExperience exp, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Hero(
          tag: 'zone_icon_${exp.id}',
          child: Container(
            padding: const EdgeInsets.all(10), // Reduced from 12
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(exp.iconData, color: color, size: 36), // Reduced from 48
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exp.name,
              style: GoogleFonts.outfit(
                fontSize: 20, // Reduced from 24
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.1,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              exp.subtitle.split('·').first.trim(),
              style: GoogleFonts.dmSans(
                fontSize: 12, // Reduced from 14
                color: AppColors.textMutedLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallLayout(ArcadeExperience exp, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: 'zone_icon_${exp.id}',
          child: Icon(exp.iconData, color: color, size: 22), // Reduced from 28
        ),
        AppSpacing.gapV4,
        Text(
          exp.name,
          style: GoogleFonts.dmSans(
            fontSize: 11, // Reduced from 12
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
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
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;

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
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: color.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: 2,
                      offset: const Offset(0, 15),
                    ),
                  ],
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
                                  border: Border.all(color: color.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  exp.featureTag.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                    color: color,
                                  ),
                                ),
                              ),
                              Hero(
                                tag: 'zone_icon_${exp.id}',
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: color.withValues(alpha: 0.4)),
                                  ),
                                  child: Icon(
                                    exp.iconData,
                                    color: color,
                                    size: 20,
                                  ),
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
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Padding(
          padding: AppSpacing.pagePadding,
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.brandColor.withValues(alpha: _glow.value * 0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipPath(
              clipper: _TicketClipper(holeRadius: 16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2A2A2A),
                      Color(0xFF1A1A1A),
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
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.brandColor.withValues(alpha: 0.2),
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
                        painter: _DashedLinePainter(color: Colors.white.withValues(alpha: 0.15)),
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
                                  color: AppColors.textLight,
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
                                      color: AppColors.textMutedLight,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatDuration(widget.remainingTime),
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
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
              color: AppColors.cardLight.withValues(alpha: _anim.value),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
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
    final tag = product.tags.isNotEmpty ? product.tags.first : 'Combo';
    final savePillText = product.tags.firstWhere(
      (t) => t.toUpperCase().contains('SAVE') || t.contains('%'),
      orElse: () => product.originalPrice != null
          ? 'SAVE ${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}%'
          : 'SPECIAL',
    );
    const cardAccentColor = AppColors.primaryRedDark;

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
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cardAccentColor.withValues(alpha: 0.35)),
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
                          color: AppColors.surfaceDark,
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
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), AppColors.primaryRedDark],
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

                  // Emoji & Title
                  Row(
                    children: [
                      Text(product.emoji.isNotEmpty ? product.emoji : '🍱', style: const TextStyle(fontSize: 32)),
                      AppSpacing.gapH8,
                      Expanded(
                        child: Text(
                          product.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
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
                      color: AppColors.textMutedLight,
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
                            color: AppColors.primaryRedDark,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added "${product.name}" to cart'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          backgroundColor: AppColors.primaryRed,
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
