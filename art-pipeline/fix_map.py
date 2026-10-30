"""Hand fixes on Bruno's drawn map (D179): two river crossings that stopped in the water, and wobbly hand-drawn rings.

python3 art-pipeline/fix_map.py [in.png] [out.png]
Defaults: art/source/ui/map02.png -> art/source/ui/map03.png. Nothing is drawn from scratch except one short road;
the bridges are the map's own bridge, cut and lengthened, and the rings are the map's own rings, bent.
"""
import math
import random
import sys

import numpy as np
from PIL import Image, ImageDraw

SRC = sys.argv[1] if len(sys.argv) > 1 else "art/source/ui/map02.png"
DST = sys.argv[2] if len(sys.argv) > 2 else "art/source/ui/map03.png"

im = np.asarray(Image.open(SRC).convert("RGB")).astype(float)
orig = im.copy()
L = orig.mean(2)
H, W = L.shape


# ---------------------------------------------------------------- bridges

def bridge(src_box, post_l, post_r, x0, x1, y_off=0):
    """Cut the bridge in src_box (x0, y0, x1, y1), keep its end posts (widths post_l, post_r) and stretch the deck
    between them so the bridge runs from x0 to x1. Paste it at the same rows (+ y_off). Only the deck rows and the
    dark ink of the posts are pasted, so water and bank show around the posts."""
    sx0, sy0, sx1, sy1 = src_box
    spr = orig[sy0:sy1, sx0:sx1]
    sl = spr.mean(2)
    # deck rows: where the middle of the deck is (light planks between two dark rails)
    left, deck, right = spr[:, :post_l], spr[:, post_l:spr.shape[1] - post_r], spr[:, spr.shape[1] - post_r:]
    n = x1 - x0 - post_l - post_r
    # repeat the deck's planks, every other copy mirrored so the seams meet, instead of stretching them
    tiles, flip = [], False
    while sum(t.shape[1] for t in tiles) < n:
        tiles.append(deck[:, ::-1] if flip else deck)
        flip = not flip
    new = np.concatenate([left, np.concatenate(tiles, axis=1)[:, :n], right], axis=1)
    nl = new.mean(2)
    # mask: deck body opaque, posts only where inked
    mask = np.zeros(nl.shape)
    rows = deck_rows(sl[:, post_l:spr.shape[1] - post_r])
    print("deck rows", sy0 + rows[0], sy0 + rows[1])
    mask[rows[0]:rows[1] + 1, :] = 1.0
    ink = np.clip((125 - nl) / 40, 0, 1)
    ink[:, post_l:ink.shape[1] - post_r] = 0
    mask = np.maximum(mask, ink)
    mask[:, :2] *= 0.5
    mask[:, -2:] *= 0.5
    ty = sy0 + y_off
    reg = im[ty:ty + new.shape[0], x0:x0 + new.shape[1]]
    m = mask[..., None]
    im[ty:ty + new.shape[0], x0:x0 + new.shape[1]] = reg * (1 - m) + new * m


def deck_rows(deck_l):
    """First and last row of the deck: the outer dark rails across the deck's middle columns."""
    prof = deck_l[:, deck_l.shape[1] // 4: 3 * deck_l.shape[1] // 4].mean(1)
    dark = np.where(prof < 110)[0]
    return int(dark.min()), int(dark.max())


def erase(x0, x1, y0, y1):
    """Lift an old post's ink: its dark strokes are filled in from the colours around them (diffusion), the paper
    and water between the strokes stay as drawn."""
    box = orig[y0:y1, x0:x1]
    m = box.mean(2) < 128
    m = m | np.roll(m, 1, 0) | np.roll(m, -1, 0) | np.roll(m, 1, 1) | np.roll(m, -1, 1)
    m[[0, -1], :] = False
    m[:, [0, -1]] = False
    f = box.copy()
    f[m] = box[~m].mean(0)
    for _ in range(200):
        n = (np.roll(f, 1, 0) + np.roll(f, -1, 0) + np.roll(f, 1, 1) + np.roll(f, -1, 1)) / 4
        f[m] = n[m]
    grain = (np.random.default_rng(3).normal(0, 4, f.shape[:2]))[..., None]
    f[m] = (f + grain)[m]
    im[y0:y1, x0:x1] = f


# The middle crossing below the fork: the road from the west stops at the west bank, the bridge starts mid-river.
erase(540, 564, 548, 562)
erase(540, 564, 581, 597)
bridge((545, 552, 604, 593), 14, 13, 474, 604)
# The docks crossing: the bridge stops short of the east bank. Rebuild it from the docks circle to the bank.
erase(630, 654, 684, 699)
erase(630, 654, 712, 728)
bridge((562, 690, 650, 723), 6, 15, 562, 684)


# ---------------------------------------------------------------- a road from the docks bridge to the east road

def road(points, width=15.0, seed=7):
    """A dirt road like the map's own: a lighter wash between two thin, slightly wobbly ink lines."""
    rnd = random.Random(seed)
    S = 4
    path = bezier(points, 80)
    fill = Image.new("L", (W * S, H * S), 0)
    edge = Image.new("L", (W * S, H * S), 0)
    df, de = ImageDraw.Draw(fill), ImageDraw.Draw(edge)
    df.line([(x * S, y * S) for x, y in path], fill=255, width=int(width * S), joint="curve")
    for side in (-1, 1):
        pts, w = [], 0.0
        for i, (x, y) in enumerate(path):
            nx, ny = normal(path, i)
            w += rnd.uniform(-0.25, 0.25)
            w = max(-0.8, min(0.8, w))
            off = side * (width / 2 + w)
            pts.append(((x + nx * off) * S, (y + ny * off) * S))
        de.line(pts[:-11], fill=200, width=int(1.3 * S), joint="curve")   # stop short: the end opens into the road
        # a fainter second stroke beside it, as the pen went over the line twice
        de.line([(x + nx2 * S * 1.4, y + ny2 * S * 1.4) for (x, y), (nx2, ny2) in zip(pts[3:-14], [normal(path, i) for i in range(3, len(path) - 14)])],
                fill=90, width=int(1.0 * S), joint="curve")
    fill = np.asarray(fill.resize((W, H), Image.LANCZOS)).astype(float)[..., None] / 255
    edge = np.asarray(edge.resize((W, H), Image.LANCZOS)).astype(float)[..., None] / 255
    road_col = np.array([206, 178, 118.0])
    ink_col = np.array([88, 62, 34.0])
    global im
    im = im * (1 - fill) + (im * 0.45 + road_col * 0.55) * fill
    im = im * (1 - edge) + ink_col * edge


def bezier(p, n):
    out = []
    for i in range(n + 1):
        t = i / n
        a = [(1 - t) ** 3, 3 * (1 - t) ** 2 * t, 3 * (1 - t) * t ** 2, t ** 3]
        out.append((sum(a[k] * p[k][0] for k in range(4)), sum(a[k] * p[k][1] for k in range(4))))
    return out


def normal(path, i):
    a, b = path[max(i - 1, 0)], path[min(i + 1, len(path) - 1)]
    dx, dy = b[0] - a[0], b[1] - a[1]
    d = math.hypot(dx, dy) or 1
    return -dy / d, dx / d


road([(680, 706), (722, 708), (748, 650), (748, 596)])


# ---------------------------------------------------------------- imperfect rings

def ring_fit(x0, y0):
    angs = np.linspace(0, 2 * math.pi, 120, endpoint=False)
    best = None
    for r in range(36, 54):
        for dx in range(-10, 11):
            for dy in range(-10, 11):
                cx, cy = x0 + dx, y0 + dy
                v = L[(cy + r * np.sin(angs)).astype(int), (cx + r * np.cos(angs)).astype(int)].mean()
                if best is None or v < best[0]:
                    best = (v, cx, cy, r)
    return best[1:]


def wobble(cx, cy, R, seed):
    """Bend the ring: its radius drifts a few pixels round the circle and its line thickens and thins, as drawn by
    hand. Pixels near the ring are resampled from a warped radius; the warp fades out away from the line."""
    rnd = random.Random(seed)
    harm = [(k, rnd.uniform(0.6, 1.0) * amp, rnd.uniform(0, math.tau)) for k, amp in ((2, 3.4), (3, 2.0), (5, 0.9))]
    thick = [(k, rnd.uniform(0, math.tau)) for k in (2, 3)]
    pad = 20
    x0, x1 = max(cx - R - pad, 0), min(cx + R + pad, W - 1)
    y0, y1 = max(cy - R - pad, 0), min(cy + R + pad, H - 1)
    ys, xs = np.mgrid[y0:y1 + 1, x0:x1 + 1].astype(float)
    dx, dy = xs - cx, ys - cy
    r = np.hypot(dx, dy)
    th = np.arctan2(dy, dx)
    d = sum(a * np.cos(k * th + p) for k, a, p in harm)
    k = 1.0 + 0.35 * sum(np.cos(kk * th + p) for kk, p in thick) / 2
    # source radius: the line moves out by d and its width scales by k
    rs = R + (r - R - d) / k
    w = np.clip(1 - (np.abs(r - R) - 9) / 8, 0, 1)
    w = w * w * (3 - 2 * w)
    rs = r * (1 - w) + rs * w
    sx = cx + np.cos(th) * rs
    sy = cy + np.sin(th) * rs
    out = bilinear(orig_now, sx, sy)
    im[y0:y1 + 1, x0:x1 + 1] = out


def bilinear(img, x, y):
    x = np.clip(x, 0, W - 1.001)
    y = np.clip(y, 0, H - 1.001)
    xi, yi = np.floor(x).astype(int), np.floor(y).astype(int)
    fx, fy = (x - xi)[..., None], (y - yi)[..., None]
    a = img[yi, xi]
    b = img[yi, xi + 1]
    c = img[yi + 1, xi]
    d = img[yi + 1, xi + 1]
    return a * (1 - fx) * (1 - fy) + b * fx * (1 - fy) + c * (1 - fx) * fy + d * fx * fy


GUESS = [(105, 103), (141, 280), (125, 605), (158, 855), (290, 684), (522, 700), (483, 333), (679, 232),
         (933, 115), (914, 382), (847, 605), (922, 848)]
orig_now = im.copy()
for i, (gx, gy) in enumerate(GUESS):
    cx, cy, R = ring_fit(gx, gy)
    wobble(cx, cy, R, 1819 + i)
    print(f"ring {i}: centre {cx},{cy} r{R}")

Image.fromarray(np.clip(im, 0, 255).astype(np.uint8)).save(DST)
print("saved", DST)
