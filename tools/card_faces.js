// Renders every research and humanity card exactly as the browser game draws it, rounded corners and all, to
// godot/assets/cabin/cards/<id>.png for the stats board's card spaces (D201).
// Usage: python3 build.py && node tools/card_faces.js
const path = require('path');
const fs = require('fs');
const http = require('http');
const { chromium } = require('playwright');

const OUT = path.join(__dirname, '..', 'godot', 'assets', 'cabin', 'cards');

function serve() {
  const dist = path.join(__dirname, '..', 'dist');
  return new Promise(res => {
    const srv = http.createServer((q, r) => {
      const f = path.join(dist, decodeURIComponent(q.url.split('?')[0]).replace(/^\//, '') || 'second-spark.html');
      fs.readFile(f, (e, d) => {
        if (e) { r.writeHead(404); r.end(); return; }
        const ext = path.extname(f);
        r.writeHead(200, { 'Content-Type': { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp' }[ext] || 'application/octet-stream' });
        r.end(d);
      });
    });
    srv.listen(0, () => res({ srv, url: `http://127.0.0.1:${srv.address().port}/second-spark.html` }));
  });
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const { srv, url } = await serve();
  const b = await chromium.launch();
  const pg = await b.newPage({ viewport: { width: 400, height: 600 }, deviceScaleFactor: 3 });
  await pg.goto(url);
  await pg.evaluate(() => document.fonts.ready);
  // Nothing behind the card, so its rounded corners come out clear.
  await pg.addStyleTag({ content: 'html,body{background:transparent!important;background-image:none!important} body>*:not(#cardshot){display:none!important} body::before,body::after{display:none!important}' });
  const cards = await pg.evaluate(() => window.__spark.handCards().map(c => c.id));
  for (const id of cards) {
    await pg.evaluate(id => {
      const c = window.__spark.handCards().find(k => k.id === id);
      let box = document.getElementById('cardshot');
      if (!box) {
        box = document.createElement('div');
        box.id = 'cardshot';
        box.style.cssText = 'position:fixed;left:20px;top:20px;z-index:99999;background:transparent';
        document.body.appendChild(box);
      }
      box.innerHTML = window.__spark.cardHTML(c, {});
      const card = box.querySelector('.fcard');
      card.style.boxShadow = 'none';
    }, id);
    await pg.waitForTimeout(60);
    const el = await pg.$('#cardshot .fcard');
    await el.screenshot({ path: path.join(OUT, `${id}.png`), omitBackground: true });
  }
  console.log(`wrote ${cards.length} cards to ${OUT}`);
  await b.close();
  srv.close();
})();
