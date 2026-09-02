// lib/features/address/saved_addresses_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/repositories/location_repository.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/secondary_button.dart';

class SavedAddressesScreen extends ConsumerWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final locationsAsync = ref.watch(savedLocationsProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
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
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: colors.textPrimary),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                        side: BorderSide(color: colors.border),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Saved Addresses',
                      style: AppTextStyles.headingM(colors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: locationsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.primaryRed),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading addresses: $err',
                      style: TextStyle(color: colors.textPrimary)),
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
                                color: colors.card,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusCard),
                                border: Border.all(
                                    color: colors.border,
                                    width: 1.5),
                                boxShadow: colors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colors.primaryRed
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(
                                              AppTheme.radiusML),
                                    ),
                                    child: Icon(
                                        Icons.location_on_rounded,
                                        color: colors.primaryRed,
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
                                                        colors.textPrimary,
                                                        size: 15)),
                                            if (loc.isDefault) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: colors.primaryRed
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppTheme.radiusPill),
                                                ),
                                                child: Text('Default',
                                                    style: AppTextStyles
                                                        .bodyXS(colors
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
                                                colors.textMuted)),
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
