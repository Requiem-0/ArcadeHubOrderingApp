import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/main.dart';

void main() {
  // A hidden browser tab can give the app a window 1-2 px across. The app
  // should sit it out rather than flood the console with overflow errors.
  testWidgets('lays nothing out in a near-zero window', (tester) async {
    tester.view.physicalSize = const Size(2, 2);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: ArcadeHubApp()));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
