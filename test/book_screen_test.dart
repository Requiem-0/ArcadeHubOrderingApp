import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/features/services/book_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpBook(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/book',
      routes: [GoRoute(path: '/book', builder: (_, _) => const BookScreen())],
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    // The placeholder repository fakes a delay, first for the zones and then
    // for that zone's services, so the clock has to advance twice.
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
  }

  testWidgets('leads with the rules every booking runs by', (tester) async {
    await pumpBook(tester);

    expect(find.text('Book'), findsOneWidget);
    expect(
      find.text('10:00 AM - 10:00 PM · confirmed on WhatsApp'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the first zone and what it has to book', (tester) async {
    await pumpBook(tester);

    // Play Room is first, and the label counts what is in it.
    expect(find.textContaining('PLAY ROOM'), findsWidgets);
    expect(find.text('PS5 Console Rental'), findsOneWidget);
    expect(find.text('Pick a time'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching zone swaps the services', (tester) async {
    await pumpBook(tester);
    expect(find.text('PS5 Console Rental'), findsOneWidget);

    await tester.tap(find.text('Party Room'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('PS5 Console Rental'), findsNothing);
    expect(find.text('Private Room Booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a narrow phone', (tester) async {
    await pumpBook(tester, width: 300);

    expect(find.text('PS5 Console Rental'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('goes two across when there is room', (tester) async {
    await pumpBook(tester, width: 720);

    final cards = find.text('Pick a time');
    expect(cards, findsNWidgets(2));
    // Side by side, not stacked: the second card starts right of the first.
    // Their buttons sit at different heights because the cards say different
    // amounts, so only the horizontal split proves the layout.
    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    expect(second.left, greaterThan(first.right));
    expect(tester.takeException(), isNull);
  });
}
