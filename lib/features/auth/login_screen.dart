// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPw = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _loading = false);
      context.go('/home');
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
                onPressed: () => context.go('/splash'),
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
              const AppLogo(size: 56, compact: true),
              const SizedBox(height: 24),

              // Header
              Text(
                'Welcome\nBack',
                style: AppTextStyles.display(AppColors.textLight),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to continue ordering.',
                style: AppTextStyles.bodyM(AppColors.textMutedLight),
              ),
              const SizedBox(height: 36),

              // Email
              _FieldLabel('Email or Phone Number'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: AppTextStyles.bodyL(AppColors.textLight),
                decoration: const InputDecoration(
                  hintText: 'name@example.com or phone',
                  prefixIcon: Icon(Icons.alternate_email_rounded,
                      color: AppColors.textMutedLight, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              _FieldLabel('Password'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: !_showPw,
                style: AppTextStyles.bodyL(AppColors.textLight),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded,
                      color: AppColors.textMutedLight, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _showPw = !_showPw),
                    icon: Icon(
                      _showPw
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMutedLight,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.semibold(AppColors.primaryRed, size: 13),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Sign in button
              PrimaryButton(
                label: 'SIGN IN →',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 24),

              // Register link
              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodyM(AppColors.textMutedLight),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/register'),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.semibold(AppColors.primaryRed, size: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        'Skip for now — Browse as Guest',
                        style: AppTextStyles.bodyM(AppColors.textMutedLight).copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label(AppColors.textMutedLight),
    );
  }
}
