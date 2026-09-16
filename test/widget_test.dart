// test/widget_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArcadeHubApp()));
    // Not pumpAndSettle: the splash logo sheens on a repeating timer, so the
    // tree never goes quiet and settling would time out.
    // Past the splash delay, so its timer isn't left pending at test end.
    await tester.pump(const Duration(milliseconds: 1500));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // App should render without crashing
    expect(tester.takeException(), isNull);
  });
}
