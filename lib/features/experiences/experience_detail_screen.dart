// lib/features/experiences/experience_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/repositories/experience_repository.dart';
import '../../core/repositories/service_repository.dart';
import '../../core/repositories/pos_repository.dart';
import '../../core/models/experience.dart';
import '../../shared/widgets/price_text.dart';
import '../../shared/widgets/app_network_image.dart';

class ExperienceDetailScreen extends ConsumerWidget {
  final String experienceId;

  const ExperienceDetailScreen({super.key, required this.experienceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final expAsync = ref.watch(experiencesProvider);
    final servicesAsync = ref.watch(servicesProvider(experienceId));

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: expAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.primaryRed),
        ),
        error: (err, _) => Center(
          child: Text('Error: $err', style: TextStyle(color: colors.textPrimary)),
        ),
        data: (experiences) {
          final exp = experiences.firstWhere(
            (e) => e.id == experienceId,
            orElse: () => experiences.first,
          );

          final fgColor = colors.resolveZoneForeground(exp.color);
          final heroPhoto = exp.imageUrl ??
              'https://images.unsplash.com/photo-1511512578047-dfb367046420?q=80&w=2071&auto=format&fit=crop';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Hero Photography Header ────────────────────────────
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: colors.scaffold,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
                scrolledUnderElevation: 0,
                elevation: 0,
                forceElevated: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colors.isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.90),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                          border: Border.all(
                            color: colors.isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : const Color(0xFFE2E8F0),
                            width: 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              blurRadius: 10,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: colors.isDark ? Colors.white : const Color(0xFF0F172A),
                            size: 18,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/home');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Real Zone Hero Photo
                      AppNetworkImage(
                        url: heroPhoto,
                        fallback: Container(
                          color: colors.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          child: Center(
                            child: Icon(exp.iconData, size: 64, color: fgColor),
                          ),
                        ),
                      ),

                      // Multi-stop Atmospheric Scrim Gradient that blends 100% seamlessly into colors.scaffold
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.50),
                              Colors.black.withValues(alpha: 0.20),
                              Colors.black.withValues(alpha: 0.65),
                              colors.scaffold.withValues(alpha: 0.92),
                              colors.scaffold,
                            ],
                            stops: const [0.0, 0.28, 0.58, 0.88, 1.0],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),

                      // Solid bottom overlap strip to eliminate sub-pixel rasterization seams on Chrome
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -1,
                        height: 4,
                        child: Container(
                          color: colors.scaffold,
                        ),
                      ),

                      // Floating Bottom Badge & Title Info
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Glassmorphic Solid Icon Box
                            Container(
                              padding: const EdgeInsets.all(13),
                              decoration: BoxDecoration(
                                color: colors.isDark
                                    ? const Color(0xFF1E293B).withValues(alpha: 0.9)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: colors.isDark
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x33000000),
                                    blurRadius: 18,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Hero(
                                tag: 'zone_icon_${exp.id}',
                                child: Icon(
                                  exp.iconData,
                                  color: fgColor,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Zone Name & Solid Contrast Tag
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Solid Saturated Pill Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: fgColor,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x28000000),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      'ZONE ${exp.indexNumber} • ${exp.featureTag.toUpperCase()}',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    exp.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black87,
                                          blurRadius: 10,
                                          offset: Offset(0, 2),
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
                    ],
                  ),
                ),
              ),

              // ── 2. Content Body ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Section: About
                    Text(
                      'About ${exp.name}',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${exp.tagline}. ${exp.description}',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: colors.isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Venue Spec Tag
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _SpecChip(
                        label: exp.setupDetail,
                        fgColor: fgColor,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Section: Dynamic Content (Dining Menu vs Gaming/Lounge Stations)
                    if (exp.type == ExperienceType.dining)
                      _ZoneProductsList(zoneId: exp.id, fgColor: fgColor)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Stations & Services',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          servicesAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, _) => Text(
                              'Failed to load services: $err',
                              style: GoogleFonts.dmSans(color: AppColors.error),
                            ),
                            data: (services) {
                              if (services.isEmpty) {
                                return Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: colors.card,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: colors.borderSubtle),
                                    boxShadow: colors.cardShadow,
                                  ),
                                  child: Text(
                                    'No specific bookable stations listed right now. Walk-in seating is available!',
                                    style: GoogleFonts.dmSans(
                                        color: colors.textMuted,
                                        fontSize: 13.5),
                                  ),
                                );
                              }

                              return Column(
                                children: services.map((srv) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                                    decoration: BoxDecoration(
                                      color: colors.card,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: colors.borderSubtle,
                                        width: 1,
                                      ),
                                      boxShadow: colors.cardShadow,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      srv.name,
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: colors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (srv.price != null) ...[
                                                    Text(
                                                      'Rs ${srv.price?.toInt()}',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: fgColor,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                srv.description,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12.5,
                                                  color: colors.textMuted,
                                                  height: 1.35,
                                                ),
                                              ),
                                              if (srv.durationText != null) ...[
                                                const SizedBox(height: 6),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.schedule_rounded,
                                                      size: 13,
                                                      color: fgColor,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      srv.durationText!,
                                                      style: GoogleFonts.dmSans(
                                                        fontSize: 11.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: fgColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (srv.isBookable) ...[
                                          const SizedBox(width: 14),
                                          ElevatedButton(
                                            onPressed: () {
                                              context.push(
                                                  '/service-booking?serviceId=${srv.id}');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: fgColor,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 18, vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              'Book',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SpecChip extends StatelessWidget {
  final String label;
  final Color fgColor;

  const _SpecChip({
    required this.label,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.borderSubtle, width: 1),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneProductsList extends ConsumerWidget {
  final String zoneId;
  final Color fgColor;

  const _ZoneProductsList({required this.zoneId, required this.fgColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final productsAsync = ref.watch(zoneProductsProvider(zoneId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Food & Drinks Menu',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/food-menu'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: fgColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Text(
                      'Full Menu',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: fgColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 10, color: fgColor),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        productsAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: fgColor),
          ),
          error: (err, _) => Text(
            'Error loading menu: $err',
            style: GoogleFonts.dmSans(color: AppColors.error),
          ),
          data: (products) {
            if (products.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.borderSubtle),
                  boxShadow: colors.cardShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      'Browse our full kitchen & bar selection',
                      style: GoogleFonts.dmSans(
                        color: colors.textMuted,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context.push('/food-menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fgColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Open Menu',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return GestureDetector(
                  onTap: () => context.push('/product/${product.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colors.borderSubtle,
                        width: 1,
                      ),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        // Image / Emoji with clean rounded framing
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: colors.isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: AppNetworkImage(
                            url: product.imageUrl,
                            fallback: Text(product.emoji,
                                style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Details Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (product.category.isNotEmpty &&
                                  product.category.toLowerCase() != 'all') ...[
                                const SizedBox(height: 2),
                                Text(
                                  product.category,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    color: colors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ] else if (product.description.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  product.description,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11.5,
                                    color: colors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              if (product.hasDiscount && product.discountTag != null) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primaryRed.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.discountTag!,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primaryRed,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Price & CTA pill
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            PriceText(
                              price: product.effectivePrice,
                              originalPrice: product.displayOriginalPrice,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: fgColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: fgColor,
                              ),
                            ),
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
    );
  }
}
