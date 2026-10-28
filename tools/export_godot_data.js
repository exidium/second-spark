// Exports the game data from src/data.js to godot/data/game.json, so the Godot table
// reads the same places, cards and colours as the web game. Usage: node tools/export_godot_data.js
const fs = require('fs'), path = require('path'), vm = require('vm');
const root = path.join(__dirname, '..');
const src = fs.readFileSync(path.join(root, 'src', 'data.js'), 'utf8');
const names = ['LOCS', 'BOARD_POS', 'RESEARCH', 'HUMANITY', 'SCOUNDRELS', 'RIVALS', 'YOU_COLOR', 'LAB_POS', 'MAX_ROUNDS'];
const ctx = {};
vm.runInNewContext(src + `\n;__out = {${names.join(',')}};`, ctx);
const out = JSON.parse(JSON.stringify(ctx.__out)); // drops functions, keeps plain data
const file = path.join(root, 'godot', 'data', 'game.json');
fs.writeFileSync(file, JSON.stringify(out, null, 1) + '\n');
console.log('wrote', path.relative(root, file), Object.keys(out).map(k => `${k}:${Array.isArray(out[k]) ? out[k].length : typeof out[k]}`).join(' '));
