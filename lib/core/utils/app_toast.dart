// lib/core/utils/app_toast.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../brandkit/app_colors.dart';
import '../brandkit/app_theme.dart';

enum ToastType { success, error, info, warning }

class AppToast {
  AppToast._();

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message, type: ToastType.success, duration: duration);
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    show(context, message, type: ToastType.error, duration: duration);
  }

  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message, type: ToastType.info, duration: duration);
  }

  static void showWarning(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message, type: ToastType.warning, duration: duration);
  }

  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    HapticFeedback.lightImpact();

    final (Color accentColor, IconData iconData) = switch (type) {
      ToastType.success => (const Color(0xFF00E676), Icons.check_circle_rounded),
      ToastType.error => (const Color(0xFFFF3B5C), Icons.error_rounded),
      ToastType.warning => (const Color(0xFFFFB703), Icons.warning_rounded),
      ToastType.info => (const Color(0xFF00E5FF), Icons.info_rounded),
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF18181D),
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Glowing Icon Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  iconData,
                  size: 17,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 12),

              // Message
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
