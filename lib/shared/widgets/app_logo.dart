// lib/shared/widgets/app_logo.dart
import 'package:flutter/material.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/constants.dart';

/// Placeholder logo widget for Arcade Hub.
/// Replace inner content with actual SVG/image once brandkit is delivered.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showLabel;
  final bool compact;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryRed,
                AppColors.deepRed,
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryRed.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'AH',
              style: AppTextStyles.bold(
                AppColors.onPrimary,
                size: size * 0.36,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: compact ? 8 : 14),
          Text(
            AppConstants.appName,
            style: AppTextStyles.headingM(AppColors.textLight),
          ),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodyS(AppColors.textMutedLight),
            ),
          ],
        ],
      ],
    );
  }
}
