# Character portraits: paste sheet for Higgsfield

Six images, one per scientist. Generate them in the Higgsfield app, save each under the file name given, and drop it into the `art/` folder at the project root. Claude wires them into the game after that.

## Settings (same for all six)

- **Model:** Nano Banana Pro (2:3 supported, 2k, takes image references). Fallback: Seedream 4.5.
- **Aspect:** 2:3
- **Resolution:** 2k
- **Consistency trick:** generate Dr Hélène Marchand first and re-run until the pencil look is right. Then attach that image as a reference for the other five so they read as one set.
- **Negative prompt** (paste into the negative field if the model has one; otherwise add "Avoid: ..." at the end of the prompt):

```
text, letters, words, captions, logos, watermark, signature, card frame, border, UI, photorealistic, 3D render, CGI, glossy, airbrushed, smooth digital painting, anime, cartoon, chibi, bright saturated colours, daylight, white background, gore, exposed organs in detail, modern clothing, modern objects
```

## Style block (already inside every prompt below, shown once for reference)

```
Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 1. Surgeon, Dr Hélène Marchand → `art/character-surgeon.png`

```
Dr Hélène Marchand, a severe French surgeon in a blood-flecked leather apron, scalpel in hand, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 2. Psychopath, Lucien Vautrin → `art/character-psycho.png`

```
Lucien Vautrin, a polished young man with a neat moustache and a cruel calm smile, a carnation in his lapel, bloodstain on his cuff, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 3. Zoologist, Sir Bartholomew Pike → `art/character-zoo.png`

```
Sir Bartholomew Pike, a weathered English naturalist in a top hat and travelling coat, an eel in a jar under his arm, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 4. Charlatan, Count Achille Duval → `art/character-charlatan.png`

```
Count Achille Duval, a theatrical aristocrat in a top hat and fur collar, rings on every finger, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 5. Humanitarian, Amara Okafor → `art/character-human.png`

```
Amara Okafor, a calm West African physician in a dark dress with a doctor's bag, warm steady gaze, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## 6. Heiress, Lucrezia Fontana → `art/character-heiress.png`

```
Lucrezia Fontana, a young Italian heiress in a wide-brimmed hat and pearls, an open anatomy book in her hands, alive, eyes open, a living person. Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss. Format: 2:3 portrait, head and shoulders, centred, lower 20% dark and simple.
```

## What to check before saving

- All six share the same paper tone, stroke texture and darkness.
- Eyes open, faces read as living people.
- No text, no frame, no border.
- Only a hint of blue, if any.
