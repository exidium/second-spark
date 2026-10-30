"""Houses and trees for the cabin map (D180): where they can stand on the drawn map, written to
godot/assets/cabin/village.json as map percent (x, y), facing in radians, and a size factor.

python3 art-pipeline/village.py [--houses N] [--trees N] [--seed S]
Houses stand beside the roads, ridge along the road; trees in the open ground. Nothing on the river, the roads,
the rings or the map's edge. A check image goes to art-pipeline/out/cabin/village.png.
"""
import argparse
import json
import math
import random

import numpy as np
from PIL import Image, ImageDraw

ap = argparse.ArgumentParser()
ap.add_argument("--houses", type=int, default=70)
ap.add_argument("--trees", type=int, default=60)
ap.add_argument("--seed", type=int, default=1819)
args = ap.parse_args()

MAP = "art/source/ui/map03.png"
im = np.asarray(Image.open(MAP).convert("RGB")).astype(float)
L = im.mean(2)
H, W = L.shape


def box(a, r):
    c = np.pad(a, ((r + 1, r), (r + 1, r)), mode="edge").cumsum(0).cumsum(1)
    return (c[2 * r + 1:, 2 * r + 1:] - c[:-2 * r - 1, 2 * r + 1:] - c[2 * r + 1:, :-2 * r - 1]
            + c[:-2 * r - 1, :-2 * r - 1]) / ((2 * r + 1) ** 2)


ink = L < box(L, 8) - 18

# ---------------------------------------------------------------- the river, traced by hand and snapped to the banks
# y: list of (left bank, right bank) pairs per water channel, in pixels, read off map03.
BANKS = {
    0: [(285, 375), (545, 632)], 50: [(300, 385), (535, 615)], 100: [(320, 400), (528, 600)],
    150: [(345, 410), (520, 585)], 200: [(355, 412), (520, 580)], 250: [(358, 415), (535, 592)],
    300: [(362, 418), (548, 602)], 350: [(372, 432), (550, 600)], 400: [(392, 450), (545, 595)],
    450: [(420, 470), (525, 575)], 480: [(440, 555)], 500: [(455, 550)], 550: [(470, 560)],
    600: [(492, 600)], 650: [(520, 640)], 700: [(555, 680)], 750: [(572, 700)], 800: [(562, 722)],
    850: [(548, 752)], 900: [(536, 790)], 950: [(526, 830)], 1000: [(520, 872)], 1023: [(518, 885)],
}


def snap(y, x, way):
    """The bank's ink nearest the guess, looking 18 px either side; prefer the outer side (way -1 left, +1 right)."""
    best = x
    for d in range(0, 19):
        for xx in (x + way * d, x - way * d):
            if 0 <= xx < W and ink[y, xx]:
                return xx
    return best


ys = sorted(BANKS)
water = np.zeros((H, W), bool)
for y in range(H):
    j = max(i for i in range(len(ys)) if ys[i] <= y)
    y0 = ys[j]
    y1 = ys[min(j + 1, len(ys) - 1)]
    a, b = BANKS[y0], BANKS[y1]
    t = 0 if y1 == y0 else (y - y0) / (y1 - y0)
    if len(a) != len(b):   # where the arms join, interpolate the outer banks only
        a = [(a[0][0], a[-1][1])] if len(b) == 1 else a
        b = [(b[0][0], b[-1][1])] if len(a) == 1 else b
    for (l0, r0), (l1, r1) in zip(a, b):
        l = int(round(l0 + (l1 - l0) * t))
        r = int(round(r0 + (r1 - r0) * t))
        l, r = snap(y, l, -1), snap(y, r, 1)
        water[y, l:r + 1] = True


def dist_to(mask, cap):
    """City-block distance to the nearest True pixel, up to cap."""
    d = np.full(mask.shape, cap, float)
    d[mask] = 0
    m = mask.copy()
    for k in range(1, cap):
        m = m | np.roll(m, 1, 0) | np.roll(m, -1, 0) | np.roll(m, 1, 1) | np.roll(m, -1, 1)
        d[m & (d == cap)] = k
    return d


# roads: ink off the river, without the rings' ink
SPOTS = {
    "square": (10.4, 10.2), "cemetery": (13.9, 27.3), "church": (12.2, 59.2), "odeon": (15.7, 83.7),
    "market": (28.3, 66.9), "docks": (51.0, 68.4), "hospital": (47.3, 32.6), "slaughter": (66.4, 22.8),
    "first": (91.3, 11.3), "academy": (89.3, 37.4), "morgue": (82.7, 59.3), "alley": (90.0, 82.9),
}
yy, xx = np.mgrid[0:H, 0:W]
rings = np.zeros((H, W), bool)
for px, py in SPOTS.values():
    rings |= np.hypot(xx - px * W / 100, yy - py * H / 100) < 66
roads = ink & ~(dist_to(water, 6) < 5) & ~rings & (box(L, 15) > 140)   # not the dark stains


def big_parts(mask, min_px):
    """Only the connected pieces of at least min_px pixels (8-neighbour): the long road lines, not paper specks."""
    seen = np.zeros(mask.shape, bool)
    keep = np.zeros(mask.shape, bool)
    for y0, x0 in zip(*np.nonzero(mask)):
        if seen[y0, x0]:
            continue
        stack, part = [(y0, x0)], []
        seen[y0, x0] = True
        while stack:
            y, x = stack.pop()
            part.append((y, x))
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    ny, nx = y + dy, x + dx
                    if 0 <= ny < H and 0 <= nx < W and mask[ny, nx] and not seen[ny, nx]:
                        seen[ny, nx] = True
                        stack.append((ny, nx))
        if len(part) >= min_px:
            for y, x in part:
                keep[y, x] = True
    return keep


# close small gaps in the sketchy road lines first, so a road's line holds together as one piece
joined = roads | np.roll(roads, 1, 0) | np.roll(roads, -1, 0) | np.roll(roads, 1, 1) | np.roll(roads, -1, 1)
roads = big_parts(joined, 200) & roads
roads_d = dist_to(roads, 60)
water_d = dist_to(water, 40)

# keep out: river and its banks, rings and a ring of space around them, the map's edge
edge = 40
blocked = (water_d < 14) | rings | (xx < edge) | (yy < edge) | (xx > W - edge) | (yy > H - edge)


def road_dir(x, y):
    """Direction along the nearest road: perpendicular to the distance gradient."""
    gx = roads_d[y, min(x + 3, W - 1)] - roads_d[y, max(x - 3, 0)]
    gy = roads_d[min(y + 3, H - 1), x] - roads_d[max(y - 3, 0), x]
    return math.atan2(gx, -gy) if (gx or gy) else 0.0


rnd = random.Random(args.seed)
placed = []   # (x, y, radius)


def free(x, y, r):
    return all(math.hypot(x - a, y - b) >= r + c for a, b, c in placed)


houses = []
tries = 0
while len(houses) < args.houses and tries < 200000:
    tries += 1
    x, y = rnd.randrange(W), rnd.randrange(H)
    if blocked[y, x] or not (15 <= roads_d[y, x] <= 24):
        continue
    if not free(x, y, 13):
        continue
    houses.append({"x": round(x / W * 100, 2), "y": round(y / H * 100, 2),
                   "ang": round(road_dir(x, y) + rnd.choice((0, math.pi)) + rnd.uniform(-0.12, 0.12), 3),
                   "s": round(rnd.uniform(0.85, 1.2), 2), "long": round(rnd.uniform(1.0, 1.6), 2)})
    placed.append((x, y, 13))

trees = []
tries = 0
while len(trees) < args.trees and tries < 200000:
    tries += 1
    # trees come in small clumps: half start a clump, half join one
    if trees and rnd.random() < 0.55:
        t = rnd.choice(trees)
        x = int(t["x"] * W / 100 + rnd.uniform(-22, 22))
        y = int(t["y"] * H / 100 + rnd.uniform(-22, 22))
        if not (0 <= x < W and 0 <= y < H):
            continue
    else:
        x, y = rnd.randrange(W), rnd.randrange(H)
    if blocked[y, x] or roads_d[y, x] < 12:
        continue
    if not free(x, y, 9):
        continue
    trees.append({"x": round(x / W * 100, 2), "y": round(y / H * 100, 2), "s": round(rnd.uniform(0.75, 1.3), 2),
                  "kind": rnd.choice(("round", "round", "cone"))})
    placed.append((x, y, 9))

json.dump({"houses": houses, "trees": trees}, open("godot/assets/cabin/village.json", "w"), indent=0)
print(f"{len(houses)} houses, {len(trees)} trees")

vis = Image.fromarray(im.astype(np.uint8)).convert("RGB")
ov = np.asarray(vis).astype(float)
ov[water] = ov[water] * 0.5 + np.array([40, 90, 200]) * 0.5
ov[roads] = [200, 30, 30]
vis = Image.fromarray(ov.astype(np.uint8))
d = ImageDraw.Draw(vis)
for h in houses:
    x, y, a = h["x"] * W / 100, h["y"] * H / 100, h["ang"]
    c, s = math.cos(a) * 7 * h["long"], math.sin(a) * 7 * h["long"]
    d.line([(x - c, y - s), (x + c, y + s)], fill=(255, 255, 255), width=8)
for t in trees:
    x, y = t["x"] * W / 100, t["y"] * H / 100
    d.ellipse([x - 5, y - 5, x + 5, y + 5], fill=(30, 120, 40))
vis.save("art-pipeline/out/cabin/village.png")
