import '../constants.dart';
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
  Future<List<OrderModel>> getTickets({String? businessId}) async {
    try {
      final response = await _client.get('/ticket/');
      final rawList = (response is Map && response['tickets'] is List)
          ? response['tickets'] as List
          : (response is Map && response['data'] is List)
              ? response['data'] as List
              : (response is List ? response : []);

      if (rawList.isEmpty) return [];

      final targetBizId = businessId ?? AppConstants.activeBusinessId;

      final allOrders = rawList
          .whereType<Map<String, dynamic>>()
          .map((t) => OrderModel.fromJson(t))
          .toList();

      final filteredOrders = allOrders.where((order) {
        if (order.businessId == null) return true;
        return order.businessId == targetBizId;
      }).toList();

      return filteredOrders;
    } catch (e) {
      dev.log('Error fetching tickets API: $e', name: 'OrderRepository');
      return [];
    }
  }

  /// Fetch simplified order history for current customer
  Future<List<OrderModel>> getMyOrders({String? businessId}) async {
    try {
      final response = await _client.get('/ticket/my-orders');
      final rawList = (response is Map && response['orders'] is List)
          ? response['orders'] as List
          : (response is Map && response['data'] is List)
              ? response['data'] as List
              : (response is List ? response : []);

      if (rawList.isEmpty) return [];

      final targetBizId = businessId ?? AppConstants.activeBusinessId;

      final allOrders = rawList
          .whereType<Map<String, dynamic>>()
          .map((o) => OrderModel.fromJson(o))
          .toList();

      // Filter by active business ID to prevent cross-tenant data leakage
      final filteredOrders = allOrders.where((order) {
        if (order.businessId == null) return true;
        return order.businessId == targetBizId;
      }).toList();

      return filteredOrders;
    } catch (e) {
      dev.log('Error fetching my-orders API: $e', name: 'OrderRepository');
      return [];
    }
  }

  /// Fetch full ticket details & metadata
  Future<OrderModel> getTicketById(String id) async {
    try {
      final response = await _client.get('/ticket/$id');
      final rawMap = (response is Map && response['ticket'] != null)
          ? response['ticket']
          : (response is Map && response['response'] != null)
              ? response['response']
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
    final targetBizId = AppConstants.activeBusinessId;
    final payload = <String, dynamic>{
      'businessId': targetBizId,
      'ticketName': spot != null ? 'Table $spot' : 'Online Order',
      'items': items,
      'total': totalAmount,
      'grandTotal': totalAmount,
      'discount': 0,
      'paymentMethod': paymentMethod ?? 'cash',
      'paidStatus': 'pending',
      if (spot case final s?) 'table': s,
      if (note case final n?) 'note': n,
    };

    try {
      final response = await _client.post('/ticket/', body: payload);
      final rawData = (response is Map && response['response'] != null)
          ? response['response']
          : (response is Map && response['ticket'] != null)
              ? response['ticket']
              : response;

      if (rawData is Map<String, dynamic>) {
        return OrderModel.fromJson(rawData);
      }
    } catch (e) {
      dev.log('Error creating ticket API: $e', name: 'OrderRepository');
    }

    return OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      date: 'Just Now',
      status: OrderStatus.pending,
      total: totalAmount,
      items: items
          .map((i) => OrderItem(
                name: i['productName']?.toString() ?? i['name']?.toString() ?? 'Item',
                qty: (i['quantity'] ?? i['qty'] as num?)?.toInt() ?? 1,
                price: (i['unitPrice'] ?? i['price'] as num?)?.toDouble(),
              ))
          .toList(),
      spot: spot,
      paymentMethod: paymentMethod,
      businessId: targetBizId,
    );
  }

  /// Send dine-in table request (water, waiter, food status, bill)
  Future<dynamic> sendTableRequest({
    required String tableOrSpot,
    required String requestType, // 'water', 'waiter', 'food', 'bill'
    String? message,
  }) async {
    return await _client.post('/ticket/table-request', body: <String, dynamic>{
      'businessId': AppConstants.activeBusinessId,
      'table': tableOrSpot,
      'spot': tableOrSpot,
      'requestType': requestType,
      if (message case final m?) 'message': m,
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
