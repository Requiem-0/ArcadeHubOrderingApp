// lib/features/experiences/experience_detail_screen.dart
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
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: colors.textPrimary))),
        data: (experiences) {
          final exp = experiences.firstWhere(
            (e) => e.id == experienceId,
            orElse: () => experiences.first,
          );

          final fgColor = colors.resolveZoneForeground(exp.color);
          final bgColor = colors.resolveZoneBackground(exp.color);
          final borderColor = colors.resolveZoneBorder(exp.color);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Hero Header ─
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: colors.scaffold,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: colors.textPrimary, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        side: BorderSide(color: colors.border),
                      ),
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
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fgColor.withValues(alpha: colors.isDark ? 0.25 : 0.12),
                          fgColor.withValues(alpha: colors.isDark ? 0.05 : 0.02),
                          colors.scaffold,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                // Glassmorphic Dual-Shadow Icon Box
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: borderColor,
                                      width: 1.5,
                                    ),
                                    boxShadow: colors.isDark
                                        ? [
                                            BoxShadow(
                                              color: fgColor.withValues(alpha: 0.25),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                              offset: const Offset(0, 3),
                                            ),
                                          ]
                                        : colors.cardShadow,
                                  ),
                                  child: Hero(
                                    tag: 'zone_icon_${exp.id}',
                                    child: Icon(
                                      exp.iconData,
                                      color: fgColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${exp.featureTag.toUpperCase()} • ZONE ${exp.indexNumber}',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          color: fgColor,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        exp.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 2. Content Body ─────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Typographic Pull-Quote Hook
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 3.5,
                          height: 38,
                          decoration: BoxDecoration(
                            color: fgColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            exp.tagline,
                            style: GoogleFonts.outfit(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section: About
                    Text(
                      'About ${exp.name}',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exp.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        color: colors.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Hardware & Venue Spec Tag
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _SpecChip(
                          label: exp.setupDetail, fgColor: fgColor, bgColor: bgColor, borderColor: borderColor),
                    ),
                    const SizedBox(height: 28),

                    // Section: Dynamic Content (Stations vs Menu)
                    if (exp.type == ExperienceType.dining)
                      _ZoneProductsList(zoneId: exp.id, fgColor: fgColor)
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Stations & Services',
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
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
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colors.card,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: colors.border),
                                    boxShadow: colors.cardShadow,
                                  ),
                                  child: Text(
                                    'No specific bookable stations listed right now. Walk-in seating is available!',
                                    style: GoogleFonts.dmSans(
                                        color: colors.textMuted,
                                        fontSize: 13),
                                  ),
                                );
                              }

                              return Column(
                                children: services.map((srv) {
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
                                    decoration: BoxDecoration(
                                      color: colors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: fgColor.withValues(alpha: 0.35),
                                        width: 1.2,
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
                                                        fontSize: 15.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: colors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (srv.price != null) ...[
                                                    Text(
                                                      'Rs ${srv.price?.toInt()}',
                                                      style: GoogleFonts.outfit(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.bold,
                                                        color: fgColor,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                srv.description,
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 12,
                                                  color: colors.textMuted,
                                                  height: 1.3,
                                                ),
                                              ),
                                              if (srv.durationText != null) ...[
                                                const SizedBox(height: 5),
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
                                                        fontWeight: FontWeight.w600,
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
                                          const SizedBox(width: 12),
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
                                                  horizontal: 16, vertical: 6),
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                            ),
                                            child: const Text(
                                              'Book',
                                              style: TextStyle(
                                                fontSize: 12,
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
  final Color bgColor;
  final Color borderColor;

  const _SpecChip({
    required this.label,
    required this.fgColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: fgColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
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
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/food-menu'),
              child: Row(
                children: [
                  Text(
                    'Full Menu',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: fgColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 11, color: fgColor),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
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
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.push('/food-menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: fgColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Open Food & Drinks Menu',
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
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: fgColor.withValues(alpha: 0.15),
                      ),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Row(
                      children: [
                        // Image / Emoji
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: fgColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: (product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  product.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(product.emoji,
                                        style: const TextStyle(fontSize: 28)),
                                  ),
                                )
                              : Center(
                                  child: Text(product.emoji,
                                      style: const TextStyle(fontSize: 28)),
                                ),
                        ),
                        const SizedBox(width: 14),
                        // Details
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
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Price
                        Text(
                          'Rs ${product.price.toInt()}',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: fgColor,
                          ),
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
