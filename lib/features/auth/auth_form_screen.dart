// lib/features/auth/auth_form_screen.dart
// Generic screen for Forgot Password / Reset Password / Verify Email
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
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

class AuthFormScreen extends StatefulWidget {
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
  State<AuthFormScreen> createState() => _AuthFormScreenState();
}

class _AuthFormScreenState extends State<AuthFormScreen> {
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
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _loading = false);
      context.go(widget.nextRoute);
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
