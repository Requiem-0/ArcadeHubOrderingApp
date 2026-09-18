// lib/features/experiences/experience_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../core/constants.dart';
import '../../core/utils/app_toast.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/product_model.dart';

/// Text colour for something filled with a zone colour. Zone colours run from
/// white (Rooftop) through yellow and green to red, so white text only works
/// on the darker ones.
Color _inkOn(Color fill) =>
    fill.computeLuminance() > 0.45 ? const Color(0xFF0A0A0A) : Colors.white;

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
                                        color: _inkOn(fgColor),
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
                    // One line per thing to do there
                    ...exp.description
                        .split('\n')
                        .where((line) => line.trim().isNotEmpty)
                        .map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: fgColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    line.trim(),
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      height: 1.45,
                                      color: colors.isDark
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                                    Flexible(
                                                      child: Text(
                                                        srv.durationText!,
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: GoogleFonts.dmSans(
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: fgColor,
                                                        ),
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
                                              foregroundColor: _inkOn(fgColor),
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

                    // The menu comes after the zone's own content
                    const SizedBox(height: 34),
                    _ZoneMenuStrips(zoneId: exp.id, accent: fgColor),
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
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
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
              zoneId == 'sportsbar' ? 'Drinks' : 'Food',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.go('/food-menu'),
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
          error: (_, _) => Row(
            children: [
              Expanded(
                child: Text(
                  'The menu didn\'t load. Check your connection.',
                  style: GoogleFonts.dmSans(color: colors.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => ref.invalidate(zoneProductsProvider(zoneId)),
                child: Text('Try again', style: TextStyle(color: fgColor)),
              ),
            ],
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
                      zoneId == 'sportsbar'
                          ? 'No drinks on the menu yet.'
                          : 'No food on the menu yet.',
                      style: GoogleFonts.dmSans(
                        color: colors.textMuted,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () => context.go('/food-menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fgColor,
                        foregroundColor: _inkOn(fgColor),
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


/// The menu under a zone's own content, as short swipeable strips so it never
/// buries what the zone is about. The bar and restro pages already list their
/// half of the menu above, so they only get the other half here.
class _ZoneMenuStrips extends ConsumerWidget {
  final String zoneId;
  final Color accent;

  const _ZoneMenuStrips({required this.zoneId, required this.accent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final showFood = zoneId != 'rooftop';
    final showDrinks = zoneId != 'sportsbar';

    List<ProductModel> load(String zone) => ref
        .watch(zoneProductsProvider(zone))
        .maybeWhen(
          data: (items) => items.where((p) => p.effectivePrice > 0).toList(),
          orElse: () => const <ProductModel>[],
        );

    final food = showFood ? load('rooftop') : const <ProductModel>[];
    final drinks = showDrinks ? load('sportsbar') : const <ProductModel>[];
    if (food.isEmpty && drinks.isEmpty) return const SizedBox.shrink();

    final isDiningZone = zoneId == 'rooftop' || zoneId == 'sportsbar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isDiningZone ? 'Also on the menu' : 'Menu',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.go('/food-menu'),
              style: TextButton.styleFrom(
                foregroundColor: accent,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                minimumSize: const Size(0, 32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See all',
                    style: GoogleFonts.dmSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
        if (food.isNotEmpty) ...[
          const SizedBox(height: 10),
          _StripLabel(text: 'Food', color: colors.textMuted),
          _ProductStrip(items: food),
        ],
        if (drinks.isNotEmpty) ...[
          const SizedBox(height: 18),
          _StripLabel(text: 'Drinks', color: colors.textMuted),
          _ProductStrip(items: drinks),
        ],
      ],
    );
  }
}

class _StripLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _StripLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: color,
        ),
      ),
    );
  }
}

class _ProductStrip extends StatelessWidget {
  final List<ProductModel> items;

  const _ProductStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _StripCard(product: items[i]),
      ),
    );
  }
}

class _StripCard extends ConsumerWidget {
  final ProductModel product;

  const _StripCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final p = product;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/product/${p.id}'),
        child: Container(
          width: 124,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 84,
                width: double.infinity,
                child: AppNetworkImage(
                  url: p.imageUrl,
                  height: 84,
                  width: double.infinity,
                  fallback: Center(
                    child: Text(p.emoji, style: const TextStyle(fontSize: 30)),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
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
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          Material(
                            color: colors.primaryRed,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {
                                if (p.variants.isNotEmpty) {
                                  context.push('/product/${p.id}');
                                  return;
                                }
                                HapticFeedback.lightImpact();
                                ref.read(cartProvider.notifier).add(p.id, p);
                                AppToast.showSuccess(
                                    context, 'Added "${p.name}" to cart');
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(Icons.add,
                                    size: 16, color: Colors.white),
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
    );
  }
}
