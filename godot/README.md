# Second Spark, Godot diorama

An experiment: the same Paris map as a 3D table in Godot 4.7. No full rules yet.

## Run it
Open this `godot/` folder in Godot (Project Manager, Import, pick `project.godot`) and press Play, or from a terminal:

```
godot --path godot
```

## What it does
- The painted map lies on a wooden table. Each place is a dark disc with its name and one ring per action space (gold rings are scientist only).
- You have a scientist (top hat) and two assistants (flat caps) along the front edge. Click one to lift it, then click a glowing place: it hops along an arc and lands with a small squash.
- The three rivals take turns after you, each move shown in a toast at the bottom.
- When everyone is placed, night falls (the light dims and turns blue, lanterns glow at each place). At dawn the meeples hop home and Day 2 begins.
- Right-drag turns the table, the mouse wheel zooms.

## Files
- `scripts/main.gd`: everything, built in code (table, places, meeples, turns, night and dawn, camera, HUD).
- `assets/board.jpg`: a copy of `art/ui/board.jpg`.
- `godot --path godot -- --shot` plays one move and saves two screenshots to `tests/` (git-ignored).

## Next steps if this continues
1. Port the rules: `src/data.js` cards and numbers into a GDScript data file, then `src/engine.js` phase by phase.
2. Card rows beside each place, popups as Godot Control scenes, the laboratory as its own 3D scene.
3. Exports: Godot builds desktop, mobile and web from the same project.
