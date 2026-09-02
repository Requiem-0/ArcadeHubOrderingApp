// lib/core/brandkit/theme_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kThemePrefKey = 'arcade_theme_is_dark';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_kThemePrefKey)) {
        state = prefs.getBool(_kThemePrefKey) ?? true;
      }
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    await setTheme(!state);
  }

  Future<void> setTheme(bool isDark) async {
    state = isDark;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kThemePrefKey, isDark);
    } catch (_) {}
  }
}

/// Global dark mode toggle provider with SharedPreferences persistence.
/// Defaults to true (Dark Mode) matching Arcade Hub branding.
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});
