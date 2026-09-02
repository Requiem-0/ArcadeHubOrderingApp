// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/experiences.dart';
import '../../core/repositories/auth_repository.dart';

class ArcadeAppDrawer extends ConsumerWidget {
  const ArcadeAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.asData?.value;
    final isLoggedIn = user != null;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 16,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF180708),
              Color(0xFF0E0E12),
              Color(0xFF0B0B0E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          border: Border(
            right: BorderSide(
              color: AppColors.primaryRed.withValues(alpha: 0.3),
              width: 1.2,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Brand Header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 18, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryRed, AppColors.deepRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withValues(alpha: 0.4),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_esports_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arcade Hub',
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'GAME HOUSE · RESTRO',
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Identity Quick Card ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                child: Material(
                  color: AppColors.surfaceLight.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                      if (isLoggedIn) {
                        context.push('/profile');
                      } else {
                        context.push('/login');
                      }
                    },
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryRed, AppColors.deepRed],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipOval(
                              child: (user?.image != null && user!.image!.isNotEmpty)
                                  ? Image.network(
                                      user.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Center(
                                        child: Text(
                                          user.name.substring(0, 1).toUpperCase(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: isLoggedIn
                                          ? Text(
                                              user.name.substring(0, 1).toUpperCase(),
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoggedIn ? user.name : 'Guest',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isLoggedIn ? 'View Profile' : 'Tap to sign in',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 11,
                                    color: AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textMutedLight.withValues(alpha: 0.6),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),
              const Divider(color: AppColors.borderLight, height: 1),

              // ── Scrollable Sections ───────────────────────────────────
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Section 1: Zones & Experiences
                    _buildSectionHeader('EXPERIENCES & ZONES'),
                    ...kArcadeExperiences.map((exp) => _DrawerZoneTile(exp: exp)),

                    const SizedBox(height: 10),
                    const Divider(color: AppColors.borderLight, height: 1),
                    const SizedBox(height: 10),

                    // Section 2: Quick Links
                    _buildSectionHeader('EXPLORE & ORDERS'),
                    _DrawerLink(
                      icon: Icons.restaurant_menu_rounded,
                      iconColor: const Color(0xFFFF7A00),
                      label: 'Food & Drinks Menu',
                      badge: 'ORDER',
                      badgeColor: AppColors.primaryRed,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/food-menu');
                      },
                    ),
                    _DrawerLink(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFFFFB703),
                      label: 'Recent Orders',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/orders');
                      },
                    ),
                    _DrawerLink(
                      icon: Icons.favorite_rounded,
                      iconColor: const Color(0xFFFF3B5C),
                      label: 'Favourites',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/favourites');
                      },
                    ),
                    _DrawerLink(
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      label: 'Saved Addresses',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/addresses');
                      },
                    ),
                    _DrawerLink(
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      label: 'Contact & Support',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/contact');
                      },
                    ),
                    _DrawerLink(
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFF9D4EDD),
                      label: 'Settings',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                        context.push('/settings');
                      },
                    ),
                  ],
                ),
              ),

              // ── Venue Status Footer ───────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF08080C),
                  border: const Border(
                    top: BorderSide(color: AppColors.borderLight, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00E676),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00E676),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OPEN TODAY · 10 AM – 11 PM',
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: AppColors.textLight,
                            ),
                          ),
                          Text(
                            'Lakeside-6, Pokhara, Nepal',
                            style: GoogleFonts.dmSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'v1.0.4',
                      style: GoogleFonts.dmSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMutedLight.withValues(alpha: 0.5),
                      ),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMutedLight.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

/// Experience Zone Tile with Glowing Accent Badge
class _DrawerZoneTile extends StatelessWidget {
  final ArcadeExperience exp;

  const _DrawerZoneTile({required this.exp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
            context.push('/experience/${exp.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: exp.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: exp.color.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      exp.iconData,
                      size: 16,
                      color: exp.color == const Color(0xFFF8FAFC)
                          ? AppColors.textLight
                          : exp.color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exp.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMutedLight.withValues(alpha: 0.35),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Action Link with Optional Badge
class _DrawerLink extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final VoidCallback onTap;

  const _DrawerLink({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.badge,
    this.badgeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(icon, size: 16, color: iconColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.dmSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? AppColors.primaryRed).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: (badgeColor ?? AppColors.primaryRed).withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.dmSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: badgeColor ?? AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMutedLight.withValues(alpha: 0.35),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
