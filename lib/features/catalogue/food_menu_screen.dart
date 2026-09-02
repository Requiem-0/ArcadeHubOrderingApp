import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/repositories/pos_repository.dart';
import '../../features/cart/cart_provider.dart';
import '../../features/favourites/favourites_provider.dart';
import '../../shared/widgets/category_pill.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/price_text.dart';

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
    final catalogAsync = ref.watch(catalogProvider);
    final cart = ref.watch(cartProvider);
    final favs = ref.watch(favouritesProvider);
    final totalCartCount = cart.values.fold<int>(0, (sum, q) => sum + q);

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
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
                          'Food & Drinks Catalogue',
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textLight,
                          ),
                        ),
                        Text(
                          'Arcade Hub Menu',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textLight, size: 26),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (totalCartCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryRed,
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
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (products) {
                  final categories = ['All', ...products.map((p) => p.category).toSet().toList()];
                  final filtered = products.where((p) {
                    final matchSearch = _search.isEmpty || p.name.toLowerCase().contains(_search.toLowerCase());
                    final matchCat = _category == 'All' || p.category == _category;
                    return matchSearch && matchCat;
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Search Input
                      TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search delicious items...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.textMutedLight),
                          suffixIcon: _search.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
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
                          itemBuilder: (_, i) => CategoryPill(
                            label: categories[i],
                            active: _category == categories[i],
                            onTap: () => setState(() => _category = categories[i]),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 2-Column Grid Layout with Generous Spacing & White Space
                      if (filtered.isEmpty)
                        EmptyState(
                          iconData: Icons.search_off_rounded,
                          iconColor: const Color(0xFFFF7A00),
                          title: 'No items found',
                          subtitle: 'Try a different category or search query',
                          action: TextButton(
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _category = 'All');
                            },
                            child: const Text('Reset filters'),
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
                            final qty = cart[p.id] ?? 0;
                            final isFav = favs.contains(p.id);

                            return GestureDetector(
                              onTap: () => context.push('/product/${p.id}'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.borderLight, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
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
                                              color: AppColors.primaryRed.withValues(alpha: 0.12),
                                            ),
                                            child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                                ? Image.network(
                                                    p.imageUrl!,
                                                    height: 115,
                                                    width: double.infinity,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) => Center(
                                                      child: Text(p.emoji, style: const TextStyle(fontSize: 48)),
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(p.emoji, style: const TextStyle(fontSize: 48)),
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
                                                color: Colors.white.withValues(alpha: 0.9),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                isFav ? Icons.favorite : Icons.favorite_border,
                                                color: isFav ? AppColors.error : AppColors.textMutedLight,
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
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      p.category,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 11,
                                        color: AppColors.textMutedLight,
                                      ),
                                    ),
                                    const Spacer(),

                                    // Price & Cart Button Row
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        PriceText(price: p.price, originalPrice: p.originalPrice),
                                        if (qty > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryRed,
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
                                                  onTap: () => ref.read(cartProvider.notifier).add(p.id),
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
                                            onTap: () => ref.read(cartProvider.notifier).add(p.id),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                color: AppColors.primaryRedDark,
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
