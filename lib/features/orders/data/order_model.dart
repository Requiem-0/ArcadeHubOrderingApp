// lib/features/orders/data/order_model.dart

enum OrderStatus { completed, pending, cancelled }

class OrderItem {
  final String name;
  final int qty;
  final String? variant;
  final double? price;
  final String? imageUrl;
  final String? note;

  const OrderItem({
    required this.name,
    required this.qty,
    this.variant,
    this.price,
    this.imageUrl,
    this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Variant resolution: variantItems.name or variant string
    String? variantName;
    if (json['variantItems'] is Map<String, dynamic>) {
      variantName = json['variantItems']['name']?.toString();
    } else if (json['variant'] != null) {
      variantName = json['variant']?.toString();
    }

    return OrderItem(
      name: json['productName']?.toString() ??
          json['name']?.toString() ??
          (json['product'] is Map ? json['product']['name']?.toString() : null) ??
          'Item',
      qty: (json['quantity'] ?? json['qty'] as num?)?.toInt() ?? 1,
      variant: variantName,
      price: (json['unitPrice'] ?? json['preTaxPrice'] ?? json['price'] as num?)?.toDouble(),
      imageUrl: json['productImage']?.toString() ?? json['image']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'qty': qty,
        if (variant != null) 'variant': variant,
        if (price != null) 'price': price,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (note != null) 'note': note,
      };
}

class OrderModel {
  final String id;
  final int? invoice;
  final String date;
  final OrderStatus status;
  final double total;
  final double? discount;
  final List<OrderItem> items;
  final String? spot;
  final String? paymentMethod;
  final String? businessId;
  final String? businessName;
  final String? businessAddress;

  const OrderModel({
    required this.id,
    this.invoice,
    required this.date,
    required this.status,
    required this.total,
    this.discount,
    required this.items,
    this.spot,
    this.paymentMethod,
    this.businessId,
    this.businessName,
    this.businessAddress,
  });

  String get statusLabel => status.name;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // If wrapped in {"response": {"Ticket": ...}} or {"ticket": ...}
    Map<String, dynamic> root = json;
    if (json['response'] is Map<String, dynamic>) {
      root = json['response'] as Map<String, dynamic>;
    }

    // Ticket sub-map if present
    Map<String, dynamic> ticketData = root;
    if (root['Ticket'] is Map<String, dynamic>) {
      ticketData = root['Ticket'] as Map<String, dynamic>;
    } else if (root['ticket'] is Map<String, dynamic>) {
      ticketData = root['ticket'] as Map<String, dynamic>;
    }

    // Status parsing
    final rawStatus = (ticketData['status'] ??
            ticketData['paidStatus'] ??
            root['status'] ??
            root['paidStatus'])
        ?.toString()
        .toLowerCase() ??
        '';
    OrderStatus parsedStatus = OrderStatus.pending;
    if (rawStatus.contains('complete') ||
        rawStatus.contains('delivered') ||
        rawStatus.contains('paid')) {
      parsedStatus = OrderStatus.completed;
    } else if (rawStatus.contains('cancel') || rawStatus.contains('reject')) {
      parsedStatus = OrderStatus.cancelled;
    }

    // Items extraction (search in root and ticketData)
    final parsedItems = _parseItems(root, ticketData);

    // ID parsing with full fallback chain (handles _id, orderId, id)
    final parsedId = ticketData['_id']?.toString() ??
        ticketData['orderId']?.toString() ??
        ticketData['id']?.toString() ??
        root['_id']?.toString() ??
        root['orderId']?.toString() ??
        root['id']?.toString() ??
        'ORD-000';

    // Date parsing with clean readable formatting
    final rawDate = ticketData['createdAt']?.toString() ??
        ticketData['date']?.toString() ??
        root['createdAt']?.toString() ??
        root['date']?.toString();
    final parsedDate = _formatDate(rawDate);

    // Total parsing (grandTotal authoritative, fallback to total / totalAmount)
    final parsedTotal = (ticketData['grandTotal'] ??
            ticketData['total'] ??
            ticketData['totalAmount'] ??
            root['grandTotal'] ??
            root['total'] ??
            root['totalAmount'] as num?)
        ?.toDouble() ??
        0.0;

    return OrderModel(
      id: parsedId,
      invoice: (ticketData['invoice'] ?? root['invoice'] as num?)?.toInt(),
      date: parsedDate,
      status: parsedStatus,
      total: parsedTotal,
      discount: (ticketData['discount'] ?? root['discount'] as num?)?.toDouble(),
      items: parsedItems,
      spot: ticketData['table']?.toString() ??
          ticketData['spot']?.toString() ??
          root['table']?.toString() ??
          root['spot']?.toString(),
      paymentMethod:
          ticketData['paymentMethod']?.toString() ?? root['paymentMethod']?.toString(),
      businessId: _extractBusinessId(ticketData, root),
      businessName:
          ticketData['businessName']?.toString() ?? root['businessName']?.toString(),
      businessAddress:
          ticketData['businessAddress']?.toString() ?? root['businessAddress']?.toString(),
    );
  }

  static String? _extractBusinessId(
      Map<String, dynamic> ticketData, Map<String, dynamic> root) {
    for (final key in ['businessId', 'business', 'storeId', 'adminId']) {
      final val = ticketData[key] ?? root[key];
      if (val is String && val.isNotEmpty) return val;
      if (val is Map) {
        final nestedId = val['_id']?.toString() ?? val['id']?.toString();
        if (nestedId != null && nestedId.isNotEmpty) return nestedId;
      }
    }
    return null;
  }

  static List<OrderItem> _parseItems(
      Map<String, dynamic> root, Map<String, dynamic> ticketData) {
    // 1. Check ticketProducts (POST /api/ticket response)
    final rawTicketProducts =
        root['ticketProducts'] ?? ticketData['ticketProducts'];
    if (rawTicketProducts is Map<String, dynamic> &&
        rawTicketProducts['item'] is List) {
      return (rawTicketProducts['item'] as List)
          .whereType<Map<String, dynamic>>()
          .map((i) => OrderItem.fromJson(i))
          .toList();
    }

    // 2. Check items or products field
    final rawItems = root['items'] ??
        ticketData['items'] ??
        root['products'] ??
        ticketData['products'];

    if (rawItems is List) {
      final List<OrderItem> result = [];
      for (final element in rawItems) {
        if (element is Map<String, dynamic>) {
          // Nested item array: items[].item[] (my-orders response)
          if (element['item'] is List) {
            for (final subItem in element['item'] as List) {
              if (subItem is Map<String, dynamic>) {
                result.add(OrderItem.fromJson(subItem));
              }
            }
          } else {
            // Direct item
            result.add(OrderItem.fromJson(element));
          }
        }
      }
      return result;
    } else if (rawItems is Map<String, dynamic>) {
      // Single items object: items.item[] (GET /api/ticket/{order_id} response)
      final subList =
          rawItems['item'] ?? rawItems['items'] ?? rawItems['products'];
      if (subList is List) {
        return subList
            .whereType<Map<String, dynamic>>()
            .map((i) => OrderItem.fromJson(i))
            .toList();
      }
    }

    return [];
  }

  static String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Today';

    final dt = DateTime.tryParse(rawDate);
    if (dt == null) return rawDate;

    final local = dt.toLocal();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[local.month - 1];
    final hour = local.hour > 12
        ? local.hour - 12
        : (local.hour == 0 ? 12 : local.hour);
    final period = local.hour >= 12 ? 'PM' : 'AM';
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month ${local.day}, $hour:$minute $period';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (invoice != null) 'invoice': invoice,
        'date': date,
        'status': status.name,
        'total': total,
        if (discount != null) 'discount': discount,
        'items': items.map((i) => i.toJson()).toList(),
        if (spot != null) 'spot': spot,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
        if (businessId != null) 'businessId': businessId,
        if (businessName != null) 'businessName': businessName,
        if (businessAddress != null) 'businessAddress': businessAddress,
      };
}
