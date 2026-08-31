// lib/core/repositories/business_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/catalogue/data/product_model.dart';

class BusinessRepository {
  final ApiClient _client;

  BusinessRepository(this._client);

  /// List all businesses with optional geo parameters
  Future<List<dynamic>> getBusinesses({
    double? latitude,
    double? longitude,
    double? distance,
  }) async {
    final query = <String, dynamic>{};
    if (latitude != null) query['latitude'] = latitude;
    if (longitude != null) query['longitude'] = longitude;
    if (distance != null) query['distance'] = distance;

    final response = await _client.get('/businesses', queryParams: query);
    if (response is List) return response;
    if (response is Map && response['businesses'] is List) {
      return response['businesses'] as List;
    }
    return [];
  }

  /// Fetch featured businesses
  Future<List<dynamic>> getFeaturedBusinesses() async {
    final response = await _client.get('/businesses/featured');
    if (response is List) return response;
    if (response is Map && response['businesses'] is List) {
      return response['businesses'] as List;
    }
    return [];
  }

  /// Fetch business details by ID
  Future<Map<String, dynamic>> getBusinessById(String id) async {
    final response = await _client.get('/businesses/$id');
    return response is Map<String, dynamic> ? response : {};
  }

  /// Fetch business details by owner ObjectId
  Future<Map<String, dynamic>> getBusinessByOwner(String ownerId) async {
    final response = await _client.get('/businesses/owner/$ownerId');
    return response is Map<String, dynamic> ? response : {};
  }

  /// Search businesses by location string
  Future<List<dynamic>> getBusinessByLocation(String location) async {
    final response = await _client.get('/businesses/location/$location');
    if (response is List) return response;
    return [];
  }

  /// Get tax configuration (VAT, service tax, inclusive/exclusive)
  Future<Map<String, dynamic>> getTaxConfig(String businessId) async {
    final response = await _client.get('/businesses/$businessId/tax/getall');
    return response is Map<String, dynamic> ? response : {};
  }

  /// Fetch business profile + embedded products
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    final response = await _client.get('/businesses/$businessId/products');
    final rawList = (response is Map && response['products'] is List)
        ? response['products'] as List
        : (response is List ? response : []);

    return rawList
        .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
        .toList();
  }
}

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return BusinessRepository(client);
});
