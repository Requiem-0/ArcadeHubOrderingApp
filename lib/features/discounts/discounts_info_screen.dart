// lib/features/discounts/discounts_info_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/constants.dart';

class DiscountsInfoScreen extends StatelessWidget {
  const DiscountsInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final active = AppConstants.isDiscountActiveNow();

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        title: Text(
          'App Discounts & Offers',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: active ? AppColors.success : AppColors.primaryRedDark,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${(AppConstants.discountPercentage ?? 10).toInt()}% Daily App Discount',
                                style: GoogleFonts.outfit(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textLight,
                                ),
                              ),
                              Text(
                                active ? '● ACTIVE RIGHT NOW' : 'Active Daily 5:00 PM – 8:00 PM',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: active ? AppColors.success : AppColors.primaryRedDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Enjoy ${(AppConstants.discountPercentage ?? 10).toInt()}% off any food or beverage order placed directly through the Arcade Hub app during active hours (5:00 PM - 8:00 PM).',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textMutedLight,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Browse Menu & Order Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
