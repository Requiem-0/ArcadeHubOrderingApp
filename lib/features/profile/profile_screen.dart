// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/auth_repository.dart';
import '../../shared/widgets/primary_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedInAsync = ref.watch(isLoggedInStateProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
          children: [
            Text('My Profile',
                style: AppTextStyles.headingL(AppColors.textLight)),
            const SizedBox(height: 20),

            loggedInAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryRed)),
              error: (_, __) => _buildGuestCard(context),
              data: (isLoggedIn) => isLoggedIn ? _buildUserCard(context, ref) : _buildGuestCard(context),
            ),
            const SizedBox(height: 28),

            _Section(
              title: 'ORDERS & HISTORY',
              items: [
                _ProfileItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'My Orders',
                  subtitle: 'View past orders',
                  onTap: () => context.push('/orders'),
                ),
                _ProfileItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favourites',
                  subtitle: 'Your saved items',
                  onTap: () => context.go('/favourites'),
                ),
              ],
            ),

            _Section(
              title: 'ACCOUNT',
              items: [
                _ProfileItem(
                  icon: Icons.location_on_outlined,
                  label: 'Saved Addresses',
                  subtitle: 'Manage delivery addresses',
                  onTap: () => context.push('/addresses'),
                ),
              ],
            ),

            _Section(
              title: 'PREFERENCES',
              items: [
                _ProfileItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  subtitle: 'App preferences',
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),

            const SizedBox(height: 12),
            loggedInAsync.maybeWhen(
              data: (isLoggedIn) => isLoggedIn
                  ? Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusL),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await ref.read(authRepositoryProvider).logout();
                          ref.invalidate(isLoggedInStateProvider);
                          if (context.mounted) context.go('/login');
                        },
                        child: Text(
                          'Sign Out',
                          style: AppTextStyles.semibold(AppColors.error, size: 15),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👋', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Browsing as Guest',
                        style: AppTextStyles.headingS(AppColors.textLight)),
                    const SizedBox(height: 2),
                    Text('Sign in to track orders & book rooms',
                        style: AppTextStyles.bodyS(AppColors.textMutedLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Sign In / Create Account',
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryRed, AppColors.deepRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryRed.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                'AH',
                style: AppTextStyles.headingM(Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Arcade Hub User',
                  style: AppTextStyles.headingS(Colors.white)),
              Text('Signed In Account',
                  style: AppTextStyles.bodyS(
                      Colors.white.withValues(alpha: 0.8))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label(AppColors.textMutedLight)),
          const SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusML),
              ),
              child: Icon(icon, color: AppColors.primaryRed, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyL(AppColors.textLight)),
                  Text(subtitle,
                      style: AppTextStyles.bodyS(AppColors.textMutedLight)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMutedLight, size: 22),
          ],
        ),
      ),
    );
  }
}
