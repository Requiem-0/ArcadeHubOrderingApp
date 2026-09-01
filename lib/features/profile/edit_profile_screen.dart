// lib/features/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/auth_repository.dart';
import '../../shared/widgets/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _populateUser(dynamic user) {
    if (_initialized || user == null) return;
    _nameCtrl.text = user.name ?? '';
    _phoneCtrl.text = user.phone ?? '';
    _addressCtrl.text = user.address ?? '';
    _initialized = true;
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your full name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    try {
      await ref.read(authRepositoryProvider).updateProfile(
            name: name,
            phone: phone,
            address: address,
          );

      if (mounted) {
        ref.invalidate(currentUserProvider);
        ref.invalidate(isLoggedInStateProvider);
        HapticFeedback.mediumImpact();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update profile. Please check your connection and try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    userAsync.whenData((user) => _populateUser(user));

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textLight),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.headingM(AppColors.textLight),
                  ),
                ],
              ),
            ),

            Expanded(
              child: userAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
                error: (_, __) => _buildForm(),
                data: (_) => _buildForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'AH';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Preview Lockup ──────────────────────────────────
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryRed, AppColors.deepRed],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryRed.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.headingL(Colors.white),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderLight, width: 2),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    size: 16,
                    color: AppColors.primaryRed,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── Name Field ─────────────────────────────────────────────
          Text('FULL NAME', style: AppTextStyles.label(AppColors.textMutedLight)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyL(AppColors.textLight),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. Ren Gurung',
              prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textMutedLight, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // ── Phone Field ────────────────────────────────────────────
          Text('PHONE NUMBER', style: AppTextStyles.label(AppColors.textMutedLight)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyL(AppColors.textLight),
            decoration: const InputDecoration(
              hintText: 'e.g. 9816647410',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textMutedLight, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // ── Address Field ──────────────────────────────────────────
          Text('DELIVERY / HOME ADDRESS', style: AppTextStyles.label(AppColors.textMutedLight)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            maxLines: 2,
            style: AppTextStyles.bodyL(AppColors.textLight),
            decoration: const InputDecoration(
              hintText: 'e.g. Lakeside, Ward 6, Pokhara',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Icon(Icons.location_on_outlined, color: AppColors.textMutedLight, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 36),

          // ── Submit Button ──────────────────────────────────────────
          PrimaryButton(
            label: 'Save Profile Changes',
            loading: _saving,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
