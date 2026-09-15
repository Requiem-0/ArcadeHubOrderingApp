// lib/features/home/venue_map/venue_floor_plan.dart
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/brandkit/app_theme_colors.dart';
import '../../../core/brandkit/experiences.dart';
import '../../../shared/widgets/app_logo.dart';

/// Opens the Arcade Hub floor plan as a bottom sheet.
Future<void> showVenueFloorPlan(BuildContext context) {
  final colors = context.appColors;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const _FloorPlanSheet(),
  );
}

// ── Layout ───────────────────────────────────────────────────────────────
//
// Traced from the client's detailed sketch of the 4th floor, at roughly one
// plan unit per 50 px of the sketch. x runs left to right across the sketch,
// y runs top to bottom.
//
// Taken from the sketch: every room's position and outline, the round bar,
// the stair opening (open on its right), the dividing wall with its passage,
// the counter, and the washroom / table tennis / elevator wing beyond it.
// Confirmed by the client: the elevator doors face the table tennis area and
// the building ends right behind the elevator.
// Added at the client's request: a mini golf course between the stairs and
// the Play Room.
// Assumed: the round bar is the Sports Bar zone; doorways (the sketch shows
// none); the washroom's own wall.

const double _planW = 26.4;
const double _planH = 13.2;

/// Where the indoor floor starts; left of this is the open-air terrace.
const double _hallLeft = 3.5;

/// The wall splitting the main hall from the service wing on the right.
const double _wingLeft = 21.35;

/// The terrace pushes out past the hall's left edge; the plan starts here.
const double _planLeft = -0.7;

// Both restro areas are drawn 20% larger than the sketch, per the client.
// The terrace grows wider outward and runs the building's full length (the
// building is too short for the full 20% there).
const Rect _terrace = Rect.fromLTRB(_planLeft, 0, _hallLeft, _planH);
const Rect _partyRoom = Rect.fromLTRB(4.95, 0, 10.8, 3.75);
const Rect _playRoom = Rect.fromLTRB(10.8, 0, 16.6, 3.75);
const double _restroTop = 9.18; // 20% deeper into the hall than sketched
const Rect _indoorRestro = Rect.fromLTRB(
  _hallLeft,
  _restroTop,
  _wingLeft,
  _planH,
);
const Rect _washroom = Rect.fromLTRB(_wingLeft, 0, _planW, 1.8);
const Rect _stair = Rect.fromLTRB(10.75, 5.85, 13.9, 7.7);
const double _elevatorLeft = 24.2;
const double _elevatorTop = 5.85;

/// The service wing ends flush with the back of the elevator.
const double _wingBottom = 7.15;
const Rect _elevator = Rect.fromLTRB(
  _elevatorLeft,
  _elevatorTop,
  25.5,
  _wingBottom,
);
const Rect _counter = Rect.fromLTRB(19.2, 5.5, 19.9, 7.3);

/// Mini golf, in the strip of hall between the Play Room and the stairs.
const Rect _golf = Rect.fromLTRB(10.95, 4.2, 15.1, 5.45);
const Offset _golfHole = Offset(14.55, 4.82);
const double _golfBumperX = 13.65;

const Offset _barCentre = Offset(7.25, 6.65);
// 10% smaller than first drawn, per the client.
const double _barRadius = 1.08; // centreline of the round counter
const double _barZone = 1.75; // the green floor around it
const double _barDepth = 0.38; // counter width and height

class _Wall {
  final double x0, y0, x1, y1, height;
  const _Wall(this.x0, this.y0, this.x1, this.y1, this.height);
}

const double _tall = 1.05;
const double _low = 0.2;
const double _partition = 0.5;

const List<_Wall> _walls = [
  // Exterior. The back walls stand full height; the front walls are cut down
  // like a model's cutaway so the rooms show. The terrace wall stays at
  // partition height so it doesn't hide the terrace behind it.
  _Wall(_hallLeft, 0, _planW, 0, _tall),
  _Wall(_planW, 0, _planW, _wingBottom, _low),
  _Wall(_wingLeft, _wingBottom, _planW, _wingBottom, _low),
  _Wall(_wingLeft, _wingBottom, _wingLeft, _planH, _low),
  _Wall(_hallLeft, _planH, _wingLeft, _planH, _low),
  _Wall(_hallLeft, 0, _hallLeft, 6.2, _partition),
  _Wall(_hallLeft, 7.1, _hallLeft, 11.1, _partition),
  _Wall(_hallLeft, 12.0, _hallLeft, _planH, _partition),

  // Party Room and Play Room, each with a doorway onto the hall.
  _Wall(4.95, 0, 4.95, 3.75, _partition),
  _Wall(10.8, 0, 10.8, 3.75, _partition),
  _Wall(16.6, 0, 16.6, 3.75, _partition),
  _Wall(4.95, 3.75, 7.3, 3.75, _partition),
  // The Play Room doorway sits at the right end, clear of the mini golf.
  _Wall(8.3, 3.75, 15.4, 3.75, _partition),
  _Wall(16.3, 3.75, 16.6, 3.75, _partition),

  // Indoor Restro, with two wide openings onto the hall.
  _Wall(_hallLeft, _restroTop, 8.0, _restroTop, _partition),
  _Wall(9.2, _restroTop, 15.0, _restroTop, _partition),
  _Wall(16.2, _restroTop, _wingLeft, _restroTop, _partition),

  // Dividing wall, broken by the passage through to the wing.
  _Wall(_wingLeft, 0, _wingLeft, 4.2, _partition),
  _Wall(_wingLeft, 4.9, _wingLeft, _wingBottom, _partition),
  _Wall(18.8, 4.2, _wingLeft, 4.2, _partition),
  _Wall(18.55, 4.9, _wingLeft, 4.9, _partition),

  // Washroom.
  _Wall(_wingLeft, 1.8, 22.3, 1.8, _partition),
  _Wall(23.2, 1.8, _planW, 1.8, _partition),
];

/// An upright box on the floor plane, from [z0] to [z1].
class _Prism {
  final List<Offset> base;
  final double z0, z1;
  final Color? colour;

  const _Prism(this.base, this.z0, this.z1, {this.colour});

  /// A wall of [thickness] along [a]–[b], squared off past both ends so
  /// meeting walls close their corners.
  factory _Prism.wall(
    Offset a,
    Offset b,
    double thickness,
    double z0,
    double z1, {
    Color? colour,
  }) {
    final dir = (b - a) / (b - a).distance;
    final n = Offset(-dir.dy, dir.dx) * (thickness / 2);
    final ext = dir * (thickness / 2);
    return _Prism(
      [a - ext + n, b + ext + n, b + ext - n, a - ext - n],
      z0,
      z1,
      colour: colour,
    );
  }

  factory _Prism.box(Rect r, double z0, double z1, {Color? colour}) => _Prism(
    [r.topLeft, r.topRight, r.bottomRight, r.bottomLeft],
    z0,
    z1,
    colour: colour,
  );
}

// ── Sheet ────────────────────────────────────────────────────────────────

class _FloorPlanSheet extends StatefulWidget {
  const _FloorPlanSheet();

  @override
  State<_FloorPlanSheet> createState() => _FloorPlanSheetState();
}

class _FloorPlanSheetState extends State<_FloorPlanSheet>
    with SingleTickerProviderStateMixin {
  // One build-up as the sheet opens: the floor settles, each zone takes its
  // colour, the walls rise, then the names appear.
  late final AnimationController _build = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_build.status != AnimationStatus.dismissed) return;
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      _build.value = 1;
    } else {
      _build.forward();
    }
  }

  @override
  void dispose() {
    _build.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final palette = colors.isDark ? _PlanPalette.dark : _PlanPalette.light;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  const AppLogoPlate(size: 40, glow: false),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arcade Hub',
                        style: GoogleFonts.outfit(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: colors.textPrimary,
                        ),
                      ),
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
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: palette.paper,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: AspectRatio(
                aspectRatio: _PlanFrame.aspect,
                // The floor is wide, so small labels need a closer look.
                child: InteractiveViewer(
                  maxScale: 4,
                  child: AnimatedBuilder(
                    animation: _build,
                    builder: (context, _) => CustomPaint(
                      painter: _FloorPlanPainter(
                        palette: palette,
                        progress: _build.value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Take the stairs or the elevator up to the 4th floor. '
                'Pinch the plan to zoom in.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  height: 1.4,
                  color: colors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Palette ──────────────────────────────────────────────────────────────

class _PlanPalette {
  final Color paper;
  final Color slabTop, slabLit, slabShade, tileLine, deckLine;
  final Color wallTop, wallLit, wallShade;
  final Color symbolLabel, amenity;
  final Color pit, stepTop, rail;
  final Color turf, turfStripe, flag;
  final double floorTint;
  final bool isDark;

  const _PlanPalette({
    required this.paper,
    required this.slabTop,
    required this.slabLit,
    required this.slabShade,
    required this.tileLine,
    required this.deckLine,
    required this.wallTop,
    required this.wallLit,
    required this.wallShade,
    required this.symbolLabel,
    required this.amenity,
    required this.pit,
    required this.stepTop,
    required this.rail,
    required this.turf,
    required this.turfStripe,
    required this.flag,
    required this.floorTint,
    required this.isDark,
  });

  static const dark = _PlanPalette(
    paper: Color(0xFF17181C),
    slabTop: Color(0xFF24252B),
    slabLit: Color(0xFF1C1D22),
    slabShade: Color(0xFF121317),
    tileLine: Color(0x0DFFFFFF),
    deckLine: Color(0x1FFFFFFF),
    wallTop: Color(0xFF4A4B53),
    wallLit: Color(0xFF34353C),
    wallShade: Color(0xFF26272D),
    symbolLabel: Color(0xFFA2A2AB),
    amenity: Color(0xFF7D8BA3),
    pit: Color(0xFF0B0B0E),
    stepTop: Color(0xFF3A3B42),
    rail: Color(0xFFB8B8C0),
    turf: Color(0xFF2C6B42),
    turfStripe: Color(0xFF33784B),
    flag: Color(0xFFE11D2A),
    floorTint: 0.3,
    isDark: true,
  );

  static const light = _PlanPalette(
    paper: Color(0xFFF1F1F4),
    slabTop: Color(0xFFFBFBFD),
    slabLit: Color(0xFFDDDDE3),
    slabShade: Color(0xFFC9C9D1),
    tileLine: Color(0x0F000000),
    deckLine: Color(0x1A000000),
    wallTop: Color(0xFFFFFFFF),
    wallLit: Color(0xFFE2E2E8),
    wallShade: Color(0xFFCACAD3),
    symbolLabel: Color(0xFF63636B),
    amenity: Color(0xFF7D8BA3),
    pit: Color(0xFF6E6E7A),
    stepTop: Color(0xFFE9E9EF),
    rail: Color(0xFF55555E),
    turf: Color(0xFF5DB477),
    turfStripe: Color(0xFF6BC084),
    flag: Color(0xFFD62828),
    floorTint: 0.32,
    isDark: false,
  );

  /// The zone's brand colour, made legible on this surface. Rooftop Restro's
  /// near-white disappears on a light sheet, so it falls back to slate there.
  Color zone(Color c) {
    if (!isDark && c.computeLuminance() > 0.8) return const Color(0xFF8391A7);
    return c;
  }

  /// The zone colour pushed away from its own floor tint, so names stay
  /// legible: lighter on the dark sheet, darker on the light one.
  Color zoneInk(Color c) {
    final z = zone(c);
    final hsl = HSLColor.fromColor(z);
    final lightness = isDark
        ? hsl.lightness + (1 - hsl.lightness) * 0.35
        : hsl.lightness * 0.62;
    return hsl.withLightness(lightness.clamp(0.0, 1.0)).toColor();
  }

  /// Floor tint strength. Near-white zones glare on the dark sheet at the
  /// strength the saturated zones need, so they're toned down there.
  double tintFor(Color c) =>
      isDark && c.computeLuminance() > 0.8 ? floorTint * 0.5 : floorTint;
}

// ── Projection ───────────────────────────────────────────────────────────

/// Isometric projection matching the venue map: the camera sits off the
/// front-right corner of the sketch, so the top of the sketch is the back.
class _PlanFrame {
  static const double _k = math.sqrt1_2;
  static const double _zScale = 0.82;
  static const double _slab = 0.35;
  static const double _pad = 0.7;

  static final double _minX = (_planLeft - _planH) * _k - _pad;
  static final double _maxX = _planW * _k + _pad;
  static final double _minY = _planLeft * _k * 0.5 - _tall * _zScale - _pad;
  static final double _maxY =
      (_planW + _planH) * _k * 0.5 + _slab * _zScale + _pad;

  static final double aspect = (_maxX - _minX) / (_maxY - _minY);

  final double scale;
  final Offset origin;

  _PlanFrame(Size size)
    : scale = size.width / (_maxX - _minX),
      origin = Offset(
        -_minX * size.width / (_maxX - _minX),
        -_minY * size.width / (_maxX - _minX),
      );

  Offset project(double x, double y, [double z = 0]) => Offset(
    origin.dx + (x - y) * _k * scale,
    origin.dy + ((x + y) * _k * 0.5 - z * _zScale) * scale,
  );

  /// Canvas transform that maps plan units on the floor plane to the screen,
  /// so text and icons can lie flat on the floor.
  Float64List floorMatrix(double lift) {
    final a = _k * scale, b = _k * 0.5 * scale;
    return Float64List.fromList([
      a, b, 0, 0, //
      -a, b, 0, 0, //
      0, 0, 1, 0, //
      origin.dx, origin.dy - lift * _zScale * scale, 0, 1,
    ]);
  }
}

// ── Painter ──────────────────────────────────────────────────────────────

class _FloorPlanPainter extends CustomPainter {
  final _PlanPalette palette;
  final double progress;

  _FloorPlanPainter({required this.palette, required this.progress});

  static const _camera = Offset(math.sqrt1_2, math.sqrt1_2);
  static final _light =
      const Offset(1.0, 0.45) / const Offset(1.0, 0.45).distance;

  double _phase(double start, double end) => Curves.easeOutCubic.transform(
    ((progress - start) / (end - start)).clamp(0.0, 1.0),
  );

  static ArcadeExperience _experience(String id) =>
      kArcadeExperiences.firstWhere((e) => e.id == id);

  @override
  void paint(Canvas canvas, Size size) {
    final f = _PlanFrame(size);

    // The whole floor settles up into place as it fades in.
    final settle = _phase(0.0, 0.35);
    canvas.save();
    canvas.translate(0, (1 - settle) * 14);
    if (settle < 1) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, settle));
    }

    _paintSlab(canvas, f);
    _paintZones(canvas, f);
    _paintMiniGolf(canvas, f);
    _paintStairwell(canvas, f);
    canvas.drawPath(
      _rect(f, _elevator),
      Paint()..color = palette.wallLit.withValues(alpha: _phase(0.45, 0.9)),
    );
    _paintFloorLabels(canvas, f);
    _paintUprights(canvas, f);

    if (settle < 1) canvas.restore();
    canvas.restore();
  }

  // Floor ------------------------------------------------------------------

  void _paintSlab(Canvas canvas, _PlanFrame f) {
    const d = -_PlanFrame._slab;
    // The building plus the terrace hanging off its left side.
    final outline = <Offset>[
      const Offset(_planLeft, 0),
      const Offset(_planW, 0),
      const Offset(_planW, _wingBottom),
      const Offset(_wingLeft, _wingBottom),
      const Offset(_wingLeft, _planH),
      const Offset(_planLeft, _planH),
    ];

    // Slab edges that face the camera.
    for (var i = 0; i < outline.length; i++) {
      final a = outline[i], b = outline[(i + 1) % outline.length];
      final e = b - a;
      final normal = Offset(e.dy, -e.dx) / e.distance;
      if (normal.dx * _camera.dx + normal.dy * _camera.dy <= 0.001) continue;
      canvas.drawPath(
        Path()..addPolygon([
          f.project(a.dx, a.dy),
          f.project(b.dx, b.dy),
          f.project(b.dx, b.dy, d),
          f.project(a.dx, a.dy, d),
        ], true),
        Paint()..color = normal.dx > 0.5 ? palette.slabLit : palette.slabShade,
      );
    }

    final top = Path()
      ..addPolygon([for (final p in outline) f.project(p.dx, p.dy)], true);
    canvas.drawPath(top, Paint()..color = palette.slabTop);

    // Tiles indoors, clipped to the building's outline, deck boards on the
    // terrace.
    final tile = Paint()
      ..color = palette.tileLine
      ..strokeWidth = 1;
    canvas.save();
    canvas.clipPath(top);
    for (var x = _hallLeft + 1; x < _planW; x++) {
      canvas.drawLine(f.project(x, 0), f.project(x, _planH), tile);
    }
    for (var y = 1.0; y < _planH; y++) {
      canvas.drawLine(f.project(_hallLeft, y), f.project(_planW, y), tile);
    }
    canvas.restore();
    final deck = Paint()
      ..color = palette.deckLine
      ..strokeWidth = 1;
    for (var y = _terrace.top + 0.4; y < _terrace.bottom; y += 0.4) {
      canvas.drawLine(
        f.project(_terrace.left, y),
        f.project(_terrace.right, y),
        deck,
      );
    }
  }

  void _paintZones(Canvas canvas, _PlanFrame f) {
    final restro = _experience('rooftop').color;
    final areas = <(Path, Path, Color, double)>[
      (
        _rect(f, _partyRoom),
        _rect(f, _partyRoom.deflate(0.34)),
        _experience('partyroom').color,
        0.15,
      ),
      (
        _rect(f, _playRoom),
        _rect(f, _playRoom.deflate(0.34)),
        _experience('playroom').color,
        0.23,
      ),
      (
        _disc(f, _barCentre, _barZone),
        _disc(f, _barCentre, _barZone - 0.3),
        _experience('sportsbar').color,
        0.31,
      ),
      (_rect(f, _terrace), _rect(f, _terrace.deflate(0.34)), restro, 0.39),
      (
        _rect(f, _indoorRestro),
        _rect(f, _indoorRestro.deflate(0.34)),
        restro,
        0.39,
      ),
    ];

    for (final (floor, rim, colour, start) in areas) {
      final t = _phase(start, start + 0.4);
      if (t == 0) continue;
      canvas.drawPath(
        floor,
        Paint()
          ..color = palette
              .zone(colour)
              .withValues(alpha: palette.tintFor(colour) * t),
      );
      canvas.drawPath(
        rim,
        Paint()
          ..color = palette.zoneInk(colour).withValues(alpha: 0.55 * t)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.1,
      );
    }

    // The washroom isn't a zone; a quiet neutral wash marks it apart.
    final t = _phase(0.45, 0.8);
    canvas.drawPath(
      _rect(f, _washroom),
      Paint()..color = palette.amenity.withValues(alpha: 0.16 * t),
    );
  }

  Path _rect(_PlanFrame f, Rect r, [double z = 0]) => Path()
    ..addPolygon([
      f.project(r.left, r.top, z),
      f.project(r.right, r.top, z),
      f.project(r.right, r.bottom, z),
      f.project(r.left, r.bottom, z),
    ], true);

  Path _disc(_PlanFrame f, Offset c, double r, [double z = 0]) =>
      Path()..addPolygon([
        for (var i = 0; i < 40; i++)
          f.project(
            c.dx + r * math.cos(i * 2 * math.pi / 40),
            c.dy + r * math.sin(i * 2 * math.pi / 40),
            z,
          ),
      ], true);

  void _paintFloorLabels(Canvas canvas, _PlanFrame f) {
    final t = _phase(0.6, 1.0);
    if (t == 0) return;

    void zone(
      String id,
      Offset at, {
      String? text,
      double size = 0.95,
      double? maxWidth,
      bool icon = true,
      double angle = 0,
    }) {
      final exp = _experience(id);
      _floorText(
        canvas,
        f,
        centre: at,
        text: text ?? exp.name,
        icon: icon ? exp.iconData : null,
        colour: palette.zoneInk(exp.color).withValues(alpha: t),
        size: size,
        maxWidth: maxWidth,
        angle: angle,
        rise: 1 - t,
      );
    }

    void note(String text, Offset at, {IconData? icon, double size = 0.62}) {
      _floorText(
        canvas,
        f,
        centre: at,
        text: text,
        icon: icon,
        colour: palette.symbolLabel.withValues(alpha: t),
        size: size,
        rise: 1 - t,
      );
    }

    // Names are nudged toward the back of each room: a wall on a room's front
    // edge rises over the floor just behind it and would clip them.
    zone(
      'partyroom',
      const Offset(7.4, 1.45),
      maxWidth: _partyRoom.width - 1.1,
    );
    zone(
      'playroom',
      const Offset(13.25, 1.45),
      maxWidth: _playRoom.width - 1.1,
    );
    zone(
      'rooftop',
      const Offset(12.4, 11.2),
      text: 'Indoor Restro',
      maxWidth: 12,
    );
    // Along the terrace's length, reading up it, so the name fits the strip.
    zone(
      'rooftop',
      const Offset(1.4, 6.6),
      text: 'Outdoor Restro',
      icon: false,
      size: 1.0,
      maxWidth: 11,
      angle: -math.pi / 2,
    );
    // Behind the bar rather than on it, with its icon in the middle of the ring.
    zone('sportsbar', const Offset(7.25, 4.3), icon: false, size: 0.8);
    _floorText(
      canvas,
      f,
      centre: _barCentre,
      text: '',
      icon: _experience('sportsbar').iconData,
      colour: palette
          .zoneInk(_experience('sportsbar').color)
          .withValues(alpha: t),
      size: 0.54,
      rise: 1 - t,
    );

    // On the turf, between the tee end and the bumper.
    _floorText(
      canvas,
      f,
      centre: const Offset(12.25, 4.83),
      text: 'Mini Golf',
      colour: const Color(0xFFF2FAF4).withValues(alpha: 0.95 * t),
      size: 0.46,
      maxWidth: _golfBumperX - _golf.left - 0.5,
      rise: 1 - t,
    );

    note('Stairs', const Offset(15.1, 6.8));
    // Just in front of the counter: further forward, the Indoor Restro's wall
    // rises over it; further left, it runs into the Stairs label.
    note('Counter', const Offset(19.3, 7.72), size: 0.55);
    // Low on the wing floor, left of the shaft: any higher and the shaft's
    // tall left wall rises over the end of the word.
    note('Elevator', const Offset(22.3, 6.62), size: 0.5);
    note('Washroom', Offset(_washroom.center.dx, 0.8), size: 0.58);
    note(
      'Table Tennis',
      const Offset(23.9, 3.05),
      icon: Icons.sports_tennis_rounded,
      size: 0.58,
    );
  }

  /// Text (and an optional icon above it) printed flat on the floor plane.
  void _floorText(
    Canvas canvas,
    _PlanFrame f, {
    required Offset centre,
    required String text,
    required Color colour,
    required double size,
    required double rise,
    IconData? icon,
    double? maxWidth,
    double angle = 0,
  }) {
    // Lay out at a comfortable pixel size, then scale down into plan units.
    const px = 40.0;
    final label = TextPainter(
      text: TextSpan(
        text: text,
        style: GoogleFonts.outfit(
          fontSize: px,
          fontWeight: FontWeight.w800,
          color: colour,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    TextPainter? glyph;
    if (icon != null) {
      glyph = TextPainter(
        text: TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: px * 1.15,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            color: colour,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }

    var unit = size / px;
    if (maxWidth != null && label.width * unit > maxWidth) {
      unit = maxWidth / label.width;
    }
    final hasText = text.isNotEmpty;
    final gap = glyph != null && hasText ? px * 0.12 : 0.0;
    final blockH = (hasText ? label.height : 0) + (glyph?.height ?? 0) + gap;

    canvas.save();
    canvas.transform(f.floorMatrix(rise * 0.35));
    canvas.translate(centre.dx, centre.dy);
    canvas.rotate(angle);
    canvas.scale(unit);
    var y = -blockH / 2;
    if (glyph != null) {
      glyph.paint(canvas, Offset(-glyph.width / 2, y));
      y += glyph.height + gap;
    }
    if (hasText) label.paint(canvas, Offset(-label.width / 2, y));
    canvas.restore();
  }

  // Stairwell ----------------------------------------------------------------

  /// The stair comes up from the floor below: an opening cut into the slab
  /// with steps dropping away to the left. People step out on the right.
  ///
  /// Steps falling away from the camera hide behind the near edge of the
  /// opening once they get steep, so the well is kept shallow and each step
  /// edge is picked out in light.
  void _paintStairwell(Canvas canvas, _PlanFrame f) {
    final t = _phase(0.4, 0.85);
    if (t == 0) return;

    const depth = 0.6;
    const steps = 8;
    const well = _stair;
    final opening = _rect(f, well);
    Path face(List<Offset> pts) => Path()..addPolygon(pts, true);

    canvas.save();
    // Everything below floor level is seen only through the opening; the
    // surrounding slab hides the rest, exactly as a real stairwell would.
    canvas.clipPath(opening);
    if (t < 1) {
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, t));
    }

    canvas.drawPath(opening, Paint()..color = palette.pit);

    canvas.drawPath(
      face([
        f.project(well.left, well.top),
        f.project(well.right, well.top),
        f.project(well.right, well.top, -depth),
        f.project(well.left, well.top, -depth),
      ]),
      Paint()..color = palette.slabShade,
    );
    canvas.drawPath(
      face([
        f.project(well.left, well.top),
        f.project(well.left, well.bottom),
        f.project(well.left, well.bottom, -depth),
        f.project(well.left, well.top, -depth),
      ]),
      Paint()..color = Color.lerp(palette.slabLit, palette.pit, 0.35)!,
    );

    final run = well.width / steps;
    final rise = depth / steps;
    final nosing = Paint()
      ..color = palette.wallTop.withValues(alpha: 0.55)
      ..strokeWidth = 1.1;
    for (var i = steps - 1; i >= 0; i--) {
      final x1 = well.right - i * run;
      final x0 = x1 - run;
      final z = -(i + 1) * rise;
      final shade = i / (steps - 1);
      canvas.drawPath(
        face([
          f.project(x0, well.top, z),
          f.project(x1, well.top, z),
          f.project(x1, well.bottom, z),
          f.project(x0, well.bottom, z),
        ]),
        Paint()..color = Color.lerp(palette.stepTop, palette.pit, shade * 0.8)!,
      );
      canvas.drawLine(
        f.project(x0, well.top, z),
        f.project(x0, well.bottom, z),
        nosing,
      );
    }

    if (t < 1) canvas.restore();
    canvas.restore();

    canvas.drawPath(
      opening,
      Paint()
        ..color = palette.wallTop.withValues(alpha: 0.9 * t)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  // Uprights -----------------------------------------------------------------

  void _paintUprights(Canvas canvas, _PlanFrame f) {
    final rise = _phase(0.3, 0.8);
    final fixtures = _phase(0.45, 0.9);

    final prisms = <_Prism>[
      for (final w in _walls)
        _Prism.wall(
          Offset(w.x0, w.y0),
          Offset(w.x1, w.y1),
          0.16,
          0,
          w.height * rise,
        ),
      ..._barPrisms(fixtures),
      _Prism.box(_counter, 0, 0.45 * fixtures),
      ..._golfPrisms(fixtures),
      ..._elevatorPrisms(fixtures),
    ]..sort((p, q) => _depth(p.base).compareTo(_depth(q.base)));

    for (final p in prisms) {
      if (p.z1 - p.z0 <= 0.01) continue;
      _paintPrism(canvas, f, p);
    }

    if (fixtures > 0) {
      _paintElevatorDoorSeam(canvas, f, fixtures);
      _paintGolfFlag(canvas, f, fixtures);
      // Stair rail, open on the right where people step out.
      _railing(canvas, f, [
        _stair.topRight,
        _stair.topLeft,
        _stair.bottomLeft,
        _stair.bottomRight,
      ], fixtures);
      // Terrace parapet rail along its three open sides.
      _railing(canvas, f, [
        const Offset(_hallLeft, 0),
        _terrace.topLeft,
        _terrace.bottomLeft,
        const Offset(_hallLeft, _planH),
      ], fixtures);
    }
  }

  // Mini golf ----------------------------------------------------------------

  /// Striped turf with the cup cut into it.
  void _paintMiniGolf(Canvas canvas, _PlanFrame f) {
    final t = _phase(0.35, 0.75);
    if (t == 0) return;

    final turf = _rect(f, _golf);
    canvas.save();
    canvas.clipPath(turf);
    canvas.drawPath(turf, Paint()..color = palette.turf.withValues(alpha: t));
    // Mown stripes across the course.
    final stripe = Paint()..color = palette.turfStripe.withValues(alpha: t);
    for (var x = _golf.left; x < _golf.right; x += 0.7) {
      canvas.drawPath(
        _rect(f, Rect.fromLTRB(x, _golf.top, x + 0.35, _golf.bottom)),
        stripe,
      );
    }
    canvas.restore();

    // The cup.
    canvas.drawPath(
      _disc(f, _golfHole, 0.13),
      Paint()..color = Colors.black.withValues(alpha: 0.75 * t),
    );
  }

  /// A low border around the course and a bumper wall to play around.
  List<_Prism> _golfPrisms(double t) {
    const kerb = 0.14, w = 0.08;
    final h = kerb * t;
    final g = _golf;
    return [
      _Prism.wall(g.topLeft, g.topRight, w, 0, h),
      _Prism.wall(g.topRight, g.bottomRight, w, 0, h),
      _Prism.wall(g.bottomRight, g.bottomLeft, w, 0, h),
      _Prism.wall(g.bottomLeft, g.topLeft, w, 0, h),
      // Leaves a gap at the front for the ball to get through.
      _Prism.wall(
        const Offset(_golfBumperX, 4.2),
        const Offset(_golfBumperX, 4.95),
        0.1,
        0,
        h,
      ),
    ];
  }

  /// The pin in the cup, with a flag in the brand red.
  void _paintGolfFlag(Canvas canvas, _PlanFrame f, double t) {
    const top = 0.95;
    final base = f.project(_golfHole.dx, _golfHole.dy);
    final tip = f.project(_golfHole.dx, _golfHole.dy, top * t);
    canvas.drawLine(
      base,
      tip,
      Paint()
        ..color = palette.rail.withValues(alpha: t)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    if (t < 0.6) return;
    final flag = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        f.project(_golfHole.dx + 0.42, _golfHole.dy, top * t - 0.12).dx,
        f.project(_golfHole.dx + 0.42, _golfHole.dy, top * t - 0.12).dy,
      )
      ..lineTo(
        f.project(_golfHole.dx, _golfHole.dy, top * t - 0.26).dx,
        f.project(_golfHole.dx, _golfHole.dy, top * t - 0.26).dy,
      )
      ..close();
    canvas.drawPath(flag, Paint()..color = palette.flag.withValues(alpha: t));
  }

  /// The round bar counter, built from short straight segments so it sorts
  /// against the walls like everything else.
  List<_Prism> _barPrisms(double t) {
    const segments = 28;
    final top = palette.zone(_experience('sportsbar').color);
    Offset at(int i) =>
        _barCentre +
        Offset(
              math.cos(i * 2 * math.pi / segments),
              math.sin(i * 2 * math.pi / segments),
            ) *
            _barRadius;
    return [
      for (var i = 0; i < segments; i++)
        _Prism.wall(
          at(i),
          at(i + 1),
          _barDepth,
          0,
          _barDepth * t,
          colour: Color.lerp(top, palette.wallTop, palette.isDark ? 0.35 : 0.2),
        ),
    ];
  }

  // The elevator doors face the table tennis area. That face points away
  // from the camera, so the shaft is drawn as a cutaway like the building:
  // the far walls stand full height and carry the doors, the near side is cut
  // low so you look in and see them. Its back is the building's outer wall.
  static const double _shaftH = 1.25;
  static const double _doorH = 0.9;
  static const double _doorFrom = 24.55;
  static const double _doorTo = 25.15;

  List<_Prism> _elevatorPrisms(double t) {
    const w = 0.1;
    const e = _elevator;
    final tall = _shaftH * t;
    final door = _doorH * t;
    const doorA = Offset(_doorFrom, _elevatorTop);
    const doorB = Offset(_doorTo, _elevatorTop);
    return [
      _Prism.wall(e.topLeft, e.bottomLeft, w, 0, tall),
      _Prism.wall(e.topLeft, doorA, w, 0, tall),
      _Prism.wall(doorB, e.topRight, w, 0, tall),
      _Prism.wall(doorA, doorB, w, door, tall),
      _Prism.wall(
        doorA,
        doorB,
        w * 0.6,
        0,
        door,
        colour: Color.lerp(palette.wallShade, palette.pit, 0.35),
      ),
      _Prism.wall(e.topRight, e.bottomRight, w, 0, _low * t),
    ];
  }

  /// The seam between the two door leaves, on the face you see from inside.
  void _paintElevatorDoorSeam(Canvas canvas, _PlanFrame f, double t) {
    const y = _elevatorTop + 0.05;
    const mid = (_doorFrom + _doorTo) / 2;
    canvas.drawLine(
      f.project(mid, y, 0),
      f.project(mid, y, _doorH * t),
      Paint()
        ..color = palette.wallTop.withValues(alpha: 0.85 * t)
        ..strokeWidth = 1.1,
    );
  }

  /// A guard rail along [corners], with posts every ~0.45 units.
  void _railing(Canvas canvas, _PlanFrame f, List<Offset> corners, double t) {
    const h = 0.4;
    final rail = Paint()
      ..color = palette.rail.withValues(alpha: t)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final post = Paint()
      ..color = palette.rail.withValues(alpha: 0.7 * t)
      ..strokeWidth = 1;

    for (var side = 0; side + 1 < corners.length; side++) {
      final a = corners[side], b = corners[side + 1];
      final n = math.max(2, ((b - a).distance / 0.45).round());
      for (var i = 0; i <= n; i++) {
        final p = Offset.lerp(a, b, i / n)!;
        canvas.drawLine(f.project(p.dx, p.dy), f.project(p.dx, p.dy, h), post);
      }
    }
    final first = f.project(corners.first.dx, corners.first.dy, h);
    final top = Path()..moveTo(first.dx, first.dy);
    for (final c in corners.skip(1)) {
      final q = f.project(c.dx, c.dy, h);
      top.lineTo(q.dx, q.dy);
    }
    canvas.drawPath(top, rail);
  }

  double _depth(List<Offset> pts) =>
      pts.fold<double>(0, (s, p) => s + p.dx + p.dy) / pts.length;

  void _paintPrism(Canvas canvas, _PlanFrame f, _Prism p) {
    final base = p.base;
    for (var i = 0; i < base.length; i++) {
      final a = base[i], b = base[(i + 1) % base.length];
      final e = b - a;
      if (e.distance == 0) continue;
      final normal = Offset(e.dy, -e.dx) / e.distance;
      if (normal.dx * _camera.dx + normal.dy * _camera.dy <= 0.001) continue;
      final shade = ((normal.dx * _light.dx + normal.dy * _light.dy) + 1) / 2;
      final tone = Color.lerp(palette.wallShade, palette.wallLit, shade)!;
      canvas.drawPath(
        Path()..addPolygon([
          f.project(a.dx, a.dy, p.z0),
          f.project(b.dx, b.dy, p.z0),
          f.project(b.dx, b.dy, p.z1),
          f.project(a.dx, a.dy, p.z1),
        ], true),
        Paint()
          ..color = p.colour == null ? tone : Color.lerp(p.colour, tone, 0.45)!,
      );
    }
    canvas.drawPath(
      Path()
        ..addPolygon([for (final q in base) f.project(q.dx, q.dy, p.z1)], true),
      Paint()..color = p.colour ?? palette.wallTop,
    );
  }

  @override
  bool shouldRepaint(_FloorPlanPainter old) =>
      old.progress != progress || old.palette != palette;
}
