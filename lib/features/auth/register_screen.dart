// lib/features/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../shared/widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
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
                onPressed: () => context.go('/login'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textLight),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Join The\nExperience',
                style: AppTextStyles.display(AppColors.textLight),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to get started.',
                style: AppTextStyles.bodyM(AppColors.textMutedLight),
              ),
              const SizedBox(height: 32),

              _buildField('Full Name', _name, icon: Icons.person_outline_rounded, placeholder: 'John Doe'),
              _buildField('Email Address', _email, icon: Icons.alternate_email_rounded, placeholder: 'name@example.com', type: TextInputType.emailAddress),
              _buildField('Phone Number', _phone, icon: Icons.phone_outlined, placeholder: '+92 300 1234567', type: TextInputType.phone),
              _buildField('Password', _password, icon: Icons.lock_outline_rounded, placeholder: '••••••••', isPassword: true, key: 'password'),
              _buildField('Confirm Password', _confirm, icon: Icons.lock_outline_rounded, placeholder: '••••••••', isPassword: true, key: 'confirm'),

              const SizedBox(height: 12),
              PrimaryButton(label: 'Create Account', loading: _loading, onPressed: _submit),
              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyM(AppColors.textMutedLight),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: Text(
                            'Sign In',
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

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    IconData? icon,
    String? placeholder,
    bool isPassword = false,
    String? key,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AppTextStyles.label(AppColors.textMutedLight),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: isPassword && !(_pwVis[key ?? label] ?? false),
            keyboardType: type,
            style: AppTextStyles.bodyL(AppColors.textLight),
            decoration: InputDecoration(
              hintText: placeholder,
              prefixIcon: icon != null
                  ? Icon(icon, color: AppColors.textMutedLight, size: 20)
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () => setState(
                          () => _pwVis[key ?? label] = !(_pwVis[key ?? label] ?? false)),
                      icon: Icon(
                        (_pwVis[key ?? label] ?? false)
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMutedLight,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
