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
- `src/ui.js`: promise modals (`ask`, `askYN`), threshold tooltip, human input (`clickSpace`, `humanPre`), all rendering (`render`, `labPanel`, `locCards`, `rivalsPanel`), title and end screens, boot.

All four JS files are concatenated into one IIFE by `build.py`, so they share scope. Order matters only for top-level `const`s used at load time.

## Conventions
- **Player-facing text:** no em dashes (the build fails if one appears). Short, plain sentences. Every option shows its exact gain and cost.
- **Yes/no questions** use Accept / Refuse with the effect written in the question. **Encounter choices** keep their story wording.
- **Tooltips** only on the blue threshold squares of the expertise and reputation bars. Nowhere else. A place explains itself on the scrap of paper inside its popup.
- **Original names and art** for anything creative. Mechanics and numbers may match the physical game.
- Keep the single dark visual identity and the colour meanings: muscle red, skin yellow, alive blue, damage yellow lightning.
- State must stay JSON-serializable. If its shape changes, bump `SAVE_KEY` and `S.v` together.
- Test hooks live on `window.__spark`. Don't remove them.

## Publishing
`dist/` is the whole deliverable: the page plus `dist/art/`. Open it through a server or as a folder, never as pasted HTML.
- **Public test build:** `npm run deploy` rebuilds and pushes `dist/` to the `gh-pages` branch, served at https://exidium.github.io/second-spark/. Commit to `main` first so the source matches.
- **Single file:** `python3 build.py --embed` if someone needs one self-contained HTML (several MB).
