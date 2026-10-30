# The Second Spark: 3D landmark art pipeline

Paste the section **Brief for Claude Code** into Claude Code. Save the section **prompts.md** as `art-pipeline/prompts.md` in the project (or let Claude Code do it from this file).

---

## Brief for Claude Code

```
Set up an art pipeline for The Second Spark that turns concept prompts into 3D landmark models for Godot. Use the Nano Banana connection you already have for all image generation. Work in a new folder art-pipeline/ at the project root. Don't touch src/ or dist/.

CHECK FIRST
1. Tell me which Nano Banana tool you have (skill, MCP or API), whether it accepts a reference image for image-to-image, and whether it can fix the aspect ratio to 1:1. Report before generating anything.

DATA
2. Create art-pipeline/buildings.json with one entry per building: id, name, concept prompt. The 13 buildings and full prompts are in art-pipeline/prompts.md, along with the shared negative prompt and the four view prompts (front, back, left, right).

SCRIPT (art-pipeline/run.py)
3. For each building:
   a. Concept: generate with the concept prompt, 1:1, save to art-pipeline/out/<id>/concept.png. Skip if it exists.
   b. Views: for each of front, back, left, right, generate with concept.png as the reference image and the matching view prompt. Save as <id>/front.png, <id>/back.png, <id>/left.png, <id>/right.png. Skip existing files.
   c. Contact sheet: compose concept + four views into <id>/sheet.png so I can check consistency at a glance.
   d. 3D: leave a slot for Hunyuan 3D 3.1 Pro multi-view. For now, if <id>/model.glb exists (I'll generate it in the Hunyuan web app and drop it in), continue; otherwise print the four file paths to upload and stop for that building. Structure the step so I can later plug in an API call with the same four inputs.
   e. Decimate: if Blender is installed (`which blender`), run it headless with a Python script that imports model.glb, applies Decimate down to about 2,000 triangles for landmarks and 600 for the filler house, and exports <id>/model_low.glb. If Blender isn't installed, say so and skip.
4. Commands: `run all`, `run <id>`, `run <id> --step views`. Never regenerate an existing file unless I pass --force. Log every generation to art-pipeline/log.txt.
5. Run only the graveyard first (`run cemetery`), stop, and show me sheet.png before doing the rest.

GODOT
6. Create godot/assets/landmarks/ and copy each model_low.glb there with a README listing building ids and the credit "generated with Nano Banana and Hunyuan 3D". In Godot, override each model's material with a flat-colour StandardMaterial3D in the game palette (slate grey, bone, dark umber, brass; blue only for the academy dome, red only for the guillotine) so the models match the pixel shader. Keep the generated textures on disk but don't use them by default.

REVIEW RULE
After each contact sheet, the building's footprint, roof heights and main parts must match across all four views. If a view invents a new wing or drops a tower, regenerate only that view with --force, attaching both the concept and the front view as references.
```

---

## prompts.md

### Shared style block

Every concept prompt is: subject sentence + this block.

```
Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

### Shared negative prompt

```
background scenery, city, street, ground plane beyond the base, fog, smoke, night, dramatic lighting, cast shadows, glow, people, carriages, text, labels, watermark, frame, multiple separate buildings, cropped, cut off, photorealistic, fine ornament
```

### Concept prompts (full, ready to paste)

**cemetery** (Graveyard)
```
Concept art of a single isolated game building: a walled graveyard with a small stone chapel, rows of tombstones, two mausoleums and three bare black trees, all on a flat square cobbled base, with an iron gate on the front side. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**square** (Public Square)
```
Concept art of a single isolated game building: a cobbled town square on a flat square base with a wooden scaffold and a tall guillotine with a dark red frame and a steel blade, a few wooden barrels and a lamppost, the scaffold steps facing the front. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**slaughter** (Slaughterhouse)
```
Concept art of a single isolated game building: three long low stone slaughterhouse sheds side by side with dark slate roofs, wide doors facing the front, and wooden animal pens in front of them, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**church** (Saint-Roch)
```
Concept art of a single isolated game building: a baroque church with a tall square bell tower, a pediment facade with pilasters facing the front, and a wide flight of steps, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**first** (First Player, cathedral)
```
Concept art of a single isolated game building: a Gothic cathedral with twin square towers and a rose window on the front, a tall nave with flying buttresses and a small spire, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**morgue** (Morgue)
```
Concept art of a single isolated game building: a low grim stone morgue, a single-storey block with one arched door on the front, small barred windows and a flat slate roof, standing on a stone quay edge, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**market** (Market)
```
Concept art of a single isolated game building: a long open market hall, a slate roof on thin iron pillars with no walls, rows of wooden market stalls with awnings underneath, the long side facing the front, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**hospital** (Hospital)
```
Concept art of a single isolated game building: a wide two-storey hospital built around an open square courtyard with a few trees, a small chapel with a cross on the roof at one front corner, and an arched gate in the middle of the front side, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**academy** (Academy)
```
Concept art of a single isolated game building: a neoclassical academy with a colonnade of columns across the front, a triangular pediment and a central dome with a faint cold blue glass lantern on top, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**docks** (Docks)
```
Concept art of a single isolated game building: a stone quay with a tall wooden harbour crane, two flat barges moored along the front edge, stacked crates, barrels and coils of rope, and a small customs hut at the back, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**alley** (Dark Alley)
```
Concept art of a single isolated game building: one crooked leaning five-storey house with a sagging slate roof, boarded windows, a single dark doorway on the front and a dead lantern beside it, flanked by two short stubs of alley wall, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**odeon** (Odéon)
```
Concept art of a single isolated game building: a theatre with a columned portico on the front, a wide flight of steps, a flat-topped block behind with a shallow slate roof, and two lampposts at the foot of the steps, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

**house** (filler house, run with 4 or 5 different seeds as house-1 to house-5)
```
Concept art of a single isolated game building: a tall narrow Parisian town house of five storeys, two windows wide, shutters, a shop door on the ground floor at the front, a steep slate roof with two dormers and chimney pots, on a flat square base. Seen from a three-quarter front view slightly from above, centred, filling most of the frame, on a plain flat mid-grey background with no ground beyond the base, no surroundings and no other objects. Low-poly stylised 3D look, flat shaded surfaces, clean simple geometry, clear silhouette, no fine detail. Soft even studio lighting from all sides, no cast shadows, no fog, no glow, no night. Architecture of Paris in 1819: pale dirty stone and grey plaster, steep dark slate roofs, dormer windows, chimney pots. Muted palette of slate grey, bone, dark umber and tarnished brass. Square 1:1.
```

### View prompts (attach concept.png as the reference; same for every building)

**front**
```
Using the attached concept as the exact reference, show the same building, unchanged in shape, colours and details, seen straight from the front (the side with the main entrance) at eye level with the camera level with the base, perfectly centred, on the same plain flat mid-grey background, same soft even lighting, no cast shadows, no perspective distortion, orthographic look. Square 1:1.
```

**back**
```
Using the attached concept as the exact reference, show the same building, unchanged in shape, colours and details, seen straight from the back (the side opposite the main entrance) at eye level with the camera level with the base, perfectly centred, on the same plain flat mid-grey background, same soft even lighting, no cast shadows, no perspective distortion, orthographic look. Square 1:1.
```

**left**
```
Using the attached concept as the exact reference, show the same building, unchanged in shape, colours and details, seen straight from the left side (the main entrance is on the right of this view) at eye level with the camera level with the base, perfectly centred, on the same plain flat mid-grey background, same soft even lighting, no cast shadows, no perspective distortion, orthographic look. Square 1:1.
```

**right**
```
Using the attached concept as the exact reference, show the same building, unchanged in shape, colours and details, seen straight from the right side (the main entrance is on the left of this view) at eye level with the camera level with the base, perfectly centred, on the same plain flat mid-grey background, same soft even lighting, no cast shadows, no perspective distortion, orthographic look. Square 1:1.
```

### buildings.json ids

cemetery, square, slaughter, church, first, morgue, market, hospital, academy, docks, alley, odeon, house-1, house-2, house-3, house-4, house-5

---

## Hunyuan 3D 3.1 Pro (web app, until the API slot is filled)

1. Choose multi-view. Upload front, back, left, right into their slots.
2. Choose textured output, PBR off (flat colours are overridden in Godot anyway).
3. Export GLB. Save as `art-pipeline/out/<id>/model.glb`.
4. Run `run <id>` again; the script picks up from the GLB, decimates and copies to Godot.

## Checks

- All four views: same footprint, same roof heights, same number of towers, chimneys and trees.
- Grey background kept in every view (white eats the pale stone).
- After decimation, landmarks at about 2,000 triangles, filler houses at about 600.
- In Godot, a door should be roughly the same height on every building; scale models to match.
