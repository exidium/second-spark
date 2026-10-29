#!/usr/bin/env python3
"""Draws two textures for the Godot table, in the pixel look (drawn at 40 px per world unit, scaled x2 nearest).

  art/ui/player-board.png  the face of your board: stone wall, zone frames, decay columns, stores, jar boxes,
                           operating slab, gold tray, police spots and card placeholders.

The zone rectangles mirror the constants at the top of the board section in godot/scripts/view/board.gd
(MAT_X, MAT_W, MAT_D, LAB_CARDS, DECAY_COLS, STORES, JAR_Z, TABLE_X, PILES). Change both together, then run
this and `node tools/export_godot_data.js`.
"""
import math, os, random
import numpy as np
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PPU = 40
rng = np.random.default_rng(7)
random.seed(7)

def hexc(h):
    h = h.lstrip('#')
    return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)], dtype=float)

# ---------------------------------------------------------------- your board
MAT_X, MAT_W, MAT_D = 0.95, 16.7, 3.9
X0, Z0 = MAT_X - MAT_W / 2, -MAT_D / 2
W, H = round(MAT_W * PPU), round(MAT_D * PPU)
img = np.zeros((H, W, 3))

def px(x, z):
    return int(round((x - X0) * PPU)), int(round((z - Z0) * PPU))

def noise(h, w, amp):
    return rng.normal(0, amp, (h, w, 1))

def fill(x0, z0, x1, z1, col, amp=6.0):
    a, b = px(x0, z0)
    c, d = px(x1, z1)
    img[b:d, a:c] = hexc(col) + noise(d - b, c - a, amp)

def frame(x0, z0, x1, z1, col='#8a6a3a', t=1, shadow=True):
    a, b = px(x0, z0)
    c, d = px(x1, z1)
    k = hexc(col)
    img[b:b + t, a:c] = k * 1.15
    img[d - t:d, a:c] = k * 0.75
    img[b:d, a:a + t] = k * 1.05
    img[b:d, c - t:c] = k * 0.8
    if shadow:   # inner shadow along top and left
        img[b + t:b + t + 2, a + t:c - t] *= 0.6
        img[b + t:d - t, a + t:a + t + 2] *= 0.7

def planks(x0, z0, x1, z1, base, horizontal=True, w=0.36):
    a, b = px(x0, z0)
    c, d = px(x1, z1)
    hh, ww = d - b, c - a
    yy, xx = np.mgrid[0:hh, 0:ww]
    along = xx if horizontal else yy
    across = yy if horizontal else xx
    n = int(w * PPU)
    plank = across // n
    tone = (np.sin(plank * 12.9898) * 43758.5453) % 1.0
    grain = np.sin(along * 0.18 + np.sin(across * 0.9 + plank) * 2.0) * 0.5 + 0.5
    v = 0.82 + 0.18 * tone + 0.10 * grain
    region = hexc(base) * v[..., None] + noise(hh, ww, 4)
    region[(across % n) == 0] *= 0.45
    img[b:d, a:c] = region

# Stone wall: bricks in rows, each with its own tone.
bw, bh = int(0.5 * PPU), int(0.25 * PPU)
stone = hexc('#3b4040')
for r in range(0, H, bh):
    off = (r // bh % 2) * bw // 2
    for c in range(-bw, W, bw):
        tone = rng.uniform(0.78, 1.12)
        tint = np.array([rng.uniform(-4, 4), rng.uniform(-2, 5), rng.uniform(-2, 6)])
        a, b = max(0, c + off), min(W, c + off + bw)
        if b <= a:
            continue
        img[r:r + bh, a:b] = stone * tone + tint + noise(min(bh, H - r), b - a, 5)
        img[r:r + bh, a:a + 1] = stone * 0.45
        img[r:r + 1, a:b] = stone * 0.45

# Heading band along the far edge.
fill(X0, Z0, X0 + MAT_W, -1.45, '#231c1a', 3)
a, b = px(X0, -1.45)
img[b:b + 1, :] = hexc('#8a6a3a')

# Laboratory: a dark wooden shelf behind the four lab cards.
planks(-7.3, -1.4, -4.0, 1.85, '#3a2a1e')
frame(-7.3, -1.4, -4.0, 1.85)
# Decomposition: four purple velvet columns, a stone strip at the top of each.
fill(-3.975, -1.4, 0.475, 1.85, '#1d1922', 3)
frame(-3.975, -1.4, 0.475, 1.85)
for c in [-3.35, -2.3, -1.2, -0.15]:
    fill(c - 0.45, -1.33, c + 0.45, 1.78, '#2f2340', 7)
    fill(c - 0.45, -1.33, c + 0.45, -1.08, '#46404a', 4)
    frame(c - 0.45, -1.33, c + 0.45, 1.78, '#5b4a6e')
# Stores: three stone trays.
for z in [-0.95, 0.15, 1.25]:
    fill(0.85, z - 0.49, 2.35, z + 0.49, '#4a4640', 5)
    frame(0.85, z - 0.49, 2.35, z + 0.49, '#6e6352')
# Jars: four small wooden boxes.
for z in [-1.0, -0.2, 0.6, 1.4]:
    planks(2.64, z - 0.33, 3.26, z + 0.33, '#4a3020', False, 0.15)
    frame(2.64, z - 0.33, 3.26, z + 0.33, '#6b5a3a')
# Operating table: dark red planks.
planks(3.3, -1.4, 6.0, 1.85, '#3a1a18', False, 0.42)
frame(3.3, -1.4, 6.0, 1.85)
# Supplies: gold tray, two police spots, four card placeholders.
fill(6.2, -1.4, 9.2, 1.85, '#262126', 3)
frame(6.2, -1.4, 9.2, 1.85)
fill(6.3, -1.35, 7.6, -0.4, '#5a4a2a', 5)
frame(6.3, -1.35, 7.6, -0.4, '#a8873e')
yy, xx = np.mgrid[0:H, 0:W]
for cx in [8.23, 8.67]:
    a, b = px(cx, -0.9)
    d = np.hypot(xx - a, yy - b)
    img[(d < 0.17 * PPU)] = hexc('#2a1f18') + 0
    img[(d >= 0.15 * PPU) & (d < 0.19 * PPU)] = hexc('#a8443a')
for k in range(4):
    cx = 6.75 + k * 0.65
    a, b = px(cx - 0.28, 0.75 - 0.38)
    c, d = px(cx + 0.28, 0.75 + 0.38)
    img[b:d, a:c] *= 0.75
    for x in range(a, c):
        if (x // 3) % 2 == 0:
            img[b, x] = img[d - 1, x] = hexc('#b9ac93')
    for y in range(b, d):
        if (y // 3) % 2 == 0:
            img[y, a] = img[y, c - 1] = hexc('#b9ac93')

img = np.clip(img, 0, 255).astype(np.uint8)
board = Image.fromarray(img).resize((W * 2, H * 2), Image.NEAREST)
board.save(os.path.join(ROOT, 'art/ui/player-board.png'))

print('player-board.png', board.size)
