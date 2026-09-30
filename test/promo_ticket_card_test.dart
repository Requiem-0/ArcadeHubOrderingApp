import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/features/home/home_screen.dart';

void main() {
  // The card is a ticket: a fixed-width stub on the left leaves the right-hand
  // column narrow, so its labels have to give way rather than overflow.
  for (final width in [290.0, 320.0, 360.0, 412.0]) {
    testWidgets('fits at ${width.toInt()}px', (tester) async {
      tester.view.physicalSize = Size(width, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(ProviderScope(
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: Padding(
              // What the home screen gives it.
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const PromoTicketCard(
                title: 'App orders',
                subtitle: '10 AM-4 PM daily',
                discountValue: '10',
                discountType: '%',
                remainingTime: Duration(hours: 2, minutes: 5),
                countLabel: 'Ends in',
              ),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a long label does not push the countdown out', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: PromoTicketCard(
              title: 'App orders only, every day',
              subtitle: 'Ten in the morning until four in the afternoon',
              discountValue: '10',
              discountType: '%',
              remainingTime: Duration(hours: 11, minutes: 59),
              countLabel: 'Offer finishes in about',
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 300));

    // The countdown is the thing that has to stay readable.
    expect(find.text('11:59:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
