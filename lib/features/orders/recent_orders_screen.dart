// lib/features/orders/recent_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/constants.dart';
import '../../core/repositories/order_repository.dart';
import '../../features/orders/data/order_model.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/secondary_button.dart';

class RecentOrdersScreen extends ConsumerWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(myOrdersProvider);

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
                    onPressed: () => context.pop(),
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
                  Text('Recent Orders',
                      style: AppTextStyles.headingM(AppColors.textLight)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ordersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryRed),
                ),
                error: (err, stack) => Center(
                  child: Text('Error loading orders: $err',
                      style: AppTextStyles.bodyM(AppColors.error)),
                ),
                data: (orders) {
                  final totalSpent =
                      orders.fold<double>(0, (s, o) => s + o.total);

                  if (orders.isEmpty) {
                    return EmptyState(
                      icon: '📦',
                      title: 'No orders yet',
                      subtitle: 'Your order history will appear here.',
                      action: SecondaryButton(
                        label: 'Browse Menu',
                        onPressed: () => context.go('/home'),
                        fullWidth: false,
                      ),
                    );
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    children: [
                      // Summary card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryRed,
                              Color(0xFF660000),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusXXL),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryRed.withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THIS MONTH',
                              style: AppTextStyles.label(
                                  Colors.white.withOpacity(0.7)),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _StatItem(
                                  value: '${orders.length}',
                                  label: 'orders placed',
                                ),
                                const SizedBox(width: 32),
                                _StatItem(
                                  value:
                                      '${AppConstants.currencySymbol} ${totalSpent.toStringAsFixed(0)}',
                                  label: 'total spent',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      ...orders.map((order) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _OrderCard(order: order),
                          )),
                    ],
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.headingL(Colors.white)),
        Text(label, style: AppTextStyles.bodyS(Colors.white.withOpacity(0.7))),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.completed:
        return AppColors.success;
      case OrderStatus.pending:
        return AppColors.pending;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id,
                  style: AppTextStyles.bodyS(AppColors.textMutedLight)),
              const Spacer(),
              Text(order.date,
                  style: AppTextStyles.bodyS(AppColors.textMutedLight)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                ),
                child: Text(
                  order.statusLabel,
                  style: AppTextStyles.bodyXS(_statusColor).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...order.items.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Text('${item.name} × ${item.qty}',
                        style: AppTextStyles.bodyM(AppColors.textLight)),
                    if (item.variant != null) ...[
                      const SizedBox(width: 4),
                      Text('(${item.variant})',
                          style:
                              AppTextStyles.bodyXS(AppColors.textMutedLight)),
                    ],
                  ],
                ),
              )),
          if (order.items.length > 3)
            Text('+${order.items.length - 3} more',
                style: AppTextStyles.bodyXS(AppColors.textMutedLight)),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderLight, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppConstants.currencySymbol} ${order.total.toStringAsFixed(0)}',
                style: AppTextStyles.bold(AppColors.textLight, size: 18),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'Reorder',
                  style: AppTextStyles.semibold(AppColors.primaryRed, size: 14)
                      .copyWith(decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
