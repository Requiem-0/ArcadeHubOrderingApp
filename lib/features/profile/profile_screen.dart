// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInAsync = ref.watch(isLoggedInStateProvider);
    final userAsync = ref.watch(currentUserProvider);
    final favIds = ref.watch(favouritesProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    final orderCount = ordersAsync.asData?.value.length ?? 0;
    final favCount = favIds.length;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: Stack(
        children: [
          // ── Ambient Background Glows ────────────────────────────────
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryRedDark.withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6B0000).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main Content ───────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 120),
              children: [
                // ── Header Title & Badge ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Account & Profile',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppColors.textLight,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRedDark.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(
                          color: AppColors.primaryRedDark.withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            loggedInAsync.value == true ? 'ARCADE VIP' : 'GUEST',
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── User Identity Hero Card ───────────────────────────
                loggedInAsync.when(
                  loading: () => const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
                  ),
                  error: (_, __) => _buildGuestHeroCard(context),
                  data: (isLoggedIn) => isLoggedIn
                      ? userAsync.when(
                          loading: () => const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
                          ),
                          error: (_, __) => _buildUserHeroCard(
                            context,
                            'Arcade Hub User',
                            'member@arcadehub.com',
                            null,
                            favCount: favCount,
                            orderCount: orderCount,
                          ),
                          data: (user) => _buildUserHeroCard(
                            context,
                            user?.name.isNotEmpty == true ? user!.name : 'Arcade Hub User',
                            user?.email.isNotEmpty == true
                                ? user!.email
                                : (user?.phone ?? 'Active Member'),
                            user?.address,
                            favCount: favCount,
                            orderCount: orderCount,
                          ),
                        )
                      : _buildGuestHeroCard(context),
                ),
                const SizedBox(height: 24),

                // ── Section 1: Venue & Activity ───────────────────────
                _buildSectionHeader('VENUE & REWARDS'),
                const SizedBox(height: 12),
                _buildCardContainer([
                  _buildMenuRow(
                    context: context,
                    icon: Icons.favorite_rounded,
                    iconColor: const Color(0xFFFF3B5C),
                    iconBgColor: const Color(0xFFFF3B5C).withValues(alpha: 0.15),
                    label: 'Favourites & Wishlist',
                    badge: favCount > 0 ? '$favCount' : null,
                    onTap: () => context.go('/favourites'),
                  ),
                  const _MenuDivider(),
                  _buildMenuRow(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    iconColor: const Color(0xFFFF9F1C),
                    iconBgColor: const Color(0xFFFF9F1C).withValues(alpha: 0.15),
                    label: 'Order History & Receipts',
                    badge: orderCount > 0 ? '$orderCount' : null,
                    onTap: () => context.go('/orders'),
                  ),
                  const _MenuDivider(),
                  _buildMenuRow(
                    context: context,
                    icon: Icons.location_on_rounded,
                    iconColor: const Color(0xFF00E5FF),
                    iconBgColor: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    label: 'Saved Addresses',
                    onTap: () => context.push('/addresses'),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Section 2: Account & Security ─────────────────────
                _buildSectionHeader('ACCOUNT & SECURITY'),
                const SizedBox(height: 12),
                _buildCardContainer([
                  if (loggedInAsync.value == true) ...[
                    _buildMenuRow(
                      context: context,
                      icon: Icons.lock_rounded,
                      iconColor: const Color(0xFF00E676),
                      iconBgColor: const Color(0xFF00E676).withValues(alpha: 0.15),
                      label: 'Change Password',
                      onTap: () => context.push('/change-password'),
                    ),
                    const _MenuDivider(),
                  ],
                  _buildMenuRow(
                    context: context,
                    icon: Icons.tune_rounded,
                    iconColor: const Color(0xFF9D4EDD),
                    iconBgColor: const Color(0xFF9D4EDD).withValues(alpha: 0.15),
                    label: 'App Settings & Preferences',
                    onTap: () => context.push('/settings'),
                  ),
                  const _MenuDivider(),
                  _buildMenuRow(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    iconColor: const Color(0xFF38BDF8),
                    iconBgColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    label: 'Contact Support & Help Desk',
                    onTap: () => context.push('/contact'),
                  ),
                ]),
                const SizedBox(height: 32),

                // ── Sign Out Pill ─────────────────────────────────────
                if (loggedInAsync.value == true)
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          await ref.read(authRepositoryProvider).logout();
                          ref.invalidate(isLoggedInStateProvider);
                          ref.invalidate(currentUserProvider);
                          ref.invalidate(myOrdersProvider);
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                            color: AppColors.error.withValues(alpha: 0.1),
                            border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.logout_rounded, color: AppColors.error, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Sign Out of Account',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
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
        ],
      ),
    );
  }

  // ── Section Header ──────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: AppColors.textMutedLight,
        ),
      ),
    );
  }

  // ── Card Container ──────────────────────────────────────────────────
  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  // ── User Identity Hero Card ─────────────────────────────────────────
  Widget _buildUserHeroCard(
    BuildContext context,
    String name,
    String subtitle,
    String? address, {
    required int favCount,
    required int orderCount,
  }) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'AH';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1618),
            AppColors.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryRedDark.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRedDark.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with glowing gradient ring
              Container(
                width: 68,
                height: 68,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF16161A),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primaryRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textMutedLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address != null && address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: AppColors.primaryRed,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              address,
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                color: AppColors.textMutedLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Edit Profile Button
              IconButton(
                tooltip: 'Edit Profile',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: AppColors.borderLight),
                  ),
                ),
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: AppColors.textLight,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/edit-profile');
                },
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 14),

          // Mini Stats Bento Row
          Row(
            children: [
              _buildMiniStat(
                label: 'Saved Wishlist',
                value: '$favCount Items',
                icon: Icons.favorite_border_rounded,
                color: const Color(0xFFFF3B5C),
                onTap: () => context.go('/favourites'),
              ),
              Container(
                width: 1,
                height: 28,
                color: AppColors.borderLight,
              ),
              _buildMiniStat(
                label: 'Orders Placed',
                value: '$orderCount Orders',
                icon: Icons.shopping_bag_outlined,
                color: const Color(0xFFFF9F1C),
                onTap: () => context.go('/orders'),
              ),
              Container(
                width: 1,
                height: 28,
                color: AppColors.borderLight,
              ),
              _buildMiniStat(
                label: 'Member Status',
                value: 'Verified VIP',
                icon: Icons.shield_outlined,
                color: const Color(0xFF00E676),
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Mini Stat Widget ────────────────────────────────────────────────
  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 12, color: color),
                    const SizedBox(width: 4),
                    Text(
                      value,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMutedLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Guest Hero Card ─────────────────────────────────────────────────
  Widget _buildGuestHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1618),
            AppColors.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryRedDark.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryRedDark.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primaryRedDark.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 28,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Arcade Hub',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sign in to sync your orders, addresses & unlock VIP benefits.',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textMutedLight,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Sign In / Register',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/login');
            },
          ),
        ],
      ),
    );
  }

  // ── Rich Menu Row ───────────────────────────────────────────────────
  Widget _buildMenuRow({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Tinted Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 16),

              // Title
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                ),
              ),

              // Optional Count Badge
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(color: iconColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Arrow
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMutedLight,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.borderLight,
      height: 1,
      indent: 72,
    );
  }
}
