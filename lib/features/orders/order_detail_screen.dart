// lib/features/orders/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../core/repositories/order_repository.dart';
import 'data/order_model.dart';

class OrderDetailScreen extends ConsumerWidget {
  final String orderId;
  final OrderModel? initialOrder;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: FutureBuilder<OrderModel>(
          future: ref.read(orderRepositoryProvider).getTicketById(orderId),
          initialData: initialOrder,
          builder: (context, snapshot) {
            final order = snapshot.data ?? initialOrder;

            if (order == null && snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colors.primaryRed),
              );
            }

            if (order == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Order not found', style: TextStyle(color: colors.textPrimary)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              );
            }

            final statusColor = _statusColor(order.status);

            return Column(
              children: [
                // ── App Bar ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 24, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/orders');
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
                        style: IconButton.styleFrom(
                          backgroundColor: colors.card,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                            side: BorderSide(color: colors.border),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order Details',
                              style: AppTextStyles.headingM(colors.textPrimary),
                            ),
                            Text(
                              order.id,
                              style: AppTextStyles.bodyXS(colors.textMuted),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          order.statusLabel.toUpperCase(),
                          style: AppTextStyles.bodyXS(statusColor).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Body Scroll ─────────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                    children: [
                      // ── Status Stepper ───────────────────────────────
                      _buildStatusTracker(colors, order),
                      const SizedBox(height: 24),

                      // ── Location & Metadata Card ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(color: colors.border),
                          boxShadow: colors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.storefront_rounded, size: 20, color: colors.primaryRed),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.businessName ?? 'Arcade Hub',
                                      style: AppTextStyles.semibold(colors.textPrimary, size: 15),
                                    ),
                                  ],
                                ),
                                if (order.invoice != null)
                                  Text(
                                    'Invoice #${order.invoice}',
                                    style: AppTextStyles.bodyXS(colors.textMuted),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Divider(color: colors.border, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TABLE / SPOT', style: AppTextStyles.label(colors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.spot != null && order.spot!.isNotEmpty ? 'Table ${order.spot}' : 'Dine-In',
                                      style: AppTextStyles.semibold(colors.textPrimary, size: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ORDER DATE', style: AppTextStyles.label(colors.textMuted)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.date,
                                      style: AppTextStyles.bodyS(colors.textPrimary),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Itemized Order Receipt ────────────────────────
                      Text('ITEMIZED RECEIPT', style: AppTextStyles.label(colors.textMuted)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(color: colors.border),
                          boxShadow: colors.cardShadow,
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < order.items.length; i++) ...[
                              _buildReceiptItem(colors, order.items[i]),
                              if (i < order.items.length - 1)
                                Divider(color: colors.border, height: 16),
                            ],
                            const SizedBox(height: 16),
                            Divider(color: colors.border, thickness: 1.5),
                            const SizedBox(height: 14),

                            // Total summary rows
                            if (order.discount != null && order.discount! > 0) ...[
                              _buildSummaryRow(
                                colors,
                                'Discount',
                                '- ${AppConstants.currencySymbol} ${order.discount!.toStringAsFixed(0)}',
                                color: AppColors.success,
                              ),
                              const SizedBox(height: 8),
                            ],
                            _buildSummaryRow(
                              colors,
                              'Grand Total',
                              '${AppConstants.currencySymbol} ${order.total.toStringAsFixed(0)}',
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Payment Badge ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colors.cardElevated,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payment_rounded, color: colors.primaryRed, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Payment Method',
                              style: AppTextStyles.bodyM(colors.textMuted),
                            ),
                            const Spacer(),
                            Text(
                              (order.paymentMethod ?? 'Cash').toUpperCase(),
                              style: AppTextStyles.semibold(colors.textPrimary, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusTracker(AppThemeColors colors, OrderModel order) {
    final isCompleted = order.status == OrderStatus.completed;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isCancelled ? AppColors.error.withValues(alpha: 0.3) : colors.primaryRed.withValues(alpha: 0.3),
        ),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isCancelled
                ? 'Order Cancelled'
                : isCompleted
                    ? 'Order Completed'
                    : 'Order in Progress',
            style: AppTextStyles.headingS(colors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepIcon(
                colors: colors,
                icon: Icons.check_circle_rounded,
                label: 'Placed',
                active: true,
                completed: true,
              ),
              _buildStepLine(colors: colors, active: !isCancelled),
              _buildStepIcon(
                colors: colors,
                icon: Icons.soup_kitchen_rounded,
                label: 'Kitchen',
                active: !isCancelled,
                completed: isCompleted,
              ),
              _buildStepLine(colors: colors, active: isCompleted),
              _buildStepIcon(
                colors: colors,
                icon: isCancelled ? Icons.cancel_rounded : Icons.task_alt_rounded,
                label: isCancelled ? 'Cancelled' : 'Served',
                active: isCompleted || isCancelled,
                completed: isCompleted,
                isError: isCancelled,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon({
    required AppThemeColors colors,
    required IconData icon,
    required String label,
    required bool active,
    required bool completed,
    bool isError = false,
  }) {
    final color = isError
        ? AppColors.error
        : completed
            ? AppColors.success
            : active
                ? colors.primaryRed
                : colors.textMuted;

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodyXS(color).copyWith(
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required AppThemeColors colors, required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: active ? colors.primaryRed : colors.border,
      ),
    );
  }

  Widget _buildReceiptItem(AppThemeColors colors, OrderItem item) {
    final priceStr = item.price != null
        ? '${AppConstants.currencySymbol} ${(item.price! * item.qty).toStringAsFixed(0)}'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: colors.primaryRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Text(
            '${item.qty}x',
            style: AppTextStyles.semibold(colors.primaryRed, size: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.semibold(colors.textPrimary, size: 14),
              ),
              if (item.variant != null)
                Text(
                  item.variant!,
                  style: AppTextStyles.bodyXS(colors.textMuted),
                ),
            ],
          ),
        ),
        if (priceStr.isNotEmpty)
          Text(
            priceStr,
            style: AppTextStyles.semibold(colors.textPrimary, size: 14),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(AppThemeColors colors, String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.headingS(colors.textPrimary)
              : AppTextStyles.bodyM(colors.textMuted),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.bold(color ?? colors.primaryRed, size: 20)
              : AppTextStyles.semibold(color ?? colors.textPrimary, size: 14),
        ),
      ],
    );
  }
}
