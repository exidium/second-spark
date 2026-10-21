# Image prompts: 96-pixel, 32-colour pixel art (Nano Banana 2)

One prompt per image, 156 in all (the six characters are at the end). Style: retro pixel art on a 96-pixel canvas with a strict 32-colour gothic palette. Each prompt is complete (subject, style, canvas, avoid list) because Nano Banana 2 has no negative-prompt field. Save each result under the **file name** given into `art/source/`; Claude then snaps it to the exact canvas and 32 colours and writes the game copy into `art/`.

## Before you start

1. Generators never output a true 96-pixel image: they draw big pixels on a large canvas. That is fine. Ask for the look; the exact size and the 32-colour quantisation are applied afterwards by script (`tools/pixelize.py`).
2. Make the Cemetery first. When one looks right, keep it in the chat and start every later prompt with "Same style and palette as this image". That is what keeps 150 images as one set. Keep a second reference for the cadavers, which use a darker palette with no blue.
3. Canvases: locations and lab spaces 96x54, cadavers and scoundrels 64x96 portrait with the lower fifth plain (the numbers sit there), everything else 96x72.
4. At this size every image needs one silhouette and one light. If a result is busy, say "simplify, one focal point" and regenerate.

## Locations (12) · used in location popups

### Cemetery → `location-cemetery.png`

```
The Cemetery of Père Lachaise at night: leaning tombstones, a stone cross, a bare tree, a half-dug grave with a spade in the earth, a lantern on the ground. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square → `location-square.png`

```
The Place de Grève at night after an execution: the guillotine on its scaffold, the Hôtel de Ville behind, a dispersing crowd. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue → `location-morgue.png`

```
The Paris Morgue: bodies on stone slabs under sheets, an arched window, a hanging lantern, a keeper with a ledger. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Slaughterhouse → `location-slaughter.png`

```
The Montmartre slaughterhouse: carcasses on hooks, a blood-dark floor drain, a butcher sharpening a cleaver. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital → `location-hospital.png`

```
The Hôpital de la Charité at night: a long ward of beds, sisters in white cornettes, a porter with a covered trolley. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Academy → `location-academy.png`

```
The domed Institut de France on the Seine at night, lit windows, a scholar on the steps. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Market → `location-market.png`

```
Les Halles market at night: ice carts, fish stalls, an instrument maker’s stall with Leyden jars. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Docks → `location-docks.png`

```
Port Saint-Nicolas on the Seine at night: moored barges, crates, a lantern on a post, figures in the fog. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dark Alley → `location-alley.png`

```
A narrow alley in the Faubourg Saint-Marcel: a single wall lamp, a cloaked figure, a body in a doorway. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Saint-Roch → `location-church.png`

```
The church of Saint-Roch on the Rue Saint-Honoré at night, candles glowing through the open doors. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### First Player → `location-first.png`

```
The square before Notre-Dame at night, the Creature’s hulking silhouette at the foot of the towers. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Théâtre de l’Odéon → `location-odeon.png`

```
The Théâtre de l’Odéon lit for opening night, columns, carriages and an elegant crowd. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Lab spaces (4) · used in lab place popups

### Practice → `lab-practice.png`

```
An anatomy book open beside a skull and calipers on a laboratory bench. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Give Blood → `lab-blood.png`

```
A lancet in a forearm, blood running into a pewter bowl. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Repair → `lab-repair.png`

```
Curved needles and catgut stitching a torn limb on the operating table. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Charge Jars → `lab-charge.png`

```
Two Leyden jars on a bench crackling with blue electricity from a turning static generator. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 54 pixels, wide establishing view of the place at night, small figures at most. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Cadavers (52) · used in cadaver cards

### Cemetery · stage IV · Cemetery 01 → `cemetery-01.png`

```
An elderly washerwoman in a collapsed pine coffin, sunken eye sockets, grave dirt in her grey hair, freshly dug up by lantern light, grave dirt and roots around, months in the ground, flesh shrunken and blackened, skin parchment-thin and torn, teeth bared. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage IV · Cemetery 02 → `cemetery-02.png`

```
A middle-aged stonemason, jaw slack and fallen open, burial shirt stained black with fluids, freshly dug up by lantern light, grave dirt and roots around, months in the ground, flesh shrunken and blackened, skin parchment-thin and torn, teeth bared. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage IV · Cemetery 03 → `cemetery-03.png`

```
A young conscript of the Grande Armée in a rotting uniform, a sabre scar across his cheek split wide, freshly dug up by lantern light, grave dirt and roots around, months in the ground, flesh shrunken and blackened, skin parchment-thin and torn, teeth bared. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage IV · Cemetery 04 → `cemetery-04.png`

```
A stout innkeeper in a burst burial suit, belly collapsed, beetles in the folds of cloth, freshly dug up by lantern light, grave dirt and roots around, months in the ground, flesh shrunken and blackened, skin parchment-thin and torn, teeth bared. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage bones · Cemetery 05 → `cemetery-05.png`

```
A jumble of brown bones and a cracked skull in a collapsed coffin, roots growing through the ribs, a few strands of hair and rags of skin still clinging. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage bones · Cemetery 06 → `cemetery-06.png`

```
A skeleton still wrapped in a rotted shroud, finger bones clutching a tarnished rosary, a few strands of hair and rags of skin still clinging. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage bones · Cemetery 07 → `cemetery-07.png`

```
A pile of femurs, ribs and vertebrae dumped beside an open grave, soil clinging to them, a few strands of hair and rags of skin still clinging. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage bones · Cemetery 08 → `cemetery-08.png`

```
A skull and long bones in a broken lead-lined coffin, a corroded name plate beside them, a few strands of hair and rags of skin still clinging. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage III · Cemetery 09 → `cemetery-09.png`

```
A woman in her thirties, a dried rose still pinned in her hair, cheeks swollen and split, freshly dug up by lantern light, grave dirt and roots around, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage III · Cemetery 10 → `cemetery-10.png`

```
A grey-bearded Seine sailor, tattooed forearm gone purple-black, cheeks torn, freshly dug up by lantern light, grave dirt and roots around, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage III · Cemetery 11 → `cemetery-11.png`

```
A young man with a rope burn around his neck, face swollen dark, tongue thick between his teeth, freshly dug up by lantern light, grave dirt and roots around, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage III · Cemetery 12 → `cemetery-12.png`

```
A seamstress with needle-scarred fingers, skin waxy and torn at the lips, hair matted with soil, freshly dug up by lantern light, grave dirt and roots around, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage III · Cemetery 13 → `cemetery-13.png`

```
A gaunt old priest in a mouldering cassock, flesh shrinking back from the fingernails, freshly dug up by lantern light, grave dirt and roots around, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cemetery · stage IV · Cemetery 14 → `cemetery-14.png`

```
A corpulent merchant in rotted burial silk, body burst and leaking, rings sunk into swollen fingers, freshly dug up by lantern light, grave dirt and roots around, months in the ground, flesh shrunken and blackened, skin parchment-thin and torn, teeth bared. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 01 → `hospital-01.png`

```
An old woman with a fever-ravaged face, a blood-soaked bandage around her throat, eye swollen shut, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 02 → `hospital-02.png`

```
A moustached porter with a surgical saw wound across his shoulder, sutures torn open, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 03 → `hospital-03.png`

```
A young clerk with a bullet wound at the temple, a crust of blood down his cheek, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 04 → `hospital-04.png`

```
A young woman dead of cholera, skin blue-grey and drawn tight, eyes sunken, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 05 → `hospital-05.png`

```
A bald old man with a sunken chest, bruised black where the surgeon’s ribs-spreader went in, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 06 → `hospital-06.png`

```
A coal porter with a crushed chest, broken ribs pushing against bloodied linen, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 07 → `hospital-07.png`

```
A long-haired young man with a deep gash from brow to jaw, stitches half done, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 08 → `hospital-08.png`

```
A washerwoman with a bloody amputation stump at the elbow, the bandage slipping, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 09 → `hospital-09.png`

```
An old soldier with gangrene creeping black up his neck from an old wound, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 10 → `hospital-10.png`

```
A woman with a slashed throat clumsily sutured, dried blood in the pillow, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 11 → `hospital-11.png`

```
A stout baker, face mottled purple from apoplexy, foam dried at the lips, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 12 → `hospital-12.png`

```
A thin young man with a bloody chest tube wound, ribs showing through the skin, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage I · Hospital 13 → `hospital-13.png`

```
A woman with tight curls, lips split and swollen from a beating, bruised eye, lying on a stained hospital pillow under coarse linen, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital · stage II · Hospital 14 → `hospital-14.png`

```
A white-haired old man with a stab wound under the ribs, linen stiff with blood, lying on a stained hospital pillow under coarse linen, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 01 → `morgue-01.png`

```
A drowned woman from the Seine, wild wet hair full of river weed, face swollen and blotched, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 02 → `morgue-02.png`

```
A drowned old bargeman, skin wrinkled white and peeling from the water, eyes clouded, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 03 → `morgue-03.png`

```
A young woman with a deep stab wound at the throat, dark blood clotted in her collarbone, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 04 → `morgue-04.png`

```
A woman with her lower face torn and bloody from a fall, teeth broken, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 05 → `morgue-05.png`

```
A broad-shouldered man with knife wounds across his shoulder, flesh flayed back, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 06 → `morgue-06.png`

```
A middle-aged woman pulled from the river after a week, bloated and green-veined, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 07 → `morgue-07.png`

```
An old labourer with a crushed skull, matted hair, a dent above the ear, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage III · Morgue 08 → `morgue-08.png`

```
A pale young girl of twenty with a slashed neck, black hair fanned on the slab, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a week, bloated, marbled green veins under the skin, skin slipping at the edges. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 09 → `morgue-09.png`

```
A young rake with a duelling wound in his chest, shirt torn open, bruising spreading, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 10 → `morgue-10.png`

```
A woman frozen in the street, lips black, frost still in her lashes, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 11 → `morgue-11.png`

```
An old man found in a cellar, face half-eaten by rats, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 12 → `morgue-12.png`

```
A young woman with a garrotte mark cutting deep into her neck, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 13 → `morgue-13.png`

```
A drowned student, face swollen tight, a wound at the temple from the bridge pillar, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Morgue · stage II · Morgue 14 → `morgue-14.png`

```
A burly carter crushed under his own wagon, chest caved in, a broken arm folded wrong, lying on a cold stone morgue slab, a sheet pulled down to the chest, dead a day or two, lividity pooling purple, lips greying. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 01 → `square-01.png`

```
An executed highwayman, the guillotine cut clean through his neck, head laid back against the stump, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 02 → `square-02.png`

```
An executed young woman forger, dark hair cropped for the blade, blood pooling under the neck, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 03 → `square-03.png`

```
An executed army deserter, neck severed, eyes half open, shirt collar cut away, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 04 → `square-04.png`

```
An executed poisoner, grey hair hacked short, a crust of blood along the cut, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 05 → `square-05.png`

```
An executed counterfeiter, heavy jaw slack, the clean red ring of the blade at his neck, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 06 → `square-06.png`

```
An executed arsonist, soot still on his face, neck wound raw and wet, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 07 → `square-07.png`

```
An executed woman murderer, hair shorn, collar torn open, blood on the cobbles beneath, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 08 → `square-08.png`

```
An executed robber with a broken nose, bruises from the crowd, neck stump dark, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 09 → `square-09.png`

```
An executed street thief, very young, the cut neck glistening in the lantern light, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Square · stage I · Public Square 10 → `square-10.png`

```
Big Gustave the butcher of Rungis, executed, an enormous man with a vast slack face, the blade wound across a thick neck, dumped on wet cobblestones beside the scaffold, straw soaked dark, freshly dead, skin still waxy-pale, blood barely dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients. Strict 32-colour palette: soot black, charcoal, grave-dirt brown, grey-green, livid purple, jaundiced yellow, clotted oxblood, bone white, dirty linen, slate grey, lantern gold; no blue anywhere, these bodies have no spark of life. Lit hard from one side by a single lantern, dithering for the falloff. An anatomist's study of the dead: unflinching but clean-edged, never cartoon gore. One clear silhouette readable at thumbnail size. Canvas 64 by 96 pixels, portrait, the body seen from above as it lies, head and upper torso, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Scoundrels (16) · used in Docks cards

### Hospital Thief → `scoundrel-01.png`

```
A hulking hospital porter with a black beard carrying a sheet-wrapped corpse over his shoulder. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital Thief → `scoundrel-02.png`

```
A hard-faced nurse in a stained apron and cap, a covered trolley behind her. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital Thief → `scoundrel-03.png`

```
A sly hospital orderly with a ring of keys, a sheet-covered trolley behind him. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hospital Thief → `scoundrel-04.png`

```
A pale girl with bloody sleeves pushing a trolley under a dirty sheet. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dog Catcher → `scoundrel-05.png`

```
A dog catcher in a ragged hat and coat with a long net pole, a cage of strays behind. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dog Catcher → `scoundrel-06.png`

```
A heavy old dog catcher with a coil of rope and a muzzle pole, his cart behind him. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dog Catcher → `scoundrel-07.png`

```
A sharp-faced young woman with a black fringe holding a muzzle pole. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dog Catcher → `scoundrel-08.png`

```
A boy in a feathered hat and green coat with a snare noose. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cutthroat → `scoundrel-09.png`

```
A smiling gentleman in a dark coat, a thin knife glinting in his gloved hand. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cutthroat → `scoundrel-10.png`

```
A hooded woman in a burgundy cloak, blade hidden in the folds. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cutthroat → `scoundrel-11.png`

```
A woman in a black cloak and red scarf in an alley doorway, a bloody cleaver at her side. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cutthroat → `scoundrel-12.png`

```
A scarred knife-sharpener with a whetstone, rolled sleeves stained red. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Body Snatcher → `scoundrel-13.png`

```
A gravedigger with a long spade over his shoulder, moonlit fog behind. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Body Snatcher → `scoundrel-14.png`

```
A body snatcher in a battered top hat and green coat, rope and hook in hand. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Body Snatcher → `scoundrel-15.png`

```
A tidy young widow in mourning blue with a sack over her shoulder. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### The Bone Collector → `scoundrel-16.png`

```
An old man in a wide-brimmed hat leaning on a stick, a sack of bones at his feet. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 64 by 96 pixels, portrait, head and shoulders centred, the lower fifth kept dark and plain. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Research (16) · used in Academy cards

### Countermeasures → `research-01.png`

```
A wax-sealed letter of warning lying on a desk beside a dagger. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Unethical Experiment → `research-02.png`

```
A living man strapped to a table, a galvanic arc crawling over his chest. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Pickling Jars → `research-03.png`

```
Shelves of glass pickling jars holding organs in cloudy fluid. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Steady Hands → `research-04.png`

```
An anatomist’s hands drawing a curved needle through a stitched seam of flesh. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Private Pupil → `research-05.png`

```
A rich young pupil in fine clothes watching a demonstration, purse on the table. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Guest Lecturer → `research-06.png`

```
A crowded candlelit lecture theatre, a shrouded body on the demonstration table. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Healing Salve → `research-07.png`

```
A pot of salve, linen bandages and a scalpel beside a stitched limb. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Burning the Candle → `research-08.png`

```
A candle burnt to the stub over heaps of notes and an open skull. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Fresh as Morning → `research-09.png`

```
Fresh white flowers laid on a pale chest, morning light through a window. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Close Dissection → `research-10.png`

```
An open dissection with organs pinned and labelled on a board. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Evening Study → `research-11.png`

```
A scholar asleep over an anatomy book by candlelight. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Practical Study → `research-12.png`

```
A dead cat pinned on a dissection board, scalpels laid out. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Electrolysis → `research-13.png`

```
An electrolysis cell bubbling around a heart in a glass dish, blue sparks. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Public Galvanism → `research-14.png`

```
A dead dog twitching on a table before a gasping crowd, blue current in the wires. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Transfusion → `research-15.png`

```
A brass transfusion apparatus joining two arms with a tube of blood. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Publish a Paper → `research-16.png`

```
A hand press printing an anatomical treatise, fresh pages hanging to dry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Humanity (16) · used in Saint-Roch cards

### Whisper to the Captain → `humanity-01.png`

```
Whispering to an old grey-bearded sea captain in a fur-collared coat in a tavern corner. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Fund the Captain → `humanity-02.png`

```
Coins pressed into the gloved hand of an old sea captain. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Tell the Captain Everything → `humanity-03.png`

```
Confessing at a table to an old sea captain with a pistol on the table. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Petition the Prefect → `humanity-04.png`

```
A petition being signed before a stern prefect at a desk. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### A Trap of Your Own → `humanity-05.png`

```
A spring trap and tripwire set inside a laboratory door. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Royal Pardon → `humanity-06.png`

```
A royal pardon with a red wax seal, the guillotine blurred behind. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### A Decent Burial → `humanity-07.png`

```
A plain coffin lowered into a grave with a handful of flowers. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Night at the Graves → `humanity-08.png`

```
A lantern vigil among tombstones at night, a cloaked watcher. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Shame the Morgue → `humanity-09.png`

```
The morgue doors chained shut with a notice nailed to them. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Mercy for Beasts → `humanity-10.png`

```
Cage doors opened and stray dogs running into the night. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Walk the Quays → `humanity-11.png`

```
A lone figure with a lantern walking the foggy quays of the Seine. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cut the Wires → `humanity-12.png`

```
Cut copper wires dangling from a Leyden jar, pliers beside it. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cross Their Path → `humanity-13.png`

```
A hand on a chest blocking a narrow street doorway. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### The Dignity of the Dead → `humanity-14.png`

```
A speaker at a lectern beside a shrouded body, hand raised. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Urchin Raid → `humanity-15.png`

```
Street urchins running off down an alley with stolen specimen jars. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### A Careless Lantern → `humanity-16.png`

```
An overturned lantern setting a pile of research papers alight. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Events (19) · used in the day card

### A Porter for Hire → `event-01.png`

```
A hospital porter pocketing coins beside a covered trolley. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Glut of Meat → `event-02.png`

```
Carcasses piled high in a slaughterhouse yard under a stormy sky with lightning. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Hard Times → `event-03.png`

```
A queue of hungry Parisians outside a shuttered bakery. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### An Anonymous Letter → `event-04.png`

```
An anonymous letter unfolded on a table in candlelight. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Patrols at the Graves → `event-05.png`

```
Gendarmes with lanterns patrolling between tombstones, lightning in the sky. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Fire at the Academy → `event-06.png`

```
The Academy library ablaze at night, books burning. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cattle Plague → `event-07.png`

```
Dead cattle lying in a muddy field, flies. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Cholera → `event-08.png`

```
Rows of cholera victims under sheets in a hospital ward, lightning at the windows. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Student Parade → `event-09.png`

```
Students with banners and torches outside the Academy, gendarmes waiting. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Loyalty Pledges → `event-10.png`

```
Citizens signing loyalty pledges under a Bourbon flag, a guillotine in the square. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Student Riots → `event-11.png`

```
Students throwing stones at a barricade, smoke and torches. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### A Dead Man’s Notes → `event-12.png`

```
A dead man’s notebook with anatomical sketches, lightning outside the window. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### All Saints’ Day → `event-13.png`

```
Candles on graves on All Saints’ night, mourners in black. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### A Widow’s Bequest → `event-14.png`

```
A widow in black handing a purse to a professor, a guillotine visible through the window. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### The Captain’s Wrath → `event-15.png`

```
An old sea captain smashing a Leyden jar with the butt of his pistol. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Opening Night at the Odéon → `event-16.png`

```
The Théâtre de l’Odéon lit for opening night, carriages and a crowd. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### The Flesh Is Willing → `event-17.png`

```
A stitched body on a slab, its fingers beginning to curl toward a blue spark. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Storm from the Sea → `event-18.png`

```
A storm sweeping in from the sea over the Seine, boats tossed, lightning. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Inquiry at the Hospital → `event-19.png`

```
Gendarmes sealing the hospital doors with a notice of inquiry. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Encounters (15) · used in the day card

### Encounter 01 → `encounter-01.png`

```
The Creature, huge and scarred, leaning bleeding in a doorway, a hand pressed to his side. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 02 → `encounter-02.png`

```
The Creature in a shadowed corner of a laboratory, beckoning. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 03 → `encounter-03.png`

```
A boy pressing a folded note into a hand on a crowded boulevard. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 04 → `encounter-04.png`

```
The Creature’s silhouette in a rain-lashed window lit by lightning. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 05 → `encounter-05.png`

```
A sweltering laboratory, flies over a slab, the Creature fanning the air. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 06 → `encounter-06.png`

```
The Creature walking into a laboratory with a dripping sack. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 07 → `encounter-07.png`

```
An old sea captain bleeding from the arm, crouching behind laboratory shelves with a pistol. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 08 → `encounter-08.png`

```
An old sea captain confronting a scholar between tall library shelves. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 09 → `encounter-09.png`

```
A hospital stairwell crowded with the dying after a massacre, nurses running. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 10 → `encounter-10.png`

```
A woman in a dark hood stepping out of river fog by the quay. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 11 → `encounter-11.png`

```
The Creature sitting quietly in the corner of a laboratory, watching. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 12 → `encounter-12.png`

```
An old sea captain sitting by a bed at night with a pistol across his lap. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 13 → `encounter-13.png`

```
The Creature hurling a book that bursts into a cloud of pages. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 14 → `encounter-14.png`

```
The Creature holding out a heavy burlap bag that moves. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Encounter 15 → `encounter-15.png`

```
An open grave at night with three pale fresh bodies, eyes watching from the dark. Retro pixel art, drawn pixel by pixel on a tiny grid, crisp hard-edged pixels, no anti-aliasing, no blur, no gradients, no smooth shading. Strict 32-colour palette: soot black, charcoal, deep plum, bruised purple, oxblood red, dried-blood brown, tarnished brass, candle gold, bone white, parchment, slate blue-grey, and one cold galvanic blue reserved for electricity or life. Gothic 1819 Paris, Mary Shelley mood: a single warm lamp or candle lights the scene out of near-black shadow, dithering for the falloff. Melancholic and unsettling, suggested rather than graphic. Clean silhouettes readable at thumbnail size, one clear focal point, nothing fussy. Canvas 96 by 72 pixels, one clear object or moment, simple dark background. Do not include: text, letters, numbers, captions, logos, watermark, signature, card frame, border, UI, anti-aliasing, blur, gradients, soft shading, photorealism, 3D render, painterly brushwork, pencil strokes, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

## Characters (6) · used in the character picker, your character popup and the rivals

### Lucien Vautrin (Psychopath) → `character-psycho.png`

```
Lucien Vautrin, a polished young man with a neat moustache and a cruel calm smile, a carnation in his lapel, a bloodstain on his cuff. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Amara Okafor (Humanitarian) → `character-human.png`

```
Amara Okafor, a calm West African physician with a warm steady gaze, a dark high-collared dress, a leather doctor's bag strap across her shoulder. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Sir Bartholomew Pike (Zoologist) → `character-zoo.png`

```
Sir Bartholomew Pike, a weathered English naturalist with grey sideburns, a top hat and travelling coat, a glass jar with an eel beside him. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Lucrezia Fontana (Heiress) → `character-heiress.png`

```
Lucrezia Fontana, a young Italian heiress in a wide-brimmed hat and pearls, an open anatomy book held near her face. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Count Achille Duval (Charlatan) → `character-charlatan.png`

```
Count Achille Duval, a theatrical aristocrat with a waxed moustache, a top hat and a fur collar, rings on his fingers. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```

### Dr Hélène Marchand (Surgeon) → `character-surgeon.png`

```
Dr Hélène Marchand, a severe French surgeon with her hair pinned back, a blood-flecked leather apron, a scalpel raised near her shoulder. Detailed dithered pixel art in the style of a dark gothic video game portrait: visible checkerboard dithering on the skin and shadows, hard-edged pixels, no anti-aliasing, no smooth gradients. Warm sepia, umber and tarnished-brass palette with deep black shadows, limited to about 32 colours, plus ONE small cold electric-blue glow somewhere in the background (a Leyden jar or a window). Extreme close-up of the head and shoulders, the face large and filling most of the frame, turned three-quarters to the side, a serious intense expression, eyes open, a living person with a realistic, individual face. Behind them a dim laboratory: glass bottles, brass apparatus, a lit candle, a night window, all out of focus and dark. Lit from one side by candlelight. Canvas 64 by 96 pixels, portrait. Do not include: text, letters, numbers, captions, logos, watermark, card frame, border, UI, cartoon style, chibi, flat colours, full body, wide shot, small face, bright saturated colours, daylight, white background, modern clothing, modern objects.
```
