// lib/features/orders/order_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
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
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: FutureBuilder<OrderModel>(
          future: ref.read(orderRepositoryProvider).getTicketById(orderId),
          initialData: initialOrder,
          builder: (context, snapshot) {
            final order = snapshot.data ?? initialOrder;

            if (order == null && snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryRed),
              );
            }

            if (order == null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Order not found', style: TextStyle(color: AppColors.textLight)),
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
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textLight),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
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
                              style: AppTextStyles.headingM(AppColors.textLight),
                            ),
                            Text(
                              order.id,
                              style: AppTextStyles.bodyXS(AppColors.textMutedLight),
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
                      _buildStatusTracker(order),
                      const SizedBox(height: 24),

                      // ── Location & Metadata Card ──────────────────────
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.storefront_rounded, size: 20, color: AppColors.primaryRed),
                                    const SizedBox(width: 8),
                                    Text(
                                      order.businessName ?? 'Arcade Hub',
                                      style: AppTextStyles.semibold(AppColors.textLight, size: 15),
                                    ),
                                  ],
                                ),
                                if (order.invoice != null)
                                  Text(
                                    'Invoice #${order.invoice}',
                                    style: AppTextStyles.bodyXS(AppColors.textMutedLight),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: AppColors.borderLight, height: 1),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('TABLE / SPOT', style: AppTextStyles.label(AppColors.textMutedLight)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.spot != null && order.spot!.isNotEmpty ? 'Table ${order.spot}' : 'Dine-In',
                                      style: AppTextStyles.semibold(AppColors.textLight, size: 14),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('ORDER DATE', style: AppTextStyles.label(AppColors.textMutedLight)),
                                    const SizedBox(height: 4),
                                    Text(
                                      order.date,
                                      style: AppTextStyles.bodyS(AppColors.textLight),
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
                      Text('ITEMIZED RECEIPT', style: AppTextStyles.label(AppColors.textMutedLight)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusL),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Column(
                          children: [
                            for (int i = 0; i < order.items.length; i++) ...[
                              _buildReceiptItem(order.items[i]),
                              if (i < order.items.length - 1)
                                const Divider(color: AppColors.borderLight, height: 16),
                            ],
                            const SizedBox(height: 16),
                            const Divider(color: AppColors.borderLight, thickness: 1.5),
                            const SizedBox(height: 14),

                            // Total summary rows
                            if (order.discount != null && order.discount! > 0) ...[
                              _buildSummaryRow(
                                'Discount',
                                '- ${AppConstants.currencySymbol} ${order.discount!.toStringAsFixed(0)}',
                                color: AppColors.success,
                              ),
                              const SizedBox(height: 8),
                            ],
                            _buildSummaryRow(
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
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.payment_rounded, color: AppColors.primaryRed, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Payment Method',
                              style: AppTextStyles.bodyM(AppColors.textMutedLight),
                            ),
                            const Spacer(),
                            Text(
                              (order.paymentMethod ?? 'Cash').toUpperCase(),
                              style: AppTextStyles.semibold(AppColors.textLight, size: 14),
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

  Widget _buildStatusTracker(OrderModel order) {
    final isCompleted = order.status == OrderStatus.completed;
    final isCancelled = order.status == OrderStatus.cancelled;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: isCancelled ? AppColors.error.withValues(alpha: 0.3) : AppColors.primaryRed.withValues(alpha: 0.3),
        ),
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
            style: AppTextStyles.headingS(AppColors.textLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStepIcon(
                icon: Icons.check_circle_rounded,
                label: 'Placed',
                active: true,
                completed: true,
              ),
              _buildStepLine(active: !isCancelled),
              _buildStepIcon(
                icon: Icons.soup_kitchen_rounded,
                label: 'Kitchen',
                active: !isCancelled,
                completed: isCompleted,
              ),
              _buildStepLine(active: isCompleted),
              _buildStepIcon(
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
                ? AppColors.primaryRed
                : AppColors.textMutedLight;

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

  Widget _buildStepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
        color: active ? AppColors.primaryRed : AppColors.borderLight,
      ),
    );
  }

  Widget _buildReceiptItem(OrderItem item) {
    final priceStr = item.price != null
        ? '${AppConstants.currencySymbol} ${(item.price! * item.qty).toStringAsFixed(0)}'
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primaryRed.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Text(
            '${item.qty}x',
            style: AppTextStyles.semibold(AppColors.primaryRed, size: 12),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: AppTextStyles.semibold(AppColors.textLight, size: 14),
              ),
              if (item.variant != null)
                Text(
                  item.variant!,
                  style: AppTextStyles.bodyXS(AppColors.textMutedLight),
                ),
            ],
          ),
        ),
        if (priceStr.isNotEmpty)
          Text(
            priceStr,
            style: AppTextStyles.semibold(AppColors.textLight, size: 14),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.headingS(AppColors.textLight)
              : AppTextStyles.bodyM(AppColors.textMutedLight),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.bold(color ?? AppColors.primaryRed, size: 20)
              : AppTextStyles.semibold(color ?? AppColors.textLight, size: 14),
        ),
      ],
    );
  }
}
