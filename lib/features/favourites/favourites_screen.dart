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
        child: catalogAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryRed),
          ),
          error: (_, __) => const Center(
            child: Text('Error loading catalog'),
          ),
          data: (allProducts) {
            final favProducts =
                allProducts.where((p) => favIds.contains(p.id)).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Favourites',
                          style: AppTextStyles.headingL(AppColors.textLight)),
                      Text('${favProducts.length} items',
                          style: AppTextStyles.bodyM(AppColors.textMutedLight)),
                    ],
                  ),
                ),
                Expanded(
                  child: favProducts.isEmpty
                      ? EmptyState(
                          icon: '♡',
                          title: 'No favourites yet',
                          subtitle: 'Tap the heart on any item to save it here.',
                          action: PrimaryButton(
                            label: 'Browse Menu',
                            onPressed: () => context.go('/food-menu'),
                          ),
                        )
                      : GridView.builder(
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
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceLight
                                                    .withValues(alpha: 0.9),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppTheme.radiusXS),
                                              ),
                                              child: const Icon(
                                                  Icons.favorite_rounded,
                                                  color: AppColors.error,
                                                  size: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(p.name,
                                              style: AppTextStyles.semibold(
                                                  AppColors.textLight,
                                                  size: 13),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                          Text(p.prepTime ?? '',
                                              style: AppTextStyles.bodyXS(
                                                  AppColors.textMutedLight)),
                                          const SizedBox(height: 6),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              PriceText(
                                                  price: p.price,
                                                  originalPrice: p.originalPrice,
                                                  small: true),
                                              if (qty > 0)
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryRed,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppTheme.radiusPill),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () => ref
                                                            .read(cartProvider
                                                                .notifier)
                                                            .remove(p.id),
                                                        child: const Icon(
                                                            Icons.remove,
                                                            color: Colors.white,
                                                            size: 14),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 6),
                                                        child: Text('$qty',
                                                            style: AppTextStyles
                                                                .bold(Colors.white,
                                                                    size: 12)),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () => ref
                                                            .read(cartProvider
                                                                .notifier)
                                                            .add(p.id),
                                                        child: const Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 14),
                                                      ),
                                                    ],
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
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
