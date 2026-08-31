// lib/features/cart/cart_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cart state: Map<productId, quantity>
class CartNotifier extends StateNotifier<Map<String, int>> {
  CartNotifier() : super({});

  void add(String id) {
    state = {...state, id: (state[id] ?? 0) + 1};
  }

  void remove(String id) {
    final current = state[id] ?? 0;
    if (current <= 1) {
      final updated = Map<String, int>.from(state);
      updated.remove(id);
      state = updated;
    } else {
      state = {...state, id: current - 1};
    }
  }

  void setQty(String id, int qty) {
    if (qty <= 0) {
      final updated = Map<String, int>.from(state);
      updated.remove(id);
      state = updated;
    } else {
      state = {...state, id: qty};
    }
  }

  void clear() => state = {};

  int qty(String id) => state[id] ?? 0;

  int get totalItems => state.values.fold(0, (sum, q) => sum + q);
}

final cartProvider =
    StateNotifierProvider<CartNotifier, Map<String, int>>((ref) {
  return CartNotifier();
});

/// Derived: total item count (for badge)
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).values.fold(0, (sum, q) => sum + q);
});
