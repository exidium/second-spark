# Card art style: dark coloured-pencil

One shared style block keeps all 140+ illustrations consistent. Every card prompt = **subject line** + **style block** + **format line**, with the **negative prompt** if your tool supports one.

`card-list.xlsx` has a ready-to-paste **Prompt** for every card (156 images: 140 cards, 12 locations, 4 lab spaces), plus its negative prompt, aspect and file name. Prompts are formulas built from the **Style** sheet, so editing a style there updates every prompt.

Two styles: the **standard** block below for everything, and a darker, **visceral cadaver** block (section 2b) for the 52 cadaver cards.

---

## 1. Style block (paste after every subject)

```
Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris, Mary Shelley mood. Low-key candlelit lighting: a single warm light source (candle, lantern or lamp) carving figures out of near-black shadow. Muted palette of soot black, bruised plum, oxblood red, tarnished brass and bone white, with one small accent of cold galvanic blue where electricity or life appears. Subtle vignette fading to black at the edges. Melancholic, unsettling, quietly beautiful rather than gory: wounds and death are suggested with restraint, never graphic. Hand-made imperfections, no digital gloss.
```

## 2. Negative prompt

```
text, letters, words, captions, logos, watermark, signature, card frame, border, UI, photorealistic, 3D render, CGI, glossy, airbrushed, smooth digital painting, anime, cartoon, chibi, bright saturated colours, daylight, white background, gore, exposed organs in detail, modern clothing, modern objects
```

## 2b. Cadaver style and negative (cadaver cards only)

Same pencil technique, but darker and unflinching. The restraint sentence is replaced and gore is removed from the negative, while cartoon gore stays banned so it reads as an anatomist's study, not a splatter film.

```
Dark hand-drawn coloured-pencil illustration on black-toned paper. Visible pencil strokes and dense cross-hatching, waxy layered colour, soft grain of the paper showing through. Gothic 1819 Paris anatomical horror, Mary Shelley mood. Even darker than daylight allows: the body emerges from deep black, lit hard from one side by a single lantern. Visceral and unflinching: decaying flesh built up in waxy layers of grey-green, livid purple, jaundiced yellow and clotted oxblood; raw wounds, torn stitches, split skin, exposed bone and sinew where the body is broken; flies and grave dirt where it fits. Rendered with the cold precision of an anatomist's study, not cartoon splatter. No blue anywhere: these bodies have no spark of life. Hand-made imperfections, no digital gloss.
```

```
text, letters, words, captions, logos, watermark, signature, card frame, border, UI, photorealistic, 3D render, CGI, glossy, airbrushed, smooth digital painting, anime, cartoon, comic-book gore, paint-splatter blood, bright saturated red, daylight, white background, modern clothing, modern objects, blue light, living expression, open smiling eyes
```

Each cadaver subject = a distinct person and how they died + where they lie (Cemetery: dug up from the grave; Hospital: stained pillow; Morgue: stone slab; Public Square: cobblestones by the scaffold) + how far gone they are, from the card's stage:

| Stage | Decay wording |
|---|---|
| I | freshly dead, skin still waxy-pale, blood barely dry |
| II | dead a day or two, lividity pooling purple, lips greying |
| III | dead a week, bloated, marbled green veins, skin slipping |
| IV | months in the ground, shrunken and blackened, parchment skin, teeth bared |
| Bones only | bones and skull, rags of skin and hair still clinging |

Cadaver framing: 2:3, the body seen from above as it lies, head and upper torso.

## 3. Format lines (pick one per card type)

| Card type | Aspect | Composition |
|---|---|---|
| Cadavers, scoundrels, characters | 2:3 portrait | Head and shoulders, centred, face turned slightly, room for the card's number strip at the bottom (keep the lower 20% dark and simple) |
| Locations and lab spaces | 16:9 landscape | Wide establishing view of the place at night, building or room as the subject, small figures at most |
| Research, humanity, events, encounters | 4:3 landscape | One clear object or moment in close-up, simple dark background |

Format line template: `Format: {aspect}, {composition}.`

---

## 4. First test: lock the style

Generate these four together before anything else. If they read as one set, the style is locked.

**Test 1, location (16:9)**
```
The Cemetery of Père Lachaise at night: leaning tombstones, a stone cross, a bare tree, a half-dug grave with a spade stuck in the earth, a crescent moon behind thin cloud, one lantern on the ground glowing warm.
[style block]
Format: 16:9, wide establishing view of the place at night, small figures at most.
```

**Test 2, cadaver (2:3)**
```
A young laundress lying dead in a plain coffin, eyes closed, dark hair spread on the pillow, faint bruising at the throat, hands folded, linen shroud.
[style block]
Format: 2:3, head and shoulders, centred, lower 20% dark and simple.
```

**Test 3, scoundrel (2:3)**
```
A body snatcher in a battered top hat and long coat, holding a spade over his shoulder, sly half-smile, fog behind him on the quay.
[style block]
Format: 2:3, head and shoulders, centred, lower 20% dark and simple.
```

**Test 4, object (4:3)**
```
A Leyden jar on a laboratory bench crackling with a thin thread of cold blue electricity, copper wire, a scorched notebook beside it.
[style block]
Format: 4:3, one object in close-up, simple dark background.
```

### What to check in the test set
- Same paper tone, stroke texture and darkness across all four.
- The only blue is the electricity in Test 4. If blue leaks into other images, add "no blue except electricity" to the subject.
- No text or frames anywhere.
- Faces read as people, not caricatures.

---

## 5. Next steps after the style is locked
1. Save the four approved images as **style references** and attach them to every later generation if your tool supports image references.
2. Generate by deck, copying the **Prompt** and **Negative prompt** columns. Every card already has its own person or scene.
3. Save each image under the **File name** column (for example `cemetery-01.png`, `scoundrel-13.png`, `location-morgue.png`, `lab-charge.png`) so they can be wired into the game.
4. In the game, the SVG art in `src/art.js` becomes a fallback; images go in `dist/art/` and are referenced by card id.
