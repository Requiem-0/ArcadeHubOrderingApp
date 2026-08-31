// lib/shared/widgets/price_text.dart
import 'package:flutter/material.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/constants.dart';

class PriceText extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final bool small;

  const PriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.small = false,
  });

  String _format(double n) =>
      '${AppConstants.currencySymbol} ${n.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        originalPrice != null && originalPrice! > price;
    final fontSize = small ? 13.0 : 16.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (hasDiscount) ...[
          Text(
            _format(originalPrice!),
            style: AppTextStyles.bodyM(AppColors.textMutedLight).copyWith(
              decoration: TextDecoration.lineThrough,
              fontSize: fontSize - 2,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          _format(price),
          style: AppTextStyles.bold(AppColors.primaryRed, size: fontSize),
        ),
      ],
    );
  }
}
