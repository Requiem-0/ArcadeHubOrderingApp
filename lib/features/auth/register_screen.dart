// lib/features/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/primary_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _pwVis = <String, bool>{};
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _email, _phone, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() async {
    final name = _name.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    final password = _password.text;
    final confirm = _confirm.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      AppToast.showWarning(context, 'Please fill in all required fields');
      return;
    }

    if (password != confirm) {
      AppToast.showWarning(context, 'Passwords do not match');
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            phone: phone,
            password: password,
            confirmPassword: confirm,
          );

      if (mounted) {
        String successMsg = 'Registration successful! Please sign in.';
        if (res is Map && res['data']?['message'] != null) {
          successMsg = res['data']['message'].toString();
        }
        AppToast.showSuccess(context, successMsg);
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Registration failed. Please check your information.';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primaryRed.withValues(alpha: colors.isDark ? 0.15 : 0.05),
              colors.scaffold,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 72)),
                  const SizedBox(height: 20),
                  Text(
                    'Create Account',
                    style: AppTextStyles.headingXL(colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join Arcade Hub to track orders and earn member rewards.',
                    style: AppTextStyles.bodyM(colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  _field('FULL NAME', _name, 'e.g. Ren Gurung', Icons.person_outline_rounded, colors),
                  _field('EMAIL ADDRESS', _email, 'user@example.com', Icons.mail_outline_rounded, colors, keyboard: TextInputType.emailAddress),
                  _field('PHONE NUMBER', _phone, '+977 9800000000', Icons.phone_outlined, colors, keyboard: TextInputType.phone),
                  _pwField('PASSWORD', _password, 'password', colors),
                  _pwField('CONFIRM PASSWORD', _confirm, 'confirm', colors),

                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Create Account',
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTextStyles.bodyM(colors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.semibold(colors.primaryRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    String hint,
    IconData icon,
    AppThemeColors colors, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label(colors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: AppTextStyles.bodyL(colors.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
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
              prefixIcon: Icon(icon, color: colors.textMuted, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pwField(String label, TextEditingController ctrl, String key, AppThemeColors colors) {
    final show = _pwVis[key] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label(colors.textMuted)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: !show,
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
                onPressed: () => setState(() => _pwVis[key] = !show),
                icon: Icon(
                  show
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colors.textMuted,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
