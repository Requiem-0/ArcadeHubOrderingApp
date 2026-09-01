// lib/features/auth/auth_form_screen.dart
// Generic screen for Forgot Password / Reset Password / Verify Email
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import '../../shared/widgets/primary_button.dart';

class AuthField {
  final String key;
  final String label;
  final String placeholder;
  final bool isPassword;

  const AuthField({
    required this.key,
    required this.label,
    required this.placeholder,
    this.isPassword = false,
  });
}

class AuthFormScreen extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final List<AuthField> fields;
  final String buttonLabel;
  final String backRoute;
  final String nextRoute;

  const AuthFormScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.buttonLabel,
    required this.backRoute,
    required this.nextRoute,
  });

  @override
  ConsumerState<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends ConsumerState<AuthFormScreen> {
  late final Map<String, TextEditingController> _ctrls;
  final Map<String, bool> _pwVis = {};
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrls = {for (final f in widget.fields) f.key: TextEditingController()};
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() async {
    final values = {for (final e in _ctrls.entries) e.key: e.value.text.trim()};

    // Validation
    for (final f in widget.fields) {
      if ((values[f.key] ?? '').isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter ${f.label.toLowerCase()}'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _loading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      String successMsg = 'Request completed successfully.';

      if (values.containsKey('email') && values.containsKey('code')) {
        // Verify Email
        await authRepo.verifyEmail(
          email: values['email']!,
          code: values['code']!,
        );
        successMsg = 'Email verified successfully! You can now log in.';
      } else if (values.containsKey('code') && values.containsKey('pw')) {
        // Reset Password
        final newPw = values['pw']!;
        final confirmPw = values['pw2'] ?? newPw;
        if (newPw != confirmPw) {
          throw ApiException('Passwords do not match');
        }
        await authRepo.resetPassword(
          token: values['code']!,
          newPassword: newPw,
          confirmPassword: confirmPw,
        );
        successMsg = 'Password reset successfully! Please log in.';
      } else if (values.containsKey('email')) {
        // Send reset token
        final res = await authRepo.sendResetToken(emailOrPhone: values['email']!);
        if (res is Map && res['message'] != null) {
          successMsg = res['message'].toString();
        } else {
          successMsg = 'Reset token sent to your email!';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMsg),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(widget.nextRoute);
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Action failed. Please check your information.';
        if (e is ApiException) {
          if (e.body is Map && e.body['error'] != null) {
            msg = e.body['error'].toString();
          } else if (e.body is Map && e.body['message'] != null) {
            msg = e.body['message'].toString();
          } else if (e.body is Map && e.body['data']?['message'] != null) {
            msg = e.body['data']['message'].toString();
          } else {
            msg = e.message;
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => context.go(widget.backRoute),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textLight),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(widget.title, style: AppTextStyles.headingXL(AppColors.textLight)),
              const SizedBox(height: 8),
              Text(widget.subtitle, style: AppTextStyles.bodyM(AppColors.textMutedLight)),
              const SizedBox(height: 32),

              for (final f in widget.fields) ...[
                Text(
                  f.label.toUpperCase(),
                  style: AppTextStyles.label(AppColors.textMutedLight),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _ctrls[f.key],
                  obscureText: f.isPassword && !(_pwVis[f.key] ?? false),
                  style: AppTextStyles.bodyL(AppColors.textLight),
                  decoration: InputDecoration(
                    hintText: f.placeholder,
                    suffixIcon: f.isPassword
                        ? IconButton(
                            onPressed: () => setState(
                                () => _pwVis[f.key] = !(_pwVis[f.key] ?? false)),
                            icon: Icon(
                              (_pwVis[f.key] ?? false)
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMutedLight,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 18),
              ],

              const SizedBox(height: 8),
              PrimaryButton(label: widget.buttonLabel, loading: _loading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
