// lib/shared/widgets/view_cart_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../features/cart/cart_provider.dart';

/// Sticky "View cart" strip for browsing screens. Renders nothing while the
/// cart is empty, so it never takes space it hasn't earned.
class ViewCartBar extends ConsumerWidget {
  /// Room to leave underneath, e.g. for the floating tab bar.
  final double bottomInset;

  const ViewCartBar({super.key, this.bottomInset = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final count = ref.watch(cartCountProvider);
    if (count == 0) return const SizedBox.shrink();
    final subtotal = ref.watch(cartSubtotalProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 12),
      child: Material(
        color: colors.primaryRed,
        borderRadius: BorderRadius.circular(18),
        elevation: 6,
        shadowColor: colors.primaryRed.withValues(alpha: 0.4),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            HapticFeedback.lightImpact();
            context.go('/cart');
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_rounded,
                    size: 18, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'View cart · $count ${count == 1 ? 'item' : 'items'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  AppConstants.formatPrice(subtotal),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
