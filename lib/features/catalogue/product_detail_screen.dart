// lib/features/catalogue/product_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/constants.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/price_text.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedVariant;
  final Set<String> _selectedAddons = {};

  @override
  void initState() {
    super.initState();
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first.id;
    }
  }

  double get _currentPrice {
    if (_selectedVariant != null) {
      final variant = widget.product.variants
          .firstWhere((v) => v.id == _selectedVariant,
              orElse: () => widget.product.variants.first);
      return variant.price;
    }
    return widget.product.price;
  }

  double get _addonsTotal => widget.product.addons
      .where((a) => _selectedAddons.contains(a.id))
      .fold(0, (sum, a) => sum + a.price);


  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final favs = ref.watch(favouritesProvider);
    final qty = cart[widget.product.id] ?? 0;
    final isFav = favs.contains(widget.product.id);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // Hero image area
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.scaffoldLight,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                  ),
                  child: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textLight, size: 18),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: IconButton(
                      onPressed: () => ref
                          .read(favouritesProvider.notifier)
                          .toggle(widget.product.id),
                      icon: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? AppColors.error : AppColors.textLight,
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
                          AppColors.borderLight,
                          AppColors.primaryRed.withOpacity(0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(widget.product.emoji,
                          style: const TextStyle(fontSize: 90)),
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppColors.scaffoldLight,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + price
                      Text(widget.product.name,
                          style: AppTextStyles.headingL(AppColors.textLight)),
                      const SizedBox(height: 4),
                      if (widget.product.prepTime != null)
                        Row(children: [
                          const Icon(Icons.access_time_rounded,
                              color: AppColors.textMutedLight, size: 14),
                          const SizedBox(width: 4),
                          Text(widget.product.prepTime!,
                              style: AppTextStyles.bodyS(AppColors.textMutedLight)),
                        ]),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          PriceText(
                              price: _currentPrice,
                              originalPrice: widget.product.originalPrice),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryRed.withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusPill),
                            ),
                            child: Text(
                              '+${(AppConstants.vatRate * 100).toStringAsFixed(0)}% VAT',
                              style: AppTextStyles.bodyXS(AppColors.primaryRed),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tags
                      if (widget.product.tags.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          children: widget.product.tags.map((tag) {
                            final isGood = ['Organic', 'Vegan'].contains(tag);
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: isGood
                                    ? AppColors.success.withOpacity(0.15)
                                    : AppColors.error.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusPill),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.bodyXS(
                                    isGood ? AppColors.success : AppColors.error),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Description
                      if (widget.product.longDescription != null) ...[
                        Text(widget.product.longDescription!,
                            style: AppTextStyles.bodyM(AppColors.textMutedLight)),
                        const SizedBox(height: 24),
                      ],

                      // Variants
                      if (widget.product.variants.isNotEmpty) ...[
                        const SectionHeader(title: 'Choose Size'),
                        const SizedBox(height: 12),
                        ...widget.product.variants.map((v) {
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
                                    ? AppColors.primaryRed.withOpacity(0.1)
                                    : AppColors.surfaceLight,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSM),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primaryRed
                                      : AppColors.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _RadioDot(selected: selected),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(v.label,
                                          style: AppTextStyles.bodyM(
                                              AppColors.textLight))),
                                  Text(
                                    'Rs ${v.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.semibold(
                                        AppColors.primaryRed, size: 14),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],

                      // Addons
                      if (widget.product.addons.isNotEmpty) ...[
                        const SectionHeader(title: 'Add-ons'),
                        const SizedBox(height: 12),
                        ...widget.product.addons.map((a) {
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
                                    ? AppColors.primaryRed.withOpacity(0.1)
                                    : AppColors.surfaceLight,
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSM),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primaryRed
                                      : AppColors.borderLight,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _CheckDot(selected: selected),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(a.name,
                                          style: AppTextStyles.bodyM(
                                              AppColors.textLight))),
                                  Text(
                                    '+Rs ${a.price.toStringAsFixed(0)}',
                                    style: AppTextStyles.semibold(
                                        AppColors.primaryRed, size: 14),
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
                color: AppColors.scaffoldLight.withOpacity(0.95),
                border: const Border(
                    top: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Total',
                          style: AppTextStyles.bodyXS(AppColors.textMutedLight)),
                      Text(
                        'Rs ${(_currentPrice + _addonsTotal) * (qty == 0 ? 1 : qty)}',
                        style: AppTextStyles.bold(AppColors.primaryRed, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  if (qty > 0) ...[
                    _FloatingQtyControl(
                      qty: qty,
                      onDecrement: () =>
                          ref.read(cartProvider.notifier).remove(widget.product.id),
                      onIncrement: () =>
                          ref.read(cartProvider.notifier).add(widget.product.id),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (qty == 0) {
                          ref.read(cartProvider.notifier).add(widget.product.id);
                        } else {
                          context.go('/cart');
                        }
                      },
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryRed, AppColors.deepRed],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.35),
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
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.primaryRed : AppColors.textMutedLight,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.primaryRed : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.primaryRed : AppColors.textMutedLight,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: const Icon(Icons.remove, color: AppColors.textLight, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text('$qty',
                style: AppTextStyles.bold(AppColors.textLight, size: 16)),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.add, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}
