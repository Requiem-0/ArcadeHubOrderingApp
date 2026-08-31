// lib/shared/widgets/category_pill.dart
import 'package:flutter/material.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';

class CategoryPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const CategoryPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryRed : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: active ? AppColors.primaryRed : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Text(
          label,
          style: AppTextStyles.labelM(
            active ? AppColors.onPrimary : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
