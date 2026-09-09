import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../shared/widgets/category_pill.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';
import '../../shared/widgets/app_network_image.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final catalogAsync = ref.watch(catalogProvider);
    final cart = ref.watch(cartProvider);
    final favs = ref.watch(favouritesProvider);
    final totalCartCount = ref.watch(cartCountProvider);

    return Scaffold(
      backgroundColor: colors.scaffold,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: colors.textPrimary),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Food & Drinks',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Menu',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.shopping_cart_outlined, color: colors.textPrimary, size: 26),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (totalCartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colors.primaryRed,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              '$totalCartCount',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: colors.textPrimary))),
                data: (products) {
                  final distinctCategories = products
                      .map((p) => p.category.trim())
                      .where((c) => c.isNotEmpty && c.toLowerCase() != 'all')
                      .toSet()
                      .toList()
                    ..sort();
                  final categories = ['All', ...distinctCategories];
                  final filtered = products.where((p) {
                    final matchSearch = _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase());
                    final matchCat = _category == 'All' || p.category.toLowerCase() == _category.toLowerCase();
                    return matchSearch && matchCat;
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Search Input
                      TextField(
                        controller: _searchCtrl,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search menu...',
                          hintStyle: TextStyle(color: colors.textMuted),
                          filled: true,
                          fillColor: colors.card,
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
                          prefixIcon: Icon(Icons.search, color: colors.textMuted),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: colors.textMuted),
                                  onPressed: () => _searchCtrl.clear(),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Category Pills
                      SizedBox(
                        height: 38,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) => CategoryPill(
                            label: categories[i],
                            active: _category == categories[i],
                            onTap: () => setState(() => _category = categories[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2-Column Grid Layout
                      if (filtered.isEmpty)
                        EmptyState(
                          iconData: Icons.search_off_rounded,
                          iconColor: const Color(0xFFFF7A00),
                          title: 'No items',
                          subtitle: 'Try a different search or category',
                          action: TextButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _category = 'All');
                            },
                            child: Text('Reset filters', style: TextStyle(color: colors.primaryRed)),
                          ),
                        )
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.84,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            final qty = ref.read(cartProvider.notifier).getProductQuantity(p.id);
                            final isFav = favs.contains(p.id);

                            return GestureDetector(
                              onTap: () => context.push('/product/${p.id}'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colors.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colors.border, width: 1.5),
                                  boxShadow: colors.cardShadow,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Top Row (Image container + Favorite icon)
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: Container(
                                            height: 115,
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              color: colors.primaryRed.withValues(alpha: 0.08),
                                            ),
                                            child: AppNetworkImage(
                                              url: p.imageUrl,
                                              height: 115,
                                              width: double.infinity,
                                              fallback: Text(p.emoji,
                                                  style: const TextStyle(fontSize: 48)),
                                            ),
                                          ),
                                        ),
                                        if (p.hasDiscount)
                                          Positioned(
                                            top: 6,
                                            left: 6,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: colors.primaryRed,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: colors.primaryRed
                                                        .withValues(alpha: 0.4),
                                                    blurRadius: 6,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                p.discountTag ?? 'OFFER',
                                                style: GoogleFonts.dmSans(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: GestureDetector(
                                            onTap: () => ref.read(favouritesProvider.notifier).toggle(p.id),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: colors.isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav ? AppColors.error : colors.textMuted,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                     if (p.category.isNotEmpty && p.category.toLowerCase() != 'all') ...[
                                       const SizedBox(height: 2),
                                       Text(
                                         p.category,
                                         maxLines: 1,
                                         overflow: TextOverflow.ellipsis,
                                         style: GoogleFonts.dmSans(
                                           fontSize: 11,
                                           color: colors.textMuted,
                                         ),
                                       ),
                                     ],
                                    const Spacer(),

                                    // Price & Cart Button Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        PriceText(price: p.effectivePrice, originalPrice: p.displayOriginalPrice),
                                        if (qty > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: colors.primaryRed,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () => ref.read(cartProvider.notifier).remove(p.id),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                    child: Text('−', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                  ),
                                                ),
                                                Text('$qty', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                                InkWell(
                                                  onTap: () => ref.read(cartProvider.notifier).add(p.id, p),
                                                  child: const Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 4),
                                                    child: Text('+', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          GestureDetector(
                                            onTap: () {
                                              if (p.variants.isNotEmpty) {
                                                context.push('/product/${p.id}');
                                              } else {
                                                ref.read(cartProvider.notifier).add(p.id, p);
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: colors.primaryRed,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
