#!/usr/bin/env python3
"""Generate card art with Google's Nano Banana (Gemini image models) from docs/prompts/all-images.md.

Usage:
  python3 tools/gen_gemini.py --only location-cemetery              # one image (style test)
  python3 tools/gen_gemini.py --set Locations --ref art/source/location-cemetery.png
  python3 tools/gen_gemini.py --all --ref art/source/location-cemetery.png --cadaver-ref art/source/hospital-01.png

Reads GEMINI_API_KEY from the environment. Saves originals to art/source/<set folder>/<file>.png, skips files that exist
unless --force. Pass --ref to attach a finished image as the style reference ("same style and palette as this image").
Run tools/pixelize.py afterwards to make the 96-pixel game copies.
"""
import argparse, base64, json, os, re, sys, time, urllib.request, urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SHEET = ROOT / 'docs' / 'prompts' / 'all-images.md'
MODEL = os.environ.get('NB_MODEL', 'gemini-3.1-flash-image')
API = f'https://generativelanguage.googleapis.com/v1beta/models/{MODEL}:generateContent'
ASPECT = {(96, 54): '16:9', (64, 96): '2:3', (72, 96): '3:4', (96, 72): '4:3', (64, 64): '1:1'}
# Sheet section -> folder under art/source/ (originals) and art/ (game copies)
FOLDER = {'Locations': 'locations', 'Lab spaces': 'locations', 'Cadavers': 'cadavers', 'Scoundrels': 'scoundrels', 'Research': 'research', 'Humanity': 'humanity', 'Events': 'events', 'Encounters': 'encounters', 'Characters': 'characters', 'Board': 'ui', 'Frames': 'frames', 'Icons': 'icons', 'City': 'city', 'Town': 'town'}

def parse_sheet():
    txt = SHEET.read_text(encoding='utf-8'); items = []; section = None
    for block in re.split(r'\n(?=## |### )', txt):
        if block.startswith('## '): section = block.split('(')[0][3:].strip(); continue
        m = re.match(r'### (.+?) → `([^`]+)`\n\n```\n(.*?)\n```', block, re.S)
        if m: items.append({'set': section, 'label': m.group(1), 'file': m.group(2), 'prompt': m.group(3).strip()})
    return items

def aspect_of(prompt):
    m = re.search(r'Canvas (\d+) by (\d+) pixels', prompt); return ASPECT.get((int(m.group(1)), int(m.group(2))), '1:1') if m else '1:1'

def call(prompt, ref, key, style_prefix=True, seed=None, aspect=None):
    """ref: None, one path, or a list of paths (sent in order). style_prefix adds the 'same style' sentence used by the
    card sheet; the art pipeline's view prompts carry their own wording and pass False."""
    parts = []
    refs = [] if not ref else (list(ref) if isinstance(ref, (list, tuple)) else [ref])
    for r in refs:
        r = Path(r)
        parts.append({'inline_data': {'mime_type': 'image/png' if r.suffix == '.png' else 'image/jpeg', 'data': base64.b64encode(r.read_bytes()).decode()}})
    if refs and style_prefix:
        prompt = 'Same style and palette as the attached image. ' + prompt
    parts.append({'text': prompt})
    gen = {'responseModalities': ['IMAGE'], 'imageConfig': {'aspectRatio': aspect or aspect_of(prompt)}}
    if seed is not None:
        gen['seed'] = int(seed)
    body = {'contents': [{'parts': parts}], 'generationConfig': gen}
    req = urllib.request.Request(API + f'?key={key}', data=json.dumps(body).encode(), headers={'Content-Type': 'application/json'})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=180) as r: d = json.loads(r.read())
            break
        except urllib.error.HTTPError as e:
            msg = e.read().decode(errors='replace')[:300]
            if e.code in (429, 500, 503) and attempt < 3: time.sleep(8 * (attempt + 1)); continue
            raise RuntimeError(f'HTTP {e.code}: {msg}')
    for c in d.get('candidates', []):
        for p in c.get('content', {}).get('parts', []):
            if 'inlineData' in p: return base64.b64decode(p['inlineData']['data'])
    raise RuntimeError('no image in response: ' + json.dumps(d)[:300])

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--only', nargs='*', default=[]); ap.add_argument('--set', dest='sets', nargs='*', default=[])
    ap.add_argument('--all', action='store_true'); ap.add_argument('--ref'); ap.add_argument('--cadaver-ref'); ap.add_argument('--force', action='store_true'); ap.add_argument('--limit', type=int, default=0)
    a = ap.parse_args(); key = os.environ.get('GEMINI_API_KEY') or sys.exit('GEMINI_API_KEY not set')
    items = parse_sheet()
    todo = [i for i in items if a.all or i['set'] in a.sets or Path(i['file']).stem in a.only]
    if a.limit: todo = todo[:a.limit]
    print(f'{len(todo)} images with {MODEL}'); done = fail = 0
    for i in todo:
        out = ROOT / 'art' / 'source' / FOLDER.get(i['set'], 'misc') / i['file']; out.parent.mkdir(parents=True, exist_ok=True)
        if out.exists() and not a.force: print(f'skip {i["file"]} (exists)'); continue
        ref = Path(a.cadaver_ref) if (i['set'] == 'Cadavers' and a.cadaver_ref) else (Path(a.ref) if a.ref else None)
        print(f'{i["file"]} ...', end=' ', flush=True)
        try:
            out.write_bytes(call(i['prompt'], ref, key)); done += 1; print(f'ok ({out.stat().st_size // 1024} KB)')
        except Exception as e:
            fail += 1; print(f'FAILED: {e}')
    print(f'done {done}, failed {fail}')

if __name__ == '__main__': main()
