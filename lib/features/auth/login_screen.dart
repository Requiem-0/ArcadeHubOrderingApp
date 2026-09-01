// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/primary_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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
    final emailOrPhone = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (emailOrPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email or phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).login(
            emailOrPhone: emailOrPhone,
            password: password,
          );
      if (mounted) {
        ref.invalidate(isLoggedInStateProvider);
        ref.invalidate(currentUserProvider);
        ref.invalidate(myOrdersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful! Welcome to Arcade Hub.'),
            backgroundColor: AppColors.success,
          ),
        );
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Invalid credentials. Please check your email/phone and password.';
        if (e is ApiException) {
          if (e.body is Map && e.body['error'] != null) {
            msg = e.body['error'].toString();
          } else if (e.body is Map && e.body['message'] != null) {
            msg = e.body['message'].toString();
          } else {
            msg = e.message;
          }
        }

        if (msg.toLowerCase().contains('deactivate') ||
            msg.toLowerCase().contains('reactivate')) {
          _showReactivateDialog(emailOrPhone, password);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showReactivateDialog(String emailOrPhone, String password) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text('Account Deactivated',
            style: AppTextStyles.headingS(AppColors.textLight)),
        content: Text(
          'Your account is currently deactivated. Would you like to reactivate it now and sign in?',
          style: AppTextStyles.bodyM(AppColors.textMutedLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.semibold(AppColors.textMutedLight)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSM),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                await ref.read(authRepositoryProvider).reactivate(
                      emailOrPhone: emailOrPhone,
                      password: password,
                    );
                if (mounted) {
                  ref.invalidate(isLoggedInStateProvider);
                  ref.invalidate(currentUserProvider);
                  ref.invalidate(myOrdersProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account reactivated! Welcome back.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                }
              } catch (err) {
                if (mounted) {
                  final errorMsg = err is ApiException
                      ? err.message
                      : 'Reactivation failed. Please try again.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMsg),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: Text('Reactivate & Sign In',
                style: AppTextStyles.semibold(Colors.white)),
          ),
        ],
      ),
    );
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
                      // ── 1. Top Pinned Navigation Bar ──────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => context.go('/splash'),
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

                      // ── 2. Vertically Centered Form Group ──────────────
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
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
                                  child: const AppLogo(size: 44, compact: true),
                                ),
                                const SizedBox(height: 20),

                                // Centered Headline
                                Text(
                                  'Welcome Back',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Email Input
                                TextField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: AppTextStyles.bodyL(AppColors.textLight),
                                  decoration: const InputDecoration(
                                    hintText: 'Email or phone number',
                                    prefixIcon: Icon(Icons.alternate_email_rounded,
                                        color: AppColors.textMutedLight, size: 20),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Password Input
                                TextField(
                                  controller: _passwordCtrl,
                                  obscureText: !_showPw,
                                  style: AppTextStyles.bodyL(AppColors.textLight),
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                                        color: AppColors.textMutedLight, size: 20),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _showPw = !_showPw),
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
                                const SizedBox(height: 6),

                                // Forgot password link
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push('/forgot-password'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTextStyles.semibold(
                                          AppColors.primaryRed,
                                          size: 12.5),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 22),

                                // Primary Sign In Button
                                PrimaryButton(
                                  label: 'SIGN IN →',
                                  loading: _loading,
                                  onPressed: _submit,
                                ),
                                const SizedBox(height: 20),

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
                                const SizedBox(height: 20),

                                // Compact Footer Navigation Actions
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12.5,
                                        color: AppColors.textMutedLight,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push('/register'),
                                      child: Text(
                                        'Sign Up',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
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

                      // ── 3. Subtle Footer Brand Lockup ────────────────
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
}
