// lib/features/favourites/favourites_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';
import '../../shared/widgets/price_text.dart';

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favIds = ref.watch(favouritesProvider);
    final cart = ref.watch(cartProvider);
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textLight),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceLight,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Favourites',
                          style: AppTextStyles.headingM(AppColors.textLight)),
                      Text('${favIds.length} items saved',
                          style: AppTextStyles.bodyXS(AppColors.textMutedLight)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
                error: (_, __) => EmptyState(
                  iconData: Icons.wifi_off_rounded,
                  iconColor: AppColors.error,
                  title: 'Unable to Load Items',
                  subtitle: 'Check your internet connection and try again.',
                  action: SizedBox(
                    width: 160,
                    child: SecondaryButton(
                      label: 'Retry',
                      onPressed: () => ref.invalidate(catalogProvider),
                      fullWidth: false,
                    ),
                  ),
                ),
                data: (allProducts) {
                  final favProducts =
                      allProducts.where((p) => favIds.contains(p.id)).toList();

                  if (favProducts.isEmpty) {
                    return EmptyState(
                      iconData: Icons.favorite_border_rounded,
                      iconColor: const Color(0xFFFF3B5C),
                      title: 'No Favourites Yet',
                      subtitle: 'Tap the heart on any menu item or drink to save it here for quick reordering.',
                      action: SizedBox(
                        width: 180,
                        child: PrimaryButton(
                          label: 'Browse Menu',
                          onPressed: () => context.go('/food-menu'),
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: favProducts.length,
                    itemBuilder: (_, i) {
                      final p = favProducts[i];
                      final qty = cart[p.id] ?? 0;
                      return GestureDetector(
                        onTap: () => context.push('/product/${p.id}'),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusCard),
                            border:
                                Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(AppTheme.radiusCard)),
                                    child: Container(
                                      height: 110,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryRed.withValues(alpha: 0.12),
                                      ),
                                      child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                          ? Image.network(
                                              p.imageUrl!,
                                              height: 110,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Text(p.emoji, style: const TextStyle(fontSize: 44)),
                                              ),
                                            )
                                          : Center(
                                              child: Text(p.emoji, style: const TextStyle(fontSize: 44)),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => ref
                                          .read(favouritesProvider.notifier)
                                          .toggle(p.id),
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.favorite,
                                          color: AppColors.primaryRed,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      style: AppTextStyles.bold(
                                          AppColors.textLight,
                                          size: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.category.toUpperCase(),
                                      style: AppTextStyles.label(
                                          AppColors.textMutedLight),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        PriceText(price: p.price),
                                        if (qty > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryRed,
                                              borderRadius:
                                                  BorderRadius.circular(AppTheme.radiusPill),
                                            ),
                                            child: Text(
                                              '$qty in cart',
                                              style: AppTextStyles.bodyXS(
                                                  Colors.white),
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () => ref
                                                .read(cartProvider.notifier)
                                                .add(p.id),
                                            child: Container(
                                              width: 26,
                                              height: 26,
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryRed,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add,
                                                  color: Colors.white,
                                                  size: 14),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
