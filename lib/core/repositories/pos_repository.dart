// lib/core/repositories/pos_repository.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../constants.dart';
import '../../features/catalogue/data/product_model.dart';
import '../../features/catalogue/data/sample_products.dart';

class PosRepository {
  final ApiClient _client;

  PosRepository(this._client);

  /// Fetch the full catalog. Errors propagate rather than falling back to
  /// sample data, so screens hide or show a retry instead of fake products.
  Future<List<ProductModel>> getCatalog({String? businessId}) async {
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products';
      final response = await _client.get(endpoint);

      final rawList = (response is Map && response['products'] is List)
          ? response['products'] as List
          : (response is List ? response : []);

      final products = rawList
          .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
          .toList();

      // Products carry their category as an id; the names ("Drinks") live in
      // a separate list. Swap ids for names so menus can filter on them.
      final categories = await getCategories(businessId: targetBizId);
      final names = {for (final c in categories) c.id: c.name};
      return [
        for (final p in products)
          names.containsKey(p.category) ? p.withCategory(names[p.category]!) : p,
      ];
    } catch (e) {
      dev.log('API catalog fetch error: $e', name: 'PosRepository');
      rethrow;
    }
  }

  /// Fetch product categories
  Future<List<CategoryModel>> getCategories({String? businessId}) async {
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products/categories';
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
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products/category/$categoryId';
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
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products/popularity';
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
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products/$id';
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
    final targetBizId = businessId ?? AppConstants.activeBusinessId;
    try {
      final endpoint = '/businesses/$targetBizId/products/recent-purchase';
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

  /// Filter the catalogue for a zone page.
  ///
  /// The Sports Bar serves drinks and the Rooftop Restro serves everything
  /// else, split on the item's POS category: any category with "drink" in its
  /// name (Drinks, Soft Drinks, Hot Drinks...) goes to the bar. Bundles have
  /// their own home section and stay out of both.
  Future<List<ProductModel>> getProductsForZone(String zoneId, {String? businessId}) async {
    final catalog = await getCatalog(businessId: businessId);
    final menu = catalog.where((p) => !_isBundle(p)).toList();

    switch (zoneId.toLowerCase()) {
      case 'sportsbar':
        return menu.where(_isDrink).toList();
      case 'rooftop':
        return menu.where((p) => !_isDrink(p)).toList();
      default:
        return menu;
    }
  }

  static bool _isDrink(ProductModel p) =>
      p.category.toLowerCase().contains('drink');

  static bool _isBundle(ProductModel p) =>
      p.category.trim().toLowerCase().startsWith('bundle');
}

final posRepositoryProvider = Provider<PosRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return PosRepository(client);
});

final zoneProductsProvider = FutureProvider.family<List<ProductModel>, String>((ref, zoneId) async {
  return ref.read(posRepositoryProvider).getProductsForZone(zoneId);
});

final catalogProvider = FutureProvider<List<ProductModel>>((ref) async {
  return ref.read(posRepositoryProvider).getCatalog(businessId: AppConstants.activeBusinessId);
});

final bundleProductsProvider = Provider<AsyncValue<List<ProductModel>>>((ref) {
  final catalogAsync = ref.watch(catalogProvider);
  return catalogAsync.whenData((products) => products
      .where((p) =>
          p.category.trim().toLowerCase() == 'bundle' ||
          p.category.trim().toLowerCase() == 'bundles')
      .toList());
});
