import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/core/repositories/auth_repository.dart';
import 'package:arcadehuborderingapp/core/repositories/order_repository.dart';
import 'package:arcadehuborderingapp/features/orders/data/order_model.dart';
import 'package:arcadehuborderingapp/features/orders/recent_orders_screen.dart';

void main() {
  // Real orders come back with a 24-character Mongo id, which is what used to
  // push the date and the status pill off the card.
  OrderModel order({
    String id = '6a96d205ab1acaab3ebd329d',
    int? invoice,
    String itemName = 'Cyanide',
  }) =>
      OrderModel(
        id: id,
        invoice: invoice,
        date: 'Sep 1, 7:09 PM',
        status: OrderStatus.pending,
        total: 871,
        items: [OrderItem(name: itemName, qty: 1)],
      );

  Future<void> pumpOrders(
    WidgetTester tester,
    List<OrderModel> orders, {
    double width = 360,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/orders',
      routes: [
        GoRoute(path: '/orders', builder: (_, _) => const RecentOrdersScreen()),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        isLoggedInStateProvider.overrideWith((ref) async => true),
        myOrdersProvider.overrideWith((ref) async => orders),
      ],
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a long order id does not overflow the card', (tester) async {
    await pumpOrders(tester, [order()]);

    expect(tester.takeException(), isNull);
  });

  testWidgets('names the order by its tail, not the whole id',
      (tester) async {
    await pumpOrders(tester, [order()]);

    expect(find.text('#bd329d'), findsOneWidget);
    expect(find.text('6a96d205ab1acaab3ebd329d'), findsNothing);
  });

  testWidgets('prefers the POS invoice number when there is one',
      (tester) async {
    await pumpOrders(tester, [order(invoice: 1042)]);

    expect(find.text('#1042'), findsOneWidget);
  });

  testWidgets('keeps the reference and status readable beside it',
      (tester) async {
    await pumpOrders(tester, [order(invoice: 1042)]);

    // The date has a line of its own, so all three read in full even on a
    // small phone with the test font, which is wider than the real one.
    for (final label in ['#1042', 'pending', 'Sep 1, 7:09 PM']) {
      final paragraph =
          tester.renderObject<RenderParagraph>(find.text(label).first);
      expect(paragraph.didExceedMaxLines, isFalse,
          reason: '"$label" is cut off');
    }
  });

  testWidgets('a long item name trims instead of overflowing',
      (tester) async {
    await pumpOrders(
      tester,
      [order(itemName: 'Just gimme some moneyy and a very long name indeed')],
      width: 300,
    );

    expect(tester.takeException(), isNull);
  });
}
