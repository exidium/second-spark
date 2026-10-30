#!/usr/bin/env python3
"""The Second Spark reference images (D172): concept image, then front, left and top views. Images only; Bruno makes
the 3D models himself from them.

  python3 art-pipeline/run.py all                   concept image of every building in buildings.json
  python3 art-pipeline/run.py cemetery              one building's concept
  python3 art-pipeline/run.py all --step views      front, left and top views (only after the concepts are approved)
  python3 art-pipeline/run.py all --step sheet      one sheet per building, and out/concepts.png with every concept
  add --force to regenerate files that exist (with --step views: --view top to redo a single view)

Images come from Nano Banana 2 (Gemini) through tools/gen_gemini.py; GEMINI_API_KEY must be in the environment.
Every generation is logged to art-pipeline/log.txt. The town ground plan is art-pipeline/ground.py.
"""
import argparse, json, os, sys, time
from pathlib import Path
from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont, ImageStat

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
OUT = HERE / 'out'
LOG = HERE / 'log.txt'
VIEWS = ['front', 'left', 'top']
STEPS = ['concept', 'views', 'sheet']
COPY_LIMIT = 12.5   # a view whose outlines are this close to the concept kept its three-quarter camera
TRIES = 3
FONT = ROOT / 'godot' / 'assets' / 'fonts' / 'Amarante-Regular.ttf'

sys.path.insert(0, str(ROOT / 'tools'))
import gen_gemini  # noqa: E402

DATA = json.loads((HERE / 'buildings.json').read_text(encoding='utf-8'))


def log(bid, step, msg):
    line = f'{time.strftime("%Y-%m-%d %H:%M:%S")}  {bid:10s} {step:9s} {msg}'
    print(line)
    with LOG.open('a', encoding='utf-8') as f:
        f.write(line + '\n')


def key():
    k = os.environ.get('GEMINI_API_KEY')
    if not k:
        sys.exit('GEMINI_API_KEY is not set (source ~/.zshrc first).')
    return k


def font(size):
    try:
        return ImageFont.truetype(str(FONT), size)
    except OSError:
        return ImageFont.load_default()


def generate(bid, step, out, prompt, refs, seed=None):
    t0 = time.time()
    names = ', '.join(Path(r).name for r in refs) or 'none'
    try:
        img = gen_gemini.call(prompt, refs, key(), style_prefix=False, seed=seed, aspect='1:1')
    except Exception as e:  # noqa: BLE001
        log(bid, step, f'FAILED {out.name} (model {gen_gemini.MODEL}, refs: {names}): {str(e)[:160]}')
        return False
    out.write_bytes(img)
    log(bid, step, f'ok {out.name} ({len(img) // 1024} KB, {time.time() - t0:.0f} s, model {gen_gemini.MODEL}, refs: {names})')
    return True


def step_concept(b, d, force, only=None):
    out = d / 'concept.png'
    if out.exists() and not force:
        print('  concept.png exists, skip')
        return True
    prompt = b['prompt'] + ' Do not include: ' + DATA['negative'] + '.'
    return generate(b['id'], 'concept', out, prompt, [], b.get('seed'))


def difference(a, b):
    """Mean difference of the two images' outlines at 64 px, so a paler or line-drawn copy of the concept's camera still
    counts as a copy: below COPY_LIMIT means the view kept the concept's three-quarter camera."""
    g = lambda p: Image.open(p).convert('L').resize((128, 128)).filter(ImageFilter.FIND_EDGES).resize((64, 64))
    return ImageStat.Stat(ImageChops.difference(g(a), g(b))).mean[0]


def copied(d, v):
    return difference(d / 'concept.png', d / f'{v}.png') < COPY_LIMIT


STRICT = ('The attached concept is a three-quarter view from above. Do NOT reuse its camera angle. Redraw the building flat '
          'and square-on, as if the camera stood on the ground far away with a very long lens, facing the {face} directly: '
          'no top surfaces and no second side are visible, the roofs show only as outlines against the background, the base '
          'is a thin horizontal line. Keep everything that stands on the base, at the same places and sizes: every building, '
          'wall, gate, tree, crane, boat, stall and prop. The whole width of the base fills the drawing. ')


def step_views(b, d, force, only=None):
    concept = d / 'concept.png'
    if not concept.exists():
        print('  no concept.png yet, run the concept step first')
        return False
    ok = True
    for v in VIEWS:
        if only and v != only:
            continue
        out = d / f'{v}.png'
        if out.exists() and not force:
            if not copied(d, v):
                print(f'  {v}.png exists, skip')
                continue
            print(f'  {v}.png copies the concept, redo')
        # The left and top views also get the front view, so the footprint and heights stay the same.
        refs = [concept]
        if v != 'front' and (d / 'front.png').exists():
            refs.append(d / 'front.png')
        prompt = DATA['views'][v] + ' Do not include: ' + DATA['negative'] + ', perspective, three-quarter view.'
        if len(refs) > 1:
            prompt = 'The first attached image is the concept, the second is the front elevation of the same building. ' + prompt
        if v != 'top':
            prompt = STRICT.format(face={'front': 'front (the side with the main entrance)', 'left': 'left side'}[v]) + prompt
        for t in range(TRIES):
            done = generate(b['id'], 'views', out, prompt, refs)
            if not done or not copied(d, v):
                break
            log(b['id'], 'views', f'{v}.png copies the concept (difference {difference(d / "concept.png", out):.1f}), try {t + 2}')
        ok = done and not copied(d, v) and ok
    return ok


def step_sheet(b, d, force, only=None):
    files = [d / 'concept.png'] + [d / f'{v}.png' for v in VIEWS]
    if not files[0].exists():
        print('  no concept.png yet')
        return False
    S, s, pad, head = 900, 440, 20, 40
    sheet = Image.new('RGB', (S + 2 * s + 4 * pad, S + 2 * pad + head), (40, 40, 44))
    draw = ImageDraw.Draw(sheet)
    f = font(26)
    draw.text((pad, 6), f'{b["id"]}  ({b["name"]})', fill=(235, 225, 200), font=f)
    sheet.paste(Image.open(files[0]).convert('RGB').resize((S, S)), (pad, pad + head))
    draw.text((pad + 8, pad + head + 6), 'concept', fill=(255, 255, 255), font=f)
    for i, v in enumerate(VIEWS):
        x = S + 2 * pad + (i % 2) * (s + pad)
        y = pad + head + (i // 2) * (s + pad)
        if files[i + 1].exists():
            sheet.paste(Image.open(files[i + 1]).convert('RGB').resize((s, s)), (x, y))
        else:
            draw.rectangle((x, y, x + s, y + s), outline=(90, 90, 96))
        draw.text((x + 8, y + 6), v, fill=(255, 255, 255), font=f)
    sheet.save(d / 'sheet.png')
    print(f'  sheet.png written')
    return True


def overview():
    """Every concept on one page, for the approval round."""
    items = [b for b in DATA['buildings'] if (OUT / b['id'] / 'concept.png').exists()]
    if not items:
        return
    cols, s, pad, cap = 5, 360, 16, 34
    rows = (len(items) + cols - 1) // cols
    img = Image.new('RGB', (cols * (s + pad) + pad, rows * (s + cap + pad) + pad), (40, 40, 44))
    draw = ImageDraw.Draw(img)
    f = font(22)
    for i, b in enumerate(items):
        x = pad + (i % cols) * (s + pad)
        y = pad + (i // cols) * (s + cap + pad)
        img.paste(Image.open(OUT / b['id'] / 'concept.png').convert('RGB').resize((s, s)), (x, y + cap))
        draw.text((x, y + 4), f'{b["id"]}  {b["name"]}', fill=(235, 225, 200), font=f)
    img.save(OUT / 'concepts.png')
    print(f'overview written: {OUT / "concepts.png"}')


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('target', help='a building id, or "all"')
    ap.add_argument('--step', choices=STEPS, default='concept')
    ap.add_argument('--view', choices=VIEWS, help='with --step views: only this view')
    ap.add_argument('--force', action='store_true', help='regenerate files that exist')
    a = ap.parse_args()
    ids = [b['id'] for b in DATA['buildings']]
    if a.target != 'all' and a.target not in ids:
        sys.exit(f'unknown id {a.target}; known: {", ".join(ids)}')
    todo = DATA['buildings'] if a.target == 'all' else [b for b in DATA['buildings'] if b['id'] == a.target]
    fn = {'concept': step_concept, 'views': step_views, 'sheet': step_sheet}[a.step]
    for b in todo:
        d = OUT / b['id']
        d.mkdir(parents=True, exist_ok=True)
        print(f'== {b["id"]} ({b["name"]})')
        fn(b, d, a.force, a.view)
    if a.step in ('concept', 'sheet'):
        overview()


if __name__ == '__main__':
    main()
