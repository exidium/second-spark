#!/usr/bin/env python3
"""The cabin's map (D177), step 1: the board's geography drawn exactly from godot/town/town.gd (river, islands, bridges,
roads, a small circle at each landmark) as a clean ink layout, art-pipeline/out/cabin/map-layout.png. Nano Banana then
restyles it as an old parchment map (map.png), keeping every line where it is.

  python3 art-pipeline/cabin_map.py
"""
import math, re
from pathlib import Path
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
SRC = (HERE.parent / 'godot' / 'town' / 'town.gd').read_text(encoding='utf-8')
OUT = HERE / 'out' / 'cabin'
N = 2048            # pixels for board percent 0..100
V2 = r'Vector2\(\s*(-?[\d.]+)\s*,\s*(-?[\d.]+)\s*\)'


def block(name):
    i = SRC.index(f'const {name} :=')
    j, depth = SRC.index('[', i), 0
    for k in range(j, len(SRC)):
        depth += {'[': 1, ']': -1}.get(SRC[k], 0)
        if depth == 0:
            return SRC[j:k + 1]


def px(a, b):
    return (float(a) / 100 * N, float(b) / 100 * N)


def pts(s):
    return [px(a, b) for a, b in re.findall(V2, s)]


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    img = Image.new('RGB', (N, N), (238, 230, 210))
    d = ImageDraw.Draw(img)
    for m, w in re.findall(r'\[\[(.*?)\], ([\d.]+)\]', block('ROADS'), re.S):
        d.line(pts(m), fill=(120, 105, 85), width=int(float(w) * 1.3), joint='curve')
    for m in re.findall(r'\[(Vector2.*?)\]', block('WATER'), re.S):
        d.polygon(pts(m), fill=(70, 95, 110), outline=(30, 30, 30), width=5)
    for m, w in re.findall(r'\[(Vector2\(.*?\), Vector2\(.*?\)), ([\d.]+)\]', block('BRIDGES')):
        a, b = pts(m)
        d.line([a, b], fill=(150, 135, 110), width=int(float(w) * 2.2))
        d.line([a, b], fill=(30, 30, 30), width=3)
    for pid, pos in re.findall(r'"(\w+)": \{"name": "[^"]+".*?"pos": (Vector2\([^)]*\))', SRC):
        x, y = pts(pos)[0]
        r = 34
        d.ellipse((x - r, y - r, x + r, y + r), outline=(30, 30, 30), width=5)
    img.save(OUT / 'map-layout.png')
    print('written', OUT / 'map-layout.png')


if __name__ == '__main__':
    main()
