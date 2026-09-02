// lib/features/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/network/api_client.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../core/utils/app_toast.dart';
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
      AppToast.showWarning(context, 'Please enter your email or phone number');
      return;
    }

    if (password.isEmpty) {
      AppToast.showWarning(context, 'Please enter your password');
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

        AppToast.showSuccess(context, 'Welcome back to Arcade Hub!');
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String msg = 'Invalid credentials. Please check email/phone and password.';
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
          AppToast.showError(context, msg);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showReactivateDialog(String emailOrPhone, String password) {
    final colors = context.appColors;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          'Reactivate Account',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        content: Text(
          'Your account is currently deactivated. Would you like to reactivate it and log in now?',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: colors.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.dmSans(color: colors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primaryRed,
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
                  AppToast.showSuccess(context, 'Account reactivated! Welcome back.');
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                }
              } catch (e) {
                if (mounted) {
                  final msg = e is ApiException ? e.message : 'Reactivation failed.';
                  AppToast.showError(context, msg);
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: Text('Reactivate', style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 84)),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to\nArcade Hub',
                    style: AppTextStyles.headingXL(colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to reserve gaming slots, order food, and view your receipts.',
                    style: AppTextStyles.bodyM(colors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Email/Phone input
                  Text('EMAIL OR PHONE', style: AppTextStyles.label(colors.textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: AppTextStyles.bodyL(colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'user@example.com or 9800000000',
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
                      prefixIcon: Icon(Icons.person_outline_rounded,
                          color: colors.textMuted, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password input
                  Text('PASSWORD', style: AppTextStyles.label(colors.textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: !_showPw,
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
                        onPressed: () => setState(() => _showPw = !_showPw),
                        icon: Icon(
                          _showPw
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: colors.textMuted,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  PrimaryButton(
                    label: 'Sign In',
                    loading: _loading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyM(colors.textMuted),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Register',
                          style: AppTextStyles.semibold(colors.primaryRed),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Guest explore link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                      child: Text(
                        'Continue browsing as Guest',
                        style: AppTextStyles.bodyS(colors.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
