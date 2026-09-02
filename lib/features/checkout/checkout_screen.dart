// lib/features/checkout/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/catalogue/data/sample_products.dart';
import '../../core/repositories/order_repository.dart';
import '../../core/utils/app_toast.dart';
import '../../shared/widgets/primary_button.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  bool _loading = false;
  final _spotCtrl = TextEditingController();
  String _paymentMethod = 'Cash / Card at Table';

  final List<String> _paymentMethods = [
    'Cash / Card at Table',
    'eSewa / Khalti Digital QR',
    'Fonepay QR',
  ];

  @override
  void dispose() {
    _spotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final cart = ref.watch(cartProvider);
    final activeDiscount = AppConstants.isDiscountActiveNow();

    final entries = cart.entries
        .map((e) => (
              product: kSampleProducts.firstWhere((p) => p.id == e.key,
                  orElse: () => kSampleProducts.first),
              qty: e.value
            ))
        .toList();

    final subtotal =
        entries.fold<double>(0, (sum, e) => sum + e.product.price * e.qty);
    final discountAmount = activeDiscount
        ? (subtotal * ((AppConstants.discountPercentage ?? 10) / 100)).roundToDouble()
        : 0.0;
    final taxable = subtotal - discountAmount;
    final tax = (taxable * AppConstants.vatRate).roundToDouble();
    final total = taxable + tax;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 20, 16),
              decoration: BoxDecoration(
                color: colors.scaffold,
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/cart');
                      }
                    },
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Checkout Order',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Spot / Location Selection
                  Text(
                    'ORDERING LOCATION / SPOT IN VENUE',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _spotCtrl,
                    style: TextStyle(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Counter Pickup, Rooftop Table 3...',
                      hintStyle: TextStyle(color: colors.textMuted),
                      filled: true,
                      fillColor: colors.card,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colors.primaryRed),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Payment Method
                  Text(
                    'PAYMENT METHOD',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: _paymentMethods.map((pm) {
                      final isSelected = _paymentMethod == pm;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => setState(() => _paymentMethod = pm),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colors.primaryRed.withValues(alpha: 0.1)
                                  : colors.card,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? colors.primaryRed
                                    : colors.border,
                              ),
                              boxShadow: colors.cardShadow,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? colors.primaryRed
                                      : colors.textMuted,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    pm,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Receipt card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.border),
                      boxShadow: colors.cardShadow,
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppConstants.appName,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colors.primaryRed,
                          ),
                        ),
                        Text(
                          'Order Summary',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: colors.textMuted,
                          ),
                        ),
                        Divider(color: colors.border, height: 20),

                        ...entries.map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${e.product.name} × ${e.qty}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'NPR ${(e.product.price * e.qty).toInt()}',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            )),

                        Divider(color: colors.border, height: 20),

                        _ReceiptRow('Subtotal', 'NPR ${subtotal.toInt()}'),
                        if (discountAmount > 0)
                          _ReceiptRow('10% App Discount', '-NPR ${discountAmount.toInt()}', color: AppColors.success),
                        _ReceiptRow('Govt VAT (13%)', 'NPR ${tax.toInt()}'),

                        Divider(color: colors.border, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Payable',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            Text(
                              'NPR ${total.toInt()}',
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: colors.primaryRed,
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
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: colors.scaffold,
          border: Border(top: BorderSide(color: colors.border)),
        ),
        child: SafeArea(
          top: false,
          child: PrimaryButton(
            label: 'Place Order',
            loading: _loading,
            onPressed: () async {
              if (cart.isEmpty) return;
              setState(() => _loading = true);
              try {
                final orderItemsPayload = entries
                    .map((e) => {
                          'productId': e.product.id,
                          'name': e.product.name,
                          'price': e.product.price,
                          'qty': e.qty,
                        })
                    .toList();

                await ref.read(orderRepositoryProvider).createTicket(
                      items: orderItemsPayload,
                      totalAmount: total,
                      spot: _spotCtrl.text.isNotEmpty
                          ? _spotCtrl.text
                          : 'Counter Pickup',
                      paymentMethod: _paymentMethod,
                    );

                if (!mounted) return;
                ref.read(cartProvider.notifier).clear();
                context.go('/order-success');
              } catch (_) {
                if (!mounted) return;
                AppToast.showError(context, 'Unable to place order. Please check your connection.');
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _ReceiptRow(this.label, this.value, {this.color});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.dmSans(fontSize: 13, color: colors.textMuted)),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
