// lib/shared/widgets/app_network_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_theme_colors.dart';
import 'app_logo.dart';

/// Network image with disk caching and Arcade Hub branding while it loads.
///
/// POS product photos come off a remote image host and can take a beat on a
/// slow connection. Rather than flashing an empty box (or a broken-image
/// glyph on failure), this shows the Arcade Hub "AH" mark, then fades the
/// real photo in. Repeat views are served from cache, so they appear instantly.
class AppNetworkImage extends StatelessWidget {
  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  /// Shown instead of the logo when the image is missing or fails — used for
  /// product emojis and avatar initials.
  final Widget? fallback;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return _wrap(fallback ?? const AppLogoPlaceholder());
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, _) => _wrap(const AppLogoPlaceholder(pulsing: true)),
      errorWidget: (_, _, _) => _wrap(fallback ?? const AppLogoPlaceholder()),
    );
  }

  Widget _wrap(Widget child) => SizedBox(
        width: width,
        height: height,
        child: Center(child: child),
      );
}

/// The Arcade Hub wordmark, sized to whatever box it lands in.
///
/// Deliberately understated: it fills the gap while a photo loads without
/// competing with the real content that replaces it.
class AppLogoPlaceholder extends StatefulWidget {
  final bool pulsing;

  const AppLogoPlaceholder({super.key, this.pulsing = false});

  @override
  State<AppLogoPlaceholder> createState() => _AppLogoPlaceholderState();
}

class _AppLogoPlaceholderState extends State<AppLogoPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(AppLogoPlaceholder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.pulsing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Sit at roughly a third of the shorter side, clamped so the mark
        // stays legible in a cart thumbnail and restrained on a hero image.
        final shortest = [
          constraints.maxWidth.isFinite ? constraints.maxWidth : 64.0,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 64.0,
        ].reduce((a, b) => a < b ? a : b);
        final size = (shortest * 0.34).clamp(22.0, 72.0);

        final mark = SizedBox(
          width: size * 1.5,
          child: Image.asset(
            kLogoAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryRed, AppColors.deepRed],
                ),
                borderRadius: BorderRadius.circular(size * 0.22),
              ),
            ),
          ),
        );

        return ColoredBox(
          color: colors.primaryRed.withValues(alpha: 0.06),
          child: Center(
            child: widget.pulsing
                ? FadeTransition(
                    opacity: Tween<double>(begin: 0.35, end: 0.85)
                        .animate(CurvedAnimation(
                      parent: _controller,
                      curve: Curves.easeInOut,
                    )),
                    child: mark,
                  )
                : Opacity(opacity: 0.55, child: mark),
          ),
        );
      },
    );
  }
}
