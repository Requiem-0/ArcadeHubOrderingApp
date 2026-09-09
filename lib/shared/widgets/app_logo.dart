// lib/shared/widgets/app_logo.dart
import 'package:flutter/material.dart';
import '../../core/brandkit/app_colors.dart';
import '../../core/brandkit/app_text_styles.dart';
import '../../core/constants.dart';

/// Path to the Arcade Hub wordmark.
///
/// Cut out from the JPEG the client supplied, so it sits on any background.
/// If a flat-backed image is ever swapped in here, set
/// [kLogoHasTransparency] to false and the plate comes back.
const String kLogoAsset = 'assets/images/logo.png';
const bool kLogoHasTransparency = true;

/// Arcade Hub logo.
///
/// Falls back to the drawn "AH" mark if the artwork is missing, so the app
/// still builds and renders before the asset is dropped in.
class AppLogo extends StatelessWidget {
  final double size;
  final bool showLabel;
  final bool compact;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Image.asset(
            kLogoAsset,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => _FallbackMark(size: size),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: compact ? 8 : 14),
          Text(
            AppConstants.appName,
            style: AppTextStyles.headingM(AppColors.textLight),
          ),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(
              AppConstants.appTagline,
              style: AppTextStyles.bodyS(AppColors.textMutedLight),
            ),
          ],
        ],
      ],
    );
  }
}

/// The wordmark as a lit arcade marquee.
///
/// A flat white tile on a black screen reads as a sticker. Real cabinets
/// carry their logo on a backlit acrylic panel in a metal bezel, and that is
/// what this builds: a steel frame catching light from above, an acrylic
/// face with a specular sheen, and the venue's red spilling onto the dark
/// around it.
///
/// [glow] drives the light spill. Leave it on where the tile is the subject
/// (splash, sign-in). Turn it off in a header, where a bloom would pull
/// attention off the content.
class AppLogoPlate extends StatelessWidget {
  final double size;
  final bool glow;

  const AppLogoPlate({super.key, this.size = 132, this.glow = true});

  @override
  Widget build(BuildContext context) {
    final bezel = size * 0.055;
    final outerRadius = size * 0.26;

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        // Brushed steel, lit from the top-left.
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF44444C), Color(0xFF1A1A20)],
          stops: [0.0, 0.75],
        ),
        borderRadius: BorderRadius.circular(outerRadius),
        boxShadow: [
          if (glow)
            BoxShadow(
              color: AppColors.primaryRed.withValues(alpha: 0.45),
              blurRadius: size * 0.72,
              spreadRadius: size * 0.02,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.62),
            blurRadius: size * 0.22,
            offset: Offset(0, size * 0.07),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius - bezel),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Acrylic face, brightest where the light hits.
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFE4E4EA)],
                ),
              ),
            ),

            // Sheen on the acrylic, beneath the ink.
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(size * 0.06),
              child: Center(
                child: Image.asset(
                  kLogoAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _FallbackMark(size: size * 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Drawn "AH" badge, used until the artwork lands.
class _FallbackMark extends StatelessWidget {
  final double size;

  const _FallbackMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Center(
        child: Text(
          'AH',
          style: AppTextStyles.bold(AppColors.onPrimary, size: size * 0.36),
        ),
      ),
    );
  }
}
