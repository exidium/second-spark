#!/usr/bin/env python3
"""Snap generated images to the game's pixel-art spec: exact canvas, 32 colours, hard pixels.

Usage:
  python3 tools/pixelize.py art/source/locations/location-cemetery.png        # writes art/locations/location-cemetery.png (true 96px)
  python3 tools/pixelize.py art/source/characters/*.png --width 384          # native look at 384px wide, 32 colours (what the game uses)
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

def folder_for(stem):
    k = stem.split('-')[0]
    return {'location':'locations','lab':'locations','cemetery':'cadavers','hospital':'cadavers','morgue':'cadavers','square':'cadavers','scoundrel':'scoundrels','research':'research','humanity':'humanity','event':'events','encounter':'encounters','character':'characters'}.get(k, 'misc')

def pixelize(src, scale, width):
    stem = src.stem; w, h = canvas_for(stem)
    out_dir = ROOT / 'art' / folder_for(stem); out_dir.mkdir(parents=True, exist_ok=True)
    im = Image.open(src).convert('RGB')
    # crop to the target aspect from the centre, then shrink with box filter so big "fake pixels" average cleanly
    tw, th = im.size; target = w / h
    if tw / th > target: nw = int(th * target); im = im.crop(((tw - nw) // 2, 0, (tw - nw) // 2 + nw, th))
    else: nh = int(tw / target); im = im.crop((0, (th - nh) // 2, tw, (th - nh) // 2 + nh))
    if width:
        # "native" mode: keep the generator's own pixel look at a display size, 32 colours, small PNG
        big = im.resize((width, round(width * h / w)), Image.LANCZOS).quantize(colors=32, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
        out = out_dir / f'{stem}.png'; big.save(out, optimize=True)
        print(f'{out.relative_to(ROOT)} {big.size[0]}x{big.size[1]} {len(big.getcolors())} colours, {out.stat().st_size // 1024} KB'); return
    small = im.resize((w, h), Image.BOX)
    q = small.quantize(colors=32, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    out = out_dir / f'{stem}.png'
    q.save(out, optimize=True)
    msg = f'{out.relative_to(ROOT)} {w}x{h} {len(q.getcolors())} colours'
    if scale > 1:
        big = q.convert('RGB').resize((w * scale, h * scale), Image.NEAREST)
        bo = out_dir / f'{stem}@{scale}x.png'; big.save(bo, optimize=True); msg += f', {bo.name}'
    print(msg)

ap = argparse.ArgumentParser(); ap.add_argument('files', nargs='+'); ap.add_argument('--scale', type=int, default=1); ap.add_argument('--width', type=int, default=0, help='native mode: keep the generated look, quantise to 32 colours at this width')
a = ap.parse_args()
for f in a.files: pixelize(Path(f), a.scale, a.width)
