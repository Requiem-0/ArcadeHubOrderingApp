import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_breakpoints.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/constants.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../shared/widgets/app_network_image.dart';
import '../../shared/widgets/category_pill.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/view_cart_bar.dart';
import 'data/product_model.dart';

class FoodMenuScreen extends ConsumerStatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  ConsumerState<FoodMenuScreen> createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends ConsumerState<FoodMenuScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _search = _searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchCtrl.clear();
    setState(() => _category = 'All');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final catalogAsync = ref.watch(catalogProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
      bottomNavigationBar: const ViewCartBar(
        bottomInset: AppConstants.bottomNavHeight,
      ),
      body: SafeArea(
        bottom: false,
        child: catalogAsync.when(
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.primaryRed),
          ),
          error: (_, _) => Center(
            child: EmptyState(
              iconData: Icons.wifi_off_rounded,
              iconColor: colors.primaryRed,
              title: 'Menu did not load',
              subtitle: 'Check your internet connection and try again.',
              action: TextButton(
                onPressed: () => ref.invalidate(catalogProvider),
                child: Text('Try again',
                    style: TextStyle(color: colors.primaryRed)),
              ),
            ),
          ),
          data: (products) {
            final names = {
              for (final p in products)
                if (p.category.trim().isNotEmpty &&
                    p.category.trim().toLowerCase() != 'all')
                  p.category.trim(),
            }.toList()
              ..sort();
            final categories = ['All', ...names];

            final query = _search.trim().toLowerCase();
            final filtered = products.where((p) {
              final matchSearch = query.isEmpty ||
                  p.name.toLowerCase().contains(query) ||
                  p.category.toLowerCase().contains(query);
              final matchCat = _category == 'All' ||
                  p.category.toLowerCase() == _category.toLowerCase();
              return matchSearch && matchCat;
            }).toList();

            return Column(
              children: [
                // Title and a live count of what is on screen
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      context.canPop() ? 10 : 28, 16, 28, 14),
                  child: Row(
                    children: [
                      if (context.canPop())
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded,
                              size: 18, color: colors.textPrimary),
                          onPressed: () => context.pop(),
                        ),
                      Expanded(
                        child: Text(
                          'Menu',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${filtered.length} ${filtered.length == 1 ? 'item' : 'items'}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Search stays put, so filtering never means scrolling back up
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
                  child: TextField(
                    controller: _searchCtrl,
                    textInputAction: TextInputAction.search,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: colors.textPrimary),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: 'Search the menu',
                      hintStyle: GoogleFonts.dmSans(
                          fontSize: 14, color: colors.textMuted),
                      filled: true,
                      fillColor: colors.card,
                      prefixIcon:
                          Icon(Icons.search_rounded, color: colors.textMuted),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 18, color: colors.textMuted),
                              onPressed: _searchCtrl.clear,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            BorderSide(color: colors.primaryRed, width: 1.4),
                      ),
                    ),
                  ),
                ),

                // Categories, only when the POS actually has some
                if (categories.length > 1)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      itemCount: categories.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) => CategoryPill(
                        label: categories[i],
                        active: _category == categories[i],
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _category = categories[i]);
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 22),

                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: EmptyState(
                            iconData: Icons.search_off_rounded,
                            iconColor: colors.primaryRed,
                            title: 'Nothing matches',
                            subtitle: 'Try another search or category.',
                            action: TextButton(
                              onPressed: _resetFilters,
                              child: Text('Clear filters',
                                  style: TextStyle(color: colors.primaryRed)),
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                              context.gutter + 8, 4, context.gutter + 8, 130),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            // Two cards on a phone, more once there is room,
                            // without letting any card get cramped.
                            crossAxisCount: context.gridColumns(
                              minCardWidth: 150,
                              horizontalPadding: (context.gutter + 8) * 2,
                              spacing: 24,
                              max: 4,
                            ),
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 30,
                            mainAxisExtent: 196,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) =>
                              _MenuCard(product: filtered[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MenuCard extends ConsumerWidget {
  final ProductModel product;

  const _MenuCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    final p = product;
    ref.watch(cartProvider); // rebuild when quantities change
    final qty = ref.read(cartProvider.notifier).getProductQuantity(p.id);
    final isFav = ref.watch(favouritesProvider).contains(p.id);
    final price = p.effectivePrice;

    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/product/${p.id}'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo
              Stack(
                children: [
                  SizedBox(
                    height: 96,
                    width: double.infinity,
                    child: AppNetworkImage(
                      url: p.imageUrl,
                      height: 96,
                      width: double.infinity,
                      fallback: Container(
                        color: colors.primaryRed.withValues(alpha: 0.08),
                        child: Center(
                          child: Text(p.emoji,
                              style: const TextStyle(fontSize: 40)),
                        ),
                      ),
                    ),
                  ),
                  if (p.hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: colors.primaryRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.discountTag ?? 'OFFER',
                          style: GoogleFonts.dmSans(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: colors.isDark
                          ? Colors.black.withValues(alpha: 0.55)
                          : Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(favouritesProvider.notifier).toggle(p.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? AppColors.error : colors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: 13.5,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: price > 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (p.displayOriginalPrice != null)
                                        Text(
                                          AppConstants.formatPrice(
                                              p.displayOriginalPrice!),
                                          style: GoogleFonts.dmSans(
                                            fontSize: 10.5,
                                            color: colors.textMuted,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      Text(
                                        AppConstants.formatPrice(price),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    'Ask at counter',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: colors.textMuted,
                                    ),
                                  ),
                          ),
                          if (qty > 0)
                            _QtyStepper(product: p, qty: qty)
                          else
                            Material(
                              color: colors.primaryRed,
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  if (p.variants.isNotEmpty) {
                                    context.push('/product/${p.id}');
                                  } else {
                                    ref
                                        .read(cartProvider.notifier)
                                        .add(p.id, p);
                                  }
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(Icons.add,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyStepper extends ConsumerWidget {
  final ProductModel product;
  final int qty;

  const _QtyStepper({required this.product, required this.qty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colors.primaryRed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onTap: () => ref.read(cartProvider.notifier).remove(product.id),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              '$qty',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            onTap: () =>
                ref.read(cartProvider.notifier).add(product.id, product),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
