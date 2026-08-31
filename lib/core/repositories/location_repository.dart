// lib/core/repositories/location_repository.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/address/location_model.dart';

class LocationRepository {
  final ApiClient _client;

  LocationRepository(this._client);

  /// Fetch saved delivery addresses for logged in user
  Future<List<LocationModel>> getLocations() async {
    try {
      final response = await _client.get('/location/');
      final rawList = (response is Map && response['locations'] is List)
          ? response['locations'] as List
          : (response is List ? response : []);

      return rawList
          .map((l) => LocationModel.fromJson(l as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('Error fetching locations API: $e', name: 'LocationRepository');
      return [];
    }
  }

  /// Fetch locations for specific customer ID
  Future<List<LocationModel>> getLocationsByCustomer(String customerId) async {
    try {
      final response = await _client.get('/location/$customerId');
      final rawList = (response is Map && response['locations'] is List)
          ? response['locations'] as List
          : (response is List ? response : []);

      return rawList
          .map((l) => LocationModel.fromJson(l as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a new delivery address
  Future<LocationModel> addLocation({
    required String title,
    required String address,
    String? note,
    bool isDefault = false,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _client.post('/location/', body: {
      'title': title,
      'address': address,
      if (note != null) 'note': note,
      'isDefault': isDefault,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    });
    final rawData = (response is Map && response['location'] != null)
        ? response['location']
        : response;

    return LocationModel.fromJson(rawData as Map<String, dynamic>);
  }

  /// Update existing location or set default flag
  Future<LocationModel> updateLocation(
    String locationId, {
    String? title,
    String? address,
    String? note,
    bool? isDefault,
  }) async {
    final response = await _client.patch('/location/$locationId', body: {
      if (title != null) 'title': title,
      if (address != null) 'address': address,
      if (note != null) 'note': note,
      if (isDefault != null) 'isDefault': isDefault,
    });
    final rawData = (response is Map && response['location'] != null)
        ? response['location']
        : response;

    return LocationModel.fromJson(rawData as Map<String, dynamic>);
  }

  /// Delete saved location
  Future<dynamic> deleteLocation(String locationId) async {
    return await _client.delete('/location/$locationId');
  }
}

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return LocationRepository(client);
});

final savedLocationsProvider = FutureProvider<List<LocationModel>>((ref) async {
  return ref.read(locationRepositoryProvider).getLocations();
});
