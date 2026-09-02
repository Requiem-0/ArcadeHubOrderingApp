// lib/features/orders/recent_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../core/repositories/auth_repository.dart';
import '../../core/repositories/order_repository.dart';
import '../../features/orders/data/order_model.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/secondary_button.dart';

class RecentOrdersScreen extends ConsumerWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final loggedInAsync = ref.watch(isLoggedInStateProvider);
    final ordersAsync = ref.watch(myOrdersProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
              child: Row(
                children: [
                  Text(
                    'Recent Orders',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: loggedInAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.primaryRed),
                ),
                error: (err, _) => _buildGuestState(context, colors),
                data: (isLoggedIn) {
                  if (!isLoggedIn) {
                    return _buildGuestState(context, colors);
                  }

                  return ordersAsync.when(
                    loading: () => Center(
                      child: CircularProgressIndicator(color: colors.primaryRed),
                    ),
                    error: (err, _) => EmptyState(
                      iconData: Icons.wifi_off_rounded,
                      iconColor: AppColors.error,
                      title: 'Unable to Load Orders',
                      subtitle: 'Please check your internet connection and try again.',
                      action: SizedBox(
                        width: 160,
                        child: SecondaryButton(
                          label: 'Retry',
                          onPressed: () => ref.invalidate(myOrdersProvider),
                          fullWidth: false,
                        ),
                      ),
                    ),
                    data: (orders) {
                      if (orders.isEmpty) {
                        return EmptyState(
                          iconData: Icons.receipt_long_rounded,
                          iconColor: colors.primaryRed,
                          title: 'No Orders Yet',
                          subtitle: 'Your active kitchen orders and past receipts will appear here.',
                          action: SizedBox(
                            width: 180,
                            child: PrimaryButton(
                              label: 'Browse Menu',
                              onPressed: () => context.go('/home'),
                            ),
                          ),
                        );
                      }

                      final totalSpent =
                          orders.fold<double>(0, (s, o) => s + o.total);

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
                        children: [
                          // Summary card
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors.primaryRed,
                                  colors.deepRed,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primaryRed.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'THIS MONTH',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.5,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestState(BuildContext context, AppThemeColors colors) {
    return EmptyState(
      iconData: Icons.person_outline_rounded,
      iconColor: colors.primaryRed,
      title: 'Guest Account',
      subtitle: 'Sign in to track real-time kitchen progress, receipts, and order history.',
      action: SizedBox(
        width: 200,
        child: PrimaryButton(
          label: 'Sign In / Register',
          onPressed: () => context.push('/login'),
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
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
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
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/order/${order.id}', extra: order);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(order.id,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        )),
                    const Spacer(),
                    Text(order.date,
                        style: AppTextStyles.bodyS(colors.textMuted)),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        order.statusLabel,
                        style: AppTextStyles.bodyXS(_statusColor).copyWith(
                          fontWeight: FontWeight.w700,
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
                              style: AppTextStyles.bodyM(colors.textPrimary)),
                          if (item.variant != null) ...[
                            const SizedBox(width: 4),
                            Text('(${item.variant})',
                                style:
                                    AppTextStyles.bodyXS(colors.textMuted)),
                          ],
                        ],
                      ),
                    )),
                if (order.items.length > 3)
                  Text('+${order.items.length - 3} more',
                      style: AppTextStyles.bodyXS(colors.textMuted)),
                const SizedBox(height: 10),
                Divider(color: colors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppConstants.currencySymbol} ${order.total.toStringAsFixed(0)}',
                      style: AppTextStyles.bold(colors.textPrimary, size: 18),
                    ),
                    Row(
                      children: [
                        Text(
                          'View Receipt',
                          style: AppTextStyles.semibold(colors.textMuted, size: 13),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 12, color: colors.textMuted),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
