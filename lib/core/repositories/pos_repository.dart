// lib/core/repositories/pos_repository.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../features/catalogue/data/sample_products.dart';

class PosRepository {
  final ApiClient _client;

  PosRepository(this._client);

  /// Fetch full catalog (with graceful fallback to local sample data if offline)
  Future<List<ProductModel>> getCatalog({String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products'
          : '/products';
      final response = await _client.get(endpoint);

      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      if (rawList.isEmpty) return kSampleProducts;

      return rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('API catalog fetch fallback to local sample data: $e', name: 'PosRepository');
      return kSampleProducts;
    }
  }

  /// Fetch product categories
  Future<List<CategoryModel>> getCategories({String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products/categories'
          : '/products/categories';
      final response = await _client.get(endpoint);

      final rawList = (response is Map && response['categories'] is List)
          ? response['categories'] as List
          : (response is List ? response : []);

      return rawList
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('Error fetching categories: $e', name: 'PosRepository');
      return [];
    }
  }

  /// Fetch products by category ID
  Future<List<ProductModel>> getProductsByCategory(String categoryId, {String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products/category/$categoryId'
          : '/products/category/$categoryId';
      final response = await _client.get(endpoint);

      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      return rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return kSampleProducts.where((p) => p.category == categoryId).toList();
    }
  }

  /// Fetch popular products
  Future<List<ProductModel>> getPopularProducts({String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products/popularity'
          : '/products/popularity';
      final response = await _client.get(endpoint);

      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      return rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return kSampleProducts.where((p) => p.tags.contains('Popular')).toList();
    }
  }

  /// Fetch single product details
  Future<ProductModel> getProductById(String id, {String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products/$id'
          : '/products/$id';
      final response = await _client.get(endpoint);
      final rawMap = (response is Map && response['product'] != null)
          ? response['product']
          : response;
      return ProductModel.fromJson(rawMap as Map<String, dynamic>);
    } catch (_) {
      return kSampleProducts.firstWhere(
        (p) => p.id == id,
        orElse: () => kSampleProducts.first,
      );
    }
  }

  /// Search products by keyword
  Future<List<ProductModel>> searchProducts(String keyword) async {
    try {
      final response = await _client.get('/products/search/$keyword');
      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      return rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      final query = keyword.toLowerCase();
      return kSampleProducts
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query))
          .toList();
    }
  }

  /// Send product inquiry email
  Future<dynamic> sendInquiryMail(Map<String, dynamic> payload) async {
    return await _client.post('/products/sendMail', body: payload);
  }

  /// Fetch customer recently ordered products
  Future<List<ProductModel>> getRecentPurchases({String? businessId}) async {
    try {
      final endpoint = businessId != null
          ? '/businesses/$businessId/products/recent-purchase'
          : '/products/recent-purchase';
      final response = await _client.get(endpoint);
      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      return rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Filter catalogue for a specific Experience Zone ID
  Future<List<ProductModel>> getProductsForZone(String zoneId, {String? businessId}) async {
    final catalog = await getCatalog(businessId: businessId);
    final key = zoneId.toLowerCase();

    return catalog.where((p) {
      final cat = p.category.toLowerCase();
      final name = p.name.toLowerCase();
      final tags = p.tags.map((t) => t.toLowerCase()).toList();

      if (key == 'sportsbar') {
        return cat.contains('bar') || cat.contains('drink') || cat.contains('beer') || tags.contains('sportsbar');
      } else if (key == 'rooftop') {
        return cat.contains('rooftop') || cat.contains('food') || cat.contains('main') || tags.contains('rooftop');
      } else if (key == 'playroom') {
        return cat.contains('snack') || cat.contains('gaming') || tags.contains('playroom');
      }
      return true;
    }).toList();
  }
}

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PosRepository(client);
});

final catalogProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(posRepositoryProvider).getCatalog();
});
