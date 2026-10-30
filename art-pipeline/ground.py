#!/usr/bin/env python3
"""The town ground plan (D172): a top-down plan of the board with a rectangle for every building, to place the 3D
models on. Reads the river, bridges, roads and landmark spots from godot/town/town.gd, so it matches the game.

  python3 art-pipeline/ground.py      writes art-pipeline/out/ground.png and out/ground.json

ground.json lists every lot in metres, town coordinates (x east, z south, origin at the board centre, 12 m per board
percent): id, x, z, width (frontage), depth, angle in degrees (0 means the front faces south).
"""
import json, math, random, re
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
SRC = (ROOT / 'godot' / 'town' / 'town.gd').read_text(encoding='utf-8')
FONT = ROOT / 'godot' / 'assets' / 'fonts' / 'Amarante-Regular.ttf'
SCALE = 12.0            # metres per board percent, as town.gd
PX = 2.5                # image pixels per metre: the board is 1200 m, the image 3000 px
STREET = 7.0            # lane between house blocks, metres
# Landmark footprints in metres (frontage, depth), as the game draws them.
LANDMARK = {'cemetery': (56, 42), 'square': (52, 40), 'slaughter': (54, 40), 'church': (50, 40), 'first': (56, 44),
            'morgue': (30, 24), 'market': (50, 34), 'hospital': (54, 42), 'academy': (54, 42), 'docks': (60, 40),
            'alley': (28, 28), 'odeon': (48, 38)}
# Filler house kinds: frontage range, depth, weight, colour on the plan.
HOUSES = {'house-1': ((8, 9), 12, 5, '#9aa3ad'), 'house-2': ((8, 10), 11, 3, '#8a6a4f'),
          'house-3': ((14, 16), 14, 3, '#c9c0a8'), 'house-4': ((11, 12), 12, 1, '#6c7a8c'),
          'house-5': ((8, 9), 12, 2, '#a99a7a'), 'house-6': ((9, 11), 10, 3, '#7a4f3a'),
          'house-7': ((7, 8), 13, 2, '#b8b0a0'), 'house-8': ((12, 14), 11, 1, '#a8874a')}

V2 = r'Vector2\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)'


def block(name):
    i = SRC.index(f'const {name} :=')
    j, depth = SRC.index('[', i), 0
    for k in range(j, len(SRC)):
        depth += {'[': 1, ']': -1}.get(SRC[k], 0)
        if depth == 0:
            return SRC[j:k + 1]


def pts(s):
    return [((float(a) - 50) * SCALE, (float(b) - 50) * SCALE) for a, b in re.findall(V2, s)]


water = [pts(m) for m in re.findall(r'\[(Vector2.*?)\]', block('WATER'), re.S)]
bridges = [(pts(m)[0], pts(m)[1], float(w)) for m, w in re.findall(r'\[(Vector2\(.*?\), Vector2\(.*?\)), ([\d.]+)\]', block('BRIDGES'))]
roads = [(pts(m), float(w)) for m, w in re.findall(r'\[\[(.*?)\], ([\d.]+)\]', block('ROADS'), re.S)]
places = {}
for pid, name, pos, ang in re.findall(r'"(\w+)": \{"name": "([^"]+)".*?"pos": (Vector2\([^)]*\)), "ang": ([^,]+),', SRC):
    a = eval(ang.replace('PI', str(math.pi)))  # noqa: S307  constants like -PI / 2 + 0.3
    places[pid] = (name, pts(pos)[0], a)


def inside(p, poly):
    x, y, c = p[0], p[1], False
    for i in range(len(poly)):
        (x1, y1), (x2, y2) = poly[i], poly[i - 1]
        if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
            c = not c
    return c


def seg_dist(p, a, b):
    ax, ay, bx, by = *a, *b
    dx, dy = bx - ax, by - ay
    t = max(0, min(1, ((p[0] - ax) * dx + (p[1] - ay) * dy) / (dx * dx + dy * dy or 1)))
    return math.hypot(p[0] - ax - t * dx, p[1] - ay - t * dy)


def corners(x, z, w, d, ang):
    """A lot's corners. Angle 0: frontage along x, front facing +z (south)."""
    c, s = math.cos(ang), math.sin(ang)
    return [(x + u * c + v * s, z - u * s + v * c) for u, v in ((-w / 2, -d / 2), (w / 2, -d / 2), (w / 2, d / 2), (-w / 2, d / 2))]


def blocked(poly, margin):
    cx = sum(p[0] for p in poly) / 4
    cz = sum(p[1] for p in poly) / 4
    probe = poly + [(cx, cz)]
    if any(abs(p[0]) > 600 or abs(p[1]) > 600 for p in probe):
        return True
    if any(inside(p, w) for w in water for p in probe):
        return True
    for line, width in roads:
        for a, b in zip(line, line[1:]):
            if any(seg_dist(p, a, b) < width / 2 + margin for p in probe):
                return True
    for a, b, width in bridges:
        if any(seg_dist(p, a, b) < width / 2 + margin for p in probe):
            return True
    for pid, (_, (lx, lz), ang) in places.items():
        w, d = LANDMARK[pid]
        if math.hypot(cx - lx, cz - lz) < math.hypot(w, d) / 2 + 12:
            return True
    return False


def main():
    rng = random.Random(1819)
    kinds = list(HOUSES)
    weights = [HOUSES[k][2] for k in kinds]
    lots = []
    for pid, (name, (x, z), ang) in places.items():
        w, d = LANDMARK[pid]
        lots.append({'id': pid, 'name': name, 'x': round(x, 1), 'z': round(z, 1), 'width': w, 'depth': d, 'angle': round(math.degrees(ang), 1)})
    # Blocks: two rows of houses back to back, one facing north and one south, lanes between blocks.
    row_depth = 14.0
    z = -600.0
    while z < 600:
        for side in (0, 1):
            zc = z + row_depth / 2 + side * row_depth
            x = -600.0 + rng.uniform(0, 10)
            run = 0
            while x < 600:
                k = rng.choices(kinds, weights)[0]
                (fmin, fmax), depth, _, _ = HOUSES[k]
                w = rng.randint(fmin, fmax)
                ang = 0.0 if side else math.pi   # the south row faces south, the north row north
                zz = zc + (row_depth - depth) / 2 * (1 if side else -1)   # each house sits on its street edge
                poly = corners(x + w / 2, zz, w, depth, ang)
                if not blocked(poly, 1.5):
                    lots.append({'id': k, 'x': round(x + w / 2, 1), 'z': round(zz, 1), 'width': w, 'depth': depth,
                                 'angle': round(math.degrees(ang), 1)})
                x += w
                run += 1
                if run >= rng.randint(6, 10):   # a cross lane every few houses
                    x += STREET
                    run = 0
        z += 2 * row_depth + STREET
    draw_plan(lots)
    (HERE / 'out').mkdir(exist_ok=True)
    (HERE / 'out' / 'ground.json').write_text(json.dumps({'units': 'metres', 'lots': lots}, indent=1, ensure_ascii=False), encoding='utf-8')
    counts = {k: sum(1 for l in lots if l['id'] == k) for k in kinds}
    print('ground plan:', len(places), 'landmarks,', sum(counts.values()), 'houses', counts)


def draw_plan(lots):
    size = int(1200 * PX)
    legend = 520
    img = Image.new('RGB', (size + legend, size), '#2b2f36')
    dr = ImageDraw.Draw(img)

    def px(p):
        return ((p[0] + 600) * PX, (p[1] + 600) * PX)

    for gx in range(-600, 601, 100):   # 100 m grid
        dr.line([px((gx, -600)), px((gx, 600))], fill='#33383f', width=1)
        dr.line([px((-600, gx)), px((600, gx))], fill='#33383f', width=1)
    for w in water:
        dr.polygon([px(p) for p in w], fill='#3d5a73')
    for line, width in roads:
        dr.line([px(p) for p in line], fill='#575d66', width=int(width * PX), joint='curve')
    for a, b, width in bridges:
        dr.line([px(a), px(b)], fill='#6f675a', width=int(width * PX))
    f_small, f_big, f_head = (ImageFont.truetype(str(FONT), s) for s in (14, 30, 40))
    places_by_id = {}
    for l in lots:
        poly = corners(l['x'], l['z'], l['width'], l['depth'], math.radians(l['angle']))
        if l['id'] in LANDMARK:
            places_by_id[l['id']] = (l, poly)
            continue
        col = HOUSES[l['id']][3]
        dr.polygon([px(p) for p in poly], fill=col, outline='#1c1e22')
        a = math.radians(l['angle'])   # front edge marked with a dark stripe
        f1, f2 = poly[2], poly[3]
        dr.line([px(f1), px(f2)], fill='#1c1e22', width=2)
        cx, cy = px((l['x'], l['z']))
        dr.text((cx, cy), l['id'][-1], fill='#1c1e22', font=f_small, anchor='mm')
    for pid, (l, poly) in places_by_id.items():
        dr.polygon([px(p) for p in poly], fill='#e8e2d2', outline='#000000', width=3)
        dr.line([px(poly[2]), px(poly[3])], fill='#c0392b', width=6)   # front side in red
        cx, cy = px((l['x'], l['z']))
        dr.text((cx, cy - 12), pid, fill='#111111', font=f_small, anchor='mm')
        dr.text((cx, cy + 6), f'{l["width"]} x {l["depth"]} m', fill='#444444', font=f_small, anchor='mm')
        dr.text((cx, cy + l['depth'] * PX / 2 + 34), l['name'], fill='#f0e6d0', font=f_big, anchor='mm', stroke_width=3, stroke_fill='#000000')
    x0 = size + 30
    dr.text((x0, 30), 'Second Spark: ground plan', fill='#f0e6d0', font=f_head)
    y = 100
    for line in ['Seen from above, north at the top.', 'Grid squares are 100 m.', 'The board is 1200 x 1200 m.',
                 'Red edge: the landmark front.', 'Dark edge: the house front.', '']:
        dr.text((x0, y), line, fill='#d0c8b8', font=f_small.font_variant(size=22))
        y += 34
    dr.text((x0, y), 'Landmarks (frontage x depth)', fill='#f0e6d0', font=f_big)
    y += 46
    for pid, (l, _) in places_by_id.items():
        dr.text((x0, y), f'{pid}: {l["width"]} x {l["depth"]} m', fill='#d0c8b8', font=f_small.font_variant(size=22))
        y += 30
    y += 20
    dr.text((x0, y), 'Filler houses', fill='#f0e6d0', font=f_big)
    y += 46
    for k, ((fmin, fmax), depth, _, col) in HOUSES.items():
        dr.rectangle((x0, y, x0 + 34, y + 26), fill=col, outline='#1c1e22')
        dr.text((x0 + 17, y + 13), k[-1], fill='#1c1e22', font=f_small, anchor='mm')
        dr.text((x0 + 48, y), f'{k}: {fmin} to {fmax} x {depth} m', fill='#d0c8b8', font=f_small.font_variant(size=22))
        y += 38
    img.save(HERE / 'out' / 'ground.png')
    print('written', HERE / 'out' / 'ground.png')


if __name__ == '__main__':
    main()
