// lib/core/repositories/cart_repository.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';

class CartRepository {
  final ApiClient _client;

  CartRepository(this._client);

  /// Fetch logged-in user active cart
  Future<Map<String, dynamic>> getMyCart() async {
    try {
      final response = await _client.get('/cart/my-cart');
      return response is Map<String, dynamic> ? response : {};
    } catch (e) {
      dev.log('Error fetching cart from server: $e', name: 'CartRepository');
      return {};
    }
  }

  /// Add item to cart
  Future<dynamic> addItem({
    required String productId,
    required int quantity,
    String? variantId,
    List<String>? addonIds,
  }) async {
    try {
      return await _client.post('/cart/', body: {
        'productId': productId,
        'quantity': quantity,
        if (variantId != null) 'variantId': variantId,
        if (addonIds != null) 'addonIds': addonIds,
      });
    } catch (e) {
      dev.log('Error adding item to cart API: $e', name: 'CartRepository');
      rethrow;
    }
  }

  /// Update quantity of item line
  Future<dynamic> updateQuantity({
    required String lineId,
    required int quantity,
  }) async {
    try {
      return await _client.put('/cart/', body: {
        'lineId': lineId,
        'quantity': quantity,
      });
    } catch (e) {
      dev.log('Error updating cart quantity API: $e', name: 'CartRepository');
      rethrow;
    }
  }

  /// Delete single item line by lineId
  Future<dynamic> deleteLine(String lineId) async {
    try {
      return await _client.delete('/cart/$lineId');
    } catch (e) {
      dev.log('Error deleting cart line API: $e', name: 'CartRepository');
      rethrow;
    }
  }

  /// Bulk remove multiple lines
  Future<dynamic> bulkDeleteLines(List<String> lineIds) async {
    try {
      return await _client.delete('/cart/', body: {'lineIds': lineIds});
    } catch (e) {
      dev.log('Error bulk deleting cart lines API: $e', name: 'CartRepository');
      rethrow;
    }
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return CartRepository(client);
});
