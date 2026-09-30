import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/features/services/book_screen.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpBook(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final router = GoRouter(
      initialLocation: '/book',
      routes: [GoRoute(path: '/book', builder: (_, _) => const BookScreen())],
    );
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(theme: AppTheme.dark, routerConfig: router),
    ));
    // The placeholder repository fakes a delay per zone.
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

  testWidgets('opens on every zone, nothing to pick first', (tester) async {
    await pumpBook(tester);

    // Each zone name reads twice now: once as a tab, once as a heading.
    expect(find.text('Play Room'), findsNWidgets(2));
    expect(find.text('Area 51'), findsNWidgets(2));
    expect(find.text('Party Room'), findsNWidgets(2));
    expect(find.text('PS5 Console Rental'), findsOneWidget);
    expect(find.text('Private Room Booking'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('the zone tabs', () {
    testWidgets('narrow the list to one zone', (tester) async {
      await pumpBook(tester);

      await tester.tap(find.byKey(const Key('zone-tab-partyroom')));
      await tester.pump(const Duration(milliseconds: 300));

      // Party Room's own service, and nobody else's.
      expect(find.text('Private Room Booking'), findsOneWidget);
      expect(find.text('PS5 Console Rental'), findsNothing);
      expect(find.text('VIP PS5 Station'), findsNothing);
      // Its heading is gone from the list, so the name is only the tab now.
      expect(find.text('Area 51'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('go back to everything', (tester) async {
      await pumpBook(tester);

      await tester.tap(find.byKey(const Key('zone-tab-partyroom')));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('zone-tab-all')));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('PS5 Console Rental'), findsOneWidget);
      expect(find.text('Private Room Booking'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('offer only zones with something to book', (tester) async {
      await pumpBook(tester);

      expect(find.byKey(const Key('zone-tab-all')), findsOneWidget);
      expect(find.byKey(const Key('zone-tab-playroom')), findsOneWidget);
      expect(find.byKey(const Key('zone-tab-sportsbar')), findsNothing);
      expect(find.byKey(const Key('zone-tab-rooftop')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('counts what each zone has', (tester) async {
    await pumpBook(tester);

    // Play Room has two; Area 51 and Party Room have one each.
    expect(find.text('2 options'), findsOneWidget);
    expect(find.text('1 option'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaves out a zone with nothing to book', (tester) async {
    await pumpBook(tester);

    // Walk-in only, so they are neither a tab nor a heading.
    expect(find.text('Sports Bar'), findsNothing);
    expect(find.text('Rooftop Restro'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits a narrow phone', (tester) async {
    await pumpBook(tester, width: 300);

    expect(find.text('PS5 Console Rental'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the cards compact and all one height', (tester) async {
    await pumpBook(tester);

    // These were 365, 266 and 260 tall before the card was reworked. Three
    // rows of fixed shape now, so they measure the same whatever they hold —
    // which is what lets two sit side by side without a ragged edge.
    final heights = [
      for (final id in ['srv-ps5', 'srv-vr', 'srv-party'])
        tester.getSize(find.byKey(Key('service-card-$id'))).height,
    ];

    for (final height in heights) {
      expect(height, lessThanOrEqualTo(170));
    }
    expect(heights.toSet(), hasLength(1), reason: 'cards differ in height');
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not trim the price, the name or the button',
      (tester) async {
    // 360 is a small phone; the test font is wider than the real one, so
    // anything that fits here fits on a device.
    for (final width in [360.0, 390.0]) {
      await pumpBook(tester, width: width);

      for (final label in ['PS5 Console Rental', 'NPR 2000', 'Book now']) {
        final paragraph = tester.renderObject<RenderParagraph>(
          find.text(label).first,
        );
        expect(paragraph.didExceedMaxLines, isFalse,
            reason: '"$label" is cut off at ${width.toInt()}px');
      }
    }
  });

  testWidgets('keeps the button flush with the card edge', (tester) async {
    await pumpBook(tester);

    final card = tester.getRect(find.byKey(const Key('service-card-srv-ps5')));
    final button =
        tester.getRect(find.widgetWithText(FilledButton, 'Book now').first);

    // Sitting against the card's own padding, not floating mid-row.
    expect(card.right - button.right, lessThan(16));
    expect(tester.takeException(), isNull);
  });

  testWidgets('goes two across within a zone when there is room',
      (tester) async {
    await pumpBook(tester, width: 720);

    // Four across three zones: Play Room's two share a line, then Area 51's
    // and Party Room's follow under their own headings.
    final cards = find.text('Book now');
    expect(cards, findsNWidgets(4));
    final first = tester.getRect(cards.at(0));
    final second = tester.getRect(cards.at(1));
    expect(second.left, greaterThan(first.right));
    expect(tester.takeException(), isNull);
  });
}
