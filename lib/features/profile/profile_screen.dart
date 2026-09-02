// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../features/favourites/favourites_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final loggedInAsync = ref.watch(isLoggedInStateProvider);
    final userAsync = ref.watch(currentUserProvider);
    final favIds = ref.watch(favouritesProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    final orderCount = ordersAsync.asData?.value.length ?? 0;
    final favCount = favIds.length;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          children: [
            // ── Top Bar ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account & Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arcade Hub Pokhara',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: colors.primaryRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push('/settings');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.primaryRed.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.settings_rounded,
                        size: 20,
                        color: colors.primaryRed,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Clean Profile Identity ──────────────────────────────
            loggedInAsync.when(
              loading: () => _buildSkeletonHeader(colors),
              error: (err, _) => _buildGuestHeader(context, colors),
              data: (isLoggedIn) => isLoggedIn
                  ? userAsync.when(
                      loading: () => _buildSkeletonHeader(colors),
                      error: (err, _) => _buildUserHeader(
                        context,
                        colors,
                        'Arcade Hub User',
                        'member@arcadehub.com',
                        null,
                        false,
                      ),
                      data: (user) => _buildUserHeader(
                        context,
                        colors,
                        user?.name.isNotEmpty == true ? user!.name : 'Arcade Hub User',
                        user?.email.isNotEmpty == true
                            ? user!.email
                            : (user?.phone ?? ''),
                        user?.address,
                        user?.isEmailVerified == true,
                        user?.image,
                      ),
                    )
                  : _buildGuestHeader(context, colors),
            ),

            const SizedBox(height: 24),

            // ── Bento Quick Jump Matrix (Wishlist & Orders) ──────────
            Row(
              children: [
                Expanded(
                  child: _buildBentoCard(
                    context: context,
                    title: 'Wishlist',
                    count: '$favCount',
                    subtitle: 'Saved items',
                    icon: Icons.favorite_rounded,
                    accentColor: const Color(0xFFFF3B5C),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/favourites');
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildBentoCard(
                    context: context,
                    title: 'Orders',
                    count: '$orderCount',
                    subtitle: 'Past & active',
                    icon: Icons.receipt_long_rounded,
                    accentColor: const Color(0xFFFFB703),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/orders');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section Label ───────────────────────────────────────
            Text(
              'ACCOUNT SETTINGS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: colors.textMuted.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),

            // ── Structured Menu Card Group ──────────────────────────
            Container(
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: colors.border,
                  width: 1,
                ),
                boxShadow: colors.cardShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: Column(
                  children: [
                    _buildSettingsRow(
                      context: context,
                      icon: Icons.location_on_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      title: 'Saved Addresses',
                      subtitle: 'Delivery locations & spot notes',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/addresses');
                      },
                    ),
                    Divider(color: colors.border, height: 1),
                    _buildSettingsRow(
                      context: context,
                      icon: Icons.lock_outline_rounded,
                      iconColor: const Color(0xFF00E676),
                      title: 'Change Password',
                      subtitle: 'Update your account credentials',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/change-password');
                      },
                    ),
                    Divider(color: colors.border, height: 1),
                    _buildSettingsRow(
                      context: context,
                      icon: Icons.settings_rounded,
                      iconColor: const Color(0xFF9D4EDD),
                      title: 'Settings & Theme',
                      subtitle: 'Dark theme & preferences',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/settings');
                      },
                    ),
                    Divider(color: colors.border, height: 1),
                    _buildSettingsRow(
                      context: context,
                      icon: Icons.support_agent_rounded,
                      iconColor: const Color(0xFF38BDF8),
                      title: 'Contact Support',
                      subtitle: 'Direct WhatsApp & venue phone',
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.push('/contact');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Log Out Button ──────────────────────────────────────
            if (loggedInAsync.value == true)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  border: Border.all(
                    color: const Color(0xFFFF3B5C).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: const Color(0xFFFF3B5C).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  child: InkWell(
                    onTap: () => _confirmSignOut(context, ref),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Color(0xFFFF3B5C),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF3B5C),
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
    );
  }

  // ── Centered User Identity ─────────────────────────────────────────
  Widget _buildUserHeader(
    BuildContext context,
    AppThemeColors colors,
    String name,
    String contact,
    String? address,
    bool isVerified, [
    String? imageUrl,
  ]) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Centered Glowing Avatar with Edit Badge
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colors.primaryRed, colors.deepRed],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryRed.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                            style: GoogleFonts.outfit(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                          style: GoogleFonts.outfit(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            // Floating Edit Pencil
            Material(
              color: colors.cardElevated,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/edit-profile');
                },
                customBorder: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.border, width: 1.5),
                  ),
                  child: Icon(
                    Icons.edit_rounded,
                    size: 13,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // User Name with Verified Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                name,
                style: GoogleFonts.outfit(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isVerified) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF00E676),
                size: 17,
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),

        // Contact info
        if (contact.isNotEmpty)
          Text(
            contact,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),

        // Address note if available
        if (address != null && address.isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            address,
            style: GoogleFonts.dmSans(
              fontSize: 11.5,
              color: colors.textMuted.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  // ── Centered Guest Header ─────────────────────────────────────────
  Widget _buildGuestHeader(BuildContext context, AppThemeColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primaryRed.withValues(alpha: 0.1),
          ),
          child: Center(
            child: Icon(
              Icons.person_outline_rounded,
              size: 32,
              color: colors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Guest',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to sync your orders & favourites',
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            color: colors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primaryRed,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            ),
          ),
          child: Text(
            'Sign In',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bento Matrix Card ─────────────────────────────────────────────
  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: colors.border,
              width: 1,
            ),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(icon, size: 18, color: accentColor),
                    ),
                  ),
                  Text(
                    count,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Settings Row ──────────────────────────────────────────────────
  Widget _buildSettingsRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textMuted.withValues(alpha: 0.6),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Centered Skeleton Loader ──────────────────────────────────────
  Widget _buildSkeletonHeader(AppThemeColors colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.border.withValues(alpha: 0.3),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          width: 130,
          height: 16,
          decoration: BoxDecoration(
            color: colors.border.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 170,
          height: 12,
          decoration: BoxDecoration(
            color: colors.border.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  // ── Sign Out Modal ────────────────────────────────────────────────
  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Sign Out',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your account?',
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            color: colors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.dmSans(
                color: colors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authRepositoryProvider).logout();
              ref.invalidate(isLoggedInStateProvider);
              ref.invalidate(currentUserProvider);
              ref.invalidate(myOrdersProvider);
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              'Log Out',
              style: GoogleFonts.dmSans(
                color: const Color(0xFFFF3B5C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
