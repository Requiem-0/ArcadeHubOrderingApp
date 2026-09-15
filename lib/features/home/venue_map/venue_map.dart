// lib/features/home/venue_map/venue_map.dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/brandkit/app_theme_colors.dart';
import '../../../shared/widgets/app_logo.dart';
import 'venue_floor_plan.dart';

part 'venue_map_data.dart';

const double _kVenueLat = 28.2210429;
const double _kVenueLon = 83.9869353;

/// "Find us" card: an isometric miniature of the block around the venue with
/// a directions action underneath.
class VenueMapCard extends StatelessWidget {
  const VenueMapCard({super.key});

  Future<void> _openDirections() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$_kVenueLat,$_kVenueLon',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.borderSubtle),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(6, 10, 6, 0),
            child: _VenueMapCanvas(),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'New Road, Pokhara',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '4th floor',
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.primaryRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _DirectionsButton(onTap: _openDirections, colors: colors),
                  ],
                ),
                const SizedBox(height: 8),
                // Full width, so it stays on one line instead of breaking
                // "New / Road" beside the button.
                Text(
                  'Corner of New Road and Pragati Marg',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionsButton extends StatelessWidget {
  final VoidCallback onTap;
  final AppThemeColors colors;

  const _DirectionsButton({required this.onTap, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colors.primaryRed,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.near_me_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                'Get directions',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueMapCanvas extends StatefulWidget {
  const _VenueMapCanvas();

  @override
  State<_VenueMapCanvas> createState() => _VenueMapCanvasState();
}

class _VenueMapCanvasState extends State<_VenueMapCanvas>
    with SingleTickerProviderStateMixin {
  // The block rises once, when the card first scrolls into view. It sits far
  // below the fold, so starting on mount would finish before anyone sees it.
  late final AnimationController _rise = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );
  ScrollPosition? _position;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _started = true;
      _rise.value = 1;
      return;
    }

    _position?.removeListener(_maybeStart);
    _position = Scrollable.maybeOf(context)?.position;
    _position?.addListener(_maybeStart);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStart());
  }

  void _maybeStart() {
    if (_started || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;

    final top = box.localToGlobal(Offset.zero).dy;
    if (top < MediaQuery.sizeOf(context).height * 0.85) {
      _started = true;
      _position?.removeListener(_maybeStart);
      _rise.forward();
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_maybeStart);
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = colors.isDark ? _MapPalette.dark : _MapPalette.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final frame = _Frame.fit(constraints.maxWidth);

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTapUp: (details) {
            if (frame.hitsVenue(details.localPosition)) {
              showVenueFloorPlan(context);
            }
          },
          child: SizedBox(
            width: frame.width,
            height: frame.height,
            child: AnimatedBuilder(
              animation: _rise,
              builder: (context, _) {
                final t = _rise.value;
                final pin = frame.venuePin(t);
                // The label lands last, once the venue has finished rising.
                final pinIn = Curves.easeOutBack.transform(
                  ((t - 0.62) / 0.38).clamp(0.0, 1.0),
                );

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _VenueMapPainter(
                          frame: frame,
                          palette: palette,
                          progress: t,
                        ),
                      ),
                    ),
                    Positioned(
                      left: pin.dx,
                      top: pin.dy,
                      child: FractionalTranslation(
                        // Set right of the stem: centred, the pill covers the
                        // Bhat-Bhateni label at the back of the tile.
                        translation: const Offset(-0.3, -1.0),
                        child: Opacity(
                          opacity: pinIn.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: 0.7 + 0.3 * pinIn,
                            alignment: Alignment.bottomCenter,
                            child: Semantics(
                              button: true,
                              label: 'Show the Arcade Hub floor plan',
                              child: GestureDetector(
                                onTap: () => showVenueFloorPlan(context),
                                child: _VenuePin(colors: colors),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _VenuePin extends StatelessWidget {
  final AppThemeColors colors;

  const _VenuePin({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 6, 3),
      decoration: BoxDecoration(
        color: colors.cardElevated,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: colors.isDark ? 0.5 : 0.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLogoPlate(size: 24, glow: false),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arcade Hub',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
              Text(
                '4th floor',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: colors.primaryRed,
                ),
              ),
            ],
          ),
          const SizedBox(width: 2),
          Icon(Icons.chevron_right_rounded, size: 18, color: colors.textMuted),
        ],
      ),
    );
  }
}

// ── Geometry ─────────────────────────────────────────────────────────────

class _Block {
  final double height;
  final List<double> pts;
  const _Block(this.height, this.pts);
}

class _Road {
  final int kind; // 0 primary, 1 secondary, 2 residential, 3 service
  final double width;
  final List<double> pts;
  const _Road(this.kind, this.width, this.pts);
}

class _Label {
  final String text;
  final double x;
  final double y;

  /// -1 text ends at the anchor, 0 centred on it, 1 starts at it.
  final int align;
  const _Label(this.text, this.x, this.y, this.align);
}

/// Screen placement of the diorama for a given card width.
///
/// World units are metres. The camera sits north-east of the block, looking
/// south-west, so the venue's New Road and Pragati Marg frontages face the
/// viewer. Projection is 2:1 isometric with slightly compressed heights.
class _Frame {
  static const double _k = math.sqrt1_2;
  static const double _zScale = 0.82;
  static const double _slab = 5.0;
  static const double _stem = 17.0;

  final double scale;
  final Offset origin;
  final double width;
  final double height;

  const _Frame(this.scale, this.origin, this.width, this.height);

  factory _Frame.fit(double width) {
    const h = _kTileHalf;
    final tallest = _kBlocks.fold<double>(
      _kVenueHeight,
      (m, b) => math.max(m, b.height),
    );

    const minX = -2 * h * _k;
    const maxX = 2 * h * _k;
    final minY = math.min(
      -h * _k - tallest * _zScale,
      _venueRoofScreenY() - _stem * _zScale - 16,
    );
    const maxY = h * _k + _slab * _zScale;

    const pad = 3.0;
    final s = width / (maxX - minX + 2 * pad);
    final height = (maxY - minY + 2 * pad) * s;
    return _Frame(
      s,
      Offset((-minX + pad) * s, (-minY + pad) * s),
      width,
      height,
    );
  }

  static double _venueRoofScreenY() {
    final c = _centroid(_kVenueFootprint);
    return (c.dx + c.dy) * _k * 0.5 - _kVenueHeight * _zScale;
  }

  Offset project(double x, double y, [double z = 0]) => Offset(
    origin.dx + (y - x) * _k * scale,
    origin.dy + ((x + y) * _k * 0.5 - z * _zScale) * scale,
  );

  /// Whether a tap lands on the venue building, walls or roof.
  bool hitsVenue(Offset point) {
    final outline = <Offset>[];
    for (var i = 0; i + 1 < _kVenueFootprint.length; i += 2) {
      final x = _kVenueFootprint[i], y = _kVenueFootprint[i + 1];
      outline
        ..add(project(x, y))
        ..add(project(x, y, _kVenueHeight));
    }
    return (Path()..addPolygon(_hull(outline), true)).contains(point);
  }

  /// Where the label's bottom edge sits: above the roof, at the top of the stem.
  Offset venuePin(double t) {
    final c = _centroid(_kVenueFootprint);
    final h = _kVenueHeight * _riseAt(t, 0);
    return project(c.dx, c.dy, h + _stem);
  }
}

Offset _centroid(List<double> pts) {
  var x = 0.0, y = 0.0;
  final n = pts.length ~/ 2;
  for (var i = 0; i < n; i++) {
    x += pts[i * 2];
    y += pts[i * 2 + 1];
  }
  return Offset(x / n, y / n);
}

/// Per-building rise: blocks near the venue lift first and the wave rolls
/// outward, which pulls the eye to the venue before the rest settles.
double _riseAt(double t, double distance) {
  final delay = (distance / 90.0).clamp(0.0, 1.0) * 0.4;
  return Curves.easeOutCubic.transform(((t - delay) / 0.6).clamp(0.0, 1.0));
}

// ── Palette ──────────────────────────────────────────────────────────────

class _MapPalette {
  final Color slabLit, slabShade, slabRim;
  final Color ground, kerb, road, laneDash;
  final Color top, topEdge, wallLit, wallShade, shadow;
  final Color venueTop,
      venueRoof,
      venueWallLit,
      venueWallShade,
      venueGlass,
      venueFloorLine,
      glow;
  final Color label, labelHalo;

  const _MapPalette({
    required this.slabLit,
    required this.slabShade,
    required this.slabRim,
    required this.ground,
    required this.kerb,
    required this.road,
    required this.laneDash,
    required this.top,
    required this.topEdge,
    required this.wallLit,
    required this.wallShade,
    required this.shadow,
    required this.venueTop,
    required this.venueRoof,
    required this.venueWallLit,
    required this.venueWallShade,
    required this.venueGlass,
    required this.venueFloorLine,
    required this.glow,
    required this.label,
    required this.labelHalo,
  });

  // Neighbours stay in the card's own greys so the venue red is the only
  // saturated colour on the tile.
  static const dark = _MapPalette(
    slabLit: Color(0xFF232328),
    slabShade: Color(0xFF151518),
    slabRim: Color(0xFF3A3A42),
    ground: Color(0xFF29292F),
    kerb: Color(0xFF33333A),
    road: Color(0xFF18181C),
    laneDash: Color(0xFF3C3C44),
    top: Color(0xFF45454E),
    topEdge: Color(0xFF55555F),
    wallLit: Color(0xFF34343B),
    wallShade: Color(0xFF222227),
    shadow: Color(0x66000000),
    venueTop: Color(0xFFE31C1C),
    venueRoof: Color(0xFFB70F0F),
    venueWallLit: Color(0xFFB30000),
    venueWallShade: Color(0xFF780000),
    venueGlass: Color(0xFFFFD9D2),
    venueFloorLine: Color(0x33000000),
    glow: Color(0x55CC0000),
    label: Color(0xFFA2A2AA),
    labelHalo: Color(0xFF1F1F24),
  );

  static const light = _MapPalette(
    slabLit: Color(0xFFDADAE0),
    slabShade: Color(0xFFC3C3CB),
    slabRim: Color(0xFFFFFFFF),
    ground: Color(0xFFEDEDF1),
    kerb: Color(0xFFFAFAFC),
    road: Color(0xFFD2D2D9),
    laneDash: Color(0xFFF5F5F8),
    top: Color(0xFFFFFFFF),
    topEdge: Color(0xFFFFFFFF),
    wallLit: Color(0xFFE3E3E9),
    wallShade: Color(0xFFCBCBD4),
    shadow: Color(0x1F000000),
    venueTop: Color(0xFFE53935),
    venueRoof: Color(0xFFC62828),
    venueWallLit: Color(0xFFC62828),
    venueWallShade: Color(0xFF951B1B),
    venueGlass: Color(0xFFFFF2EF),
    venueFloorLine: Color(0x26000000),
    glow: Color(0x2ED32F2F),
    label: Color(0xFF6C6C74),
    labelHalo: Color(0xFFF4F4F7),
  );
}

// ── Painter ──────────────────────────────────────────────────────────────

class _VenueMapPainter extends CustomPainter {
  final _Frame frame;
  final _MapPalette palette;
  final double progress;

  _VenueMapPainter({
    required this.frame,
    required this.palette,
    required this.progress,
  });

  // Camera and light directions on the ground plane.
  static const _camera = Offset(math.sqrt1_2, math.sqrt1_2);
  static final _light = _unit(const Offset(1.0, 0.35));

  static Offset _unit(Offset o) => o / o.distance;

  @override
  void paint(Canvas canvas, Size size) {
    _paintSlab(canvas);

    final ground = _tilePath();
    canvas.save();
    canvas.clipPath(ground);
    canvas.drawPath(ground, Paint()..color = palette.ground);
    _paintRoads(canvas);
    _paintVenueGlow(canvas);
    _paintShadows(canvas);
    canvas.restore();

    _paintPrisms(canvas);
    _paintLabels(canvas);
    _paintPinStem(canvas);
    _paintCompass(canvas, size);
    _paintAttribution(canvas, size);
  }

  // Tile -------------------------------------------------------------------

  Path _tilePath() {
    const h = _kTileHalf;
    return Path()..addPolygon([
      frame.project(-h, -h),
      frame.project(h, -h),
      frame.project(h, h),
      frame.project(-h, h),
    ], true);
  }

  void _paintSlab(Canvas canvas) {
    const h = _kTileHalf;
    const d = -_Frame._slab;

    // Soft contact shadow under the whole tile.
    canvas.drawPath(
      _tilePath().shift(Offset(0, (-d * _Frame._zScale + 3) * frame.scale)),
      Paint()
        ..color = Colors.black.withValues(
          alpha: palette == _MapPalette.dark ? 0.45 : 0.12,
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * frame.scale),
    );

    // The two faces the camera sees: +x (lit) and +y (in shade).
    canvas.drawPath(
      Path()..addPolygon([
        frame.project(h, -h),
        frame.project(h, h),
        frame.project(h, h, d),
        frame.project(h, -h, d),
      ], true),
      Paint()..color = palette.slabLit,
    );
    canvas.drawPath(
      Path()..addPolygon([
        frame.project(h, h),
        frame.project(-h, h),
        frame.project(-h, h, d),
        frame.project(h, h, d),
      ], true),
      Paint()..color = palette.slabShade,
    );

    // Hairline where the ground meets the cut edge, like a milled board.
    canvas.drawPath(
      Path()..addPolygon([
        frame.project(h, -h),
        frame.project(h, h),
        frame.project(-h, h),
      ], false),
      Paint()
        ..color = palette.slabRim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  // Ground layer -------------------------------------------------------------

  void _paintRoads(Canvas canvas) {
    final kerb = Paint()..color = palette.kerb;
    final asphalt = Paint()..color = palette.road;

    for (final pass in const [true, false]) {
      for (final r in _kRoads) {
        final w = r.width + (pass ? 1.8 : 0);
        _ribbon(canvas, r.pts, w, pass ? kerb : asphalt);
      }
    }

    final dash = Paint()
      ..color = palette.laneDash
      ..strokeWidth = math.max(1, 0.35 * frame.scale)
      ..strokeCap = StrokeCap.round;
    for (final r in _kRoads.where((r) => r.kind == 0)) {
      _dashes(canvas, r.pts, dash);
    }
  }

  void _ribbon(Canvas canvas, List<double> pts, double width, Paint paint) {
    final half = width / 2;
    for (var i = 0; i + 3 < pts.length; i += 2) {
      final a = Offset(pts[i], pts[i + 1]);
      final b = Offset(pts[i + 2], pts[i + 3]);
      final dir = b - a;
      if (dir.distance == 0) continue;
      final n = Offset(-dir.dy, dir.dx) / dir.distance * half;
      canvas.drawPath(
        Path()..addPolygon([
          frame.project(a.dx + n.dx, a.dy + n.dy),
          frame.project(b.dx + n.dx, b.dy + n.dy),
          frame.project(b.dx - n.dx, b.dy - n.dy),
          frame.project(a.dx - n.dx, a.dy - n.dy),
        ], true),
        paint,
      );
    }
    // Round the joints so bends don't show notches.
    for (var i = 0; i + 1 < pts.length; i += 2) {
      canvas.drawPath(_groundDisc(pts[i], pts[i + 1], half), paint);
    }
  }

  Path _groundDisc(double x, double y, double r) {
    const steps = 12;
    return Path()..addPolygon([
      for (var s = 0; s < steps; s++)
        frame.project(
          x + r * math.cos(s * 2 * math.pi / steps),
          y + r * math.sin(s * 2 * math.pi / steps),
        ),
    ], true);
  }

  void _dashes(Canvas canvas, List<double> pts, Paint paint) {
    const on = 2.2, period = 5.0;
    var carry = 0.0;
    for (var i = 0; i + 3 < pts.length; i += 2) {
      final a = Offset(pts[i], pts[i + 1]);
      final b = Offset(pts[i + 2], pts[i + 3]);
      final len = (b - a).distance;
      if (len == 0) continue;
      final u = (b - a) / len;
      for (var s = carry; s < len; s += period) {
        final p0 = a + u * s;
        final p1 = a + u * math.min(s + on, len);
        canvas.drawLine(
          frame.project(p0.dx, p0.dy),
          frame.project(p1.dx, p1.dy),
          paint,
        );
      }
      carry = (carry - len) % period;
      if (carry < 0) carry += period;
    }
  }

  void _paintVenueGlow(Canvas canvas) {
    final c = _centroid(_kVenueFootprint);
    final centre = frame.project(c.dx, c.dy);
    final r = 30 * frame.scale;
    final strength = _riseAt(progress, 0);

    // A ground-plane circle projects to a 2:1 ellipse; squash the canvas to match.
    canvas.save();
    canvas.translate(centre.dx, centre.dy);
    canvas.scale(1, 0.5);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: palette.glow.a * strength),
            palette.glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );
    canvas.restore();
  }

  void _paintShadows(Canvas canvas) {
    final paint = Paint()..color = palette.shadow;
    final cast = -_light * 0.6;
    final venueCentre = _centroid(_kVenueFootprint);

    void shadowOf(List<double> pts, double height) {
      final ring = <Offset>[];
      final lift =
          height * _riseAt(progress, (_centroid(pts) - venueCentre).distance);
      if (lift <= 0) return;
      for (var i = 0; i + 1 < pts.length; i += 2) {
        final p = Offset(pts[i], pts[i + 1]);
        ring
          ..add(p)
          ..add(p + cast * lift);
      }
      canvas.drawPath(
        Path()..addPolygon(
          _hull(ring).map((p) => frame.project(p.dx, p.dy)).toList(),
          true,
        ),
        paint,
      );
    }

    for (final b in _kBlocks) {
      shadowOf(b.pts, b.height);
    }
    shadowOf(_kVenueFootprint, _kVenueHeight);
  }

  // Buildings ----------------------------------------------------------------

  void _paintPrisms(Canvas canvas) {
    final venueCentre = _centroid(_kVenueFootprint);
    final order =
        <({List<double> pts, double height, bool venue, double depth})>[
          for (final b in _kBlocks)
            (pts: b.pts, height: b.height, venue: false, depth: _depth(b.pts)),
          (
            pts: _kVenueFootprint,
            height: _kVenueHeight,
            venue: true,
            depth: _depth(_kVenueFootprint),
          ),
        ]..sort((a, b) => a.depth.compareTo(b.depth));

    for (final p in order) {
      final rise = _riseAt(progress, (_centroid(p.pts) - venueCentre).distance);
      final h = p.height * rise;
      if (h <= 0.05) continue;
      if (p.venue) {
        _paintVenue(canvas, h, rise);
      } else {
        _paintPrism(
          canvas,
          p.pts,
          h,
          top: palette.top,
          lit: palette.wallLit,
          shade: palette.wallShade,
          edge: palette.topEdge,
        );
      }
    }
  }

  double _depth(List<double> pts) {
    final c = _centroid(pts);
    return c.dx + c.dy;
  }

  /// Visible walls of a counter-clockwise footprint, far wall first.
  List<({Offset a, Offset b, Offset normal})> _visibleWalls(List<double> pts) {
    final n = pts.length ~/ 2;
    final walls = <({Offset a, Offset b, Offset normal})>[];
    for (var i = 0; i < n; i++) {
      final a = Offset(pts[i * 2], pts[i * 2 + 1]);
      final j = (i + 1) % n;
      final b = Offset(pts[j * 2], pts[j * 2 + 1]);
      final e = b - a;
      if (e.distance == 0) continue;
      final normal = Offset(e.dy, -e.dx) / e.distance;
      if (normal.dx * _camera.dx + normal.dy * _camera.dy > 0.001) {
        walls.add((a: a, b: b, normal: normal));
      }
    }
    walls.sort((w1, w2) {
      final d1 = (w1.a.dx + w1.b.dx + w1.a.dy + w1.b.dy);
      final d2 = (w2.a.dx + w2.b.dx + w2.a.dy + w2.b.dy);
      return d1.compareTo(d2);
    });
    return walls;
  }

  Color _wallTone(Offset normal, Color lit, Color shade) {
    final t = ((normal.dx * _light.dx + normal.dy * _light.dy) + 1) / 2;
    return Color.lerp(shade, lit, t)!;
  }

  Path _quad(Offset a, Offset b, double z0, double z1) => Path()
    ..addPolygon([
      frame.project(a.dx, a.dy, z0),
      frame.project(b.dx, b.dy, z0),
      frame.project(b.dx, b.dy, z1),
      frame.project(a.dx, a.dy, z1),
    ], true);

  Path _cap(List<double> pts, double z) => Path()
    ..addPolygon([
      for (var i = 0; i + 1 < pts.length; i += 2)
        frame.project(pts[i], pts[i + 1], z),
    ], true);

  void _paintPrism(
    Canvas canvas,
    List<double> pts,
    double h, {
    required Color top,
    required Color lit,
    required Color shade,
    required Color edge,
  }) {
    for (final w in _visibleWalls(pts)) {
      canvas.drawPath(
        _quad(w.a, w.b, 0, h),
        Paint()..color = _wallTone(w.normal, lit, shade),
      );
    }
    final cap = _cap(pts, h);
    canvas.drawPath(cap, Paint()..color = top);
    canvas.drawPath(
      cap,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..strokeJoin = StrokeJoin.round,
    );
  }

  /// The venue gets the detail the neighbours don't: floor lines, Arcade
  /// Hub's own floor lit up with window mullions, a parapet roof, and a
  /// rooftop plant box.
  void _paintVenue(Canvas canvas, double h, double rise) {
    final pts = _kVenueFootprint;
    final walls = _visibleWalls(pts);

    for (final w in walls) {
      canvas.drawPath(
        _quad(w.a, w.b, 0, h),
        Paint()
          ..color = _wallTone(
            w.normal,
            palette.venueWallLit,
            palette.venueWallShade,
          ),
      );

      // Floor slabs, only once they've risen past each level.
      final line = Paint()
        ..color = palette.venueFloorLine
        ..strokeWidth = 1;
      for (var level = 1; level < _kVenueLevels; level++) {
        final z = _kVenueHeight / _kVenueLevels * level;
        if (z >= h - 0.4) break;
        canvas.drawLine(
          frame.project(w.a.dx, w.a.dy, z),
          frame.project(w.b.dx, w.b.dy, z),
          line,
        );
      }

      // Arcade Hub's floor glows; it lights once the building has risen past it.
      final levelH = _kVenueHeight / _kVenueLevels;
      final z0 = levelH * _kVenueFloor + 0.55;
      final z1 = levelH * (_kVenueFloor + 1) - 0.55;
      if (h >= z1) {
        final e = w.b - w.a;
        final g0 = w.a + e * 0.05;
        final g1 = w.a + e * 0.95;
        canvas.drawPath(
          _quad(g0, g1, z0, z1),
          Paint()..color = palette.venueGlass.withValues(alpha: 0.95 * rise),
        );

        // Mullions roughly every 3 m, so the band reads as windows.
        final mullion = Paint()
          ..color = palette.venueWallShade.withValues(alpha: 0.45)
          ..strokeWidth = 1;
        final panes = math.max(2, ((g1 - g0).distance / 3).round());
        for (var i = 1; i < panes; i++) {
          final m = g0 + (g1 - g0) * (i / panes);
          canvas.drawLine(
            frame.project(m.dx, m.dy, z0),
            frame.project(m.dx, m.dy, z1),
            mullion,
          );
        }
      }
    }

    // Roof: slab, then a recessed deck inside the parapet.
    canvas.drawPath(_cap(pts, h), Paint()..color = palette.venueTop);
    final inset = _inset(pts, 1.4);
    canvas.drawPath(_cap(inset, h), Paint()..color = palette.venueRoof);

    // Rooftop plant box, set back toward the rear corner.
    if (rise > 0.85) {
      final c = _centroid(pts);
      final box = [
        c.dx - 6.5,
        c.dy - 6.5,
        c.dx - 1.5,
        c.dy - 6.5,
        c.dx - 1.5,
        c.dy - 2.5,
        c.dx - 6.5,
        c.dy - 2.5,
      ];
      final boxH = 2.6 * ((rise - 0.85) / 0.15);
      for (final w in _visibleWalls(box)) {
        canvas.drawPath(
          _quad(w.a, w.b, h, h + boxH),
          Paint()
            ..color = _wallTone(
              w.normal,
              palette.venueWallLit,
              palette.venueWallShade,
            ),
        );
      }
      canvas.drawPath(_cap(box, h + boxH), Paint()..color = palette.venueTop);
    }
  }

  List<double> _inset(List<double> pts, double d) {
    final c = _centroid(pts);
    final out = <double>[];
    for (var i = 0; i + 1 < pts.length; i += 2) {
      final p = Offset(pts[i], pts[i + 1]);
      final v = p - c;
      final len = v.distance;
      final q = len <= d ? c : c + v / len * (len - d * 1.3);
      out
        ..add(q.dx)
        ..add(q.dy);
    }
    return out;
  }

  // Overlays -----------------------------------------------------------------

  void _paintPinStem(Canvas canvas) {
    final t = ((progress - 0.62) / 0.38).clamp(0.0, 1.0);
    if (t == 0) return;
    final c = _centroid(_kVenueFootprint);
    final h = _kVenueHeight * _riseAt(progress, 0);
    final base = frame.project(c.dx, c.dy, h);
    final tip = frame.project(c.dx, c.dy, h + _Frame._stem * t);

    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = palette.venueTop
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.scale(1, 0.5);
    canvas.drawCircle(
      Offset.zero,
      3.2,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    canvas.restore();
  }

  void _paintLabels(Canvas canvas) {
    final t = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
    if (t == 0) return;
    for (final l in _kRoadLabels) {
      _text(
        canvas,
        l.text,
        frame.project(l.x, l.y),
        t,
        weight: FontWeight.w600,
        align: l.align,
      );
    }
    for (final l in _kLandmarks) {
      final p = frame.project(l.x, l.y);
      canvas.drawCircle(
        p,
        2.2,
        Paint()..color = palette.label.withValues(alpha: t),
      );
      // Side-set names clear the dot sideways; centred names sit under it.
      final offset = l.align == 0
          ? const Offset(0, 10)
          : Offset(6.0 * l.align, 0);
      _text(
        canvas,
        l.text,
        p + offset,
        t,
        weight: FontWeight.w500,
        align: l.align,
      );
    }
  }

  void _text(
    Canvas canvas,
    String text,
    Offset at,
    double opacity, {
    required FontWeight weight,
    int align = 0,
  }) {
    TextPainter build(Paint? stroke, Color? fill) => TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: weight,
          letterSpacing: 0.2,
          foreground: stroke,
          color: fill,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final halo = build(
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round
        ..color = palette.labelHalo.withValues(alpha: 0.9 * opacity),
      null,
    );
    final ink = build(null, palette.label.withValues(alpha: opacity));
    final dx = switch (align) {
      < 0 => ink.width,
      0 => ink.width / 2,
      _ => 0.0,
    };
    final origin = at - Offset(dx, ink.height / 2);
    halo.paint(canvas, origin);
    ink.paint(canvas, origin);
  }

  /// True north, since the grid is rotated to square up the streets.
  void _paintCompass(Canvas canvas, Size size) {
    final r = math.pi * _kGridRotationDeg / 180;
    final north = Offset(-math.sin(r), math.cos(r)); // (0, 1) in grid space
    final screen = Offset(
      (north.dy - north.dx) * math.sqrt1_2,
      (north.dx + north.dy) * math.sqrt1_2 * 0.5,
    );
    final dir = screen / screen.distance;

    final centre = Offset(size.width - 34, size.height - 26);
    final tip = centre + dir * 9;
    final tail = centre - dir * 6;
    final side = Offset(-dir.dy, dir.dx) * 3.6;

    canvas.drawCircle(centre, 13, Paint()..color = palette.labelHalo);
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(tail.dx + side.dx, tail.dy + side.dy)
        ..lineTo(centre.dx, centre.dy)
        ..close(),
      Paint()..color = palette.venueTop,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(centre.dx, centre.dy)
        ..lineTo(tail.dx - side.dx, tail.dy - side.dy)
        ..close(),
      Paint()..color = palette.label,
    );

    final n = TextPainter(
      text: TextSpan(
        text: 'N',
        style: GoogleFonts.dmSans(
          fontSize: 8,
          fontWeight: FontWeight.w700,
          color: palette.label,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final at = centre + dir * 19;
    n.paint(canvas, at - Offset(n.width / 2, n.height / 2));
  }

  void _paintAttribution(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: '© OpenStreetMap contributors',
        style: GoogleFonts.dmSans(
          fontSize: 8.5,
          color: palette.label.withValues(alpha: 0.8),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(12, size.height - tp.height - 8));
  }

  @override
  bool shouldRepaint(_VenueMapPainter old) =>
      old.progress != progress ||
      old.palette != palette ||
      old.frame.width != frame.width;
}

/// Andrew's monotone chain.
List<Offset> _hull(List<Offset> points) {
  final p = [
    ...points,
  ]..sort((a, b) => a.dx != b.dx ? a.dx.compareTo(b.dx) : a.dy.compareTo(b.dy));
  if (p.length < 3) return p;
  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);
  final lower = <Offset>[];
  for (final q in p) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, q) <= 0) {
      lower.removeLast();
    }
    lower.add(q);
  }
  final upper = <Offset>[];
  for (final q in p.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, q) <= 0) {
      upper.removeLast();
    }
    upper.add(q);
  }
  return [...lower..removeLast(), ...upper..removeLast()];
}
