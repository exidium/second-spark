// AI-only simulation. Usage: node tests/sim.js [games=20]
// Plays full games with every player controlled by the AI and reports length, endings, winners and page errors.
const path = require('path');
const fs = require('fs');
const { chromium } = require('playwright');
const http = require('http');
// Serve dist/ so the page's relative art/ paths resolve.
function serve() { const dist = path.join(__dirname, '..', 'dist'); return new Promise(res => { const srv = http.createServer((q, r) => { const f = path.join(dist, decodeURIComponent(q.url.split('?')[0]).replace(/^\//, '') || 'second-spark.html'); fs.readFile(f, (e, d) => { if (e) { r.writeHead(404); r.end(); return; } const ext = path.extname(f); r.writeHead(200, { 'Content-Type': { '.html': 'text/html; charset=utf-8', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp' }[ext] || 'application/octet-stream' }); r.end(d); }); }); srv.listen(0, () => res({ srv, url: `http://127.0.0.1:${srv.address().port}/second-spark.html` })); }); }
(async () => {
  const { srv, url } = await serve();
  const b = await chromium.launch(); const pg = await b.newPage();
  const errs = []; pg.on('pageerror', e => errs.push(e.message + ' | ' + (e.stack || '').split('\n').slice(0, 3).join(' ')));
  await pg.goto(url);
  const N = +process.argv[2] || 20;
  const res = await pg.evaluate(async (N) => {
    const out = [];
    for (let g = 0; g < N; g++) {
      const X = window.__spark; X.newGame('Sim', 3, 'random', { fast: true, allAI: true });
      let t = 0; while (X.S.phase !== 'end' && t++ < 4000) { await new Promise(r => setTimeout(r, 0)); }
      const S = X.S; if (S.phase !== 'end') { out.push({ stuck: S.phase, round: S.round }); continue; }
      out.push({ round: S.final.round, reason: S.final.reason, rows: S.final.rows.map(r => [r.name, r.total, r.vp, r.alive, r.humPts, r.obj]), chars: S.players.map(p => p.char) });
    }
    return out;
  }, N);
  const stuck = res.filter(r => r.stuck); console.log('stuck games:', stuck.length, JSON.stringify(stuck.slice(0, 3)));
  const ok = res.filter(r => !r.stuck);
  console.log('endings (day + A=alive / C=captain):', ok.map(r => r.round + (r.reason === 'alive' ? 'A' : 'C')).join(', '));
  const wins = {}; ok.forEach(r => wins[r.rows[0][0]] = (wins[r.rows[0][0]] || 0) + 1); console.log('wins:', wins);
  console.log('average parts alive:', (ok.flatMap(r => r.rows.map(x => x[3])).reduce((a, b) => a + b, 0) / (ok.length * 4)).toFixed(2));
  console.log('page errors:', errs.filter(e => !e.includes('ERR_')).slice(0, 6));
  await b.close(); srv.close();
})();
