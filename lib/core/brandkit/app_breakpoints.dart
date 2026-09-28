// lib/core/brandkit/app_breakpoints.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_theme_colors.dart';

/// How much room the app has to work with. Named after what it means for
/// layout, not after any particular device.
enum ScreenSize {
  /// A phone held in one hand. Everything is one column.
  compact,

  /// A big phone in landscape, or a tablet. Grids gain a column.
  medium,

  /// A laptop or desktop browser, where the content is capped and centred.
  expanded,
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double medium = 600;
  static const double expanded = 1000;

  /// The widest the app's content is allowed to grow. Past this, a phone
  /// layout stops reading as a design and starts reading as a stretch, so
  /// the extra room becomes margin instead.
  static const double maxContentWidth = 720;

  /// Below this the window is a hidden or minimised tab rather than a screen.
  static const double minUsable = 200;

  static ScreenSize of(double width) {
    if (width >= expanded) return ScreenSize.expanded;
    if (width >= medium) return ScreenSize.medium;
    return ScreenSize.compact;
  }
}

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  ScreenSize get screenSize => AppBreakpoints.of(screenWidth);

  bool get isCompact => screenSize == ScreenSize.compact;

  /// True once there is room for more than a single phone column.
  bool get isRoomy => screenSize != ScreenSize.compact;

  /// Side padding that opens up a little as the window grows.
  double get gutter => switch (screenSize) {
        ScreenSize.compact => 20,
        ScreenSize.medium => 28,
        ScreenSize.expanded => 32,
      };

  /// How many columns fit without any card dropping below [minCardWidth].
  /// Always at least two, so a grid never collapses into a list.
  int gridColumns({
    required double minCardWidth,
    double horizontalPadding = 0,
    double spacing = 0,
    int max = 5,
  }) {
    final usable = screenWidth - horizontalPadding;
    if (usable <= 0) return 2;
    final fits = ((usable + spacing) / (minCardWidth + spacing)).floor();
    return fits.clamp(2, max);
  }
}

/// Caps and centres the app on a screen wider than a phone, and sits out
/// windows too small to lay anything out in.
///
/// The capped width is pushed back into [MediaQuery] so every screen inside
/// measures the space it actually has, not the size of the browser window.
class ResponsiveShell extends StatelessWidget {
  final Widget child;

  const ResponsiveShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size = media.size;

    // A hidden or minimised browser tab can hand the app a window only a
    // pixel or two across, and every row on every screen then reports an
    // overflow. No real screen is that small, so wait until it is usable.
    if (size.width < AppBreakpoints.minUsable ||
        size.height < AppBreakpoints.minUsable) {
      return const SizedBox.shrink();
    }

    final width = math.min(size.width, AppBreakpoints.maxContentWidth);
    if (width == size.width) return child;

    final colors = context.appColors;
    return ColoredBox(
      color: colors.surface,
      child: Center(
        child: Container(
          width: width,
          decoration: BoxDecoration(
            border: Border.symmetric(
              vertical: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: MediaQuery(
            data: media.copyWith(size: Size(width, size.height)),
            child: child,
          ),
        ),
      ),
    );
  }
}
