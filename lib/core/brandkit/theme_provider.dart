// lib/core/brandkit/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global dark mode toggle provider.
/// Default: dark (true) since Arcade Hub is a dark-first brand.
final themeProvider = StateProvider<bool>((ref) => true);
