import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// The cart's Checkout button pushed '/checkout' for months while the router
/// had no such route, so it landed on GoRouter's error page. Nothing about
/// that is visible until someone taps it, so this reads the source instead:
/// every literal path the app navigates to must be a route the router
/// defines.
void main() {
  test('every path the app navigates to has a route', () {
    final router = File('lib/core/navigation/app_router.dart').readAsStringSync();

    final defined = {
      for (final m in RegExp(r"GoRoute\(\s*path:\s*'([^']+)'").allMatches(router))
        m.group(1)!,
    };
    expect(defined, isNotEmpty, reason: 'no routes found to check against');

    final navigations = <String, String>{};
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final source = file.readAsStringSync();
      for (final m in RegExp(r"context\.(?:push|go|replace)\(\s*'(/[^'$]*)'")
          .allMatches(source)) {
        // Query strings are the screen's business, not the router's.
        navigations[m.group(1)!.split('?').first] = file.path;
      }
    }
    expect(navigations, isNotEmpty, reason: 'no navigation calls found');

    final missing = <String, String>{};
    for (final entry in navigations.entries) {
      if (!defined.contains(entry.key)) missing[entry.key] = entry.value;
    }

    expect(missing, isEmpty,
        reason: 'these go nowhere: ${missing.entries.map((e) => "${e.key} "
            "(${e.value})").join(', ')}');
  });
}
