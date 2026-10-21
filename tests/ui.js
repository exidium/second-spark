// Plays as the human through the real interface until the game ends, then checks phone width.
// Usage: node tests/ui.js
const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');
const http = require('http');
// Serve dist/ so the page's relative art/ paths resolve.
function serve() { const dist = path.join(__dirname, '..', 'dist'); return new Promise(res => { const srv = http.createServer((q, r) => { const f = path.join(dist, decodeURIComponent(q.url.split('?')[0]).replace(/^\//, '') || 'second-spark.html'); fs.readFile(f, (e, d) => { if (e) { r.writeHead(404); r.end(); return; } const ext = path.extname(f); r.writeHead(200, { 'Content-Type': { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp' }[ext] || 'application/octet-stream' }); r.end(d); }); }); srv.listen(0, () => res({ srv, url: `http://127.0.0.1:${srv.address().port}/second-spark.html` })); }); }
(async () => {
  const { srv, url } = await serve();
  const b = await chromium.launch(); const errs = [];
  const pg = await b.newPage({ viewport: { width: 1300, height: 1500 } });
  pg.on('pageerror', e => errs.push(e.message));
  await pg.goto(url);
  await pg.click('.charpick[data-id=surgeon]');
  await pg.click('[data-act=start]');
  let steps = 0;
  while (steps++ < 4000) {
    const st = await pg.evaluate(() => { const S = window.__spark.S; return S ? { ph: S.phase, r: S.round, cur: S.cur } : null; });
    if (!st || st.ph === 'end') break;
    if (await pg.$('#modalRoot h2')) {
      // Night work lives in the Laboratory popup: build, then throw, then end the night.
      const bb = await pg.$('#modalRoot [data-act=build]'); if (bb) { await bb.click().catch(() => {}); await pg.waitForTimeout(30); continue; }
      const th = await pg.$('#modalRoot [data-act=throw]:not([disabled])'); if (th) { await th.click().catch(() => {}); await pg.waitForTimeout(50); continue; }
      if (st.ph === 'lab' && await pg.$('#modalRoot [data-act=endlab]')) { await pg.click('#modalRoot [data-act=endlab]').catch(() => {}); await pg.waitForTimeout(50); continue; }
      const hasCards = await pg.$('#modalRoot .gcards');
      const el = (hasCards && await pg.$('#modalRoot .gcards .tog:not([disabled])')) || await pg.$('#modalRoot button.opt:not([disabled])') || await pg.$('#modalRoot .btn.primary:not([disabled])') || await pg.$('#modalRoot .btn');
      if (el) await el.click().catch(() => {}); await pg.waitForTimeout(30);
      const done = await pg.$('#modalRoot .actions .btn.primary'); if (done && (await pg.$('#modalRoot .gcards'))) await done.click().catch(() => {});
      continue;
    }
    if (st.ph === 'day' && st.cur === 0) {
      // Click a place on the board (or a lab place); the popup then offers its spaces.
      const sp = await pg.$$('.place.can'); if (sp.length) { await sp[Math.floor(Math.random() * sp.length)].click().catch(() => {}); await pg.waitForTimeout(40); continue; }
    }
    if (st.ph === 'lab') {
      const lb = await pg.$('[data-act=lab]'); if (lb) { await lb.click().catch(() => {}); await pg.waitForTimeout(40); continue; }
      await pg.click('[data-act=endlab]').catch(() => {}); await pg.waitForTimeout(50); continue;
    }
    await pg.waitForTimeout(150);
  }
  console.log('reached:', await pg.evaluate(() => { const S = window.__spark.S; return { phase: S.phase, day: S.round, vp: S.players[0].vp, ending: S.final && S.final.reason, winner: S.final && S.final.rows[0].name, yourTotal: S.final && S.final.rows.find(r => r.i === 0).total }; }), 'steps', steps);
  if (await pg.evaluate(() => window.__spark.S.phase !== 'end')) console.log('WARNING: the game did not end within the step limit');
  await pg.screenshot({ path: path.join(__dirname, 'ui-desktop.png'), fullPage: true });
  const mp = await b.newPage({ viewport: { width: 400, height: 900 } }); await mp.goto(url);
  await mp.evaluate(() => window.__spark.newGame('X', 3, 'zoo', {}));
  await mp.waitForTimeout(400); const t = await mp.$('#modalRoot .btn.primary'); if (t) await t.click(); await mp.waitForTimeout(300);
  const sw = await mp.evaluate(() => document.documentElement.scrollWidth);
  console.log('phone width 400, page scroll width:', sw, sw > 400 ? 'OVERFLOW' : 'ok');
  console.log('phone board scrolls inside its own box:', await mp.evaluate(() => { const b = document.querySelector('.boardscroll'); return b ? (b.scrollWidth > b.clientWidth ? 'yes' : 'no (fits)') : 'MISSING'; }));
  await mp.screenshot({ path: path.join(__dirname, 'ui-phone.png') });
  console.log('page errors:', errs);
  await b.close(); srv.close();
})();
