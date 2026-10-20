#!/usr/bin/env python3
"""Snap generated images to the game's pixel-art spec: exact canvas, 32 colours, hard pixels.

Usage:
  python3 tools/pixelize.py art/source/location-cemetery.png            # writes art/location-cemetery.png
  python3 tools/pixelize.py art/source/*.png --scale 4                   # also writes a 4x nearest-neighbour copy for the page

Canvas is chosen from the file name: location-*/lab-* 96x54, cadavers and scoundrels 64x96, everything else 96x72.
Requires Pillow (installed for the plain python3 on this Mac; do not run with -I).
"""
import sys, argparse
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
def canvas_for(stem):
    if stem.startswith(('location-', 'lab-')): return (96, 54)
    if stem.split('-')[0] in ('cemetery', 'hospital', 'morgue', 'square', 'scoundrel', 'character'): return (64, 96)
    return (96, 72)

def pixelize(src, scale):
    stem = src.stem; w, h = canvas_for(stem)
    im = Image.open(src).convert('RGB')
    # crop to the target aspect from the centre, then shrink with box filter so big "fake pixels" average cleanly
    tw, th = im.size; target = w / h
    if tw / th > target: nw = int(th * target); im = im.crop(((tw - nw) // 2, 0, (tw - nw) // 2 + nw, th))
    else: nh = int(tw / target); im = im.crop((0, (th - nh) // 2, tw, (th - nh) // 2 + nh))
    small = im.resize((w, h), Image.BOX)
    q = small.quantize(colors=32, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    out = ROOT / 'art' / f'{stem}.png'
    q.save(out, optimize=True)
    msg = f'{out.relative_to(ROOT)} {w}x{h} {len(q.getcolors())} colours'
    if scale > 1:
        big = q.convert('RGB').resize((w * scale, h * scale), Image.NEAREST)
        bo = ROOT / 'art' / f'{stem}@{scale}x.png'; big.save(bo, optimize=True); msg += f', {bo.name}'
    print(msg)

ap = argparse.ArgumentParser(); ap.add_argument('files', nargs='+'); ap.add_argument('--scale', type=int, default=1)
a = ap.parse_args()
for f in a.files: pixelize(Path(f), a.scale)
