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
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
          children: [
            // ── Top App Bar / Title ─────────────────────────────────
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
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Arcade Hub Pokhara',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                    border: Border.all(
                      color: AppColors.primaryRed.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: loggedInAsync.value == true ? AppColors.success : AppColors.primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (loggedInAsync.value == true ? AppColors.success : AppColors.primaryRed)
                                  .withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        loggedInAsync.value == true ? 'ARCADE VIP' : 'GUEST',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── User Identity Hero Card ─────────────────────────────
            loggedInAsync.when(
              loading: () => _buildSkeletonHero(),
              error: (_, __) => _buildGuestHeroCard(context),
              data: (isLoggedIn) => isLoggedIn
                  ? userAsync.when(
                      loading: () => _buildSkeletonHero(),
                      error: (_, __) => _buildUserHeroCard(
                        context,
                        'Arcade Hub User',
                        'member@arcadehub.com',
                        null,
                      ),
                      data: (user) => _buildUserHeroCard(
                        context,
                        user?.name.isNotEmpty == true ? user!.name : 'Arcade Hub User',
                        user?.email.isNotEmpty == true
                            ? user!.email
                            : (user?.phone ?? 'Active Member'),
                        user?.address,
                      ),
                    )
                  : _buildGuestHeroCard(context),
            ),
            const SizedBox(height: 20),

            // ── Bento Quick Jump Matrix (Favourites & Orders) ───────
            Row(
              children: [
                // Bento 1: Favourites
                Expanded(
                  child: _buildBentoCard(
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

                // Bento 2: Orders
                Expanded(
                  child: _buildBentoCard(
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

            // ── Venue & Security Section ────────────────────────────
            _buildSectionLabel('VENUE & PREFERENCES'),
            const SizedBox(height: 10),
            _buildCardGroup([
              _buildMenuRow(
                icon: Icons.location_on_rounded,
                iconColor: const Color(0xFF00E5FF),
                title: 'Saved Delivery Addresses',
                subtitle: 'Manage home, room, and table spots',
                onTap: () => context.push('/addresses'),
              ),
              if (loggedInAsync.value == true) ...[
                const _CardDivider(),
                _buildMenuRow(
                  icon: Icons.lock_rounded,
                  iconColor: const Color(0xFF00E676),
                  title: 'Change Password',
                  subtitle: 'Update account login credentials',
                  onTap: () => context.push('/change-password'),
                ),
              ],
              const _CardDivider(),
              _buildMenuRow(
                icon: Icons.tune_rounded,
                iconColor: const Color(0xFF9D4EDD),
                title: 'Settings & Theme',
                subtitle: 'Notifications, sound & appearance',
                onTap: () => context.push('/settings'),
              ),
              const _CardDivider(),
              _buildMenuRow(
                icon: Icons.headset_mic_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'Contact Support & Desk',
                subtitle: 'Help line, terms & venue info',
                onTap: () => context.push('/contact'),
              ),
            ]),
            const SizedBox(height: 32),

            // ── Sign Out Button ─────────────────────────────────────
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
                          color: AppColors.error.withValues(alpha: 0.3),
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
                              fontSize: 13.5,
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
    );
  }

  // ── Section Label ───────────────────────────────────────────────────
  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: AppColors.textMutedLight,
        ),
      ),
    );
  }

  // ── Bento Card ──────────────────────────────────────────────────────
  Widget _buildBentoCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    Text(
                      count,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.5,
                    color: AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Card Group Container ────────────────────────────────────────────
  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
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
    String? address,
  ) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'AH';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF221719),
            AppColors.surfaceLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryRed.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryRed, AppColors.deepRed],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryRed.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF141416),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.verified_rounded,
                      size: 15,
                      color: AppColors.primaryRed,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12.5,
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
                      const SizedBox(width: 3),
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

          // Edit Action Icon
          IconButton(
            tooltip: 'Edit Profile Details',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: AppColors.borderLight),
              ),
            ),
            icon: const Icon(
              Icons.edit_outlined,
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
    );
  }

  // ── Guest Hero Card ─────────────────────────────────────────────────
  Widget _buildGuestHeroCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primaryRed.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryRed.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.primaryRed.withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  Icons.sports_esports_rounded,
                  size: 26,
                  color: AppColors.primaryRed,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Arcade Hub',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sign in to sync your tickets, delivery addresses & VIP perks.',
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
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Sign In / Register',
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/login');
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Skeleton Loader ─────────────────────────────────────────────────
  Widget _buildSkeletonHero() {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: AppColors.primaryRed,
            strokeWidth: 2.5,
          ),
        ),
      ),
    );
  }

  // ── Rich Menu Row ───────────────────────────────────────────────────
  Widget _buildMenuRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 11.5,
                        color: AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMutedLight,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.borderLight,
      height: 1,
      indent: 68,
    );
  }
}
