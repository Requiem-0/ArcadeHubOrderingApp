// lib/features/home/home_screen.dart
import 'dart:async';
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
  late Duration _remainingTime;
  late String _countLabel;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }


  @override
  void dispose() {
    _timer?.cancel();
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
                  AppSpacing.gapV8,

                  // 1. Discount Promo Card
                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryRed.withValues(alpha: 0.18),
                            AppColors.surfaceLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primaryRedDark.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // 10% Off Badge
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => const LinearGradient(
                                  colors: [Color(0xFFFFD700), AppColors.primaryRedDark],
                                ).createShader(bounds),
                                child: Text(
                                  '10%',
                                  style: GoogleFonts.outfit(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'OFF',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  color: AppColors.primaryRedDark,
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapH16,

                          // Info Text
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'App-exclusive discount 🎉',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                AppSpacing.gapV4,
                                RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight,
                                    ),
                                    children: const [
                                      TextSpan(text: 'On any purchase from app\nValid '),
                                      TextSpan(
                                        text: '10 AM – 4 PM',
                                        style: TextStyle(
                                          color: Color(0xFFFFD700),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ' today'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Timer Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _formatDuration(_remainingTime),
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryRedDark,
                                  ),
                                ),
                                Text(
                                  _countLabel.toUpperCase(),
                                  style: GoogleFonts.dmSans(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AppSpacing.gapV24,

                  // 2. Explore the Hub (Tightened Grid)
                  _SectionHeader(
                    title: 'Explore the Hub',
                    actionLabel: 'See all',
                    onAction: () => context.push('/food-menu'),
                  ),
                  const SizedBox(height: 16),

                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // 3 items per row, 2 gaps of 16px
                        final itemWidth = (constraints.maxWidth - 32) / 3;
                        return Wrap(
                          spacing: 16,
                          runSpacing: 24,
                          children: kArcadeExperiences.map((exp) {
                            return SizedBox(
                              width: itemWidth,
                              child: _FeatureGridItem(exp: exp),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),

                  AppSpacing.gapV16,

                  // 3. Featured Zones Slider
                  _SectionHeader(
                    title: 'Featured',
                    actionLabel: 'See all',
                    onAction: () => context.push('/food-menu'),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 200,
                    child: PageView.builder(
                      controller: _sliderCtrl,
                      onPageChanged: (i) =>
                          setState(() => _activeSlideIndex = i),
                      itemCount: kArcadeExperiences.length,
                      itemBuilder: (context, i) {
                        final exp = kArcadeExperiences[i];
                        return _FeaturedZoneCard(exp: exp);
                      },
                    ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(kArcadeExperiences.length, (i) {
                      final active = i == _activeSlideIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active
                              ? AppColors.primaryRedDark
                              : AppColors.borderLight,
                        ),
                      );
                    }),
                  ),

                  AppSpacing.gapV32,

                  // 4. Bundle Deals Section (Filtered by Category 'Bundle')
                  _SectionHeader(
                    title: 'Bundle Deals',
                    actionLabel: 'See all',
                    onAction: () => context.push('/food-menu'),
                  ),
                  const SizedBox(height: 20),

                  ref.watch(bundleProductsProvider).when(
                        loading: () => _BundleSkeleton(),
                        error: (_, __) => _buildNoBundlesPlaceholder(),
                        data: (bundleProducts) {
                          if (bundleProducts.isEmpty) {
                            return _buildNoBundlesPlaceholder();
                          }

                          return SizedBox(
                            height: 195,
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
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.pagePadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRedDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Feature Grid Tile (3 columns, compact padding)
class _FeatureGridItem extends StatelessWidget {
  final ArcadeExperience exp;

  const _FeatureGridItem({required this.exp});

  @override
  Widget build(BuildContext context) {
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;

    return GestureDetector(
      onTap: () => context.push('/experience/${exp.id}'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Squircle Icon Container Box (reduced by 8px to 64x64)
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.cardLight,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Hero(
                tag: 'zone_icon_${exp.id}',
                child: Icon(
                  exp.iconData,
                  color: color,
                  size: 28,
                ),
              ),
            ),
          ),
          AppSpacing.gapV4,
          Text(
            exp.name,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            exp.subtitle.split('·').first.trim(),
            style: GoogleFonts.dmSans(
              fontSize: 9.5,
              color: AppColors.textMutedLight,
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

/// Featured Zone Card — rich discovery card for the home slider
class _FeaturedZoneCard extends StatelessWidget {
  final ArcadeExperience exp;

  const _FeaturedZoneCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    final color = exp.color == const Color(0xFFF8FAFC)
        ? AppColors.textLight
        : exp.color;

    return GestureDetector(
      onTap: () => context.push('/experience/${exp.id}'),
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Background huge watermark icon
            Positioned(
              right: -20,
              bottom: -30,
              child: Transform.rotate(
                angle: -0.2,
                child: Icon(
                  exp.iconData,
                  size: 160,
                  color: color.withValues(alpha: 0.05),
                ),
              ),
            ),
            
            // Subtle gradient overlay for depth
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Icon & Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'zone_icon_${exp.id}',
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Icon(
                            exp.iconData,
                            color: color,
                            size: 28,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: color.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          exp.featureTag.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Bottom Content
                  Text(
                    exp.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exp.tagline,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.textMutedLight,
                      height: 1.3,
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
    );
  }
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
        height: 195,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.pagePadding,
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (_, __) => Container(
            width: 270,
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
class _BundleCard extends ConsumerWidget {
  final ProductModel product;

  const _BundleCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = product.tags.isNotEmpty ? product.tags.first : 'Combo';
    final savePillText = product.tags.firstWhere(
      (t) => t.toUpperCase().contains('SAVE') || t.contains('%'),
      orElse: () => product.originalPrice != null
          ? 'SAVE ${(((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()}%'
          : 'SPECIAL',
    );
    const cardAccentColor = AppColors.primaryRedDark;

    return Container(
      width: 270,
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
              Text(product.emoji.isNotEmpty ? product.emoji : '🍱', style: const TextStyle(fontSize: 24)),
              AppSpacing.gapH8,
              Expanded(
                child: Text(
                  product.name,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
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
              fontSize: 11,
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
                    fontSize: 16,
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
    );
  }
}
