// lib/features/profile/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/theme_provider.dart';
import '../../core/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textLight),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Settings',
                      style: AppTextStyles.headingM(AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // Appearance
                  _SectionTitle('APPEARANCE'),
                  const SizedBox(height: 10),
                  _SettingsCard(children: [
                    _ToggleTile(
                      icon: Icons.dark_mode_outlined,
                      label: 'Dark Mode',
                      subtitle: isDark ? 'On' : 'Off',
                      value: isDark,
                      onChanged: (v) =>
                          ref.read(themeProvider.notifier).state = v,
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // Account
                  _SectionTitle('ACCOUNT'),
                  const SizedBox(height: 10),
                  _SettingsCard(children: [
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Change Password',
                      onTap: () => context.push('/change-password'),
                    ),
                    const Divider(color: AppColors.borderLight, height: 1),
                    _SettingsTile(
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete Account',
                      textColor: AppColors.error,
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),

                  // About
                  _SectionTitle('ABOUT'),
                  const SizedBox(height: 10),
                  _SettingsCard(children: [
                    _InfoTile(
                        label: 'Version', value: AppConstants.appVersion),
                    const Divider(color: AppColors.borderLight, height: 1),
                    _InfoTile(label: 'App', value: AppConstants.appName),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.label(AppColors.textMutedLight));
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
                Text(label, style: AppTextStyles.bodyL(AppColors.textLight)),
                Text(subtitle,
                    style: AppTextStyles.bodyS(AppColors.textMutedLight)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppColors.primaryRed : AppColors.borderLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(3),
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppColors.textMutedLight, size: 20),
            const SizedBox(width: 14),
            Text(label,
                style: AppTextStyles.bodyL(
                    textColor ?? AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyL(AppColors.textLight)),
          Text(value, style: AppTextStyles.bodyM(AppColors.textMutedLight)),
        ],
      ),
    );
  }
}
