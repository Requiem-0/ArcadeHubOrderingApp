// lib/features/auth/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _fields = [
    {'key': 'current', 'label': 'Current Password'},
    {'key': 'new', 'label': 'New Password'},
    {'key': 'confirm', 'label': 'Confirm New Password'},
  ];
  final Map<String, TextEditingController> _ctrls = {};
  final Map<String, bool> _vis = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _ctrls[f['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/settings'),
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
                  Text('Change Password',
                      style: AppTextStyles.headingM(AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final f in _fields) ...[
                      Text(
                        f['label']!.toUpperCase(),
                        style: AppTextStyles.label(AppColors.textMutedLight),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _ctrls[f['key']!],
                        obscureText: !(_vis[f['key']!] ?? false),
                        style: AppTextStyles.bodyL(AppColors.textLight),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.textMutedLight, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() =>
                                _vis[f['key']!] = !(_vis[f['key']!] ?? false)),
                            icon: Icon(
                              (_vis[f['key']!] ?? false)
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMutedLight,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Update Password',
                      loading: _loading,
                      onPressed: () async {
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(milliseconds: 800));
                        if (mounted) {
                          setState(() => _loading = false);
                          context.go('/settings');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
