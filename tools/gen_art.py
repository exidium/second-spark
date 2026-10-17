#!/usr/bin/env python3
"""Generate card art through the Higgsfield platform API.

Usage:
  python3 tools/gen_art.py characters            # all six scientists
  python3 tools/gen_art.py characters --only surgeon zoo
  python3 tools/gen_art.py characters --model ideogram

Credentials: HF_KEY, or HF_API_KEY + HF_API_SECRET, in the environment (same as the SDK).
Output: art/<file>.png next to this project. Existing files are skipped unless --force.
"""
import argparse, json, os, sys, time, urllib.request, urllib.error
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'art'
API = os.environ.get('HF_API_BASE', 'https://api.higgsfield.ai')

STYLE = ('Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, '
  'waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit '
  'lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of '
  'soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where '
  'electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather '
  'than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss.')
AVOID = ('Avoid: text, letters, words, captions, logos, watermark, signature, card frame, border, UI, photorealism, 3D render, '
  'CGI, glossy airbrushed digital painting, anime, cartoon, bright saturated colours, daylight, white background, gore, '
  'modern clothing, modern objects.')
PORTRAIT = 'Format: 2:3 portrait, head and shoulders, centred, face turned slightly, lower 20% dark and simple.'
PALETTE = [[18,16,22],[74,52,84],[122,42,36],[205,166,92],[236,230,214],[159,208,255]]

DECKS = {
  'characters': {'aspect': '2:3', 'format': PORTRAIT, 'items': {
    'surgeon':   'Dr Hélène Marchand, a severe French surgeon in a blood-flecked leather apron, scalpel in hand, alive, eyes open, a living person.',
    'psycho':    'Lucien Vautrin, a polished young man with a neat moustache and a cruel calm smile, a carnation in his lapel, bloodstain on his cuff, alive, eyes open, a living person.',
    'zoo':       'Sir Bartholomew Pike, a weathered English naturalist in a top hat and travelling coat, an eel in a glass jar under his arm, alive, eyes open, a living person.',
    'charlatan': 'Count Achille Duval, a theatrical aristocrat in a top hat and fur collar, rings on every finger, alive, eyes open, a living person.',
    'human':     'Amara Okafor, a calm West African physician in a dark dress with a doctor\'s bag, warm steady gaze, alive, eyes open, a living person.',
    'heiress':   'Lucrezia Fontana, a young Italian heiress in a wide-brimmed hat and pearls, an open anatomy book in her hands, alive, eyes open, a living person.',
  }, 'prefix': 'character'},
}

MODELS = {
  'recraft':  lambda prompt, ar: ('recraft/v4.1/pro/text-to-image', {'prompt': prompt, 'resolution': '2k', 'aspect_ratio': ar, 'output_format': 'png', 'colors': [{'rgb': c} for c in PALETTE]}),
  'ideogram': lambda prompt, ar: ('ideogram/v4.0', {'prompt': prompt, 'aspect_ratio': ar, 'rendering_speed': 'QUALITY'}),
  'cinema':   lambda prompt, ar: ('higgsfield-ai/soul/cinema', {'prompt': prompt, 'aspect_ratio': ar, 'resolution': '1080p'}),
}

def key():
    k = os.environ.get('HF_KEY')
    if k: return k
    a, b = os.environ.get('HF_API_KEY'), os.environ.get('HF_API_SECRET')
    if a and b: return f'{a}:{b}'
    sys.exit('Higgsfield credentials missing: set HF_KEY, or HF_API_KEY and HF_API_SECRET.')

def call(method, url, body=None):
    req = urllib.request.Request(url, method=method, data=json.dumps(body).encode() if body is not None else None,
        headers={'Authorization': f'Key {key()}', 'Content-Type': 'application/json', 'User-Agent': 'second-spark-gen/1'})
    try:
        with urllib.request.urlopen(req, timeout=120) as r: return json.loads(r.read())
    except urllib.error.HTTPError as e:
        raise RuntimeError(f'HTTP {e.code} from {url}: {e.read().decode(errors="replace")[:300]}')

def generate(endpoint, args):
    sub = call('POST', f'{API}/{endpoint}', args)
    status_url = sub.get('status_url') or f"{API}/requests/{sub['request_id']}/status"
    t0 = time.time()
    while True:
        st = call('GET', status_url)
        s = st.get('status')
        if s == 'completed': return st
        if s in ('failed', 'cancelled', 'nsfw'): raise RuntimeError(f'{s}: {json.dumps(st)[:400]}')
        if time.time() - t0 > 600: raise RuntimeError('timed out waiting for generation')
        time.sleep(2)

def main():
    ap = argparse.ArgumentParser(); ap.add_argument('deck', choices=DECKS); ap.add_argument('--only', nargs='*')
    ap.add_argument('--model', default='recraft', choices=MODELS); ap.add_argument('--force', action='store_true')
    a = ap.parse_args(); d = DECKS[a.deck]; OUT.mkdir(exist_ok=True)
    for id_, subject in d['items'].items():
        if a.only and id_ not in a.only: continue
        out = OUT / f"{d['prefix']}-{id_}.png"
        if out.exists() and not a.force: print(f'skip {out.name} (exists)'); continue
        prompt = f"{subject} {STYLE} {d['format']} {AVOID}"
        endpoint, args = MODELS[a.model](prompt, d['aspect'])
        print(f'{id_}: {endpoint} ...', end=' ', flush=True)
        try:
            res = generate(endpoint, args)
            url = res['images'][0]['url']
            urllib.request.urlretrieve(url, out)
            print(f'saved {out.relative_to(ROOT)} ({out.stat().st_size//1024} KB)')
        except Exception as e:
            print(f'FAILED: {e}')

if __name__ == '__main__': main()
