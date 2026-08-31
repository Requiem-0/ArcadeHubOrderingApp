// test/widget_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:arcadehuborderingapp/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArcadeHubApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    // App should render without crashing
    expect(tester.takeException(), isNull);
  });
}
