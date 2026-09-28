import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_breakpoints.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';

void main() {
  /// Renders [probe] at a given window width and hands it the context, so the
  /// responsive getters can be read exactly as a screen would read them.
  Future<void> at(
    WidgetTester tester,
    double width,
    void Function(BuildContext context) probe, {
    bool shell = false,
  }) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final child = Builder(builder: (context) {
      probe(context);
      return const SizedBox.expand();
    });

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark,
      home: shell ? ResponsiveShell(child: child) : child,
    ));
    await tester.pump();
  }

  group('breakpoints', () {
    test('name what the width means for layout', () {
      expect(AppBreakpoints.of(360), ScreenSize.compact);
      expect(AppBreakpoints.of(599), ScreenSize.compact);
      expect(AppBreakpoints.of(600), ScreenSize.medium);
      expect(AppBreakpoints.of(999), ScreenSize.medium);
      expect(AppBreakpoints.of(1000), ScreenSize.expanded);
      expect(AppBreakpoints.of(1920), ScreenSize.expanded);
    });
  });

  group('grid columns', () {
    testWidgets('stay at two on a phone', (tester) async {
      late int columns;
      await at(tester, 360, (c) {
        columns = c.gridColumns(
            minCardWidth: 150, horizontalPadding: 56, spacing: 24);
      });
      expect(columns, 2);
    });

    testWidgets('gain a column when there is room', (tester) async {
      late int columns;
      await at(tester, 720, (c) {
        columns = c.gridColumns(
            minCardWidth: 150, horizontalPadding: 56, spacing: 24);
      });
      expect(columns, 3);
    });

    testWidgets('never drop below two, however narrow', (tester) async {
      late int columns;
      await at(tester, 240, (c) {
        columns = c.gridColumns(
            minCardWidth: 150, horizontalPadding: 56, spacing: 24);
      });
      expect(columns, 2);
    });

    testWidgets('stop at the cap rather than going thin', (tester) async {
      late int columns;
      await at(tester, 1600, (c) {
        columns = c.gridColumns(
            minCardWidth: 150, horizontalPadding: 56, spacing: 24, max: 4);
      });
      expect(columns, 4);
    });

    testWidgets('open the gutter as the window grows', (tester) async {
      late double phone;
      late double tablet;
      await at(tester, 360, (c) => phone = c.gutter);
      await at(tester, 700, (c) => tablet = c.gutter);
      expect(phone, lessThan(tablet));
    });
  });

  group('the app shell', () {
    testWidgets('caps the width on a desktop window', (tester) async {
      late double inner;
      await at(tester, 1400, (c) => inner = MediaQuery.sizeOf(c).width,
          shell: true);

      // Screens inside measure the capped width, not the browser window.
      expect(inner, AppBreakpoints.maxContentWidth);
    });

    testWidgets('leaves a phone alone', (tester) async {
      late double inner;
      await at(tester, 390, (c) => inner = MediaQuery.sizeOf(c).width,
          shell: true);

      expect(inner, 390);
    });

    testWidgets('centres the capped content', (tester) async {
      await at(tester, 1400, (_) {}, shell: true);

      final box = tester.getRect(find.byType(SizedBox).first);
      // The hairline border down each side insets the content by a pixel.
      expect(box.width, closeTo(AppBreakpoints.maxContentWidth, 2));
      expect(box.center.dx, closeTo(700, 1));
    });

    testWidgets('lays nothing out in a near-zero window', (tester) async {
      var built = false;
      await at(tester, 2, (_) => built = true, shell: true);

      expect(built, isFalse);
    });
  });
}
