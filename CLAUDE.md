# Second Spark

A solo browser adaptation of *Abomination: The Heir of Frankenstein*: one human against 1 to 3 AI rivals, 1819 Paris, build a companion and bring her to life before Captain Walton finds the Creature.

- **What the game is and does:** `docs/SPEC.md` (source of truth for rules, data and UI).
- **Why it is the way it is:** `docs/DECISIONS.md`. Add a new entry whenever a rule, number or UI behaviour changes, with the reason and who asked.
- **Reference material** (one folder up, not part of the build): `../3341956500.json` (Tabletop Simulator save) and `../imageAssets/` (card sheets). Use them to check numbers. Never copy their art or card text into the game.

## Build and test
```
python3 build.py          # writes dist/second-spark.html and copies art/ to dist/art/ (--embed for one self-contained file)
npm install               # once, for Playwright
npm run test:sim          # 20 AI-only games: errors, stuck games, balance
npm run test:ui           # plays as the human through the UI until the game ends, checks 400px width
```
Run both tests before calling a change done. A healthy build has no page errors, no stuck games, games ending around Days 10 to 12, and no horizontal overflow at 400px.

## Code map
- `src/head.html`: title, fonts, all CSS (tokens at the top of `:root`), root containers.
- `src/data.js`: every number and card. Change balance here first.
- `src/art.js`: inline SVG art (locations, lab spaces, portraits, card icons, dice).
- `src/engine.js`: state `S`, async phase loop (`loop()`), space effects (`resolveSpace`), cadaver resolution, building (`planBuild`, `build`), the switch (`startThrow`, `resolveThrow`), dawn, encounters (`OUT` outcomes), card play, AI (`aiChoose`, `aiSpaceOptions`, `aiLab`), scoring, save.
- `src/ui.js`: promise modals (`ask`, `askYN`), threshold tooltip, human input (`clickSpace`, `humanPre`), all rendering (`render`, `labPanel`, `locCards`, `rivalsPanel`), title and end screens, motion snapshot (`seen`, `diffForRender`, `isNew`, `PACE`), boot.

All four JS files are concatenated into one IIFE by `build.py`, so they share scope. Order matters only for top-level `const`s used at load time.

## Conventions
- **Player-facing text:** no em dashes, no italics, and no font size below 11px, except 10px on the board's mini cards, marked `/*mini*/` (the build fails on an em dash or a smaller size). Short, plain sentences. Every option shows its exact gain and cost.
- **Yes/no questions** use Accept / Refuse with the effect written in the question. **Encounter choices** keep their story wording.
- **Tooltips** only on the blue threshold squares of the expertise and reputation bars and on the Cards tile (what is in your hand). Nowhere else. A place explains itself in the white line over its popup scene.
- **Original names and art** for anything creative. Mechanics and numbers may match the physical game.
- Keep the single dark visual identity and the colour meanings: muscle red, skin yellow, alive blue, damage yellow lightning.
- State must stay JSON-serializable. If its shape changes, bump `SAVE_KEY` and `S.v` together.
- Test hooks live on `window.__spark`. Don't remove them.

## Publishing
`dist/` is the whole deliverable: the page plus `dist/art/`. Open it through a server or as a folder, never as pasted HTML.
- **Public test build:** `npm run deploy` rebuilds and pushes `dist/` to the `gh-pages` branch, served at https://exidium.github.io/second-spark/. Commit to `main` first so the source matches.
- **Single file:** `python3 build.py --embed` if someone needs one self-contained HTML (several MB).

## Godot version (the real game from now on, D158)
`godot/` is the Godot 4.7 game: same rules, same art, pixel look. The web page stays as the reference until Bruno approves the Godot version.
```
node tools/export_godot_data.js   # after any change to src/data.js or art/: writes godot/data/game.json, copies art
godot --path godot                # play
npm run godot:sim                 # 20 AI-only games, headless
npm run godot:ui                  # one full game played as the human through the real popups
tools/gdcheck.sh res://scripts/main.gd   # parse-check a script without hanging
```
- `scripts/rules/game.gd`: the rules (port of `src/engine.js`), no drawing. Human choices and animations go through the presenter (`null_presenter.gd` lists every method). Keep it in step with `engine.js` while both exist.
- `scripts/main.gd`: the presenter and controller: title, layout, every popup, your turn, the night, the end, autoplay and screenshot modes (`-- --shot`, `-- --shot-title`).
- `scripts/view/board.gd`: the 3D table, synced from the state with animations. Drawn at half resolution (`SHRINK`) for the pixel look.
- `scripts/ui/`: `style.gd` (tokens, fonts, widgets), `cards.gd` (card faces), `modal.gd` (popups), `hud.gd` (side column), `lab.gd` (laboratory), `meeple_icon.gd`.
- GDScript traps: lambdas capture locals by value (a button can't hold its own popup: use `_close_from`); `:=` can't infer types from Dictionary values; new `class_name`s need `godot --headless --path godot --import` before a parse check.
- Same conventions as the web page: no em dashes, no italics, minimum 11px type, tooltips only on threshold squares and the Cards tile.
