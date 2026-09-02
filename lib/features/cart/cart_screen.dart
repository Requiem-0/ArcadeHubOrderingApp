// lib/features/cart/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/sample_products.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/price_text.dart';

import '../../core/repositories/pos_repository.dart';
import '../../core/repositories/auth_repository.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _handleCheckout(BuildContext context, WidgetRef ref) async {
    final colors = context.appColors;
    final isLoggedIn = await ref.read(authRepositoryProvider).isLoggedIn();
    if (!isLoggedIn) {
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: colors.scaffold,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryRed.withValues(alpha: 0.15),
                  border: Border.all(
                    color: colors.primaryRed.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 28,
                  color: colors.primaryRed,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in to Checkout',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Please sign in or create an account to place orders and receive order updates.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(fontSize: 13, color: colors.textMuted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Sign In / Register',
                onPressed: () {
                  Navigator.pop(ctx);
                  context.push('/login');
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Continue Browsing as Guest', style: GoogleFonts.dmSans(color: colors.textMuted)),
              ),
            ],
          ),
        ),
      );
      return;
    }
    if (context.mounted) context.push('/checkout');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final cart = ref.watch(cartProvider);
    final catalog = ref.watch(catalogProvider).asData?.value ?? [];
    final activeDiscount = AppConstants.isDiscountActiveNow();

    final entries = cart.entries
        .map((e) => (
              product: catalog.firstWhere(
                (p) => p.id == e.key,
                orElse: () => kSampleProducts.firstWhere((p) => p.id == e.key, orElse: () => kSampleProducts.first),
              ),
              qty: e.value
            ))
        .toList();

    final subtotal = ref.watch(cartSubtotalProvider);
    final discountAmount = activeDiscount
        ? (subtotal * ((AppConstants.discountPercentage ?? 10) / 100)).roundToDouble()
        : 0.0;
    final tax = ref.watch(cartVatProvider);
    final total = ref.watch(cartGrandTotalProvider);
    final isEmpty = entries.isEmpty;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Order Cart',
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        isEmpty
                            ? '0 items in cart'
                            : '${cart.values.fold(0, (s, q) => s + q)} items selected',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: isEmpty
                  ? EmptyState(
                      iconData: Icons.shopping_bag_outlined,
                      iconColor: colors.primaryRed,
                      title: 'Your Cart is Empty',
                      subtitle: "Explore Arcade Hub dishes, drinks, and combos to start an order.",
                      action: SizedBox(
                        width: 180,
                        child: PrimaryButton(
                          label: 'Browse Menu',
                          onPressed: () => context.go('/food-menu'),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      children: [
                        // Discount Banner
                        if (activeDiscount)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  size: 20,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '10% App Special Discount Applied! (-NPR ${discountAmount.toInt()})',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Cart items
                        ...entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _CartItemCard(
                                product: e.product,
                                qty: e.qty,
                                onAdd: () => ref
                                    .read(cartProvider.notifier)
                                    .add(e.product.id),
                                onRemove: () => ref
                                    .read(cartProvider.notifier)
                                    .remove(e.product.id),
                                onDelete: () => ref
                                    .read(cartProvider.notifier)
                                    .setQty(e.product.id, 0),
                              ),
                            )),

                        // Price summary
                        const SizedBox(height: 20),
                        _PriceSummary(
                          subtotal: subtotal,
                          discount: discountAmount,
                          tax: tax,
                          total: total,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isEmpty
          ? null
          : _CheckoutBar(total: total, onTap: () => _handleCheckout(context, ref)),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final ProductModel product;
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const _CartItemCard({
    required this.product,
    required this.qty,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colors.primaryRed.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(product.emoji, style: const TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                PriceText(
                  price: product.price,
                  originalPrice: product.originalPrice,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.primaryRed,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onRemove,
                  child: const Text('−', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                GestureDetector(
                  onTap: onAdd,
                  child: const Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double tax;
  final double total;

  const _PriceSummary({
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          _Row('Subtotal', 'NPR ${subtotal.toInt()}'),
          if (discount > 0)
            _Row('10% App Discount', '-NPR ${discount.toInt()}', color: AppColors.success),
          _Row('Govt VAT (13%)', 'NPR ${tax.toInt()}'),
          Divider(color: colors.border, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Grand Total',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                'NPR ${total.toInt()}',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.primaryRed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Row(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: colors.textMuted)),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final VoidCallback onTap;

  const _CheckoutBar({required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: colors.scaffold,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: 'Proceed to Checkout — NPR ${total.toInt()}',
          onPressed: onTap,
        ),
      ),
    );
  }
}
