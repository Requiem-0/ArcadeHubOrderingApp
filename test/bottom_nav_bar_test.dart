import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/core/brandkit/app_theme.dart';
import 'package:arcadehuborderingapp/shared/widgets/bottom_nav_bar.dart';

void main() {
  // Five tabs plus the active label is tight on small phones; the bar has to
  // fit without overflowing, whichever tab is active.
  for (final width in [290.0, 320.0, 360.0]) {
    for (var tab = 0; tab < 5; tab++) {
      testWidgets('fits at ${width.toInt()}px with tab $tab active',
          (tester) async {
        tester.view.physicalSize = Size(width, 700);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(ProviderScope(
          child: MaterialApp(
            theme: AppTheme.dark,
            home: Scaffold(
              bottomNavigationBar:
                  AppBottomNavBar(currentIndex: tab, onTap: (_) {}),
            ),
          ),
        ));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
