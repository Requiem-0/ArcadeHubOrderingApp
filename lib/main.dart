// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/brandkit/app_theme.dart';
import 'core/brandkit/theme_provider.dart';
import 'core/navigation/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Edge-to-edge transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: ArcadeHubApp()));
}

class ArcadeHubApp extends ConsumerWidget {
  const ArcadeHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Arcade Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
      // A hidden or minimised browser tab can hand the app a window only a
      // pixel or two across, and every row on every screen then reports an
      // overflow. No real screen is that small, so wait until it is usable.
      builder: (context, child) {
        final size = MediaQuery.sizeOf(context);
        if (size.width < 200 || size.height < 200) {
          return const SizedBox.shrink();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
