// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/constants.dart';
import '../../core/repositories/experience_repository.dart';
import '../../core/repositories/promotion_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../shared/widgets/app_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final experiencesAsync = ref.watch(experiencesProvider);
    final promotionAsync = ref.watch(activePromotionProvider);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0A0B10), // Deep slate black canvas from design
      drawer: const ArcadeAppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            // ── Clean Header Bar ─────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF11121A),
                border: Border(bottom: BorderSide(color: Color(0xFF1E202C))),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppConstants.appName,
                              style: GoogleFonts.outfit(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF355E).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFF355E).withOpacity(0.4)),
                              ),
                              child: Text(
                                'POKHARA',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFFFF355E),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppConstants.appTagline,
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 26),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF355E),
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              '$cartCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Main Content Scroll ──────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  // Dynamic Promotion Banner
                  promotionAsync.when(
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                    data: (promo) {
                      if (promo == null) return const SizedBox();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () => context.push('/discounts'),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13141C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.bolt_rounded, color: Colors.black, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promo.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFFFD700),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        promo.description,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFFFD700), size: 16),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // ── QUICK ACTIONS SECTION ───────────────────────
                  Text(
                    'QUICK ACTIONS',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.0,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _QuickActionPill(
                          icon: Icons.restaurant_menu_rounded,
                          iconColor: const Color(0xFFFF355E),
                          label: 'Food and drinks',
                          onTap: () => context.push('/food-menu'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionPill(
                          icon: Icons.sports_esports_rounded,
                          iconColor: const Color(0xFF00E5FF),
                          label: 'PS5 rental',
                          onTap: () => context.push('/service-booking'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionPill(
                          icon: Icons.bolt_rounded,
                          iconColor: const Color(0xFFFFD700),
                          label: '10% off',
                          onTap: () => context.push('/discounts'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── ARCADE HUB SPACES HEADER ────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ARCADE HUB SPACES',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1C26),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF282A38)),
                        ),
                        child: Text(
                          '6 zones',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── 2-COLUMN ZONE GRID MATRIX ───────────────────
                  experiencesAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: Color(0xFFFF355E)),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Text('Failed to load: $err', style: const TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                    data: (experiences) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.84, // Matching screenshot vertical proportions
                        ),
                        itemCount: experiences.length,
                        itemBuilder: (context, index) {
                          final exp = experiences[index];
                          final accent = exp.color == const Color(0xFFFFFFFF)
                              ? const Color(0xFFFFFFFF)
                              : exp.color;

                          return GestureDetector(
                            onTap: () => context.push('/experience/${exp.id}'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF13141C),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: const Color(0xFF1F202C)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Top Row: Feature Tag Pill + Muted Index Number
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: accent.withOpacity(0.16),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            exp.featureTag,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        exp.indexNumber,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF374151),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Icon Badge Box
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        exp.iconData,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  ),

                                  // Title & Subtitle Section
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exp.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        exp.shortDesc,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 11,
                                          height: 1.25,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Action CTA Link
                                  Row(
                                    children: [
                                      Text(
                                        'Explore',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: accent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_rounded, color: accent, size: 14),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
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
}

class _QuickActionPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickActionPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF13141C),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF222430)),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
