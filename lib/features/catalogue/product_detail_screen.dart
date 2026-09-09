// lib/features/catalogue/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import '../../shared/widgets/app_network_image.dart';

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
  final Map<String, int> _addonQuantities = {};
  int _itemCount = 1;

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
    if (product.variants.isNotEmpty) {
      final selectedId = _selectedVariant ?? product.variants.first.id;
      final variant = product.variants
          .firstWhere((v) => v.id == selectedId,
              orElse: () => product.variants.first);
      return variant.price;
    }
    return product.effectivePrice;
  }

  double _addonsTotal(ProductModel product) => product.addons.fold(
      0.0,
      (sum, a) =>
          sum + (a.price * (_addonQuantities[a.id] ?? 0)));

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final product = _resolvedProduct(ref);
    if (_selectedVariant == null && product.variants.isNotEmpty) {
      _selectedVariant = product.variants.first.id;
    }
    final cart = ref.watch(cartProvider);
    final favs = ref.watch(favouritesProvider);
    final totalInCart = ref.read(cartProvider.notifier).getProductQuantity(product.id);
    final isFav = favs.contains(product.id);
    final priceToDisplay = _currentPrice(product);
    final addonsPriceToDisplay = _addonsTotal(product);
    final unitPrice = priceToDisplay + addonsPriceToDisplay;

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
                    child: AppNetworkImage(
                      url: product.imageUrl,
                      fallback: Text(product.emoji,
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
                              originalPrice: product.displayOriginalPrice),
                          if (product.hasDiscount) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primaryRed,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusPill),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primaryRed
                                        .withValues(alpha: 0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                product.discountTag ?? 'OFFER',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(width: 10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SectionHeader(title: 'Add-ons'),
                            Text(
                              'Customise your item',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...product.addons.map((a) {
                          final addonQty = _addonQuantities[a.id] ?? 0;
                          final selected = addonQty > 0;
                          final maxLimit = a.maxAvailable > 0 ? a.maxAvailable : 5;
                          final canIncrement = addonQty < maxLimit;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.primaryRed.withValues(alpha: 0.08)
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
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (addonQty == 0) {
                                        _addonQuantities[a.id] = 1;
                                      } else {
                                        _addonQuantities.remove(a.id);
                                      }
                                    });
                                  },
                                  child: _CheckDot(selected: selected),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        a.name,
                                        style: AppTextStyles.bodyM(
                                            colors.textPrimary),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            '+Rs ${a.price.toStringAsFixed(0)}',
                                            style: AppTextStyles.semibold(
                                                colors.primaryRed, size: 13),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: colors.borderSubtle,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              'Max $maxLimit',
                                              style: GoogleFonts.dmSans(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: colors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (selected)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: colors.scaffold,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: colors.border),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              if (addonQty <= 1) {
                                                _addonQuantities.remove(a.id);
                                              } else {
                                                _addonQuantities[a.id] = addonQty - 1;
                                              }
                                            });
                                          },
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(Icons.remove, size: 16, color: colors.textPrimary),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            '$addonQty',
                                            style: GoogleFonts.outfit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: colors.primaryRed,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: canIncrement
                                              ? () {
                                                  setState(() {
                                                    _addonQuantities[a.id] = addonQty + 1;
                                                  });
                                                }
                                              : null,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            child: Icon(
                                              Icons.add,
                                              size: 16,
                                              color: canIncrement ? colors.primaryRed : colors.textMuted.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _addonQuantities[a.id] = 1;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: colors.primaryRed.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        '+ Add',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: colors.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: colors.scaffold.withValues(alpha: 0.98),
                border: Border(
                    top: BorderSide(color: colors.borderSubtle)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _FloatingQtyControl(
                    qty: _itemCount,
                    onDecrement: () {
                      if (_itemCount > 1) {
                        setState(() => _itemCount--);
                      }
                    },
                    onIncrement: () => setState(() => _itemCount++),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final selectedVarObj = product.variants.isNotEmpty
                            ? product.variants.firstWhere(
                                (v) => v.id == (_selectedVariant ?? product.variants.first.id),
                                orElse: () => product.variants.first,
                              )
                            : null;
                        ref.read(cartProvider.notifier).addItem(
                              product: product,
                              variant: selectedVarObj,
                              addons: Map.from(_addonQuantities),
                              quantity: _itemCount,
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${selectedVarObj != null ? "${product.name} (${selectedVarObj.label})" : product.name} to cart!',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: AppColors.success,
                            duration: const Duration(seconds: 2),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              textColor: Colors.white,
                              onPressed: () => context.push('/cart'),
                            ),
                          ),
                        );
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_shopping_cart_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add • Rs ${(unitPrice * _itemCount).toStringAsFixed(0)}',
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
