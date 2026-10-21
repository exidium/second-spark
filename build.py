#!/usr/bin/env python3
"""Build dist/second-spark.html from src/. Usage: python3 build.py"""
import base64, json, mimetypes
from pathlib import Path
root = Path(__file__).parent
src = root / 'src'
art = root / 'art'
imgs = {}
# Every image under art/ (any subfolder except source/) is embedded, keyed by its file stem, e.g. art/characters/character-surgeon.png -> IMG['character-surgeon'].
for f in sorted(p for p in art.rglob('*') if art.exists() and p.suffix.lower() in ('.jpg', '.jpeg', '.png', '.webp') and 'source' not in p.relative_to(art).parts):
    imgs[f.stem] = f'data:{mimetypes.guess_type(f.name)[0]};base64,' + base64.b64encode(f.read_bytes()).decode()
js = '// Generated images from art/ (empty when none). Keys are file stems, e.g. character-surgeon.\nconst IMG = ' + json.dumps(imgs) + ';\n'
js += '\n'.join((src / f).read_text(encoding='utf-8') for f in ['data.js', 'art.js', 'engine.js', 'ui.js'])
html = (src / 'head.html').read_text(encoding='utf-8') + '\n<div id="tip" hidden></div>\n<script>\n(() => {\n"use strict";\n' + js + '\n})();\n</script>\n'
if '—' in html:
    raise SystemExit('Em dash found in the build. Player-facing text must not use em dashes.')
out = root / 'dist' / 'second-spark.html'
out.parent.mkdir(exist_ok=True)
out.write_text(html, encoding='utf-8')
print(f'Built {out} ({len(html):,} bytes, {len(imgs)} images embedded)')
