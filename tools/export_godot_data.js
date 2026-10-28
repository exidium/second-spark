// Exports the game data from src/data.js to godot/data/game.json and copies art/ (minus art/source)
// to godot/assets/art, so the Godot game uses the same numbers, cards and pictures as the web build.
// Usage: node tools/export_godot_data.js
const fs = require('fs'), path = require('path'), vm = require('vm');
const root = path.join(__dirname, '..');
const src = fs.readFileSync(path.join(root, 'src', 'data.js'), 'utf8');
const names = ['MAX_ROUNDS', 'MATS', 'MAT_N', 'KEY', 'ROMAN', 'SLOT6', 'BODY_CENTRES', 'SLOT_T', 'SLOT_N', 'PARTS', 'GRAY', 'BLUE',
  'CADAVERS', 'OWNERS', 'SCOUNDRELS', 'SC_WHO', 'RESEARCH', 'MIT_N', 'HUMANITY', 'EVENTS', 'ENCOUNTERS', 'CHARACTERS', 'OBJECTIVES',
  'LOCS', 'BOARD_POS', 'LAB_POS', 'LABSPOTS', 'BUMP_TRACK', 'RIVALS', 'YOU_COLOR'];
const ctx = {};
vm.runInNewContext(src + `\n;__out = {${names.join(',')}};`, ctx);
const out = JSON.parse(JSON.stringify(ctx.__out)); // drops functions (encounter tests live in GDScript by id)
const file = path.join(root, 'godot', 'data', 'game.json');
fs.mkdirSync(path.dirname(file), { recursive: true });
fs.writeFileSync(file, JSON.stringify(out, null, 1) + '\n');
console.log('wrote', path.relative(root, file), Object.keys(out).length, 'tables');

// Art: copy changed files only.
const from = path.join(root, 'art'), to = path.join(root, 'godot', 'assets', 'art');
let copied = 0, total = 0;
(function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name), rel = path.relative(from, p);
    if (e.isDirectory()) { if (rel !== 'source') walk(p); continue; }
    if (!/\.(png|jpe?g|webp)$/i.test(e.name)) continue;
    total++;
    const dest = path.join(to, rel);
    if (fs.existsSync(dest) && fs.statSync(dest).size === fs.statSync(p).size) continue;
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.copyFileSync(p, dest); copied++;
  }
})(from);
console.log(`art: ${total} images, ${copied} copied to godot/assets/art`);
