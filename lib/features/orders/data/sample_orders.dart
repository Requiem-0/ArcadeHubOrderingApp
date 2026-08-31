// lib/features/orders/data/sample_orders.dart
import 'order_model.dart';

const List<OrderModel> kSampleOrders = [
  OrderModel(
    id: 'AH-1041',
    date: 'Aug 20',
    status: OrderStatus.completed,
    total: 730,
    items: [
      OrderItem(name: 'Sourdough Loaf', qty: 1),
      OrderItem(name: 'Croissant', qty: 1, variant: 'Chocolate'),
    ],
  ),
  OrderModel(
    id: 'AH-1039',
    date: 'Aug 18',
    status: OrderStatus.pending,
    total: 450,
    items: [
      OrderItem(name: 'Baguette', qty: 1),
      OrderItem(name: 'Cinnamon Roll', qty: 2),
    ],
  ),
  OrderModel(
    id: 'AH-1035',
    date: 'Aug 15',
    status: OrderStatus.completed,
    total: 250,
    items: [
      OrderItem(name: 'Cheese Danish', qty: 1),
    ],
  ),
];
