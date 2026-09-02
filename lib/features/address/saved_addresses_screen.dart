// lib/features/address/saved_addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/location_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/secondary_button.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(savedLocationsProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textLight),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Saved Addresses',
                      style: AppTextStyles.headingM(AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: locationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading addresses: $err',
                      style: AppTextStyles.bodyM(AppColors.error)),
                ),
                data: (locations) {
                  if (locations.isEmpty) {
                    return EmptyState(
                      iconData: Icons.location_off_rounded,
                      iconColor: const Color(0xFF00E5FF),
                      title: 'No saved addresses',
                      subtitle: 'Add an address for quick checkout.',
                      action: SecondaryButton(
                        label: '+ Add Address',
                        onPressed: () => context.push('/add-address'),
                        fullWidth: false,
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      ...locations.map((loc) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard),
                                border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryRed
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppTheme.radiusML),
                                    ),
                                    child: const Icon(
                                        Icons.location_on_rounded,
                                        color: AppColors.primaryRed,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(loc.title,
                                                style: AppTextStyles
                                                    .semibold(
                                                        AppColors.textLight,
                                                        size: 15)),
                                            if (loc.isDefault) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryRed
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppTheme.radiusPill),
                                                ),
                                                child: Text('Default',
                                                    style: AppTextStyles
                                                        .bodyXS(AppColors
                                                            .primaryRed)
                                                        .copyWith(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(loc.address,
                                            style: AppTextStyles.bodyS(
                                                AppColors.textMutedLight)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 8),
                      SecondaryButton(
                        label: '+ Add New Address',
                        onPressed: () => context.push('/add-address'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
