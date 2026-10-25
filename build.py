#!/usr/bin/env python3
"""Build dist/ from src/. Usage: python3 build.py [--embed]

Writes dist/second-spark.html and copies every image under art/ (except art/source/) to dist/art/<set>/.
The page refers to images by relative path, so dist/ must be served or opened as a folder.
--embed inlines the images as data URIs instead (one self-contained file, several MB)."""
import base64, hashlib, json, mimetypes, shutil, sys
from pathlib import Path
root = Path(__file__).parent
src = root / 'src'
art = root / 'art'
embed = '--embed' in sys.argv
out_dir = root / 'dist'
out_dir.mkdir(exist_ok=True)
imgs = {}
files = sorted(p for p in art.rglob('*') if art.exists() and p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp') and 'source' not in p.relative_to(art).parts)
if not embed:
    dest = out_dir / 'art'
    if dest.exists(): shutil.rmtree(dest)
for f in files:
    rel = f.relative_to(art)
    if embed:
        imgs[f.stem] = f'data:{mimetypes.guess_type(f.name)[0]};base64,' + base64.b64encode(f.read_bytes()).decode()
    else:
        (out_dir / 'art' / rel.parent).mkdir(parents=True, exist_ok=True)
        shutil.copy2(f, out_dir / 'art' / rel)
        # a short content hash in the query string, so browsers refetch an image when it changes and keep it otherwise
        imgs[f.stem] = f'art/{rel.as_posix()}?v={hashlib.md5(f.read_bytes()).hexdigest()[:8]}'
# IMG maps a file stem (e.g. character-surgeon, hospital-03, bg-wall) to a URL the page can use.
js = '// Images from art/ (file stem -> url). Empty when none.\nconst IMG = ' + json.dumps(imgs) + ';\n'
js += '\n'.join((src / f).read_text(encoding='utf-8') for f in ['data.js', 'art.js', 'engine.js', 'ui.js'])
html = '<!doctype html>\n' + (src / 'head.html').read_text(encoding='utf-8') + '\n<div id="tip" hidden></div>\n<script>\n(() => {\n"use strict";\n' + js + '\n})();\n</script>\n'
if '—' in html:
    raise SystemExit('Em dash found in the build. Player-facing text must not use em dashes.')
import re as _re
_small=[d for d in _re.findall(r'font-size:[^;}"]*', html) if '/*mini*/' not in d and any(float(x)<11 for x in _re.findall(r'([0-9.]+)px', d))]
if _small:
    raise SystemExit('Font size below 11px in the build: ' + ', '.join(_small[:5]) + '. The minimum is 11px.')
out = out_dir / 'second-spark.html'
out.write_text(html, encoding='utf-8')
total = sum(f.stat().st_size for f in files)
print(f'Built {out} ({len(html):,} bytes, {len(imgs)} images {"embedded" if embed else f"copied to dist/art, {total:,} bytes"})')
