// lib/features/auth/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/primary_button.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
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

  Future<void> _submit() async {
    final currentPw = _ctrls['current']?.text ?? '';
    final newPw = _ctrls['new']?.text ?? '';
    final confirmPw = _ctrls['confirm']?.text ?? '';

    if (currentPw.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      AppToast.showWarning(context, 'Please fill in all password fields');
      return;
    }

    if (newPw.length < 6) {
      AppToast.showWarning(context, 'New password must be at least 6 characters');
      return;
    }

    if (newPw != confirmPw) {
      AppToast.showWarning(context, 'New passwords do not match');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).changePassword(
            currentPassword: currentPw,
            newPassword: newPw,
          );
      if (mounted) {
        AppToast.showSuccess(context, 'Password changed successfully!');
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/profile');
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Failed to change password. Please verify current password.';
        if (e is ApiException) {
          if (e.body is Map && e.body['error'] != null) {
            msg = e.body['error'].toString();
          } else if (e.body is Map && e.body['message'] != null) {
            msg = e.body['message'].toString();
          } else {
            msg = e.message;
          }
        }
        AppToast.showError(context, msg);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffold,
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
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: colors.textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Change Password',
                      style: AppTextStyles.headingM(colors.textPrimary)),
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
                        style: AppTextStyles.label(colors.textMuted),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _ctrls[f['key']!],
                        obscureText: !(_vis[f['key']!] ?? false),
                        style: AppTextStyles.bodyL(colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: '••••••••',
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
                          prefixIcon: Icon(Icons.lock_outline_rounded,
                              color: colors.textMuted, size: 20),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() =>
                                _vis[f['key']!] = !(_vis[f['key']!] ?? false)),
                            icon: Icon(
                              (_vis[f['key']!] ?? false)
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: colors.textMuted,
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
                      onPressed: _submit,
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
