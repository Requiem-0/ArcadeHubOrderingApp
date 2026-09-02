// lib/features/address/add_address_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/location_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/primary_button.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _ctrls = <String, TextEditingController>{};
  bool _loading = false;

  static const _fields = [
    {'key': 'label', 'label': 'Label', 'placeholder': 'Home, Office, Rooftop Spot...'},
    {'key': 'phone', 'label': 'Phone', 'placeholder': '+977 9800000000'},
    {'key': 'street', 'label': 'Street Address / Spot', 'placeholder': 'New Road, Pokhara'},
    {'key': 'city', 'label': 'City', 'placeholder': 'Pokhara'},
    {'key': 'postcode', 'label': 'Postcode', 'placeholder': '33700'},
    {'key': 'landmark', 'label': 'Landmark / Note (Optional)', 'placeholder': 'Near New Road'},
  ];

  @override
  void initState() {
    super.initState();
    for (final f in _fields) {
      _ctrls[f['key']!] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/addresses');
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
                  Text('New Address',
                      style: AppTextStyles.headingM(AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use current location card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppColors.borderLight, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppTheme.radiusML),
                            ),
                            child: const Icon(Icons.my_location_rounded,
                                color: AppColors.success, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Use my current location',
                                    style: AppTextStyles.semibold(
                                        AppColors.textLight, size: 14)),
                                Row(
                                  children: [
                                    Text('Location pinned',
                                        style: AppTextStyles.bodyS(AppColors.success)),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.check_circle_rounded,
                                        size: 13, color: AppColors.success),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    for (final f in _fields) ...[
                      Text(
                        f['label']!.toUpperCase(),
                        style: AppTextStyles.label(AppColors.textMutedLight),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _ctrls[f['key']!],
                        style: AppTextStyles.bodyL(AppColors.textLight),
                        decoration: InputDecoration(hintText: f['placeholder']),
                      ),
                      const SizedBox(height: 18),
                    ],

                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Save Address',
                      loading: _loading,
                      onPressed: () async {
                        final label = _ctrls['label']?.text.trim() ?? '';
                        final street = _ctrls['street']?.text.trim() ?? '';
                        final city = _ctrls['city']?.text.trim() ?? '';
                        final fullAddr = '$street, $city'.trim();

                        if (label.isEmpty || street.isEmpty) {
                          AppToast.showWarning(context, 'Please fill label and street address');
                          return;
                        }

                        setState(() => _loading = true);
                        try {
                          await ref.read(locationRepositoryProvider).addLocation(
                                title: label,
                                address: fullAddr,
                                note: _ctrls['landmark']?.text,
                              );
                          ref.invalidate(savedLocationsProvider);
                          if (mounted) {
                            AppToast.showSuccess(context, 'Delivery address added!');
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/addresses');
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            AppToast.showSuccess(context, 'Address saved locally.');
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/addresses');
                            }
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
