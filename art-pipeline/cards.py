"""The research and humanity cards for the cabin (D202).

python3 art-pipeline/cards.py [ids]

Draws every card in godot/data/game.json (RESEARCH and HUMANITY) on Bruno's approved templates after the original
cards: engraved filigree border, title, the kind between two rules, the text centred, the gains at the bottom as
numbers with finished ink-and-watercolour icons. Humanity cards are on cool grey-white paper; research cards on cream
paper, with a strip at the bottom for the dice ability (the die in the square, the ability beside it). The corners are
cut round and transparent. Writes godot/assets/cabin/cards/<id>.webp, and tests/cards.png as a contact sheet.
Templates and icons are in art/source/ui/cards/ (icons from art-pipeline/card_icons.py).
"""
import json
import os
import sys
import textwrap
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

SRC = 'art/source/ui/cards'
DST = 'godot/assets/cabin/cards'
OUT_W = 600                                          # the cards are drawn at 848 x 1264, saved at this width
RADIUS = 46                                          # the templates' corner, in their pixels
TITLE = 'godot/assets/fonts/Amarante-Regular.ttf'
BODY = 'godot/assets/fonts/EBGaramond.ttf'
INK = (34, 30, 28)
SOFT = (78, 72, 68)
SQUARE = (135, 1131)                                 # centre of the empty square in the research strip (x 62..208, y 1057..1205)
STRIP_TEXT = (500, 1132)

G = json.load(open('godot/data/game.json'))
_icons = {}


def font(path, size, weight=None):
    f = ImageFont.truetype(path, size)
    if weight:
        try:
            f.set_variation_by_axes([weight])
        except Exception:
            pass
    return f


def icon(name, size):
    """The icon as RGBA: the white page drops out (flooded from the corners, so pale parts inside the drawing stay),
    cropped to the drawing's main mass and scaled so wide and tall shapes weigh the same."""
    if name not in _icons:
        im = Image.open(f'{SRC}/icon-{name}.png').convert('RGB')
        w, h = im.size
        edge = [im.getpixel((x, y)) for x in range(0, w, 16) for y in (0, h - 1)] + \
               [im.getpixel((x, y)) for y in range(0, h, 16) for x in (0, w - 1)]
        page = tuple(sorted(c[i] for c in edge)[len(edge) // 2] for i in range(3))
        diff = ImageChops.difference(im, Image.new('RGB', im.size, page)).convert('L')
        a = diff.point(lambda v: max(0, min(255, (v - 10) * 9)))
        flood = diff.point(lambda v: 255 if v > 14 else 0)
        for xy in ((0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)):
            ImageDraw.floodfill(flood, xy, 128)
        inside = flood.point(lambda v: 0 if v == 128 else 255).filter(ImageFilter.MaxFilter(3))
        a = ImageChops.lighter(a, inside).filter(ImageFilter.GaussianBlur(0.8))
        mass = inside.filter(ImageFilter.GaussianBlur(6)).point(lambda v: 255 if v > 110 else 0)
        a = ImageChops.multiply(a, mass.filter(ImageFilter.MaxFilter(9)))
        l, t, r, b = mass.getbbox()
        pad = int(0.04 * max(r - l, b - t))
        box = (max(0, l - pad), max(0, t - pad), min(w, r + pad), min(h, b + pad))
        out = im.crop(box).convert('RGBA')
        out.putalpha(a.crop(box))
        _icons[name] = out
    out = _icons[name]
    k = min(size * 0.92 / (out.width * out.height) ** 0.5, size * 1.25 / max(out.size))
    return out.resize((int(out.width * k), int(out.height * k)), Image.LANCZOS)


def put(card, ic, cx, cy):
    card.paste(ic, (int(cx - ic.width / 2), int(cy - ic.height / 2)), ic)


def head(d, c, kind, W, y):
    """Title (one or two lines), then the kind spaced out between two rules. Returns the y under it."""
    # The largest size at which the title fits in two lines inside the border, words never broken.
    for size in range(82, 50, -4):
        tf = font(TITLE, size)
        width = int(14 * 82 / size)
        lines = textwrap.wrap(c['name'], width, break_long_words=False)
        if len(lines) <= 2 and max(d.textlength(t, font=tf) for t in lines) <= 640:
            break
    for line in lines:
        d.text((W / 2, y), line, font=tf, fill=INK, anchor='mm')
        y += size + 6
    kf = font(BODY, 32, 600)
    label = ' '.join(kind.upper())
    tw = d.textlength(label, font=kf)
    d.text((W / 2, y), label, font=kf, fill=SOFT, anchor='mm')
    for s in (-1, 1):
        d.line((W / 2 + s * (tw / 2 + 16), y, W / 2 + s * (tw / 2 + 100), y), fill=SOFT, width=2)
    return y + 48


def body(d, text, W, top, bottom, size):
    """The card's text centred between top and bottom, smaller if it would not fit."""
    while True:
        bf = font(BODY, size, 500)
        width = int(21 * 56 / size)
        lines = textwrap.wrap(text, width)
        lh = size * 1.25
        if lh * len(lines) <= bottom - top - 20 or size <= 40:
            break
        size -= 2
    y = (top + bottom) / 2 - lh * (len(lines) - 1) / 2
    for line in lines:
        d.text((W / 2, y), line, font=bf, fill=INK, anchor='mm')
        y += lh


def gains(card, d, c, cy, W):
    row = []
    for k, v in c.get('gain', {}).items():
        name = {'exp': 'brain', 'rep': 'rep', 'coin': 'coin', 'hum': 'heart' if v > 0 else 'heartbroken'}[k]
        row.append((abs(v), icon(name, 146)))
    # Shrink the whole row if it would run past the border.
    k = 1.0
    while True:
        nf = font(TITLE, int(82 * k))
        sized = [(n, ic.resize((int(ic.width * k), int(ic.height * k)), Image.LANCZOS)) for n, ic in row]
        gap = int(44 * k)
        ws = [d.textlength(str(n), font=nf) + 6 + ic.width for n, ic in sized]
        if sum(ws) + gap * (len(ws) - 1) <= 620 or k < 0.6:
            break
        k -= 0.05
    x = W / 2 - (sum(ws) + gap * (len(ws) - 1)) / 2
    for (n, ic), w in zip(sized, ws):
        d.text((x, cy), str(n), font=nf, fill=INK, anchor='lm')
        put(card, ic, x + d.textlength(str(n), font=nf) + 6 + ic.width / 2, cy)
        x += w + gap


def humanity(c):
    im = Image.open(f'{SRC}/humanity.png').convert('RGB')
    W, H = im.size
    d = ImageDraw.Draw(im)
    y = head(d, c, 'humanity', W, 190)
    body(d, c['text'], W, y, H - 330, 56)
    gains(im, d, c, H - 250, W)
    return im


def research(c):
    im = Image.open(f'{SRC}/research.png').convert('RGB')
    W, H = im.size
    d = ImageDraw.Draw(im)
    y = head(d, c, 'research', W, 190)
    body(d, c['text'], W, y, 860, 52)
    gains(im, d, c, 950, W)
    # The dice strip: the die in the square (blue for blue dice, a grey and a blue one for any dice), the ability beside it.
    m = c['mit']
    if m == 'rerollAny':
        put(im, icon('die-gray', 86), SQUARE[0] - 15, SQUARE[1] - 15)
        put(im, icon('die-blue', 56), SQUARE[0] + 27, SQUARE[1] + 21)
    else:
        put(im, icon('die-blue' if m == 'rerollBlue' else 'die-gray', 104), *SQUARE)
    d.text(STRIP_TEXT, G['MIT_N'][m], font=font(BODY, 44, 600), fill=INK, anchor='mm')
    return im


def rounded(im):
    """Cut the white corners away: a rounded rectangle, drawn at four times the size for a smooth edge."""
    W, H = im.size
    m = Image.new('L', (W * 4, H * 4), 0)
    ImageDraw.Draw(m).rounded_rectangle((4, 4, W * 4 - 5, H * 4 - 5), radius=RADIUS * 4, fill=255)
    out = im.convert('RGBA')
    out.putalpha(m.resize((W, H), Image.LANCZOS))
    return out


def main():
    want = set(sys.argv[1:])
    cards = [(c, humanity) for c in G['HUMANITY']] + [(c, research) for c in G['RESEARCH']]
    os.makedirs(DST, exist_ok=True)
    done = []
    for c, draw in cards:
        if want and c['id'] not in want:
            continue
        im = rounded(draw(c))
        im = im.resize((OUT_W, round(im.height * OUT_W / im.width)), Image.LANCZOS)
        im.save(f"{DST}/{c['id']}.webp", quality=90)
        done.append(im)
    # Contact sheet, eight across.
    if done:
        tw, th = 300, round(300 * done[0].height / done[0].width)
        rows = (len(done) + 7) // 8
        sheet = Image.new('RGB', (8 * (tw + 10) + 10, rows * (th + 10) + 10), (30, 25, 20))
        for i, im in enumerate(done):
            t = im.resize((tw, th), Image.LANCZOS)
            sheet.paste(t, (10 + (i % 8) * (tw + 10), 10 + (i // 8) * (th + 10)), t)
        sheet.save('tests/cards.png')
    print('wrote', len(done), 'cards to', DST)


if __name__ == '__main__':
    main()
