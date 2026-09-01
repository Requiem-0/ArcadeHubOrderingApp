// lib/features/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../shared/widgets/app_logo.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryRed.withValues(alpha: 0.12),
              AppColors.scaffoldLight.withValues(alpha: 0.95),
              AppColors.scaffoldLight,
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(36, 16, 36, 40),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 56,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Bar Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => context.go('/login'),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: AppColors.textLight, size: 18),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSM),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40, height: 40),
                        ],
                      ),

                      // Centered Form Content Group
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Glassmorphic Dual-Shadow Icon Box
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primaryRed.withValues(alpha: 0.5),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryRed.withValues(alpha: 0.28),
                                        blurRadius: 14,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 4),
                                      ),
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const AppLogo(size: 40, compact: true),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Create Account',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                _buildField(_name,
                                    icon: Icons.person_outline_rounded,
                                    placeholder: 'Full Name'),
                                _buildField(_email,
                                    icon: Icons.alternate_email_rounded,
                                    placeholder: 'Email Address',
                                    type: TextInputType.emailAddress),
                                _buildField(_phone,
                                    icon: Icons.phone_outlined,
                                    placeholder: 'Phone Number',
                                    type: TextInputType.phone),
                                _buildField(_password,
                                    icon: Icons.lock_outline_rounded,
                                    placeholder: 'Password',
                                    isPassword: true,
                                    key: 'password'),
                                _buildField(_confirm,
                                    icon: Icons.lock_outline_rounded,
                                    placeholder: 'Confirm Password',
                                    isPassword: true,
                                    key: 'confirm'),

                                const SizedBox(height: 8),
                                PrimaryButton(
                                    label: 'CREATE ACCOUNT →',
                                    loading: _loading,
                                    onPressed: _submit),
                                const SizedBox(height: 18),

                                // Subtle Shadow Line Divider
                                Container(
                                  height: 1,
                                  width: 140,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.primaryRed.withValues(alpha: 0.3),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Already have an account? ',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12.5,
                                        color: AppColors.textMutedLight,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => context.go('/home'),
                                  child: Text(
                                    'Skip for now — Browse as Guest',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 12,
                                      color: AppColors.textMutedLight,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Footer Subtitle Tag
                      Center(
                        child: Text(
                          "Pokhara's Premier Entertainment Hub",
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMutedLight.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl, {
    required IconData icon,
    required String placeholder,
    bool isPassword = false,
    String? key,
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        obscureText: isPassword && !(_pwVis[key ?? placeholder] ?? false),
        keyboardType: type,
        style: AppTextStyles.bodyL(AppColors.textLight),
        decoration: InputDecoration(
          hintText: placeholder,
          prefixIcon: Icon(icon, color: AppColors.textMutedLight, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: () => setState(() =>
                      _pwVis[key ?? placeholder] = !(_pwVis[key ?? placeholder] ?? false)),
                  icon: Icon(
                    (_pwVis[key ?? placeholder] ?? false)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMutedLight,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
