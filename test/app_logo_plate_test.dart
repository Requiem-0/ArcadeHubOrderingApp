import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/shared/widgets/app_logo.dart';

void main() {
  // A plate with animation off never touches its controllers while it lives.
  // They must still exist by the time dispose() runs, or disposing builds a
  // ticker on a torn-down widget and the app crashes on the way back from a
  // pushed route.
  testWidgets('disposes cleanly when it never animated', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Center(child: AppLogoPlate(size: 40, glow: false)),
    ));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });

  testWidgets('disposes cleanly while animating', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Center(child: AppLogoPlate(size: 40, animate: true)),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    expect(tester.takeException(), isNull);
  });
}
