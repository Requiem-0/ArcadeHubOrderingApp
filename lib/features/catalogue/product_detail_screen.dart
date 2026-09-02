// lib/features/catalogue/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../features/catalogue/data/sample_products.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/price_text.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  final ProductModel? initialProduct;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedVariant;
  final Set<String> _selectedAddons = {};

  ProductModel _resolvedProduct(WidgetRef ref) {
    final catalogAsync = ref.watch(catalogProvider);
    return catalogAsync.maybeWhen(
      data: (products) => products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () =>
            widget.initialProduct ??
            kSampleProducts.firstWhere(
              (p) => p.id == widget.productId,
              orElse: () => kSampleProducts.first,
            ),
      ),
      orElse: () =>
          widget.initialProduct ??
          kSampleProducts.firstWhere(
            (p) => p.id == widget.productId,
            orElse: () => kSampleProducts.first,
          ),
    );
  }

  double _currentPrice(ProductModel product) {
    if (_selectedVariant != null && product.variants.isNotEmpty) {
      final variant = product.variants
          .firstWhere((v) => v.id == _selectedVariant,
              orElse: () => product.variants.first);
      return variant.price;
    }
    return product.price;
  }

  double _addonsTotal(ProductModel product) => product.addons
      .where((a) => _selectedAddons.contains(a.id))
      .fold(0, (sum, a) => sum + a.price);

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final product = _resolvedProduct(ref);
    final cart = ref.watch(cartProvider);
    final favs = ref.watch(favouritesProvider);
    final qty = cart[product.id] ?? 0;
    final isFav = favs.contains(product.id);
    final priceToDisplay = _currentPrice(product);
    final addonsPriceToDisplay = _addonsTotal(product);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Hero image area
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: colors.scaffold,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.card.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: colors.textPrimary, size: 18),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colors.card.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: IconButton(
                      onPressed: () => ref
                          .read(favouritesProvider.notifier)
                          .toggle(product.id),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : colors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors.border,
                          colors.primaryRed.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(product.emoji,
                                  style: const TextStyle(fontSize: 90)),
                            ),
                          )
                        : Center(
                            child: Text(product.emoji,
                                style: const TextStyle(fontSize: 90)),
                          ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.scaffold,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + price
                      Text(product.name,
                          style: AppTextStyles.headingL(colors.textPrimary)),
                      const SizedBox(height: 4),
                      if (product.prepTime != null)
                        Row(children: [
                          Icon(Icons.access_time_rounded,
                              color: colors.textMuted, size: 14),
                          const SizedBox(width: 4),
                          Text(product.prepTime!,
                              style: AppTextStyles.bodyS(colors.textMuted)),
                        ]),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          PriceText(
                              price: priceToDisplay,
                              originalPrice: product.originalPrice),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.primaryRed.withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusPill),
                            ),
                            child: Text(
                              '+${(AppConstants.vatRate * 100).toStringAsFixed(0)}% VAT',
                              style: AppTextStyles.bodyXS(colors.primaryRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      if (product.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          children: product.tags.map((tag) {
                            final isGood = ['Organic', 'Vegan'].contains(tag);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isGood
                                    ? AppColors.success.withValues(alpha: 0.15)
                                    : colors.primaryRed.withValues(alpha: 0.15),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusPill),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.bodyXS(
                                    isGood ? AppColors.success : colors.primaryRed),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      if (product.description.isNotEmpty || product.longDescription != null) ...[
                        Text(
                          product.longDescription ?? product.description,
                          style: AppTextStyles.bodyM(colors.textMuted),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Variants
                      if (product.variants.isNotEmpty) ...[
                        const SectionHeader(title: 'Choose Size'),
                        const SizedBox(height: 12),
                        ...product.variants.map((v) {
                          final selected = _selectedVariant == v.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedVariant = v.id),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.primaryRed.withValues(alpha: 0.1)
                                    : colors.card,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSM),
                                border: Border.all(
                                  color: selected
                                      ? colors.primaryRed
                                      : colors.border,
                                  width: 1.5,
                                ),
                                boxShadow: colors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  _RadioDot(selected: selected),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(v.label,
                                          style: AppTextStyles.bodyM(
                                              colors.textPrimary))),
                                  Text(
                                    'Rs ${v.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.semibold(
                                        colors.primaryRed, size: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Addons
                      if (product.addons.isNotEmpty) ...[
                        const SectionHeader(title: 'Add-ons'),
                        const SizedBox(height: 12),
                        ...product.addons.map((a) {
                          final selected = _selectedAddons.contains(a.id);
                          return GestureDetector(
                            onTap: () => setState(() {
                              selected
                                  ? _selectedAddons.remove(a.id)
                                  : _selectedAddons.add(a.id);
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colors.primaryRed.withValues(alpha: 0.1)
                                    : colors.card,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSM),
                                border: Border.all(
                                  color: selected
                                      ? colors.primaryRed
                                      : colors.border,
                                  width: 1.5,
                                ),
                                boxShadow: colors.cardShadow,
                              ),
                              child: Row(
                                children: [
                                  _CheckDot(selected: selected),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(a.name,
                                          style: AppTextStyles.bodyM(
                                              colors.textPrimary))),
                                  Text(
                                    '+Rs ${a.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.semibold(
                                        colors.primaryRed, size: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: colors.scaffold.withValues(alpha: 0.95),
                border: Border(
                    top: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total',
                          style: AppTextStyles.bodyXS(colors.textMuted)),
                      Text(
                        'Rs ${(priceToDisplay + addonsPriceToDisplay) * (qty == 0 ? 1 : qty)}',
                        style: AppTextStyles.bold(colors.primaryRed, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  if (qty > 0) ...[
                    _FloatingQtyControl(
                      qty: qty,
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).remove(product.id),
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).add(product.id),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (qty == 0) {
                          ref.read(cartProvider.notifier).add(product.id);
                        } else {
                          context.go('/cart');
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primaryRed, colors.deepRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primaryRed.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                qty > 0
                                    ? Icons.shopping_bag_rounded
                                    : Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                qty > 0 ? 'View Cart' : 'Add to Cart',
                                style: AppTextStyles.semibold(Colors.white, size: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primaryRed : colors.textMuted,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: colors.primaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _CheckDot extends StatelessWidget {
  final bool selected;
  const _CheckDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? colors.primaryRed : Colors.transparent,
        border: Border.all(
          color: selected ? colors.primaryRed : colors.textMuted,
          width: 2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 12)
          : null,
    );
  }
}

class _FloatingQtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _FloatingQtyControl({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.cardElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Icon(Icons.remove, color: colors.textPrimary, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$qty',
                style: AppTextStyles.bold(colors.textPrimary, size: 16)),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
