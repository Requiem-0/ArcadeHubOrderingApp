// lib/core/repositories/order_repository.dart
import 'dart:developer' as dev;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../../features/orders/data/order_model.dart';
import '../../features/orders/data/sample_orders.dart';

class OrderRepository {
  final ApiClient _client;

  OrderRepository(this._client);

  /// Fetch all tickets/orders
  Future<List<OrderModel>> getTickets() async {
    try {
      final response = await _client.get('/ticket/');
      final rawList = (response is Map && response['tickets'] is List)
          ? response['tickets'] as List
          : (response is List ? response : []);

      if (rawList.isEmpty) return kSampleOrders;

      return rawList
          .map((t) => OrderModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      dev.log('Error fetching tickets API, returning sample orders: $e', name: 'OrderRepository');
      return kSampleOrders;
    }
  }

  /// Fetch simplified order history for current customer
  Future<List<OrderModel>> getMyOrders() async {
    try {
      final response = await _client.get('/ticket/my-orders');
      final rawList = (response is Map && response['orders'] is List)
          ? response['orders'] as List
          : (response is List ? response : []);

      if (rawList.isEmpty) return kSampleOrders;

      return rawList
          .map((o) => OrderModel.fromJson(o as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return kSampleOrders;
    }
  }

  /// Fetch full ticket details & metadata
  Future<OrderModel> getTicketById(String id) async {
    try {
      final response = await _client.get('/ticket/$id');
      final rawMap = (response is Map && response['ticket'] != null)
          ? response['ticket']
          : response;
      return OrderModel.fromJson(rawMap as Map<String, dynamic>);
    } catch (_) {
      return kSampleOrders.firstWhere(
        (o) => o.id == id,
        orElse: () => kSampleOrders.first,
      );
    }
  }

  /// Create checkout ticket / place order
  Future<OrderModel> createTicket({
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? spot,
    String? paymentMethod,
    String? note,
  }) async {
    final payload = {
      'items': items,
      'totalAmount': totalAmount,
      if (spot != null) 'spot': spot,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (note != null) 'note': note,
    };

    final response = await _client.post('/ticket/', body: payload);
    final rawData = (response is Map && response['ticket'] != null)
        ? response['ticket']
        : response;

    if (rawData is Map<String, dynamic>) {
      return OrderModel.fromJson(rawData);
    }

    return OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: 'Just Now',
      status: OrderStatus.pending,
      total: totalAmount,
      items: items
          .map((i) => OrderItem(
                name: i['name']?.toString() ?? 'Item',
                qty: (i['qty'] as num?)?.toInt() ?? 1,
              ))
          .toList(),
      spot: spot,
      paymentMethod: paymentMethod,
    );
  }

  /// Send dine-in table request (water, waiter, food status, bill)
  Future<dynamic> sendTableRequest({
    required String tableOrSpot,
    required String requestType, // 'water', 'waiter', 'food', 'bill'
    String? message,
  }) async {
    return await _client.post('/ticket/table-request', body: {
      'spot': tableOrSpot,
      'requestType': requestType,
      if (message != null) 'message': message,
    });
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return OrderRepository(client);
});

final myOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  return ref.read(orderRepositoryProvider).getMyOrders();
});
