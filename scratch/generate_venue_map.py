"""Bake the Arcade Hub neighbourhood into Dart geometry for the isometric venue map.

Pulls building footprints and roads from OpenStreetMap around the venue
coordinate, rotates them so the local street grid sits square to the camera,
crops a diorama tile, and writes lib/features/home/venue_map/venue_map_data.dart.

    python scratch/generate_venue_map.py            # fetch live from Overpass
    python scratch/generate_venue_map.py osm.json   # reuse a cached response

Heights are stylized. Only a handful of buildings here carry building:levels
in OSM, so untagged ones get a deterministic height from footprint size.
"""
import json
import math
import sys
import urllib.parse
import urllib.request
from pathlib import Path

LAT, LON = 28.2210429, 83.9869353

# Building edges in this block run ~10.5 degrees off east (length-weighted
# histogram of footprint edges within 80 m). Rotating by that squares the
# grid to the isometric axes, so walls read as clean planes.
GRID_ROTATION_DEG = 10.5

# Tile placement in rotated metres. Shifted east of the venue: OSM has almost
# no footprints mapped to the west, while the shop row across New Road is
# dense, so this spends the tile on real geometry instead of empty ground.
TILE_CENTER = (8.0, -4.0)
# Widened by ~35%: the tile now reaches the next streets out, so there is
# something to find when the map is zoomed out. The app opens zoomed in on
# the venue, so the extra ground is there without crowding the default view.
TILE_HALF = 101.0

VENUE_WAY_ID = 403996446  # OSM "B M Complex", the footprint containing LAT/LON
# Arcade Hub is on the 4th floor. Nepal counts floors British-style (ground
# floor, then 1st), so that is the fifth storey up. The building is drawn six
# storeys tall so the lit floor reads as a floor, not as the roof.
VENUE_FLOOR = 4
VENUE_LEVELS = 6
LEVEL_M = 3.2

# Buildings people navigate by, drawn taller than their footprint alone would
# suggest so they read as the landmarks they are. Bhat-Bhateni is a multi-storey
# store that everyone in Pokhara gives directions by; OSM tags only one of its
# two footprints with levels.
HEIGHT_M = {240404776: 17.0, 415725853: 17.0, 417496459: 10.0}

# Footprints OSM has wrong for our purposes, in tile metres. Mantra Thakali is
# mapped as a restaurant, and the way is its plot, not its building: 65 by 48
# metres, which drew a slab across the parking and out over the road. Replaced
# with the building as it stands west of the parking. Local knowledge, and a
# measurement worth redoing from a satellite view.
FOOTPRINT_OVERRIDES = {
    417496459: [(-57.0, -1.0), (-38.5, -1.0), (-38.5, 17.0), (-57.0, 17.0)],
}

# Ground features the venue has but OSM does not. Local knowledge, not map
# data: the parking apron between the Arcade Hub building and Mantra Thakali.
# Polygons are in tile metres, same grid as everything else.
GROUND_AREAS = [
    ("parking", [(-37.0, 1.5), (-29.0, 1.5), (-29.0, 18.5), (-37.0, 18.5)]),
]

ROAD_WIDTH = {"primary": 8.0, "secondary": 7.0, "tertiary": 6.0,
              "residential": 5.0, "service": 3.5}
ROAD_KIND = {"primary": 0, "secondary": 1, "tertiary": 1,
             "residential": 2, "service": 3}
GROUND_KIND = {"parking": 0}

# How far apart two labels must sit once projected, in screen metres. Below
# this they overlap and the map turns into a wall of text.
LABEL_GAP = 26.0

# How far a name must stay from the venue pin card, and how high that card
# floats above the roof, both in screen metres.
PIN_CLEAR = 26.0
PIN_RISE = 28.0
K = math.sqrt(0.5)

# (display name, OSM way ids, anchor in tile metres, snap to the centreline,
# text alignment: -1 ends at the anchor, 0 centred, 1 starts at the anchor).
# New Road is a divided road, so its label sits on the median between the two
# carriageways rather than snapping onto one of them. Pragati Marg runs close
# past the venue, so its label reads away from the building.
ROAD_LABELS = [
    ("New Road", (24622459, 1390448739), (17.0, 38.0), False, 0),
    ("Pragati Marg", (108166112,), (-52.0, 18.0), True, 1),
]
# (label, OSM way id, alignment: -1 left of the dot, 0 under it, 1 right of it).
# Places people give directions by. Bhat-Bhateni sits at the back of the tile
# where the venue pin rises, so it reads leftward. The hospital is on the right
# edge of the tile, where text reading outward would run off the card.
LANDMARKS = [
    ("Bhat-Bhateni", 240404776, -1),
    ("Mantra Thakali", 417496459, -1),
    ("Kaski Model Hospital", 449297307, 0),
    ("City Square", 420495865, 1),
    ("Cherisma Emporium", 415725856, 0),
    ("Nawadurga Furniture", 415725851, 0),
    ("Bro Bakery", 420495828, 1),
    ("Juju Wears", 420481258, 0),
]

OUT = Path(__file__).resolve().parents[1] / "lib/features/home/venue_map/venue_map_data.dart"


def fetch(cache):
    if cache:
        return json.loads(Path(cache).read_text(encoding="utf-8"))
    q = f"""[out:json][timeout:60];(
      way(around:290,{LAT},{LON})["building"];
      way(around:390,{LAT},{LON})["highway"];
      way(around:350,{LAT},{LON})["landuse"];
      way(around:350,{LAT},{LON})["amenity"];);out body geom;"""
    req = urllib.request.Request(
        "https://overpass-api.de/api/interpreter",
        data=urllib.parse.urlencode({"data": q}).encode(),
        headers={"User-Agent": "arcadehub-venue-map"})
    return json.load(urllib.request.urlopen(req, timeout=90))


MX = 111320 * math.cos(math.radians(LAT))
MY = 110574
_R = math.radians(GRID_ROTATION_DEG)


def to_grid(p):
    """lat/lon -> metres east/north of the venue pin, rotated onto the grid, tile-centred."""
    x, y = (p["lon"] - LON) * MX, (p["lat"] - LAT) * MY
    gx = x * math.cos(_R) - y * math.sin(_R)
    gy = x * math.sin(_R) + y * math.cos(_R)
    return gx - TILE_CENTER[0], gy - TILE_CENTER[1]


def signed_area(poly):
    return sum(poly[i - 1][0] * poly[i][1] - poly[i][0] * poly[i - 1][1]
               for i in range(len(poly))) / 2


def inside_tile(p, margin=1.5):
    return abs(p[0]) <= TILE_HALF - margin and abs(p[1]) <= TILE_HALF - margin


def point_in_poly(p, poly):
    x, y = p
    inside = False
    n = len(poly)
    for i in range(n):
        x1, y1 = poly[i]
        x2, y2 = poly[(i + 1) % n]
        if (y1 > y) != (y2 > y):
            if x < (x2 - x1) * (y - y1) / ((y2 - y1) or 1e-9) + x1:
                inside = not inside
    return inside


def _centroid_xy(poly):
    return (sum(p[0] for p in poly) / len(poly),
            sum(p[1] for p in poly) / len(poly))


def clip_polygon(poly, h=TILE_HALF):
    """Sutherland-Hodgman against the square tile, so edge buildings are sliced
    like a cut diorama instead of vanishing."""
    def clip(points, inside, cross):
        out = []
        for i, cur in enumerate(points):
            prev = points[i - 1]
            if inside(cur):
                if not inside(prev):
                    out.append(cross(prev, cur))
                out.append(cur)
            elif inside(prev):
                out.append(cross(prev, cur))
        return out

    def at_x(xv):
        return lambda a, b: (xv, a[1] + (b[1] - a[1]) * (xv - a[0]) / (b[0] - a[0]))

    def at_y(yv):
        return lambda a, b: (a[0] + (b[0] - a[0]) * (yv - a[1]) / (b[1] - a[1]), yv)

    for inside, cross in ((lambda p: p[0] <= h, at_x(h)), (lambda p: p[0] >= -h, at_x(-h)),
                          (lambda p: p[1] <= h, at_y(h)), (lambda p: p[1] >= -h, at_y(-h))):
        poly = clip(poly, inside, cross)
        if not poly:
            break
    return poly


def clip_segment(a, b, h=TILE_HALF):
    """Liang-Barsky against the square tile. Returns the clipped segment or None."""
    t0, t1 = 0.0, 1.0
    dx, dy = b[0] - a[0], b[1] - a[1]
    for p, q in ((-dx, a[0] + h), (dx, h - a[0]), (-dy, a[1] + h), (dy, h - a[1])):
        if p == 0:
            if q < 0:
                return None
            continue
        r = q / p
        if p < 0:
            t0 = max(t0, r)
        else:
            t1 = min(t1, r)
        if t0 > t1:
            return None
    return ((a[0] + t0 * dx, a[1] + t0 * dy), (a[0] + t1 * dx, a[1] + t1 * dy))


def stylized_levels(way_id, tags, area):
    if way_id in HEIGHT_M:
        return HEIGHT_M[way_id] / LEVEL_M
    if tags.get("building:levels", "").isdigit():
        return max(1, min(8, int(tags["building:levels"])))
    levels = 3
    if area > 180:
        levels += 1
    if area > 400:
        levels += 1
    if area < 70:
        levels -= 1
    # Break up the uniform skyline without randomness, so regenerating is stable.
    if way_id % 5 == 0:
        levels += 1
    if way_id % 7 == 0:
        levels -= 1
    return max(1, min(6, levels))


def flat(points):
    return ", ".join(f"{v:.1f}" for p in points for v in p)


def main():
    data = fetch(sys.argv[1] if len(sys.argv) > 1 else None)
    ways = [e for e in data["elements"] if e["type"] == "way" and "geometry" in e]

    venue = None
    blocks = []
    roof_height = {}
    named = {way_id for _, way_id, _ in LANDMARKS}
    for w in ways:
        tags = w.get("tags", {})
        # A few places people navigate by are mapped as the business rather
        # than the building — Mantra Thakali is tagged a restaurant with no
        # building tag — so they were named on the map but stood on empty
        # ground. Anything we label gets massed.
        if "building" not in tags and w["id"] not in named:
            continue
        poly = FOOTPRINT_OVERRIDES.get(w["id"]) or [
            to_grid(p) for p in w["geometry"]
        ]
        poly = list(poly)
        if poly[0] == poly[-1]:
            poly = poly[:-1]
        poly = clip_polygon(poly)
        if len(poly) < 3:
            continue
        if signed_area(poly) < 0:
            poly.reverse()  # counter-clockwise, so edge normals point outward
        area = signed_area(poly)
        if w["id"] == VENUE_WAY_ID:
            venue = poly
            continue
        if area < 12:
            continue  # sheds and slivers read as noise at this scale
        height = stylized_levels(w["id"], tags, area) * LEVEL_M
        blocks.append((poly, height))
        roof_height[w["id"]] = height

    if venue is None:
        sys.exit("venue footprint not found inside the tile")

    roads = []
    label_lines = {}
    for w in ways:
        hw = w.get("tags", {}).get("highway")
        if hw not in ROAD_WIDTH:
            continue
        pts = [to_grid(p) for p in w["geometry"]]
        run = []
        for a, b in zip(pts, pts[1:]):
            seg = clip_segment(a, b)
            if seg is None:
                if len(run) > 1:
                    roads.append((ROAD_KIND[hw], ROAD_WIDTH[hw], run))
                run = []
                continue
            if not run:
                run = [seg[0]]
            run.append(seg[1])
            # Sample along the segment so labels can land mid-block, not only
            # at the sparse OSM vertices.
            n = max(1, int(math.hypot(seg[1][0] - seg[0][0], seg[1][1] - seg[0][1])))
            label_lines.setdefault(w["id"], []).extend(
                (seg[0][0] + (seg[1][0] - seg[0][0]) * i / n,
                 seg[0][1] + (seg[1][1] - seg[0][1]) * i / n) for i in range(n + 1))
        if len(run) > 1:
            roads.append((ROAD_KIND[hw], ROAD_WIDTH[hw], run))

    labels = []
    for name, ids, anchor, snap, align in ROAD_LABELS:
        cands = [p for i in ids for p in label_lines.get(i, [])]
        if not cands:
            continue  # road not on the tile
        if snap:
            anchor = min(cands, key=lambda p: math.hypot(p[0] - anchor[0], p[1] - anchor[1]))
        labels.append((name, anchor, align))

    # Labels crowd each other in the projection, not on the plan: the
    # isometric squashes north-south by half, so two names 30 m apart can
    # print on top of each other. Spacing is judged where they are read.
    def on_screen(p):
        return ((p[1] - p[0]) * K, (p[0] + p[1]) * K * 0.5)

    def too_close(p, taken):
        sx, sy = on_screen(p)
        return any(math.hypot(sx - tx, sy - ty) < LABEL_GAP for tx, ty in taken)

    # The venue's own pin card floats above the roof and covers whatever is
    # behind it, so names keep well clear of that patch of screen.
    vc = _centroid_xy(venue)
    pin = on_screen(vc)
    pin = (pin[0], pin[1] - PIN_RISE)

    def away_from_pin(poly, anchor):
        """The anchor, or the point on the building furthest from the pin if
        the anchor sits under it."""
        ax, ay = on_screen(anchor)
        if math.hypot(ax - pin[0], ay - pin[1]) >= PIN_CLEAR:
            return anchor
        # Sample inside the footprint rather than walking its corners: a
        # corner anchor puts the dot on the boundary, where it reads as
        # belonging to whichever building is next door.
        xs = [q[0] for q in poly]
        ys = [q[1] for q in poly]
        best, far = anchor, -1.0
        step = 2.0
        y = min(ys) + step
        while y < max(ys):
            x = min(xs) + step
            while x < max(xs):
                q = (x, y)
                if point_in_poly(q, poly) and inside_tile(q, margin=8):
                    qx, qy = on_screen(q)
                    d = math.hypot(qx - pin[0], qy - pin[1])
                    if d > far:
                        best, far = q, d
                x += step
            y += step
        return best

    # Only landmarks crowd each other. Road names sit along their road in a
    # different style, so one passing near a landmark still reads.
    taken = []
    landmarks = []
    for name, way_id, align in LANDMARKS:
        for w in ways:
            if w["id"] == way_id:
                pts = [to_grid(p) for p in w["geometry"]]
                # Big shops run off the tile. Anchoring on the raw centroid
                # floats the name out over the middle of the map, away from
                # the part of the building you can see — and in Bhat-Bhateni's
                # case, straight under the venue pin. Use the piece that is
                # on the tile.
                shown = clip_polygon(pts) or pts
                c = (sum(p[0] for p in shown) / len(shown),
                     sum(p[1] for p in shown) / len(shown))
                c = away_from_pin(shown, c)
                if inside_tile(c, margin=6) and not too_close(c, taken):
                    landmarks.append((name, c, align, roof_height.get(w["id"], 0.0)))
                    taken.append(on_screen(c))

    ground_areas = [
        (GROUND_KIND[kind], poly)
        for kind, poly in GROUND_AREAS
        if all(inside_tile(pt, margin=0) for pt in poly)
    ]

    lines = [
        "// GENERATED by scratch/generate_venue_map.py. Do not edit by hand.",
        "// Map data (c) OpenStreetMap contributors, available under the ODbL.",
        "//",
        "// Units are metres on a grid rotated to the local street layout and",
        "// centred on the tile. Building heights are stylized, not surveyed.",
        "",
        "part of 'venue_map.dart';",
        "",
        f"const double _kTileHalf = {TILE_HALF:.1f};",
        f"const double _kGridRotationDeg = {GRID_ROTATION_DEG};",
        "",
        f"const List<double> _kVenueFootprint = [{flat(venue)}];",
        f"const double _kVenueHeight = {VENUE_LEVELS * LEVEL_M:.1f};",
        f"const int _kVenueLevels = {VENUE_LEVELS};",
        f"const int _kVenueFloor = {VENUE_FLOOR}; // British numbering: ground floor is 0",
        "",
        "const List<_Block> _kBlocks = [",
        *[f"  _Block({h:.1f}, [{flat(p)}])," for p, h in blocks],
        "];",
        "",
        "const List<_Road> _kRoads = [",
        *[f"  _Road({k}, {wd:.1f}, [{flat(p)}])," for k, wd, p in roads],
        "];",
        "",
        "const List<_Label> _kRoadLabels = [",
        *[f"  _Label('{n}', {p[0]:.1f}, {p[1]:.1f}, {a})," for n, p, a in labels],
        "];",
        "",
        "// Not from OpenStreetMap: ground the venue told us about.",
        "const List<_Ground> _kGroundAreas = [",
        *[f"  _Ground({k}, [{flat(p)}])," for k, p in ground_areas],
        "];",
        "",
        "const List<_Label> _kLandmarks = [",
        *[f"  _Label('{n}', {p[0]:.1f}, {p[1]:.1f}, {a}, {z:.1f})," for n, p, a, z in landmarks],
        "];",
        "",
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT.name}: {len(blocks)} blocks, {len(roads)} road runs, "
          f"{len(labels)} road labels, {len(landmarks)} landmarks")


if __name__ == "__main__":
    main()
