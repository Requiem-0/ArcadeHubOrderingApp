// lib/features/home/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_spacing.dart';
import '../../core/brandkit/experiences.dart';
import '../../features/cart/cart_provider.dart';
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
                              color: AppColors.primaryRedDark.withOpacity(0.4),
                              blurRadius: 16,
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
                  Material(
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
                ],
              ),
            ),

            // ── Main Scroll View ───────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
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
                            AppColors.primaryRed.withOpacity(0.22),
                            AppColors.surfaceLight,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.primaryRedDark.withOpacity(0.35),
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
                  const SizedBox(height: 20),

                  Padding(
                    padding: AppSpacing.pagePadding,
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: 2.0,
                        childAspectRatio: 1.02,
                      ),
                      itemCount: kArcadeExperiences.length,
                      itemBuilder: (context, idx) {
                        final exp = kArcadeExperiences[idx];
                        return _FeatureGridItem(exp: exp);
                      },
                    ),
                  ),

                  AppSpacing.gapV32,

                  // 3. Featured Slider (Well-spaced section)
                  _SectionHeader(
                    title: 'Featured',
                    actionLabel: 'See all',
                    onAction: () => context.push('/food-menu'),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 185,
                    child: PageView.builder(
                      controller: _sliderCtrl,
                      onPageChanged: (i) => setState(() => _activeSlideIndex = i),
                      itemCount: kArcadeExperiences.length,
                      itemBuilder: (context, i) {
                        final exp = kArcadeExperiences[i];
                        return _SlideCard(exp: exp);
                      },
                    ),
                  ),
                  AppSpacing.gapV12,

                  // Slider Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(kArcadeExperiences.length, (i) {
                      final active = i == _activeSlideIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: active
                              ? AppColors.primaryRedDark
                              : Colors.white.withOpacity(0.2),
                        ),
                      );
                    }),
                  ),

                  AppSpacing.gapV32,

                  // 4. Bundle Deals Section (Well-spaced section)
                  _SectionHeader(
                    title: 'Bundle Deals',
                    actionLabel: 'See all',
                    onAction: () => context.push('/discounts'),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    height: 195,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: AppSpacing.pagePadding,
                      children: const [
                        _BundleCard(
                          emoji: '🎮🍔',
                          tag: 'Combo',
                          name: 'Play + Bite Combo',
                          inclusions: '1 hr Play Room pass + Hub burger + soft drink',
                          price: '999',
                          oldPrice: '1,265',
                          savePercentage: '21%',
                          color: Color(0xFFFFD700),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _BundleCard(
                          emoji: '🔫🌮',
                          tag: 'Squad Pack',
                          name: 'Area 51 Squad Pack',
                          inclusions: 'TT + beer pong for 4 + nacho mountain + 4 mocktails',
                          price: '2,999',
                          oldPrice: '3,860',
                          savePercentage: '22%',
                          color: Color(0xFFA855F7),
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _BundleCard(
                          emoji: '🎉🍕',
                          tag: 'Party',
                          name: 'Party Blast Bundle',
                          inclusions: 'Party Room 2 hrs + 2 large pizzas + karaoke',
                          price: '4,999',
                          oldPrice: '6,400',
                          savePercentage: '22%',
                          color: AppColors.primaryRedDark,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        _BundleCard(
                          emoji: '🏆🍺',
                          tag: 'Match Day',
                          name: 'Match Day Bundle',
                          inclusions: 'Sports bar table + beer tower (3L) + peri fries',
                          price: '2,499',
                          oldPrice: '3,020',
                          savePercentage: '17%',
                          color: Color(0xFF4CAF50),
                        ),
                      ],
                    ),
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
              color: const Color(0xFF161628),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: color.withOpacity(0.55),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.25),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                exp.iconData,
                color: color,
                size: 28,
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

/// Slide Card Component for Featured Carousel
class _SlideCard extends StatelessWidget {
  final ArcadeExperience exp;

  const _SlideCard({required this.exp});

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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.25),
              AppColors.surfaceLight,
              AppColors.surfaceDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Background Icon Specular Glow
            Positioned(
              right: -10,
              top: 10,
              child: Icon(
                exp.iconData,
                color: color.withOpacity(0.12),
                size: 130,
              ),
            ),
            // Bottom Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.surfaceDark.withOpacity(0.92),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        AppSpacing.gapH4,
                        Text(
                          exp.name.toUpperCase(),
                          style: GoogleFonts.dmSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.gapV4,
                  Text(
                    exp.name,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    exp.tagline,
                    style: GoogleFonts.dmSans(
                      fontSize: 11.5,
                      color: Colors.white.withOpacity(0.75),
                    ),
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

/// Bundle Deal Card
class _BundleCard extends ConsumerWidget {
  final String emoji;
  final String tag;
  final String name;
  final String inclusions;
  final String price;
  final String oldPrice;
  final String savePercentage;
  final Color color;

  const _BundleCard({
    required this.emoji,
    required this.tag,
    required this.name,
    required this.inclusions,
    required this.price,
    required this.oldPrice,
    required this.savePercentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
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
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.6)),
                ),
                child: Text(
                  '● $tag',
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: color,
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
                  'SAVE $savePercentage',
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
              Text(emoji, style: const TextStyle(fontSize: 24)),
              AppSpacing.gapH8,
              Expanded(
                child: Text(
                  name,
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

          // Inclusions
          Text(
            inclusions,
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
                    TextSpan(text: 'Rs. $price '),
                    TextSpan(
                      text: 'Rs. $oldPrice',
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
                  ref.read(cartProvider.notifier).add('pos-1');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added "$name" to cart'),
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
