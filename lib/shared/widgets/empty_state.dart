// lib/shared/widgets/empty_state.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';

class EmptyState extends StatelessWidget {
  final String? icon;
  final IconData? iconData;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon,
    this.iconData,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null)
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (iconColor ?? AppColors.primaryRed).withValues(alpha: 0.12),
                  border: Border.all(
                    color: (iconColor ?? AppColors.primaryRed).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (iconColor ?? AppColors.primaryRed).withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  iconData,
                  size: 34,
                  color: iconColor ?? AppColors.primaryRed,
                ),
              )
            else if (icon != null)
              Text(icon!, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                subtitle,
                style: GoogleFonts.dmSans(
                  fontSize: 13.5,
                  color: AppColors.textMutedLight,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
