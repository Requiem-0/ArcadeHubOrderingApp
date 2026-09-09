// lib/features/cart/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../catalogue/data/product_model.dart';

/// Represents a distinct line-item in the cart (product + specific variant + chosen add-ons)
class CartItem {
  final String id;
  final ProductModel product;
  final ProductVariant? variant;
  final Map<String, int> addons; // addonId -> quantity
  final int quantity;

  const CartItem({
    required this.id,
    required this.product,
    this.variant,
    this.addons = const {},
    required this.quantity,
  });

  /// Base price of the product or specific variant
  double get itemPrice => variant?.price ?? product.effectivePrice;

  /// Total price of all selected add-ons for a single unit
  double get addonsPrice {
    double sum = 0.0;
    addons.forEach((addonId, qty) {
      try {
        final a = product.addons.firstWhere((x) => x.id == addonId);
        sum += a.price * qty;
      } catch (_) {}
    });
    return sum;
  }

  /// Unit price (variant base price + add-ons)
  double get unitPrice => itemPrice + addonsPrice;

  /// Total price for this line item (unit price * quantity)
  double get totalPrice => unitPrice * quantity;

  /// Display name including variant if applicable (e.g. "Brownie (Chocolate brownie)")
  String get displayName {
    if (variant != null && variant!.label.isNotEmpty) {
      return '${product.name} (${variant!.label})';
    }
    return product.name;
  }

  /// Human-readable summary of add-ons
  String? get addonsDescription {
    if (addons.isEmpty) return null;
    final parts = <String>[];
    addons.forEach((addonId, qty) {
      try {
        final a = product.addons.firstWhere((x) => x.id == addonId);
        parts.add('${a.name}${qty > 1 ? ' x$qty' : ''}');
      } catch (_) {}
    });
    return parts.isEmpty ? null : parts.join(', ');
  }

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      id: id,
      product: product,
      variant: variant,
      addons: addons,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// Cart state notifier holding a map of lineItemId -> CartItem
class CartNotifier extends StateNotifier<Map<String, CartItem>> {
  CartNotifier() : super({});

  static String generateId({
    required String productId,
    String? variantId,
    Map<String, int>? addons,
  }) {
    final v = variantId ?? 'std';
    final sortedAddons = (addons?.entries.toList() ?? [])
      ..sort((a, b) => a.key.compareTo(b.key));
    final addonStr = sortedAddons.map((e) => '${e.key}:${e.value}').join(',');
    return '$productId::$v::$addonStr';
  }

  /// Add a customized product line item with its variant and add-ons
  void addItem({
    required ProductModel product,
    ProductVariant? variant,
    Map<String, int> addons = const {},
    int quantity = 1,
  }) {
    if (quantity <= 0) return;
    final lineId = generateId(
      productId: product.id,
      variantId: variant?.id,
      addons: addons,
    );

    if (state.containsKey(lineId)) {
      final existing = state[lineId]!;
      state = {
        ...state,
        lineId: existing.copyWith(quantity: existing.quantity + quantity),
      };
    } else {
      state = {
        ...state,
        lineId: CartItem(
          id: lineId,
          product: product,
          variant: variant,
          addons: Map.from(addons),
          quantity: quantity,
        ),
      };
    }
  }

  /// Quick-add support for catalogue grids
  void add(String productId, [ProductModel? fallbackProduct]) {
    // If an item with this product already exists in cart, increment the first one
    final matching = state.values.where((item) => item.product.id == productId).toList();
    if (matching.isNotEmpty) {
      increment(matching.first.id);
    } else if (fallbackProduct != null) {
      final defaultVariant = fallbackProduct.variants.isNotEmpty
          ? fallbackProduct.variants.first
          : null;
      addItem(
        product: fallbackProduct,
        variant: defaultVariant,
      );
    }
  }

  void increment(String lineItemId) {
    if (state.containsKey(lineItemId)) {
      final item = state[lineItemId]!;
      state = {
        ...state,
        lineItemId: item.copyWith(quantity: item.quantity + 1),
      };
    }
  }

  void decrement(String lineItemId) {
    if (state.containsKey(lineItemId)) {
      final item = state[lineItemId]!;
      if (item.quantity <= 1) {
        removeLineItem(lineItemId);
      } else {
        state = {
          ...state,
          lineItemId: item.copyWith(quantity: item.quantity - 1),
        };
      }
    }
  }

  void remove(String productId) {
    final matching = state.values.where((item) => item.product.id == productId).toList();
    if (matching.isNotEmpty) {
      decrement(matching.first.id);
    }
  }

  void removeLineItem(String lineItemId) {
    final updated = Map<String, CartItem>.from(state);
    updated.remove(lineItemId);
    state = updated;
  }

  void setQty(String lineItemId, int qty) {
    if (qty <= 0) {
      removeLineItem(lineItemId);
    } else if (state.containsKey(lineItemId)) {
      state = {
        ...state,
        lineItemId: state[lineItemId]!.copyWith(quantity: qty),
      };
    }
  }

  void clear() => state = {};

  int get totalItems => state.values.fold(0, (sum, item) => sum + item.quantity);

  /// Returns total quantity of all variants of a product in the cart
  int getProductQuantity(String productId) => state.values
      .where((item) => item.product.id == productId)
      .fold(0, (sum, item) => sum + item.quantity);
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, CartItem>>((ref) {
  return CartNotifier();
});

/// Derived: total item count (for badge)
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).values.fold(0, (sum, item) => sum + item.quantity);
});

/// Derived: Cart subtotal (sum of item totalPrice across all variants & addons)
final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.values.fold(0.0, (sum, item) => sum + item.totalPrice);
});

/// Derived: Cart VAT amount (taxable * VAT rate)
final cartVatProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final activeDiscount = AppConstants.isDiscountActiveNow();
  final discountAmount = activeDiscount
      ? (subtotal * ((AppConstants.discountPercentage ?? 10) / 100)).roundToDouble()
      : 0.0;
  final taxable = subtotal - discountAmount;
  return (taxable * AppConstants.vatRate).roundToDouble();
});

/// Derived: Cart grand total (subtotal - discount + VAT)
final cartGrandTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final activeDiscount = AppConstants.isDiscountActiveNow();
  final discountAmount = activeDiscount
      ? (subtotal * ((AppConstants.discountPercentage ?? 10) / 100)).roundToDouble()
      : 0.0;
  final vat = ref.watch(cartVatProvider);
  return (subtotal - discountAmount) + vat;
});
