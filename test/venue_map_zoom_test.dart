import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/features/home/venue_map/venue_map.dart';

void main() {
  Future<void> pumpMap(WidgetTester tester, {double width = 390}) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: const Scaffold(
          body: SingleChildScrollView(child: VenueMapCard()),
        ),
      ),
    ));
    // The block rises once it is on screen; the zoom lands a frame later.
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  }

  /// The full-screen "Find us" sheet, which is where the map carries every
  /// place name, the street names, and both controls with their words on. The
  /// card is plainer: two names and the same two controls as bare icons.
  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showVenueMap(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump();
  }

  /// How many times wider the drawing is than the window it is seen through.
  /// The map is drawn close in rather than magnified afterwards, so this —
  /// not the viewer's scale — is how far in it opens.
  double closenessOf(WidgetTester tester) {
    final viewer = find.byType(InteractiveViewer);
    final drawing = find
        .descendant(of: viewer, matching: find.byType(SizedBox))
        .first;
    return tester.getSize(drawing).width / tester.getSize(viewer).width;
  }

  Matrix4 zoomOf(WidgetTester tester) =>
      tester.widget<InteractiveViewer>(find.byType(InteractiveViewer))
          .transformationController!
          .value;

  testWidgets('the home card keeps the two names people steer by',
      (tester) async {
    await pumpMap(tester);

    // Names are painted rather than built as widgets, so what can be asserted
    // here is the furniture: both controls are on the card, as icons with no
    // words beside them.
    expect(find.byIcon(Icons.rotate_right_rounded), findsOneWidget);
    expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
    // Icons only: the words belong to the sheet, which has the room.
    expect(find.text('Rotate'), findsNothing);
    expect(find.text('Recentre'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the card can be turned too', (tester) async {
    await pumpMap(tester);
    final before = zoomOf(tester).clone();

    await tester.tap(find.byIcon(Icons.rotate_right_rounded));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(zoomOf(tester), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the street map can be pinched', (tester) async {
    await pumpMap(tester);

    final viewer =
        tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
    expect(viewer.maxScale, greaterThan(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('it opens zoomed in, framed on the venue', (tester) async {
    await pumpMap(tester);

    // The tile covers far more ground than the card can show at once, so the
    // drawing is wider than its window and slid to put the venue in view.
    expect(closenessOf(tester), greaterThan(1.3));
    expect(zoomOf(tester).entry(0, 3), isNot(0));

    // Magnifying the finished map is what blew the pin up, so the viewer
    // itself must be sitting at its natural scale.
    expect(zoomOf(tester).entry(0, 0), closeTo(1, 0.001));
  });

  testWidgets('the card opens closer in than the sheet', (tester) async {
    // The card is a thumbnail a few centimetres wide: at the sheet's
    // distance the venue reads as one more grey roof among the rest.
    await pumpMap(tester);
    final card = closenessOf(tester);

    await pumpSheet(tester);
    final sheet = closenessOf(tester);

    expect(card, greaterThan(sheet));
  });

  testWidgets('the block can be turned', (tester) async {
    await pumpSheet(tester);
    final before = zoomOf(tester).clone();

    await tester.tap(find.text('Rotate'));
    // A quarter turn is animated, so let it land.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    // The turn is in the painter, not the viewer: the zoom matrix is
    // untouched while the block itself has swung round.
    expect(zoomOf(tester), before);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recentring puts it back where it started', (tester) async {
    await pumpSheet(tester);
    final start = zoomOf(tester).clone();

    await tester.drag(find.byType(InteractiveViewer), const Offset(-60, -40));
    await tester.pump(const Duration(milliseconds: 300));
    expect(zoomOf(tester), isNot(start));

    await tester.tap(find.text('Recentre'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(zoomOf(tester).entry(0, 3), closeTo(start.entry(0, 3), 0.01));
    expect(zoomOf(tester).entry(1, 3), closeTo(start.entry(1, 3), 0.01));
    expect(tester.takeException(), isNull);
  });
}
