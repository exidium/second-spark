# Second Spark (Godot)

The game, in Godot 4.7: one human against 1 to 3 AI rivals, 1819 Paris, a 3D table in a pixel look.
Same rules and art as the web build in `../src` (D158).

## Play
Open this folder in Godot (Project Manager, Import, pick `project.godot`) and press Play, or from a terminal at the repo root:

```
godot --path godot
```

Click one of your meeples (or pick it in the side column), then click a glowing place or one of its rings. Each place opens a popup with what it does, its cards and its spaces. Right-drag turns the table, the mouse wheel zooms. At night the Laboratory button opens your operating table.

## Test
```
npm run godot:sim     # 20 AI-only games, headless: stuck games, endings, winners
npm run godot:ui      # one full game played as you through the real popups (prints AUTOPLAY END ...)
godot --path godot -- --shot         # screenshots of your first turn, a place popup, the rivals and the lab, in ../tests/
godot --path godot -- --shot-title   # the title screen
```

## Files
- `scripts/rules/game.gd`: every rule, the AI and scoring, ported from `src/engine.js`. No drawing.
- `scripts/rules/null_presenter.gd`: the list of everything the rules ask a presenter (and the silent one used by the simulation).
- `scripts/main.gd`: the presenter: title screen, layout, popups, your turn, the night, the end.
- `scripts/view/board.gd`: the 3D table, meeples, card rows, night and day.
- `scripts/ui/`: style, card faces, popups, side column, laboratory, meeple icon.
- `data/game.json` and `assets/art/`: exported from `src/data.js` and `art/` by `node tools/export_godot_data.js`. Run it after changing either.
- `assets/fonts/`: Amarante and EB Garamond (Open Font License).
- `tests/sim.gd`: the headless simulation.
