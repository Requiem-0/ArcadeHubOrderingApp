// lib/shared/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
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
      elevation: 0,
      width: 325,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101015),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
          border: Border(
            right: BorderSide(
              color: AppColors.borderLight.withValues(alpha: 0.8),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Brand Header ──────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryRed, AppColors.deepRed],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryRed.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arcade Hub',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'GAME HOUSE · RESTRO',
                            style: GoogleFonts.dmSans(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.textLight,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ── Frameless User Status Strip with Inline Action Button ─
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      // Left: Avatar + Name (Tappable to Profile/Login)
                      Expanded(
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
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: isLoggedIn
                                        ? const LinearGradient(
                                            colors: [AppColors.primaryRed, AppColors.deepRed],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isLoggedIn
                                        ? null
                                        : AppColors.surfaceLight,
                                    border: Border.all(
                                      color: isLoggedIn
                                          ? AppColors.primaryRed.withValues(alpha: 0.5)
                                          : AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: isLoggedIn
                                        ? (user.image != null && user.image!.isNotEmpty)
                                            ? Image.network(
                                                user.image!,
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Center(
                                                  child: Text(
                                                    user.name.isNotEmpty
                                                        ? user.name.substring(0, 1).toUpperCase()
                                                        : 'U',
                                                    style: GoogleFonts.outfit(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  user.name.isNotEmpty
                                                      ? user.name.substring(0, 1).toUpperCase()
                                                      : 'U',
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                        : const Center(
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 17,
                                              color: AppColors.textMutedLight,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isLoggedIn ? user.name : 'Guest',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textLight,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        isLoggedIn ? 'View Profile' : 'Not signed in',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 10.5,
                                          color: AppColors.textMutedLight,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Right: Sign In or Sign Out Action Pill
                      if (!isLoggedIn)
                        Material(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).pop();
                              context.push('/login');
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.login_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sign In',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        Material(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () async {
                              HapticFeedback.lightImpact();
                              await ref.read(authRepositoryProvider).logout();
                              ref.invalidate(currentUserProvider);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.logout_rounded,
                                    size: 12,
                                    color: AppColors.primaryRed.withValues(alpha: 0.9),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Sign Out',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryRed.withValues(alpha: 0.9),
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

                const SizedBox(height: 8),
                const Divider(color: AppColors.borderLight, height: 1),
                const SizedBox(height: 8),

                // ── Scrollable Navigation Flow (No Scrollbar Track) ───────
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // Section 1: Venue Experiences (Jump to Zone)
                        _SectionTitle('JUMP TO ZONE'),

                        // 2x3 Quick-Jump Zone Capsule Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: kArcadeExperiences.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            mainAxisExtent: 46,
                          ),
                          itemBuilder: (context, index) {
                            final exp = kArcadeExperiences[index];
                            final color = exp.color == const Color(0xFFF8FAFC)
                                ? AppColors.textLight
                                : exp.color;
                            return Material(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.of(context).pop();
                                  context.push('/experience/${exp.id}');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.14),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Center(
                                          child: Icon(exp.iconData, size: 14, color: color),
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: Text(
                                          exp.name,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 14),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: 12),

                        // Section 2: Explore & Ordering
                        _SectionTitle('EXPLORE & ORDER'),
                        _UnifiedNavRow(
                          icon: Icons.restaurant_menu_rounded,
                          iconColor: const Color(0xFFFF7A00),
                          label: 'Food & Drinks Menu',
                          badge: 'ORDER',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/food-menu');
                          },
                        ),
                        _UnifiedNavRow(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF00E5FF),
                          label: 'Saved Addresses',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/addresses');
                          },
                        ),
                        _UnifiedNavRow(
                          icon: Icons.support_agent_rounded,
                          iconColor: const Color(0xFF38BDF8),
                          label: 'Contact & Support',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/contact');
                          },
                        ),

                        const SizedBox(height: 14),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: 12),

                        // Section 3: Account & Activity (Bottom Nav / Profile)
                        _SectionTitle('ACTIVITY & SETTINGS'),
                        _UnifiedNavRow(
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFFFFB703),
                          label: 'Recent Orders',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/orders');
                          },
                        ),
                        _UnifiedNavRow(
                          icon: Icons.favorite_rounded,
                          iconColor: const Color(0xFFFF3B5C),
                          label: 'Favourites & Wishlist',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/favourites');
                          },
                        ),
                        _UnifiedNavRow(
                          icon: Icons.settings_rounded,
                          iconColor: const Color(0xFF9D4EDD),
                          label: 'Settings & Theme',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                            context.push('/settings');
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ── Venue Location Footer ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderLight,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primaryRed.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: AppColors.primaryRed,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arcade Hub Pokhara',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textLight,
                              ),
                            ),
                            Text(
                              'New Road, Pokhara, Nepal',
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: AppColors.textMutedLight,
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
      ),
    );
  }
}

/// Compact Section Header
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: AppColors.textMutedLight.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

/// Unified Single-Line Navigation Row with Identical Container Styling
class _UnifiedNavRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? badge;
  final VoidCallback onTap;

  const _UnifiedNavRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
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
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primaryRed.withValues(alpha: 0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            badge!,
                            style: GoogleFonts.dmSans(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                              color: AppColors.primaryRed,
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
