"""The stats board's painted face (D199).

python3 art-pipeline/stats_board.py

Crops Bruno's concept (art/source/ui/stats_board_concept.png) to the iron frame at twice the size, wipes the
concept's own tick marks off the three dial faces and draws ours: one tick and one number per value, after the
original board's dials. Humanity runs -10 to 10 with 0 at the top (positive clockwise, negative anticlockwise),
reputation 0 to 23 and expertise 0 to 27 clockwise from the lower left; the gap at the bottom keeps the emblem.
Thresholds (reputation 7, 15, 23; expertise 3, 8, 10, 14, 20, 27) and negative humanity are in red. The names go on
the brass plates. Writes godot/assets/cabin/stats_board.webp. Coordinates below are in the concept's pixels; the
Godot side (cabin/stats_board.gd) uses the same ones.
"""
import math
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SRC = "art/source/ui/stats_board_concept.png"
DST = "godot/assets/cabin/stats_board.webp"
CROP = (118, 84, 1178, 1142)
K = 2                                                     # drawn at twice the concept's size
FACE_R = 113
SWEEP = 140.0                                             # degrees either side of the top
DIALS = [
    # centre, values, angle of the first value, the plate's centre, name, red values
    ((334, 262), list(range(-10, 11)), None, (329, 428), "Humanity", set(range(-10, 0))),
    ((644, 262), list(range(0, 24)), -SWEEP, (643, 428), "Reputation", {7, 15, 23}),
    ((958, 262), list(range(0, 28)), -SWEEP, (960, 428), "Expertise", {3, 8, 10, 14, 20, 27}),
]
EMBLEM = [(290, 315, 380, 357), (600, 320, 690, 355), (905, 320, 1012, 359)]   # keep these clear of the wipe
INK = (46, 34, 24)
RED = (140, 22, 18)
NUM_FONT = "godot/assets/fonts/EBGaramond.ttf"
NAME_FONT = "godot/assets/fonts/Amarante-Regular.ttf"


def angle(dial, v):
    """Degrees clockwise from the top for value v (the same function as StatsBoard.dial_angle)."""
    vals = dial[1]
    if vals[0] < 0:
        return v * SWEEP / 10.0
    return -SWEEP + (v - vals[0]) * 2 * SWEEP / (vals[-1] - vals[0])


def main():
    im = Image.open(SRC).convert("RGB")
    # Wipe the old ticks: a median filter removes thin dark lines and keeps the parchment's colour.
    smooth = im.filter(ImageFilter.MedianFilter(9)).filter(ImageFilter.MedianFilter(7))
    mask = Image.new("L", im.size, 0)
    md = ImageDraw.Draw(mask)
    for (cx, cy), *_ in DIALS:
        md.ellipse((cx - FACE_R, cy - FACE_R, cx + FACE_R, cy + FACE_R), fill=255)
        r = FACE_R * 0.62
        md.ellipse((cx - r, cy - r, cx + r, cy + r), fill=0)
    for box in EMBLEM:
        md.rectangle(box, fill=0)
    im.paste(smooth, (0, 0), mask.filter(ImageFilter.GaussianBlur(2)))

    im = im.crop(CROP)
    im = im.resize((im.width * K, im.height * K), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    def font(size, weight):
        f = ImageFont.truetype(NUM_FONT, size * K)
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
        return f
    name = ImageFont.truetype(NAME_FONT, 19 * K)

    def at(x, y):
        return ((x - CROP[0]) * K, (y - CROP[1]) * K)

    for dial in DIALS:
        (cx, cy), vals, _, plate, title, red = dial
        c = at(cx, cy)
        crowded = len(vals) > 24                         # expertise: smaller type so 10 to 19 fit over the top
        num, big = (font(12, 600), font(13, 700)) if crowded else (font(15, 600), font(17, 700))
        for v in vals:
            a = math.radians(angle(dial, v))
            sx, sy = math.sin(a), -math.cos(a)
            col = RED if v in red else INK
            major = v % 5 == 0 or v in red
            r0 = FACE_R * (0.88 if major else 0.92) * K
            r1 = FACE_R * 0.985 * K
            d.line((c[0] + sx * r0, c[1] + sy * r0, c[0] + sx * r1, c[1] + sy * r1), fill=col, width=(3 if major else 2))
            rt = FACE_R * (0.77 if crowded else 0.75) * K
            f = big if (v == 0 or v in red and vals[0] >= 0) else num
            d.text((c[0] + sx * rt, c[1] + sy * rt), str(v), font=f, fill=col, anchor="mm")
        p = at(*plate)
        d.text((p[0], p[1] + K), title, font=name, fill=(52, 36, 18), anchor="mm")
        d.text((p[0], p[1]), title, font=name, fill=(38, 26, 14), anchor="mm")
    im.save(DST, quality=90)
    print("wrote", DST, im.size)


if __name__ == "__main__":
    main()
