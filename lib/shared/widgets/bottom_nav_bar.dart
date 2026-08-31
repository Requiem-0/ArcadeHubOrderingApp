// lib/shared/widgets/bottom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/brandkit/app_theme.dart';
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
    _TabItem(icon: Icons.home_rounded, label: 'Home'),
    _TabItem(icon: Icons.shopping_bag_outlined, label: 'Cart', activeIcon: Icons.shopping_bag_rounded, showBadge: true),
    _TabItem(icon: Icons.receipt_long_outlined, label: 'Orders', activeIcon: Icons.receipt_long_rounded),
    _TabItem(icon: Icons.person_outline_rounded, label: 'Profile', activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartCount = ref.watch(cartCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    );
  }
}

class _NavButton extends StatefulWidget {
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
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavButton old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctrl.forward(from: 0.9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.active ? AppColors.primaryRed : AppColors.textMutedLight;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.active
                ? AppColors.primaryRed.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.active
                        ? (widget.tab.activeIcon ?? widget.tab.icon)
                        : widget.tab.icon,
                    color: color,
                    size: 24,
                  ),
                  if (widget.badge > 0)
                    Positioned(
                      top: -6,
                      right: -10,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.badge}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                widget.tab.label,
                style: AppTextStyles.bodyXS(color).copyWith(
                  fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
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
