// lib/features/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/utils/app_toast.dart';
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

  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  String? _currentImageUrl;

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
    _currentImageUrl = user.image;
    _initialized = true;
  }

  Future<void> _pickImage() async {
    HapticFeedback.lightImpact();
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _pickedImageBytes = bytes;
          _pickedImageName = image.name;
        });
        if (mounted) {
          AppToast.showSuccess(context, 'Avatar selected! Tap save to upload.');
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Could not open image picker.');
      }
    }
  }

  Future<void> _handleSave() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();

    if (name.isEmpty) {
      AppToast.showWarning(context, 'Please enter your full name');
      return;
    }

    setState(() => _saving = true);
    HapticFeedback.lightImpact();

    try {
      await ref.read(authRepositoryProvider).updateProfile(
            name: name,
            phone: phone,
            address: address,
            imageBytes: _pickedImageBytes,
            imageName: _pickedImageName,
          );

      if (mounted) {
        ref.invalidate(currentUserProvider);
        ref.invalidate(isLoggedInStateProvider);

        AppToast.showSuccess(context, 'Profile updated successfully!');

        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (_) {
      if (mounted) {
        AppToast.showError(context, 'Unable to update profile. Check connection.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final userAsync = ref.watch(currentUserProvider);

    userAsync.whenData((user) => _populateUser(user));

    return Scaffold(
      backgroundColor: colors.scaffold,
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
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Edit Profile',
                    style: AppTextStyles.headingM(colors.textPrimary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: userAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.primaryRed),
                ),
                error: (err, _) => _buildForm(colors),
                data: (_) => _buildForm(colors),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppThemeColors colors) {
    final initials = _nameCtrl.text.trim().isNotEmpty
        ? _nameCtrl.text.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join().toUpperCase()
        : 'AH';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Preview Lockup with Pick Action ─────────────────
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primaryRed, colors.deepRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colors.primaryRed.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _pickedImageBytes != null
                          ? Image.memory(
                              _pickedImageBytes!,
                              fit: BoxFit.cover,
                              width: 96,
                              height: 96,
                            )
                          : (_currentImageUrl != null && _currentImageUrl!.isNotEmpty)
                              ? Image.network(
                                  _currentImageUrl!,
                                  fit: BoxFit.cover,
                                  width: 96,
                                  height: 96,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      initials,
                                      style: AppTextStyles.headingL(Colors.white),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    initials,
                                    style: AppTextStyles.headingL(Colors.white),
                                  ),
                                ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.cardElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _pickImage,
              child: Text(
                'Change Photo',
                style: AppTextStyles.semibold(colors.primaryRed),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Name Field ─────────────────────────────────────────────
          Text('FULL NAME', style: AppTextStyles.label(colors.textMuted)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            style: AppTextStyles.bodyL(colors.textPrimary),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'e.g. Ren Gurung',
              hintStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primaryRed),
              ),
              prefixIcon: Icon(Icons.person_outline_rounded, color: colors.textMuted, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // ── Phone Field ────────────────────────────────────────────
          Text('PHONE NUMBER', style: AppTextStyles.label(colors.textMuted)),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            style: AppTextStyles.bodyL(colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. 9816647410',
              hintStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primaryRed),
              ),
              prefixIcon: Icon(Icons.phone_outlined, color: colors.textMuted, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // ── Address Field ──────────────────────────────────────────
          Text('DELIVERY / HOME ADDRESS', style: AppTextStyles.label(colors.textMuted)),
          const SizedBox(height: 8),
          TextField(
            controller: _addressCtrl,
            maxLines: 2,
            style: AppTextStyles.bodyL(colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. New Road, Pokhara',
              hintStyle: TextStyle(color: colors.textMuted),
              filled: true,
              fillColor: colors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colors.primaryRed),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Icon(Icons.location_on_outlined, color: colors.textMuted, size: 20),
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
