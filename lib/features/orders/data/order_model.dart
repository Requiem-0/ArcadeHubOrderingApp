// lib/features/orders/data/order_model.dart

enum OrderStatus { completed, pending, cancelled }

class OrderItem {
  final String name;
  final int qty;
  final String? variant;
  final double? price;

  const OrderItem({
    required this.name,
    required this.qty,
    this.variant,
    this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name']?.toString() ?? json['productName']?.toString() ?? 'Item',
      qty: (json['qty'] ?? json['quantity'] as num?)?.toInt() ?? 1,
      variant: json['variant']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        'variant': variant,
        'price': price,
      };
}

class OrderModel {
  final String id;
  final String date;
  final OrderStatus status;
  final double total;
  final List<OrderItem> items;
  final String? spot;
  final String? paymentMethod;

  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.items,
    this.spot,
    this.paymentMethod,
  });

  String get statusLabel => status.name;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString().toLowerCase() ?? '';
    OrderStatus parsedStatus = OrderStatus.pending;
    if (rawStatus.contains('complete') || rawStatus.contains('delivered') || rawStatus.contains('paid')) {
      parsedStatus = OrderStatus.completed;
    } else if (rawStatus.contains('cancel') || rawStatus.contains('reject')) {
      parsedStatus = OrderStatus.cancelled;
    }

    final rawItems = json['items'] ?? json['products'];
    List<OrderItem> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'ORD-000',
      date: json['date']?.toString() ?? json['createdAt']?.toString() ?? 'Today',
      status: parsedStatus,
      total: (json['total'] ?? json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      items: parsedItems,
      spot: json['spot']?.toString() ?? json['table']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'status': status.name,
        'total': total,
        'items': items.map((i) => i.toJson()).toList(),
        'spot': spot,
        'paymentMethod': paymentMethod,
      };
}
