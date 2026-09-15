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
TILE_HALF = 58.0

VENUE_WAY_ID = 403996446  # OSM "B M Complex", the footprint containing LAT/LON
# Arcade Hub is on the 4th floor. Nepal counts floors British-style (ground
# floor, then 1st), so that is the fifth storey up. The building is drawn six
# storeys tall so the lit floor reads as a floor, not as the roof.
VENUE_FLOOR = 4
VENUE_LEVELS = 6
LEVEL_M = 3.2

ROAD_WIDTH = {"primary": 8.0, "secondary": 7.0, "tertiary": 6.0,
              "residential": 5.0, "service": 3.5}
ROAD_KIND = {"primary": 0, "secondary": 1, "tertiary": 1,
             "residential": 2, "service": 3}

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
    ("Kaski Model Hospital", 449297307, 0),
    ("Sanima Bank", 417799593, 0),
]

OUT = Path(__file__).resolve().parents[1] / "lib/features/home/venue_map/venue_map_data.dart"


def fetch(cache):
    if cache:
        return json.loads(Path(cache).read_text(encoding="utf-8"))
    q = f"""[out:json][timeout:60];(
      way(around:160,{LAT},{LON})["building"];
      way(around:220,{LAT},{LON})["highway"];
      way(around:200,{LAT},{LON})["landuse"];
      way(around:200,{LAT},{LON})["amenity"];);out body geom;"""
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
    for w in ways:
        tags = w.get("tags", {})
        if "building" not in tags:
            continue
        poly = [to_grid(p) for p in w["geometry"]]
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
        blocks.append((poly, stylized_levels(w["id"], tags, area) * LEVEL_M))

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

    landmarks = []
    for name, way_id, align in LANDMARKS:
        for w in ways:
            if w["id"] == way_id:
                pts = [to_grid(p) for p in w["geometry"]]
                c = (sum(p[0] for p in pts) / len(pts), sum(p[1] for p in pts) / len(pts))
                if inside_tile(c, margin=6):
                    landmarks.append((name, c, align))

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
        "const List<_Label> _kLandmarks = [",
        *[f"  _Label('{n}', {p[0]:.1f}, {p[1]:.1f}, {a})," for n, p, a in landmarks],
        "];",
        "",
    ]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"wrote {OUT.name}: {len(blocks)} blocks, {len(roads)} road runs, "
          f"{len(labels)} road labels, {len(landmarks)} landmarks")


if __name__ == "__main__":
    main()
