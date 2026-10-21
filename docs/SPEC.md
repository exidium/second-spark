# The Second Spark: Specification

A single-player digital adaptation of the board game *Abomination: The Heir of Frankenstein* (Plaid Hat Games, design by Dan Blanchett), built as a personal fan project. One human plays against 1 to 3 computer rivals in a browser.

This document describes the game **as currently built** (version 12 of the published page). Where a number is not from the physical game, it is marked **[tuned]** and explained in `DECISIONS.md`.

---

## 1. Ground rules for this project

- **Mechanics and numbers follow the physical game.** Card values (materials, stages, expertise, costs, effects, round ranges) were read from the Tabletop Simulator card sheets and the rulebook.
- **Names, wording and art are original.** Do not copy Plaid Hat card text, card names that are creative (for example "King's Mercy", "Leopold the Vast"), character names, or any of their illustrations into the game. Plain descriptive names (Cemetery, Hospital Thief, Cutthroat, Body Snatcher, Dog Catcher) are fine.
- **Captain Walton, the Creature and Victor Frankenstein** come from Mary Shelley's novel (public domain) and are used freely.
- **Writing style for all player-facing text:** no em dashes; plain, short sentences; every option shows exactly what you gain and what you pay.

---

## 2. Technology and architecture

### 2.1 Delivery
- One self-contained HTML page. Public test build on GitHub Pages at https://exidium.github.io/second-spark/ (`npm run deploy`). No server.
- No JavaScript libraries. Locations, cards and dice are hand-written inline SVG. The six character portraits are generated images (see 12.5) embedded as data URIs; the SVG portrait is the fallback when an image is missing.
- Fonts from Google Fonts: **Amarante** (every title, card name, button and label), **EB Garamond** (body text, italic for flavor). Georgia/serif fallback. Body size 16px.
- External network: none except Google Fonts. (Artifact sandbox blocks other hosts.)

### 2.2 Source layout
```
src/head.html    <title>, meta, font links, all CSS, #app and #modalRoot containers
src/data.js      all game data (anatomy, decks, events, encounters, characters, locations)
src/art.js       SVG illustrations (locations, lab spaces, portraits, card icons, dice faces)
src/engine.js    rules, state, async game loop, AI, scoring, persistence
src/ui.js        modals, tooltips, human input, all rendering, boot
build.py         concatenates the above into dist/second-spark.html, embedding every image under art/ (except source/) as `const IMG`, keyed by file stem
art/<set>/       web-sized images: ui/ (bg-wall, board, title), frames/ (card-tall-front, card-tall-back), characters/, locations/, cadavers/, scoundrels/, research/, humanity/, events/, encounters/
art/source/<set>/ originals, never embedded, ignored by git (pencil/ holds the earlier pencil-style art)
tools/gen_gemini.py  generates images with Nano Banana 2 from docs/prompts/all-images.md (needs GEMINI_API_KEY)
tools/pixelize.py    makes the game copies: 32 colours at 384px wide (--width) or a true 96-pixel canvas
```
`build.py` wraps `data.js + art.js + engine.js + ui.js` in one `(() => { "use strict"; ... })();` IIFE inside a `<script>` after `head.html` and a `<div id="tip" hidden></div>`.

### 2.3 Runtime model
- One global state object `S` (serializable JSON). `S = null` means the title screen.
- **Async game loop** (`loop()` in engine.js) runs phases in order and awaits human input through promises:
  - `ask({...})` opens a modal and resolves with the chosen option or button value.
  - `humanTurn()` resolves when the human finishes a placement (`endHumanTurn()`).
  - Lab phase waits on `labResolve`, resolved by the "End the night" button.
- `gameToken` guards against stale loops when a new game starts. A loop only runs once per token.
- AI turns use `await sleep(550)` between placements so the human can follow. With `S.fast` (tests) sleeps are 0 and all modals are skipped.
- **Rendering:** full `innerHTML` re-render of `#app` via `render()`; modals render separately into `#modalRoot`. Click handling is delegated on `document` through `data-act` attributes (board) and `data-mfn` (modal callbacks).

### 2.4 Persistence
- `localStorage` key `second-spark-paris-v5`, saved at stable points (start of each player's turn, phase changes, after actions). Wrapped in try/catch; the game works without it.
- Title screen offers "Continue Day N" when a save exists. Saves are deleted at game end.
- Artifact hot-reload hooks: `window.claude?.hot?.snapshot(() => ({S}))` and `hot.ready(start)` keep a running game across republishes.
- Saves are versioned by `S.v === 5`. Bump both the key and `v` when the state shape changes.

### 2.5 Test hooks
`window.__spark` exposes `S`, `newGame(name, nRivals, charId, {fast, allAI})`, `loop`, `endLab`, `planBuild`, `build`, `playCard`, `canPlace`, `allKeys`, `aiChoose`.

---

## 3. Setup

- Title screen: name field, **character cards** (6 characters plus a "Random scientist" card, random selected by default), rival count (1 to 3), "Light the lamps".
- Rivals: Dr Ambrose Pell (ruthless), Mme Odile Varnier (careful), Prof Horace Quill (scholar). Each gets a random remaining character.
- Each player starts with francs equal to the number of players, humanity 0, expertise 0, reputation 0, 1 empty Leyden jar, no materials.
- Character start bonuses: Charlatan reputation 3, Humanitarian humanity 2, Surgeon expertise 2.
- Random first player.
- 4 of the 6 bonus objectives are drawn.
- **Event deck (12 days):** for each day, an event whose round range includes that day, except 4 random days from 3 to 12 which get an encounter eligible for that day. Day 1 is always one of: A Porter for Hire, Glut of Meat, An Anonymous Letter, A Widow's Bequest, A Dead Man's Notes.
- Face-up rows are dealt (see 5.3).

---

## 4. Round structure

Each day runs these phases (`S.phase`):

1. **event**: reset the day; reveal the day's card.
2. **day** (city phase): players place meeples one at a time, clockwise from the first player, until nobody has a meeple or a legal space.
3. **firstmove**: whoever sits on the First Player space may move that meeple to another legal space and use it.
4. **lab**: AIs act instantly; the human builds, throws the switch, preserves, then presses "End the night".
5. **dawn**: decay, refresh the board, the Captain advances.

### 4.1 Event phase details
- Reset per player: meeples available (see 6.1), lab spaces free, switch not thrown, aid card not played, Odéon unused, Zoologist and Surgeon powers unused, `noHumLoss` off. Heiress gains 1f if she has 2 or less.
- Reset board: occupancy, bump track, closures, Thwart, Odéon.
- **Event card**: apply closures, lightning (all jars charged), execution (Public Square bodies, unless someone plays Royal Pardon), and per-event choices (asked with **Accept / Refuse** buttons).
- **Encounter card**: either resolved now on a target, or held secretly by the first player on a specific space (see 8.7).

### 4.2 End of game
- At the end of a lab phase, if any player has all 6 parts alive: game ends ("It's alive").
- At dawn the Captain advances 1 step. When he reaches step 12 the game ends ("Captain Walton has found the Creature"). Aid cards can move him faster.

---

## 5. The board

### 5.1 Locations and action spaces
Each space holds one meeple. **Sci** = scientist only. Costs listed are in francs (f).

| Location (real place) | Space | Effect |
|---|---|---|
| Cemetery (Père Lachaise) | Dig up cadavers | Free. Draw 3 hidden cemetery cadavers, resolve any (see 7.1). |
| Public Square (Place de Grève) | Buy a body | 1f. Take one face-up executed body and resolve it. Only after an execution. |
| Morgue (Quai du Marché-Neuf) | Buy cadavers | 1f. Draw 2 hidden morgue cadavers, resolve any. |
| Slaughterhouse (Montmartre) | Animal parts | +4 animal at stage II, or +3 animal at stage I. |
| Hospital (Hôpital de la Charité) | Retrieve cadaver | Take face-up hospital bodies. Free 1 at reputation 7+. +1 more for 1f at reputation 15. A Porter for Hire event: +1 more for 1f (or the first one for 1f below reputation 7). |
| | Work (Sci) | +2f (expertise 0 to 6), +3f (7 to 12), +4f (13+). |
| | Volunteer (Sci) | +1 humanity, +2 reputation. |
| Academy (Institut de France) | Advanced research (Sci) | +1 expertise and take one face-up research card. |
| | Research | Take one face-up research card. |
| | Lecture | +1f and +1 reputation (+2 reputation with a scientist). |
| | Donate (Sci) | Pay 1 to 3f, +1 reputation per franc. |
| Market (Les Halles) | Buy and sell | Any number of: sell 2 bone for 1f, sell 3 preserved flesh for 2f, buy a Leyden jar for 2f (max 4 jars, arrives empty unless lightning is in the air), buy ice for 1f. |
| Docks (Port Saint-Nicolas) | Hire a scoundrel | Pay a face-up scoundrel's cost and choose one of its benefits (see 7.2). |
| Dark Alley (Faubourg Saint-Marcel) | Murder (Sci) | +4 muscle, +4 organ, +3 blood (stage I), +2 bone. −3 humanity, +1 police marker. Blocked at 2 police markers. |
| Saint-Roch (Rue Saint-Honoré) | Atone | Take one face-up humanity card. A scientist also gains +1 humanity. |
| First Player (Parvis Notre-Dame) | Take the lead | Become first player. Cannot be bumped. Later movable (phase **firstmove**). |
| Théâtre de l'Odéon (event only) | Be seen | +2 reputation. Once per player per day. Bumping is free and sends the meeple home. |

### 5.2 Lab spaces (one per player each, never contested)
| Space | Effect |
|---|---|
| Practice (Sci) | +1 expertise |
| Give Blood | +3 blood at stage I |
| Repair (Sci) | Remove up to 3 damage from your parts |
| Charge Jars | Charge 3 jars (scientist) or 2 (assistant) |

### 5.3 Face-up displays (refreshed every dawn)
- **Academy:** 3 research cards. Taking one replaces it immediately from the deck.
- **Saint-Roch:** 3 humanity cards. Same replacement rule.
- **Hospital:** exactly 2 bodies. Not replaced until dawn. If both are gone, Retrieve is unavailable.
- **Docks:** 3 scoundrels. A hired one is replaced immediately.
- **Public Square:** bodies only appear after an execution (1 body with 2 players, 2 with 3 or 4). Discarded at dawn.
- **Cemetery and Morgue are hidden:** cards are only drawn when you use the space.

All displays are shown as mini cards beside their place on the board (art and name) and at full size in the place popup.

### 5.4 Bumping
- To use an occupied space, bump the meeple there. The bumped meeple goes to the **bump track** and is out for the day.
- Bump costs by player count **[tuned]**: 2 players `[1]`, 3 players `[1, 2]`, 4 players `[1, 1, 2]`. You pay the next free slot's cost to the bumped player. Bumping yourself is free. If the track is full, no more bumping that day.
- The First Player space cannot be bumped. The Odéon is bumped for free and the meeple returns home.
- Charlatan gains +1 reputation when bumped at the Academy.

### 5.5 Closures
Events and humanity cards can close locations for the day (`S.closed[loc]`), and Night at the Graves also blocks hiring Body Snatchers (`S.closed.snatch`). Closed locations are greyed and struck through on the map.

---

## 6. Players and resources

### 6.1 Meeples
- Start: **1 scientist, 2 assistants**.
- Reputation 7+: a 3rd assistant. Reputation 15+: one assistant becomes a 2nd scientist. **[tuned thresholds]** Counts are recomputed from current reputation each morning.
- The player chooses which meeple to send with two buttons in the status box. If the chosen kind can't use a space, the other kind is sent automatically (with a short toast).

### 6.2 Tracks and counters
| Item | Range / rule |
|---|---|
| Francs | ≥ 0 |
| Humanity | −10 to +10, scores directly at the end |
| Expertise | ≥ 0. Unlocks: arm 3, torso 8, head 14 **[tuned]**. Blue dice at 10 (1 die) and 20 (2 dice). Highest value reached scores a third. |
| Reputation | ≥ 0. 7: hospital cadavers, 3rd assistant. 15: 2nd scientist, 2nd hospital cadaver. Highest value reached scores half. |
| Police markers | 0 to 2 (Dark Alley). At 2 the Dark Alley is closed to you. Pay 3f at any time to clear all. |
| Leyden jars | 0 to 4, each charged or empty |
| Ice | Number of dawns without decay left (buying ice sets it to 2) |
| Bone | Max 12, never decays |
| Preserved flesh | Max 9, never decays, only for selling at the Market |
| Hand | Up to 3 research and 3 humanity cards. A 4th of a kind discards the oldest. |

### 6.3 Materials and decay
- Staged materials: muscle (brown), organ (purple), blood (red), animal (orange). Stage I is freshest, IV is oldest. Max 15 per cell.
- **Each dawn** (unless the player has ice): stage IV is discarded, blood at stage II is discarded, everything else moves one stage older.
- Ice: decay is skipped and ice drops by 1.
- Preserve (lab phase): move muscle or organ from the track to preserved flesh (oldest first, 3 at a time from the UI).

### 6.4 Characters (abilities use the real game's effects, names are original)
| Role | Name | Ability |
|---|---|---|
| Psychopath | Lucien Vautrin | Humanity never moves from 0. Each time you get a 2nd police marker, −1 reputation. |
| Zoologist | Sir Bartholomew Pike | Once per day: +1 gray die when throwing the switch, or charge 1 jar. |
| Charlatan | Count Achille Duval | Start at reputation 3. +1 reputation each time you are bumped at the Academy. |
| Humanitarian | Amara Okafor | Start at humanity 2. +1 VP per humanity you would gain while at 10. |
| Heiress | Lucrezia Fontana | Start of each day: +1f if you have 2 or less. Research cards that give expertise give +1 more. |
| Surgeon | Dr Hélène Marchand | Start at expertise 2. Once per night, build with 1 less material of your choice. |

### 6.5 Bonus objectives (4 of 6 per game, 10 VP each)
First to humanity 10 · First with 2 parts alive · First to expertise 27 · First with 6 parts on the table · Most francs at the end · First to reputation 23. Ties go to turn order from the first player.

---

## 7. Cards

### 7.1 Cadavers
Format: stage, then [muscle, organ, blood, bone], expertise, humanity cost. Stage 0 means bones only (no expertise option).
Resolving a cadaver: pay its humanity cost (if any), then take **either** its materials (at the card's stage; bone has no stage) **or** its expertise. Unresolved cards cost nothing. Drawn cards return to their deck (the deck reshuffles when empty).

- **Cemetery (14):** IV [0,3,0,3] e1 · IV [2,2,0,3] e1 · IV [2,2,0,2] e1 · IV [2,1,0,3] e1 · bones 5 · bones 5 · bones 4 · bones 4 · III [3,4,0,3] e1 h1 · III [3,4,0,2] e1 h1 · III [3,3,0,2] e1 h1 · III [2,3,0,3] e1 h1 · III [1,2,0,3] e1 · IV [3,4,0,2] e1
- **Hospital (14):** II [2,3,1,2] e1 · II [3,2,1,2] e1 · II [2,2,1,3] e1 · II [1,2,1,1] e1 · I [2,3,1,3] e2 · I [3,2,1,3] e2 · I [2,3,2,1] e2 · II [2,3,2,2] e1 · I [2,4,2,2] e2 · I [2,3,2,2] e2 · I [2,3,1,3] e2 · I [3,2,1,3] e2 · I [2,3,2,1] e2 · II [2,4,2,2] e1
- **Morgue (14):** II [3,3,0,3] · III [2,4,0,2] · III [2,3,0,2] · III [3,2,0,2] · III [2,2,0,3] · III [2,1,0,2] · III [4,2,0,3] · III [3,1,0,4] · II [2,4,2,2] h1 · II [2,3,1,2] h1 · II [2,3,1,3] h1 · II [3,2,1,3] h1 · II [2,3,1,1] · II [4,3,2,2] h1. All expertise 1.
- **Public Square (10):** all stage I, expertise 2: [4,3,2,4] · [3,3,3,4] · [2,4,3,3] · [2,4,2,3] · [2,3,2,3] · [3,2,2,3] · [4,2,1,2] · [4,4,3,3] · [4,4,3,2]. Plus **Big Gustave, the butcher of Rungis** [4,4,4,4], expertise 3, costs +1f. (In the physical game this card is held aside for an encounter we don't have; here it is part of the deck.)
- Cadaver display names are random Parisian occupations ("Jeanne, a laundress"). Portraits are generated from a seed.

### 7.2 Scoundrels (16, Docks)
Cost in francs, humanity cost on hiring, then choose **one** benefit.

| Count | Name | Cost | Hum | Benefit options |
|---|---|---|---|---|
| 2 | Hospital Thief | 2f | −1 | Draw 2 hospital bodies (from the face-up 2, then the deck) and resolve them |
| 2 | Hospital Thief | 1f | −1 | Draw 1 hospital body and resolve it |
| 1 | Dog Catcher | 2f | −1 | +3 expertise (−1 humanity) · +5 humanity · +8 animal (I) |
| 1 | Dog Catcher | 1f | 0 | +2 expertise (−1 humanity) · +3 humanity · +5 animal (I) |
| 2 | Dog Catcher | 1f | 0 | +2 expertise (−1 humanity) · +3 humanity · +4 animal (I) |
| 1 | Cutthroat | 2f | −1 | +2 expertise · 4 muscle, 4 organ, 4 blood (I), 3 bone |
| 1 | Cutthroat | 1f | −2 | +2 expertise · 3/3/3 (I), 3 bone |
| 1 | Cutthroat | 1f | −1 | +2 expertise · 4/3/3 (I), 2 bone |
| 1 | Cutthroat | 1f | −1 | +2 expertise · 3/4/3 (I), 3 bone |
| 1 | Body Snatcher | 2f | 0 | +2 expertise · 6 muscle, 4 organ (III), 5 bone |
| 1 | Body Snatcher | 1f | 0 | +1 expertise · 4 muscle, 4 organ (III), 3 bone |
| 1 | Body Snatcher | 1f | 0 | +1 expertise · 4 muscle, 3 organ (III), 4 bone |
| 1 | The Bone Collector | 1f | 0 | 8 bone |

Hiring a Cutthroat counts as "last dark deed" for encounter targeting.

### 7.3 Research cards (16, Academy)
Each card is used **once**, either for its effect (gain shown) or, after throwing the switch, for its dice mitigation. Using it either way discards it.

| Name | When | Effect / gain | Dice mitigation |
|---|---|---|---|
| Countermeasures | Automatic | Cancels a rival's humanity card aimed at you. +2f | Ignore all bolts |
| Unethical Experiment | Dark Alley or hiring a Cutthroat | Spend 1 charged jar, skip the normal benefit: +5 expertise, −1 humanity | Re-roll any dice |
| Pickling Jars | Market | +1f per preserved-flesh sale | Ignore broken hearts |
| Steady Hands | Building | Need 1 fewer of each material. +2 expertise | Re-roll dice showing bolts |
| Private Pupil | Any time (Play) | +2 reputation, +3f | Ignore all bolts |
| Guest Lecturer | Lecturing | +2 reputation, +2f on top | Re-roll any dice |
| Healing Salve | Any time | Remove all damage. +2 expertise | Re-roll gray dice |
| Burning the Candle | Your city turn | Use one of your placed meeples' spaces again, paying its costs | Re-roll blue dice |
| Fresh as Morning | Resolving a cadaver | Materials count as stage I. +2 reputation, +2f | Re-roll dice showing bolts |
| Close Dissection | Resolving a stage I or II cadaver | Pay cost, discard it: +4 expertise | Re-roll gray dice |
| Evening Study | Any time | +2 expertise | Re-roll gray dice |
| Practical Study | Any time | +3 expertise | Re-roll blue dice |
| Electrolysis | Resolving a stage I to III cadaver | Spend 1 charged jar, pay cost, discard: +4 expertise, +2 reputation | Re-roll gray dice |
| Public Galvanism | Any time | Spend 1 charged jar and 2 animal: +3 expertise, +2 reputation, +1f, −1 humanity | Re-roll blue dice |
| Transfusion | Give Blood | Instead of blood: +3 expertise, +1 reputation, +1f | Re-roll gray dice |
| Publish a Paper | Your city turn | Your unplaced scientist sits out today: +2 expertise, +3 reputation, +1f | Re-roll dice showing bolts |

"Re-roll" options re-roll every eligible die that isn't already showing an eye **[simplification]**.

### 7.4 Humanity cards (16, Saint-Roch)
| Name | When | Effect | Gain |
|---|---|---|---|
| Whisper to the Captain | Day (aid) | Pay 1f, Captain +1 step. Removed from game. Not from Day 11. One aid card per day. | +2 humanity |
| Fund the Captain | Day (aid) | Pay 2f, same | +3 humanity |
| Tell the Captain Everything | Day (aid) | Free, same | +1 humanity |
| Petition the Prefect | Any time (day) | Discard all hospital bodies | +1 humanity |
| A Trap of Your Own | When the Creature visits you (Now encounter) | Spend 1 charged jar to cancel the encounter | +3 humanity |
| Royal Pardon | When an execution is announced | Pay 2f to cancel it | +2 humanity, +2 reputation |
| A Decent Burial | Buying at the Public Square | Bury the body instead of resolving it | +3 humanity, +2 reputation |
| Night at the Graves | Any time (day) | Close the Cemetery and Body Snatcher hiring for the day | +1 humanity |
| Shame the Morgue | Any time (day) | Close the Morgue for the day | +1 humanity |
| Mercy for Beasts | Lecturing | Instead of the normal benefit | +3 humanity |
| Walk the Quays | Any time (day) | Close the Docks for the day | +1 humanity |
| Cut the Wires | Target a rival | Their next throw loses 1 random die | +1 humanity |
| Cross Their Path | Any time (day) | The next rival to place in Paris must choose another location | +2 humanity |
| The Dignity of the Dead | Lecturing | Instead of the normal benefit | +3 humanity |
| Urchin Raid | Target a rival | Remove up to 3 of their materials, one of each colour | +2 humanity |
| A Careless Lantern | Target a rival with 2+ research cards | Discard one at random | +2 humanity |

Targeted cards are cancelled by Countermeasures. When an AI targets the human, a toast explains what happened.

### 7.5 Events (19)
⚡ = lightning (all jars charged). ☠ = execution (Public Square bodies).

| Name | Days | Icons | Effect |
|---|---|---|---|
| A Porter for Hire | 1 to 5 | | Hospital: pay 1f for one more body than reputation allows |
| Glut of Meat | 1 to 5 | ⚡ | Slaughterhouse +2 animal and +1f |
| Hard Times | 1 to 5 | | No Hospital work. Lectures give reputation only. Jars: buy 1, get 1 free |
| An Anonymous Letter | 1 to 5 | | Anyone with humanity > 0 may take a humanity card. Highest humanity: +1 humanity |
| Patrols at the Graves | 1 to 4 | ⚡ | Cemetery closed. Scoundrels +1f |
| Fire at the Academy | 1 to 4 | ☠ | Academy closed. Anyone may pay 2f for +2 reputation. The first player picks someone for the Captain's plea (aid: humanity card +1 humanity; refuse: research card −2 humanity) |
| Cattle Plague | 1 to 5 | | Slaughterhouse closed. Dog Catchers +1f |
| Cholera | 1 to 7 | ⚡ | Hospital work +2f. Cemetery and Morgue draw 1 extra |
| Student Parade | 1 to 4 | | Academy is scientists only |
| Loyalty Pledges | 1 to 5 | ☠ | Everyone pays 1f for +1 reputation, or loses 1 reputation |
| Student Riots | 1 to 7 | ☠ | Dark Alley and Docks closed |
| A Dead Man's Notes | 1 to 7 | ⚡ | Anyone may lose 1 humanity for +2 expertise |
| All Saints' Day | 1 to 6 | | Cemetery, Morgue, hospital bodies, Hospital Thieves, Body Snatchers: +1 humanity cost |
| A Widow's Bequest | 1 to 5 | ☠ | Research and lectures +2f |
| The Captain's Wrath | 7 to 12 | ☠ | Humanity below 3: lose 1 jar |
| Opening Night at the Odéon | 5 to 12 | | Odéon location appears for the day |
| The Flesh Is Willing | 7 to 12 | ☠ | Each throw may re-roll up to 2 dice for free |
| Storm from the Sea | 7 to 12 | ⚡ | Cemetery and Docks closed |
| Inquiry at the Hospital | 6 to 12 | ☠ | Hospital closed |

Event yes/no prompts use **Accept / Refuse** buttons, with the gain and cost written in the question.

### 7.6 Encounters (15)
Encounters use **story wording** for their choices. Targets: `maxExp`, `fewestComplete`, `maxHum` (ties chosen by the first player), `fpOther` (first player chooses anyone else), `fp` (first player chooses anyone), `fpWithPart` (anyone with a part), `lastDark` (last to murder or hire a Cutthroat; skipped if nobody), `mostHumCards`.
AI first players aim harmful encounters at the leader.

| Id | Days | Trigger / target | Test or choice | Outcome A | Outcome B |
|---|---|---|---|---|---|
| e14 | 7 to 12 | Now, most expertise | Stitch him up / Turn him away | −2 muscle/organ (oldest), +3f | Lose 1 meeple today; Captain +1 (unless 11+) |
| e12 | 7 to 12 | Now, fewest complete parts | (no choice) | +4 human materials (I) of your choice, −2 humanity | |
| e10 | 7 to 12 | Now, most humanity | Go to the Docks / Burn the note | Become first player; scientist spends the day at the Docks; +1 humanity card, +1 humanity, +2f | Captain −1 step, −1 humanity |
| e8 | 6 to 12 | Now, first player picks another | 2+ parts alive? | Become first player | Draw 2 research cards |
| e6 | 7 to 12 | Now, first player picks | 3+ complete parts? | +1 empty jar (max 4) | Scientist must Give Blood now: +5 blood (I) |
| e4 | 8 to 12 | Now, first player picks | 4+ complete parts? | +1 organ, +2 muscle (I), −1 humanity | +1 organ (I), +1 humanity |
| e2 | 7 to 12 | Now, first player picks | Give him up / Hide him | −2 humanity, lose 1 jar | −1 expertise, +2 humanity |
| e28 | 7 to 12 | Secret: Academy Advanced research | Stay and listen / Leave with your books | No normal benefit, +2 humanity | No normal benefit, −1 humanity, draw 1 research |
| e26 | 8 to 12 | Secret: Hospital Retrieve | Claim the dead / Help the living | Retrieve as normal plus 2 extra bodies from the deck, −1 humanity | No normal benefit, +3 humanity, +1f |
| e24 | 6 to 12 | Secret: Docks Hire | Ask her help / Walk on | No normal benefit; pay 1f (or −1 reputation); hire any scoundrel from the whole deck; reshuffle and deal 3 new | No normal benefit, −2f |
| e22 | 5 to 12 | Now, first player picks someone with a part | 1+ part alive? | +3f | One part is downgraded one step |
| e20 | 7 to 12 | Now, last dark deed | Agree to help / Refuse | Become first player; a meeple goes to Saint-Roch now; no humanity loss today | −2 humanity (if impossible, everyone else +1 humanity) |
| e18 | 6 to 12 | Now, first player picks | Expertise 13+? | Draw 1 research | Scientist must Practice now: +2 expertise |
| e16 | 7 to 12 | Now, most humanity cards | Take the bag / Refuse it | +1 muscle, organ, blood (II) and 1 bone, −2 humanity | The next player gains 1 of each (I); you +1 humanity |
| e29 | 1 to 5 | Secret: Cemetery Dig | Climb into the grave / Dig elsewhere | Bones-only cards are redrawn; all count as stage I; resolving any costs 1 humanity total, card costs ignored | Draw only 2; card costs ignored |

A **secret** encounter is held by the first player. The first *other* player to use that exact space meets it before the space resolves. A Trap of Your Own can cancel "Now" encounters with the Creature.
**Missing:** the physical game's round 1 to 4 encounter cards were not in the exported sheets.

---

## 8. Building the companion

### 8.1 Parts
Six parts: head, torso, left arm, right arm, left leg, right leg. Each is built in two steps in the lab phase:
1. **Start** (muscle side).
2. **Add skin** (complete).

Each step needs the expertise threshold and the materials below, gives VP and **+1 expertise**. **[tuned]**: costs and expertise thresholds.

| Part | Expertise | Start (muscle) needs | Muscle VP by stage I/II/III/IV | Skin needs | Skin VP I/II/III/IV | Alive (end) |
|---|---|---|---|---|---|---|
| Head | 14 | 4 muscle, 5 organ, 3 bone | 10 / 8 / 5 / 3 | 2 muscle, 2 organ, 3 blood | 7 / 5 / 3 / 1 | 6 |
| Torso | 8 | 5 muscle, 4 organ, 2 blood, 3 bone | 8 / 6 / 4 / 2 | 4 muscle, 3 blood | 6 / 4 / 3 / 1 | 5 |
| Arm (×2) | 3 | 3 muscle, 1 organ, 2 blood, 2 bone | 5 / 4 / 2 / 1 | 3 muscle, 2 blood | 3 / 2 / 1 / 1 | 3 |
| Leg (×2) | 0 | 4 muscle, 2 blood, 3 bone | 5 / 4 / 2 / 1 | 3 muscle, 2 blood | 3 / 2 / 1 / 1 | 3 |

- VP is set by the **oldest stage** used among the staged materials.
- **Animal** substitutes for muscle, organ or blood (blood only from animal at stage I or II). Using any animal costs 1 VP, 3 or more costs 2 VP (minimum 0).
- Two buttons per buildable step: **Start / Add skin** (freshest materials first) and **Use oldest first** (shown only when it gives a different VP).
- Steady Hands (−1 of each material) and Surgeon (−1 of one material) are checkboxes above the part list at night.

### 8.2 Throw the switch
- Once per lab phase, with at least one complete (skinned) part and at least one charged jar.
- Choose 1 to 3 charged jars. They become empty. Each jar rolls **2 dice**.
- Blue dice: expertise 10 makes 1 die blue, 20 makes 2 blue.
- Dice faces **[tuned]**: gray `eye, bolt, bolt, broken heart, blank, blank`; blue `eye, eye, bolt, broken heart, blank, blank`.
- Before resolving: sabotage removes a random die; the Zoologist adds a gray die; the player may spend research cards for mitigation and use The Flesh Is Willing (free re-roll of up to 2 bad dice).
- Resolution order:
  1. **Bolts:** each places 1 damage. Damage spreads: a part can't take a 2nd damage until all parts on the table have 1. Placement is automatic, preferring alive, then skinned, then muscle parts, cheapest first **[simplification: the physical game lets the player choose]**. A part with 2 damage is **downgraded** immediately and its damage cleared: alive → not alive, skin → muscle, muscle → destroyed.
  2. **Broken hearts:** −1 humanity at most per throw.
  3. **Eyes:** each makes one complete, not-yet-alive part alive (highest alive value first).
- VP already earned is never lost by downgrading.

### 8.3 Preserve
At night, move muscle or organ (oldest first) into preserved flesh (max 9) to sell at the Market.

---

## 9. Dawn
1. Decay (or spend ice). The human gets a summary of what rotted.
2. Refresh displays: hospital 2, docks 3, research 3, humanity 3; Public Square cleared.
3. Captain +1 step. End check at 12.
4. Day number +1, first player unchanged (it changes only through the First Player space and encounters).
5. Dawn modal for the human (Begin Day N).

---

## 10. Scoring
- VP earned while building.
- Alive parts: head 6, torso 5, arms and legs 3 each.
- 10 VP per bonus objective claimed (Most francs is awarded at the end).
- Half of the highest reputation reached (rounded down).
- A third of the highest expertise reached (rounded down).
- Humanity at the end, plus or minus.
- If the Captain ended the game: +5 VP to the player(s) with the highest positive humanity.
- Ties: more alive parts, then more francs.
- End screen: verdict text (different for "alive" and "Captain" endings), score table with every column, Play again.

---

## 11. Computer rivals (AI)
- Personas: **ruthless** (Dark Alley, Cemetery), **careful** (Hospital, Morgue, ice), **scholar** (Academy, expertise).
- Placement: score every legal space and meeple kind with a heuristic based on material shortfall for its next two buildable steps, expertise gap to the next part, francs, humanity, damage, jars, and the event; subtract bump costs; add randomness. Prefers assistants unless the space needs or rewards a scientist.
- Cadaver picks: materials if useful, else expertise when behind on expertise; skips humanity-cost cards at humanity −6 or lower unless ruthless.
- Cards: plays "any time" research immediately; aid cards rarely (humanity < 2, 25%); targeted humanity cards at the leader (40%); Cross Their Path (30%); closures (20%).
- Lab: preserves stage IV flesh, builds the best VP step repeatedly (trying both material orders, Steady Hands and Surgeon), throws the switch with all charged jars (up to 3), uses a mitigation card when bolts threaten, pays off police at 2 markers with 5f+.
- First player meeple: moves it if a space scores well.

Balance target and result (30+ AI games): games end on Days 10 to 12, roughly a third with a living companion and two thirds by the Captain, wins spread across personas.

---

## 12. User interface

### 12.1 Visual identity
- Single dark look by choice: a tiled stone wall (`art/ui/bg-wall.jpg`, 1024px tile) under an ink wash on every screen, lamp-black `#121016` fallback, panels `#1b171f`, parchment text `#ece0c6`. Accent "galvanic blue" `#9fd0ff`. Engraved paper map `#d9c8a3` with ink `#3b2d22`.
- Material colours: muscle `#8a4b2b`, organ `#7a5a96`, blood `#c03b3b`, bone `#ece6d6`, animal `#e38b2c`.
- Body part state colours: **muscle bold red** (`#b23a2b`/`#e0533f`), **skin bold yellow** (`#e0b22e`/`#f0c419`), **alive blue** (`#9fd0ff`, glow). Damage: yellow lightning `#ffd36a`.
- Player colours: you `#9fd0ff`, Pell `#d6675f`, Varnier `#74b393`, Quill `#cda65c`.
- Meeple icons: scientist (top hat), assistant (plain).
- Responsive to 400px width: the board scrolls inside its own box, the page never scrolls sideways; respects reduced motion.

### 12.2 Layout (the board)
Desktop (1100px and wider): the page uses the full browser width; the right column is 380px (340px under 1400px) and the board takes the rest.

**Left column**
- Top row: the logo, the 4 bonus objectives (claimed ones show the claimant's colour) and the Captain Walton track (12 steps, skull at the end) at the right end.
- Toolbar on top of the board: "Day N · phase · first player" and "Today: card name" (click it to see the full event or encounter card). No bump track on the page; bump costs appear in the place popup.
- **The board**: Bruno's painted Paris (`art/ui/board.jpg`, 16:9). Each place is a chip with its name and one meeple slot per action space (dashed when free, filled with the occupant's colour, larger with a dark base for a scientist). Places you can use pulse blue; closed places are struck through and dimmed. Positions are percentages in `BOARD_POS` (data.js). **Tooltips only on the places.**
- Beside each place, its cards at mini size (art and name only): the face-down deck with the count left for Cemetery and Morgue; the face-up rows for Hospital (2 bodies), Academy (3 research), Saint-Roch (3 humanity), Docks (3 scoundrels), Public Square (bodies after an execution, else an empty slot).
- "Your laboratory" strip on the lower edge: Practice, Give Blood, Repair, Charge Jars as small places with your own meeple once used.
- "Who do you send?" box bottom-left: Scientist and Assistant buttons stacked, with counts, on your turn; otherwise who is choosing, or the phase.
- Below 1100px the board scrolls sideways inside its own box (minimum 760px) so the page itself never overflows.

**Right column**
- Buttons: **Your character** (portrait, name, role, ability, Zoologist charge, police payoff, VP built, people at home, cards in hand with Play buttons) , **Help** (rules, plus an Every card button) and **New game**. The points table lives in the Laboratory popup.
- Operating table (SVG figure with state colours and damage badges; click it to open the Laboratory popup) beside the squeezed decomposition track, the body line, and four counters: francs, jars charged/total, ice, police.
- Stat bars (humanity, expertise, reputation with the blue threshold squares and their tooltips), the **Laboratory** button (at night it pulses and an End the night button appears beside it) and a **Cards** button showing the number of cards in hand, which opens the hand with Play buttons.
- Rivals: three compact cards (portrait, name on one line, role, Muscle/Skin/Alive counts, Humanity/Expertise/Reputation numbers). Click one to open their lab popup: a strip with portrait, character, counters and stat bars, then the same three read-only columns as your Laboratory popup (operating table, body parts, decomposition track with the points table).
- Chronicle, newest first.

### 12.3 Popups
- **Place popup** (click a place): name, real place, illustration, text, one option per action space showing the exact gain or cost for the meeple you would send, a scientist tag, the occupant and the bump cost; the cards there at full size (framed design for Hospital and Research, plain paper otherwise), or the deck back with cards left for Cemetery and Morgue. Choosing an option places the meeple and runs the usual prompts (bump confirmation, Hospital picker, Market steppers, Docks offers, Dark Alley choice, Academy and Saint-Roch card picks). Outside your turn the popup is read-only.
- **Laboratory popup** (extra wide, three columns; opened from the Laboratory button or the operating table): column 1 the operating table at 230px with legend, VP built, body line and the switch box (1 to 3 jars); column 2 the part rows with Start / Add skin buttons (fresh or oldest first, with VP) and the Steady Hands and Surgeon toggles; column 3 the decomposition track with Preserve buttons and the points-per-part table. Cards in hand below, End the night in the footer. It refreshes in place after each action; the throw opens the dice modal and returns to it. Under 1000px the columns stack.
- Locked modals (must choose) for drawn cards and encounters; others can be cancelled.
- Cadaver resolution: illustrated cards with Materials / +N expertise / Leave toggles and any applicable research cards.
- Throw result: dice faces, legend, mitigation options, then a summary of what came alive or broke.
- Yes/no questions: **Accept / Refuse**. Encounters: story wording.
- Toasts for things done to you by rivals and for automatic meeple switching.

### 12.4 Title and end screens
- Title: How to play pinned top right (opens the rules in a modal), a white centred tagline, the centred title logo, name field, rivals selector, Light the lamps (and Continue when a save exists), then the **character card picker** in 4 columns (2 on phones): generated portrait at 3:4 on top, then role, name, a one-line perk in red and the full ability; plus a Random card. Order alternates men and women. No letter, no rules text and no card catalog button on this screen.
- End: headline (You win / X wins), ending text, full score table, Play again.

---

### 12.5 Generated art
The title logo (`art/ui/title.webp`, transparent WebP) and six pixel-art character portraits made with Nano Banana 2 from the prompts in `docs/prompts/all-images.md` (style in `ART_STYLE.md`): 384x576 PNG, 32 colours, about 60KB each. Shown in the picker, your character line (44x58 avatar), the rivals panel (30x40), the rival lab window (72x96) and the card catalog. The 14 Hospital cadavers have generated pixel portraits (`art/cadavers/hospital-NN.png`, 3:4, face to the camera); other decks use the seeded SVG face until their sets exist. Hospital cadaver and Research cards are drawn on an engraved parchment frame (`art/frames/card-tall-front.webp`, 190px wide, 3:4) with the stage numeral in the foot cartouche; the Cemetery and Morgue places show the pixel-art deck back (`art/frames/card-tall-back.png`) with the deck name on its brass plate and the cards left. Everything else is still SVG.

## 13. Testing
- `tests/sim.js` (Playwright): runs N full games with all players as AI in fast mode; reports stuck games, game length and ending type, winners, average alive parts, and page errors.
- `tests/ui.js` (Playwright): plays as the human through the real interface (random places on the board, first option in each popup, builds and throws from the Laboratory popup at night) until the game ends, reports the ending and winner, then checks the 400px layout for page overflow and that the board scrolls inside its own box.
- Before each publish: no page errors, no stuck games, no em dashes in the built file.

---

## 14. Known gaps and ideas
- Round 1 to 4 encounter cards (not in the export).
- Choosing where damage goes and which dice to re-roll (currently automatic).
- Reputation and expertise dial thresholds and VP values from the real dials are unknown; ours are tuned.
- Real anatomy card costs and shock die faces are unknown; ours are tuned.
- Tooltips on rivals' threshold squares (asked, not yet decided).
- Sound, animation of the switch, multiplayer hot-seat.
