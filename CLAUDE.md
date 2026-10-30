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
`godot/` is the Godot 4.7 project. Since D169 it opens on the town alone (`godot/town/`); the earlier table, board and HUD are archived in `godot/archive/` (git tag `archive/table-d168`). The web page stays as the reference until Bruno approves the Godot version.
```
godot --path godot                # the town (right-drag turn, left/middle drag or WASD move, wheel zoom)
godot --path godot -- --shot      # saves tests/town-1..4.png and quits
node tools/export_godot_data.js   # after any change to src/data.js or art/: writes godot/data/game.json, copies art
npm run godot:sim                 # 20 AI-only games, headless (rules only)
npm run godot:table               # the archived table
tools/gdcheck.sh res://town/town.gd   # parse-check a script without hanging
```
- `town/kit.gd`: mesh kit (walls, gable/hip roofs, pyramids, cylinders, cones, discs, glowing panes), one SurfaceTool per material, `xf` places what comes next. Faces must wind so Godot sees them front-on from their normal side; `tri()` handles it.
- `town/town.gd`: Paris 1819 from the original board (D171), seed 1819, metres, +z south. Positions are board percent converted by `P()` (12 m per percent). `WATER` polygons (scanline-filled into the occupancy grid: 1 street, 2 built, 3 water, 4 kept open, 5 boat), `BRIDGES`, `ROADS`, `PLACES` (name, colour, position, facing), `QUARTERS` (palette by nearest quarter). Streets stop at water (`street()`); quarters are a warped grid with their own lane angle (`_build_districts()`); houses line every street (`gothic_house()`). A model at `godot/assets/models/<place id>.glb` replaces that landmark.
- `town/town_main.gd`: the board's night (blue-grey sky, moon, fog, SSR), rain particles behind `RAIN` (off), camera (FOV 24, pitch -38), landmark names, shot mode (`-- --shot`, add `--nofog`). `town/ink.gdshader`: pen lines, currently unused.
- Textures in `art/town/` (512px webp, mipmaps on in their `.import`), prompts in `docs/prompts/all-images.md` (Town).
- **Reference images** (D172, `art-pipeline/`, images only, Bruno makes the 3D): `python3 art-pipeline/run.py all` (concepts and `out/concepts.png`), `--step views` (front, left, top, only after Bruno approves the concepts), `--step turnaround` (front and left cut from one side-by-side sheet, for buildings whose single views keep the concept's angle), `--step sheet`, `--force` to redo. Run with `GEMINI_API_KEY` in the environment (`zsh -c 'source ~/.zshrc; ...'`). 3D models (D173): 3D AI Studio MCP, Prism 3.1 from the concept, Smart Low Poly to `triangles`, then `blender -b --factory-startup --python art-pipeline/finish.py -- low.glb godot/assets/models/<id>.glb <height> -90 <512 for houses, 1024 for landmarks>`; log task ids in `art-pipeline/models.json`; check with `TOWN_SHOT_AT=<id> godot --path godot -- --shot` (tests/town-5.png). `python3 art-pipeline/ground.py` draws the town ground plan with every building lot (`out/ground.png`, `out/ground.json`).
- `scripts/rules/game.gd`: the rules (port of `src/engine.js`), no drawing. Keep it in step with `engine.js` while both exist.
- GDScript traps: lambdas capture locals by value; `:=` can't infer types from Dictionary or Array values or untyped loop variables (type them: `for s: float in [...]`); don't name a method `free`; new `class_name`s need `godot --headless --path godot --import` before a parse check; in shot mode wait on `process_frame`, not `frame_post_draw`.
- Same conventions as the web page: no em dashes, no italics, minimum 11px type.
