// lib/features/orders/data/sample_orders.dart
import 'order_model.dart';

const List<OrderModel> kSampleOrders = [
  OrderModel(
    id: 'AH-1041',
    date: 'Aug 20',
    status: OrderStatus.completed,
    total: 1030,
    items: [
      OrderItem(name: 'Arcade Hub Loaded Nachos', qty: 1, variant: 'Grilled Chicken Supreme', price: 820),
      OrderItem(name: 'Fewa Sunset Mocktail', qty: 1, price: 380),
    ],
  ),
  OrderModel(
    id: 'AH-1039',
    date: 'Aug 18',
    status: OrderStatus.pending,
    total: 890,
    items: [
      OrderItem(name: 'Cyberpunk Bacon Cheeseburger', qty: 1, variant: 'Single Patty Classic', price: 890),
    ],
  ),
  OrderModel(
    id: 'AH-1035',
    date: 'Aug 15',
    status: OrderStatus.completed,
    total: 1200,
    items: [
      OrderItem(name: 'Rooftop Woodfired Pizza', qty: 1, price: 950),
      OrderItem(name: 'Red Bull Energy Drink', qty: 1, price: 250),
    ],
  ),
];

