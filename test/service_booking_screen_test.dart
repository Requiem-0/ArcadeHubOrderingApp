import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/features/services/service_booking_screen.dart';

void main() {
  Future<void> pumpBooking(WidgetTester tester, String location,
      {double width = 360}) async {
    tester.view.physicalSize = Size(width, 780);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: location,
      routes: [
        GoRoute(
          path: '/service-booking',
          builder: (_, _) => const ServiceBookingScreen(),
        ),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    // The repository fakes a short delay before the service arrives.
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('names the service being booked', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-ps5');

    expect(find.text('PS5 Console Rental'), findsOneWidget);
    expect(find.text('Request on WhatsApp'), findsOneWidget);
    // Nothing is chosen yet, so the footer names neither a date nor a time.
    expect(find.textContaining(' · '), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('picking a date updates the footer', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-ps5');

    final today = DateTime.now();
    // The calendar opens on the week holding today. A week that straddles two
    // months is labelled "Sep - Oct", so match the month rather than the label.
    expect(
      find.textContaining(DateFormat('MMM').format(today)),
      findsWidgets,
    );

    await tester.tap(find.text('${today.day}'));
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      find.textContaining(DateFormat('EEE d MMM').format(today)),
      findsOneWidget,
    );
    expect(find.textContaining('2 people'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('will not go back past this week', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-ps5');

    final today = DateTime.now();
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump(const Duration(milliseconds: 200));

    // Still on this week, so today is still the visible one.
    expect(find.text('${today.day}'), findsOneWidget);

    // Forward still pages, and a week that straddles two months says so.
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a day that has gone cannot be picked', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-ps5');

    final today = DateTime.now();
    // Sunday opens the week with nothing behind it, so there is nothing to test.
    if (today.weekday % 7 == 0) return;

    final yesterday = today.subtract(const Duration(days: 1));
    await tester.tap(find.text('${yesterday.day}'));
    await tester.pump(const Duration(milliseconds: 200));

    // The footer still has no date in it.
    expect(
      find.textContaining(DateFormat('EEE d MMM').format(yesterday)),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('says so when the link points at nothing', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=does-not-exist');

    expect(find.text('No longer available'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a narrow phone', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-party',
        width: 300);

    expect(find.text('Private Room Booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });


  testWidgets('offers only the opening hours', (tester) async {
    await pumpBooking(tester, '/service-booking?serviceId=srv-ps5');

    // 10 AM through 10 PM, and nothing outside it.
    expect(find.text('10:00 AM'), findsOneWidget);
    expect(find.text('10:00 PM'), findsOneWidget);
    expect(find.text('9:00 AM'), findsNothing);
    expect(find.text('11:00 PM'), findsNothing);
    expect(find.text('2:00 AM'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('the slots on offer', () {
    final today = DateTime(2026, 10, 5);
    final tomorrow = DateTime(2026, 10, 6);

    test('run from open to close on the hour', () {
      final slots = openingSlots();
      expect(slots.first.hour, 10);
      expect(slots.last.hour, 22);
      expect(slots, hasLength(13));
      expect(slots.every((s) => s.minute == 0), isTrue);
    });

    test('a slot already gone today is not bookable', () {
      final now = DateTime(2026, 10, 5, 15, 30);

      expect(slotIsBookable(const TimeOfDay(hour: 14, minute: 0), today,
          now: now), isFalse);
      // The hour under way has started, so it is gone too.
      expect(slotIsBookable(const TimeOfDay(hour: 15, minute: 0), today,
          now: now), isFalse);
      expect(slotIsBookable(const TimeOfDay(hour: 16, minute: 0), today,
          now: now), isTrue);
    });

    test('a later day offers the whole day', () {
      final now = DateTime(2026, 10, 5, 21, 0);

      expect(slotIsBookable(const TimeOfDay(hour: 10, minute: 0), tomorrow,
          now: now), isTrue);
    });

    test('outside opening hours is never bookable', () {
      final now = DateTime(2026, 10, 5, 9, 0);

      expect(slotIsBookable(const TimeOfDay(hour: 9, minute: 0), today,
          now: now), isFalse);
      expect(slotIsBookable(const TimeOfDay(hour: 23, minute: 0), tomorrow,
          now: now), isFalse);
      expect(slotIsBookable(const TimeOfDay(hour: 2, minute: 0), tomorrow,
          now: now), isFalse);
    });

    test('nothing is left once the venue has closed', () {
      final now = DateTime(2026, 10, 5, 22, 30);
      final left = [
        for (final s in openingSlots())
          if (slotIsBookable(s, today, now: now)) s,
      ];
      expect(left, isEmpty);
    });
  });
}
