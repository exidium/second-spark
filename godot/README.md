# Second Spark, Godot diorama

An experiment: the same Paris map as a 3D table in Godot 4.7. No full rules yet.

## Run it
Open this `godot/` folder in Godot (Project Manager, Import, pick `project.godot`) and press Play, or from a terminal:

```
godot --path godot
```

## What it does
- The painted map lies on a wooden table. Each place is a dark disc with its name and one ring per action space (gold rings are scientist only).
- You have a scientist (top hat) and two assistants (flat caps) along the front edge. Click one to lift it, then click a glowing ring (one ring per action space) or the place's disc for its first free space. It hops along an arc and lands with a small squash.
- Hover a space or a card to see what it does, in the panel at the top left.
- Card rows: Research beside the Academy, Humanity beside Saint-Roch, Scoundrels beside the Docks. Researching or atoning takes the first card and leaves an empty spot until dawn; a hired scoundrel is replaced at once. Your cards lie in a fan along the front edge.
- The three rivals take turns after you, each move shown in a toast at the bottom.
- When everyone is placed, night falls (the light dims and turns blue, lanterns glow at each place). At dawn the meeples hop home and Day 2 begins.
- Right-drag turns the table, the mouse wheel zooms.

## Files
- `scripts/main.gd`: everything, built in code (table, places, meeples, turns, night and dawn, camera, HUD).
- `data/game.json`: places, spaces, cards and rivals exported from `src/data.js`. Regenerate it after changing the web game's data: `node tools/export_godot_data.js`.
- `assets/board.jpg`: a copy of `art/ui/board.jpg`.
- `godot --path godot -- --shot` plays one move and saves three screenshots to `tests/` (git-ignored).

## Next steps if this continues
1. Port the rules: `src/engine.js` phase by phase (resources, space effects, cadavers, the laboratory).
2. Popups as Godot Control scenes, the laboratory as its own 3D scene.
3. Exports: Godot builds desktop, mobile and web from the same project.
