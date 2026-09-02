// lib/shared/widgets/bottom_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../features/cart/cart_provider.dart';

class AppBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _TabItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag_rounded, label: 'Cart', showBadge: true),
    _TabItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Orders'),
    _TabItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final cartCount = ref.watch(cartCountProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: colors.isDark
                    ? colors.surface.withValues(alpha: 0.85)
                    : Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: colors.isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFD1D5DB),
                  width: 1.2,
                ),
                boxShadow: colors.isDark
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [
                        const BoxShadow(
                          color: Color(0x180F172A),
                          blurRadius: 28,
                          spreadRadius: -2,
                          offset: Offset(0, 10),
                        ),
                        const BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_tabs.length, (i) {
                    final tab = _tabs[i];
                    final active = currentIndex == i;
                    final badge = tab.showBadge && cartCount > 0 ? cartCount : 0;

                    return _NavButton(
                      tab: tab,
                      active: active,
                      badge: badge,
                      onTap: () => onTap(i),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final _TabItem tab;
  final bool active;
  final int badge;
  final VoidCallback onTap;

  const _NavButton({
    required this.tab,
    required this.active,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final activeColor = colors.primaryRed;
    final inactiveColor = colors.isDark ? colors.textMuted : const Color(0xFF475569);
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? (colors.isDark
                  ? colors.primaryRed.withValues(alpha: 0.18)
                  : colors.primaryRed.withValues(alpha: 0.10))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  active ? (tab.activeIcon ?? tab.icon) : tab.icon,
                  color: active ? activeColor : inactiveColor,
                  size: active ? 24 : 22,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colors.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                tab.label,
                style: TextStyle(
                  color: activeColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool showBadge;

  const _TabItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.showBadge = false,
  });
}
