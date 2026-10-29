# Decision log

Chronological record of the decisions that shaped *The Second Spark*, why they were made, and who asked for them. "Bruno" is the product owner; "Claude" made the call when no direction was given.

Format: **D-number. Decision** (source) followed by the reason and any consequences.

---

## Foundations

**D1. Build an original game in the spirit of Abomination, not a copy.** (Claude, first request)
Plaid Hat owns the name, art and card text. Frankenstein itself is public domain. The project is named *The Second Spark*. Later decisions moved the mechanics close to the real game (D14), but names, wording and art stay original throughout.

**D2. Solo against AI rivals, deep game, gothic illustrated look.** (Bruno, setup questions)
Chosen from three options each: solo vs AI (over hot-seat), deep ~45 minute game, gothic illustrated style.

**D3. One self-contained HTML page published as an Artifact.** (Claude)
Easy to reopen and share, no install. No libraries; all illustrations are inline SVG so nothing external can break.

**D4. Single dark theme by choice.** (Claude)
A candlelit laboratory against an engraved paper map. The page sets its own colours explicitly so it looks the same in light and dark host themes.

**D5. Galvanic blue as the one accent colour.** (Claude)
Electricity is the core fantasy; blue marks "your turn", "alive" and anything you can click.

## Setting and naming

**D6. Move from London to Paris and use the game's location names.** (Bruno: "make the name of the places similar to the game, otherwise I don't understand")
Claude had wrongly said the game was set in London; the rulebook search showed Paris. Locations now use the game's names (Cemetery, Public Square, Morgue, Slaughterhouse, Hospital, Academy, Market, Docks, Dark Alley, Saint-Roch, First Player), each shown with a real 1819 Paris place underneath (Père Lachaise, Place de Grève, and so on). Currency became francs.

**D7. Correct the designer credit to Dan Blanchett.** (Claude, after research)
An earlier answer named the wrong designer. Corrected openly.

## Tracks and economy

**D8. Show every track as a bar, including study/expertise and reputation.** (Bruno)

**D9. Suspicion was explained, then replaced by police markers.** (Bruno asked "what is suspicion?"; later "everything" from the rulebook)
The first build had an invented suspicion meter with raids. When the game was rebuilt on the rulebook, it became the real mechanic: the Dark Alley gives police markers, 2 markers block it, pay 3f to clear. The Police Prefecture location was removed.

**D10. Reputation and expertise thresholds are tuned, not known.** (Claude)
The physical dials' icons are unknown. Chosen: reputation 7 (hospital cadavers, 3rd assistant), 15 (2nd scientist, 2nd cadaver); expertise 10 and 20 (blue dice); final score uses half the highest reputation and a third of the highest expertise.

## The core loop

**D11. Rebuild around materials, building and the switch.** (Bruno, with the rulebook PDF: "we're missing building the body, to then animate")
The earlier "animate a part with one roll" loop was replaced by the rulebook's loop: cadavers give staged materials that rot; parts are built in two steps (muscle, then skin); throwing the switch with Leyden jars brings complete parts to life; damage can downgrade parts.

**D12. Anatomy costs, expertise thresholds and dice faces are tuned.** (Claude, from simulations)
The real anatomy card and dice faces aren't legible in the material we had. After moving to the real cadaver decks, materials became plentiful and games ended on Day 8 to 10. Costs were raised (legs 4 muscle/2 blood/3 bone, arms need expertise 3, torso 8, head 14) and the gray die was made harsher (1 eye, 2 bolts). Result: games end Day 10 to 12, about a third with a living companion, the rest by the Captain.

**D13. Damage placement and re-rolls are automatic.** (Claude, simplification)
The physical game lets you choose. Automatic placement spreads damage and protects muscle parts; re-roll cards re-roll every eligible die not showing an eye. Listed as a known gap.

## Cards from the real game

**D14. Use the real cards' numbers from the Tabletop Simulator export.** (Bruno found the cards in a Steam Workshop mod and exported them; asked for "Everything")
All 52 cadavers, 16 scoundrels, 16 research, 16 humanity, 19 events, 15 encounters and 6 characters were transcribed. Mechanics and numbers match; names, wording and art are original. Creative names were renamed (for example King's Mercy became Royal Pardon, Leopold the Vast became Big Gustave, the six characters got new names and portraits).

**D15. Leopold-equivalent body joins the Public Square deck.** (Claude)
In the physical game it's held aside for an encounter that wasn't in the export, so it's a rare, expensive body instead.

**D16. Early encounters are missing.** (Claude, data limit)
Only the round 5 to 12 encounter sheet (plus one round 1 to 5 card) was exported. Early days are events only. Open item.

**D17. Event deck shape.** (Claude)
12 days: events matched to each day's round range, with 4 encounters on random days from 3 to 12. Day 1 is a gentle event.

**D18. Bump track costs are guessed.** (Claude)
`[1]` for 2 players, `[1, 2]` for 3, `[1, 1, 2]` for 4.

## People on the board

**D19. Scientists and assistants.** (Bruno: "There's another thing missing: assistants and doctors")
1 scientist and 2 assistants; scientist-only spaces as in the rulebook; scientists earn slightly more at Lecture, Saint-Roch and Charge Jars. You pick who to send with two buttons; if the chosen kind can't go, the other is sent with a toast.

**D20. Action spaces with bumping instead of multi-slot locations.** (Claude, following the rulebook)
Each space holds one meeple. Matches the real board and makes blocking matter.

**D21. Six characters with a card picker.** (Bruno: "I need to be able to read what each of them do. Instead of a dropdown, make a card selection.")
Cards with portrait (open eyes, to read as living people), role, name, a red one-line perk and the full ability, plus a Random card.

## Visibility and clarity

**D22. You can see what rivals are building.** (Bruno)
Small operating tables in the Rivals panel and a full "View their lab" window.

**D23. Show the numbers on everything.** (Bruno: "always display how much expertise you get, how much you have to pay")
Every space shows its exact gain or cost for the selected meeple; materials display as "3 muscle II" instead of rows of cubes; every card shows expertise, francs and humanity.

**D24. Face-up rows visible on the board.** (Bruno: "research cards are always drawn, meaning you always see 3 per round. Same thing for Church and hospital (2 bodies only). The cemetery and morgue aren't open")
Academy 3 research, Saint-Roch 3 humanity, Hospital 2 bodies, Docks 3 scoundrels, all shown on the location cards. The rulebook says 2 research and 2 humanity; Bruno's 3 was kept, and he was asked whether to switch back. Cemetery and Morgue stay hidden until used. At the Hospital you choose which visible body to take.

**D25. The Hospital always shows exactly 2 bodies.** (Bruno)
Cholera and the "Claim the dead" encounter no longer add bodies to the display; the encounter's extra bodies come from the deck instead.

**D26. Tell players how to use each card.** (Bruno: "How do I use the research cards?")
Each card in hand has a "Use it:" line (Play button, offered at a specific place, automatic) and its dice mitigation line.

**D27. Points shown per part and in a table.** (Bruno: "list the points")
Body part rows list VP by stage and alive value; a points table shows muscle VP, skin VP and alive points for every part.

**D28. Body line with state colours.** (Bruno: "R Leg - L Leg - R Arm - L Arm - Torso - Head. Bold red if muscle, bold yellow if skin, blue if alive")
Shown in your lab, rival cards and rival lab windows.

**D29. One operating table, coloured by state, with damage badges.** (Bruno: "we only need one operation table... important to have icons for damage and how much")
Replaced the brief two-table (muscle/skin) layout. Red, yellow, blue fills; a lightning badge with the damage count on each damaged part; a legend underneath.

**D30. Decomposition track sits directly below the operating table.** (Bruno)

**D31. Rival stats as bars.** (Bruno: "show the rival cards as bars as well")

**D32. Tooltips on threshold squares.** (Bruno: "Tool tip on the blue square, on expertise and on reputation")
Hovering a blue-outlined square explains what that value unlocks.

**D33. Tooltips only on the map.** (Bruno: "remove tool tip from the cards... it's only for the map")

**D34. Accept / Refuse for yes/no questions; story wording for encounters.** (Bruno)
"Read them / Burn them" on A Dead Man's Notes was confusing. All event and reaction prompts now use Accept / Refuse with the gain and cost in the question. Encounter choices keep their story wording ("Stitch him up / Turn him away").

## Art

**D35. Hand-drawn SVG engravings, not generated images.** (Claude, after Bruno connected Higgsfield)
The Higgsfield connector in this chat only reads account data and can't generate images. Options given: generate in Higgsfield or via its CLI in Claude Code, then swap in. Until then, every location, lab space, card and portrait is an inline SVG in an engraving style.

## Process

**D36. Test with simulations and a UI driver before each publish.** (Claude)
AI-only simulations (20 to 30 games) for errors, stuck states and balance; a Playwright driver that plays as the human through the real interface; a phone-width overflow check. These caught several real bugs (for example scoundrel cards rendering empty after a naming clash).

**D37. Character portraits are generated images, embedded at build time, with the SVG portrait as fallback.** (Bruno: "Can you create the art for the scientists?")
Bruno generated the six portraits in the Higgsfield app (GPT Image 2, square 1024px) from the prompts in `docs/card-list.xlsx`. Generating from Claude Code was not possible: the Higgsfield connector only reads, and the platform API key authenticates but its account has no API credits (the app workspace's credits are separate). Each image is cropped to 3:4 (shifted right on Marchand and Okafor to drop painted text), downscaled to 480x640 JPEG and kept in `art/` with the originals in `art/source/`. `build.py` embeds every file in `art/` as a data URI in `const IMG`, and `charArt()` in ui.js shows the image when one exists. Used in the character picker, your character line, the rivals panel, the rival lab window and the card catalog. The page grew from 200KB to 830KB. `tools/gen_art.py` is ready for the API route once that account has credits.

**D38. Character picker: 4 columns, picture on top, alternating men and women.** (Bruno: "make it 4 columns, mix men and women order. Name and class below picture.")
The picker is a fixed 4-column grid (2 columns under 640px). Each card shows the portrait first, then role and name, then the perk and ability. The `CHARACTERS` list order became Vautrin, Okafor, Pike, Fontana, Duval, Marchand, so the catalog lists them the same way. No mechanical effect: character assignment is random for rivals and by choice for the human.

**D39. Fonts: Amarante for titles and card names, EB Garamond for text.** (Bruno: "put all titles and card names in this font [Amarante]. The text should use EB Garamond.")
`--f-display` (every heading, card name, button, eyebrow label and map label) is now Amarante; `--f-body` and `--f-flavor` are EB Garamond, regular and italic. Body size went from 15px to 16px because Garamond runs small. IM Fell English and Spectral are no longer loaded. An earlier edit outside this session had put Amarante on the two big headings only, through a `--f-title` token; that token now aliases `--f-display`. The same edit had overwritten the portrait CSS from D37, which was restored.

**D40. Seamless stone wall as the page background, on every screen.** (Bruno: "I've added a background for us to use. Use in all pages. It's seamless, so tile it.")
Bruno supplied `background_seamless.png` (2880px, 21MB). The original lives in `art/source/`; the page uses a 1024px JPEG tile, `art/bg-wall.jpg` (466KB), embedded like the portraits and set as the `--bg-tile` CSS variable at boot. It tiles at 1024px under a 38% ink wash and the existing candle glow, so panels and cards still read darker than the wall. Applied on `body`, so the title, game and end screens and the modal backdrop all sit on it. Rule from this: only derived, web-sized files go in `art/`; anything large goes in `art/source/`, because `build.py` embeds every file in `art/` and the Artifact limit is 16MB. Page size is now 1.45MB.

**D41. Wall tile at 512px, and the UI test plays to the end of the game.** (Bruno: "shorten the tiles by 50%. From now on, the tests should run until game is over.")
The background tile renders at 512px instead of 1024px, so the stones are half the size. `tests/ui.js` no longer stops on Day 6: it loops until `S.phase === 'end'` (step limit 4000, a full game takes about 450 steps) and prints the ending, winner and the human's total. This is a standing rule for any play-through test. CLAUDE.md and SPEC 13 updated.

**D42. No rules text on the title screen.** (Bruno: "remove it. Leave only the text on the button.")
The full rules used to be printed under the character picker. They are now only behind the How to play button (same text, in a modal) and in the header during play.

**D43. The title is a drawn logo, on the title screen and in the game header.** (Bruno: "There's an image for title now. Use that.")
Bruno supplied `title.png` (2688x1520, gold stitched lettering with a blue spark on pure black). The original is in `art/source/`; the page uses a tight crop at 1400px wide, `art/title.jpg` (286KB), drawn with `mix-blend-mode: screen` so the black ground disappears into the wall. `logoHTML()` in ui.js replaces the text heading on the title screen (up to 640px wide) and in the game header (96px tall, 80px on phones); the text heading stays as fallback when the image is missing. The end screen keeps its own "You win" heading. Page size 1.84MB. Note: `art/characters/` holds Bruno's own downloads of the portraits (webp); the build ignores subfolders, so they are not embedded.

**D44. Title logo from `title2.png`, transparent, no blend.** (Bruno: "I didn't like it. use title2.png")
The first logo sat on solid black and was screen-blended, which dulled the lettering. `title2.png` is the same lettering with an alpha channel. It is cropped and scaled to 1400px as `art/title.webp` (446KB, WebP with alpha, made with Pillow) and drawn normally with a soft drop shadow. Originals of both versions stay in `art/source/`. Page size 2.05MB.

**D45. Title screen: logo and subtitle centred, subtitle in white.** (Bruno: "centralize title and the upper subtitle. Make subtitle white, the current color sucks.")
The logo is centred in the hero column and the eyebrow line above it is centred and set in white at 13px instead of the muted grey. The in-game header is unchanged.

**D46. Title screen stripped to logo, setup and picker.** (Bruno: "remove 'see all cards' button. put the 'how to play' button on the top right of the page. Remove the text below the title.")
The Creature's letter and the See every card button are gone from the title screen. How to play sits alone in the top right corner of the page. The card catalog is still reachable from the Cards button in the game header.

**D47. Tall framed card design for Hospital cadavers and Research cards, with a wooden deck back.** (Bruno: "i have a new card design to use with the research and hospital. In the middle of the back card, there's a space to put what kind of card is it")
Bruno supplied `art/decks/tallCard_front.png` (engraved parchment frame with a cartouche at the foot) and `tallCard_back.png` (wooden back with a brass plate), both 1744x2336. The build uses `art/card-tall-front.webp` (600px) and `art/card-tall-back.webp` (360px). Full-size Hospital cadaver cards and Research cards (modals and catalog) are drawn on the front at 190px wide, aspect 3:4, title at the top, the stage numeral in the cartouche; buttons sit under the frame. The Hospital and Academy location cards show the back as the deck, with "Hospital" or "Research" on the plate and the cards left before a reshuffle. Cemetery, Morgue and Public Square cadavers, scoundrels and humanity cards keep the plain paper card until Bruno supplies their designs. The compact face-up rows on location cards are unchanged. `art/decks/` is Bruno's drop folder for deck art; the build ignores subfolders, so derived copies go to `art/`.

**D48. Board layout: painted Paris with places and cards on the left, your column on the right, popups for everything else.** (Bruno, with a wireframe and the original board as reference: "this is the layout i'd like the game to be. When you click in the map, it opens the pop up. The cards in the map are smaller, so we can fit them all... but when you click the pop up, they are in normal size in the pop up.")
Bruno supplied `art/boardImage.png` (3840x2160; original in `art/source/`, the page uses `art/board.jpg` at 1920px). Places are overlaid at percentage positions (`BOARD_POS` in data.js) as a name chip with one meeple slot per action space; beside each place sit its cards at mini size (art and name only): the face-down deck for Cemetery and Morgue with the count left, the face-up rows for Hospital, Academy, Saint-Roch, Docks and the Public Square. Clicking a place always opens its popup: illustration, text, one option per action space with the exact gain, occupant and bump cost, and the cards at full size. The four lab worker spaces are a small strip on the board's lower edge; "Who do you send?" sits bottom-left of the board. The right column holds Your character, Body points and Help buttons, the operating table with the decomposition track and four counters (francs, jars, ice, police), the stat bars, a Laboratory button, three compact rival cards (portrait, name, role, muscle/skin/alive counts, humanity/expertise/reputation) and the chronicle. Night actions (build, switch, preserve, hand) live in the Laboratory popup, which re-renders live; the character popup holds the hand and the police payoff; the points popup holds the points table and the part list. A slim header keeps the logo, day, phase, first player, today's card (click to see it), the Captain track, Cards and New game. Below 1100px the board scrolls horizontally inside its own box at 760px minimum so the page never overflows. The engraved SVG map, the location cards and the long laboratory panel are gone. Font sizes on the board use container units so they scale with it.

**D49. Full-width page, bigger board, operating table beside the decomposition track.** (Bruno: "make the game occupy 100% of the screen browser. make the boardgame image occupy more space. Operating table should be right next to the table of decomposition track. Squeeze decomposition track a bit if u need.")
The game page no longer has a max width. The right column is fixed at 380px (340px under 1400px) and the board takes everything else. In the side column the table (96px) sits left of a squeezed decomposition track: smaller type, tighter cells, and the explanatory notes hidden there (they remain in the Laboratory popup). Rival names wrap instead of truncating.

**D50. Top of the game screen: logo, objectives and the Captain on one row; a short toolbar above the board; no Cards, New game or bump track on the page.** (Bruno: "remove cards button. Remove Bump track. Put capitain waldon where bump track was. remove new game as well. put a tool bar on top of the top part of the map, short. put in tha toolbar the info about the day and the dead man's note link. Sci and Ast buttons... no. Make them one below the other, write Scientist and Assistant. Move the logo next to objectives, left side.")
The header bar is gone. The first row of the left column is the logo, the bonus objectives and the Captain Walton track at the right end. A thin toolbar sits on top of the board with "Day N · phase · first player" and the "Today: card name" link. The bump track is no longer drawn; bump costs still show in the place popup. The card catalog and New game moved into the Help popup's buttons so a game can still be abandoned. The send buttons are stacked and read Scientist and Assistant with the count.

**D51. The operating table opens the Laboratory popup, which has three columns.** (Bruno: "The operating table should be clickable and bring up the pop up of the laboratory. In the pop up, make the operation table bigger, divide this section in 3 columns.")
Clicking the operating table in the right column opens the Laboratory popup (the Laboratory button remains). The popup is extra wide (1240px) with three columns: the operating table at 230px with legend, VP built, body line and the switch box; the body parts to build with the Steady Hands and Surgeon toggles; the decomposition track with Preserve buttons and the points-per-part table. The hand of cards sits below. Under 1000px the columns stack.

**D52. Rival names on one line; a Cards button with the hand count beside Laboratory.** (Bruno: "Rivals - Names should occupy only one line, maximum, or it breaks layout. Next to laboratory, I want you to create a 'Cards' link, with a number, but this one is about the cards the player obtains in university, church, etc...")
Rival names are clipped with an ellipsis on one line (the full name is in the hover title and in their lab popup). A Cards button next to Laboratory shows the number of cards in hand and opens a popup listing them with their Play buttons; the same list stays in the character popup.

**D53. No Body points button.** (Bruno: "remove body points button.")
The points-per-part table is in the Laboratory popup (D51), so the separate popup and button are gone. The right column's top row is Your character and Help.

**D54. No body line in the rival lab popup.** (Bruno: "remove this from rivals, the text.")
The "R Leg – L Leg – …" line is gone from the rival lab popup; the operating table and part list there show the same information.

**D55. New game button next to Help.** (Bruno: "now add 'new game' button, next to help")
The right column's top row is Your character, Help, New game. The Help popup keeps the Every card button only.

**D56. Rival lab popup uses the Laboratory popup's three columns, with the rival's portrait and character on top.** (Bruno: "make the rivals pop up just like the laboratory pop up, but with the addition of their character photo and info")
Clicking a rival card opens an extra-wide popup: a strip with their portrait, character name, role and ability, VP built, francs, jars, police, their stat bars and a line on cards, ice and people at home; then the same three columns as your Laboratory, read-only: operating table with legend, body parts, decomposition track and the points table. It re-renders live during the day.

**D57. Public test build on GitHub Pages.** (Bruno: "How can I publish this, as is, so people can test it in the browser online?" Chosen: GitHub Pages, Personal project.)
The project folder is now a git repo at https://github.com/exidium/second-spark (public, because Pages is free only for public repos on a personal account). `dist/` is pushed as the `gh-pages` branch and served at https://exidium.github.io/second-spark/ (an index.html there redirects to second-spark.html). `npm run deploy` rebuilds and pushes it. A GitHub Actions workflow was tried first but Bruno's `gh` token lacks the `workflow` scope; the branch route needs none. Ignored from the repo: `node_modules`, test screenshots, and the large originals in `art/source/`, `art/characters/`, `art/decks/`. The claude.ai Artifact stays as the private preview.

**D58. One paste sheet with all 150 remaining image prompts, written for Nano Banana 2 in ChatGPT.** (Bruno: "create a prompt to generate images for each of them. I want to generate it on chat gpt nano banana 2.")
`docs/prompts/all-images.md` is generated from `docs/card-list.xlsx`: 12 locations, 4 lab spaces, 52 cadavers, 16 scoundrels, 16 research, 16 humanity, 19 events, 15 encounters, each with the file name the build expects. Because that model has no negative-prompt field, the avoid list is folded into every prompt as "Do not include". The sheet opens with the style-reference trick (keep one approved image in the chat and say "same style as this image") since that is what keeps a set consistent.

**D59. Card and location art switches to 96-pixel, 32-colour pixel art.** (Bruno: "update all prompts for images for a 96 px 32 colors.")
All 150 prompts in `docs/prompts/all-images.md` were rewritten: retro pixel art, hard pixels, no anti-aliasing, a strict 32-colour gothic palette (the cadaver set uses a darker palette with no blue), one lamp, one silhouette. Canvases: 96x54 for locations and lab spaces, 64x96 for cadavers and scoundrels, 96x72 for research, humanity, events and encounters. Generators cannot output true 96-pixel images, so `tools/pixelize.py` crops, shrinks with a box filter, quantises to 32 colours without dithering and can write a nearest-neighbour upscale for the page. The pencil-style portraits, board and title stay as they are for now; whether to redo them in pixel art is open.

**D60. Art generated through the Gemini API; art folders organised by set; the six characters redone in pixel art.** (Bruno: "ok, generate the character players. Be sure to organize everything into folders.")
With Bruno's Gemini key (stored in his shell, never in the repo), `tools/gen_gemini.py` calls Nano Banana 2 (`gemini-3.1-flash-image`) with the prompts from `docs/prompts/all-images.md`, attaching the Cemetery as the style reference. The six portraits replace the pencil-style ones (which moved to `art/source/pencil/`). Game copies are the generator's native pixel look resized to 384px wide and quantised to 32 colours (`tools/pixelize.py --width 384`), about 60KB each; true 96-pixel versions are kept for the mini cards only. Folders: `art/ui`, `art/frames`, `art/characters`, `art/locations`, `art/cadavers`, `art/scoundrels`, `art/research`, `art/humanity`, `art/events`, `art/encounters`, each mirrored under `art/source/` for originals (ignored by git). `build.py` now embeds every image under `art/` except `source/`, keyed by file stem. The old Higgsfield generator was removed.

**D61. Character portraits redone as close-up dithered pixel portraits.** (Bruno: "Horrible. the image of the characters should be more like this", then "This one is better".)
The first pixel set (wide, flat, bust with props) was rejected. The six prompts in `docs/prompts/all-images.md` now ask for an extreme close-up, face turned three-quarters, checkerboard dithering, a warm sepia and brass palette with one blue glow, and a dim laboratory behind lit by candle. They were generated with Bruno's reference image attached (`art/source/characters/style-reference.png`); the rejected set is in `art/source/characters/v1-wide/`. Lesson for the other sets: a close-up with one light and one blue accent beats a full scene.

**D62. Casting and colour fixes for the character portraits.** (Bruno: "heiress, surgeon and human are not following the art I gave you... Charlatan is very similar to the psycho. Make the Charlatan asian. The zoologist black")
Count Achille Duval is now an East Asian aristocrat (clean-shaven, sleek hair, fur collar, no hat) so he no longer echoes Vautrin; Sir Bartholomew Pike is a Black English naturalist. Heiress, surgeon and humanitarian were washed-out brown, so their prompts now carry a deep red accent (ribbon or scarf) and a "richer colour than plain sepia" line: oxblood cloth, candle-gold skin, blue-grey night window, one electric-blue Leyden jar. All five were regenerated against the style reference; the previous set is in `art/source/characters/v2/`.

**D63. Hospital cadavers and the card back are generated pixel art; cadaver cards carry an image key.** (Bruno: "ok, i like it. Create the other cadaver cards for the hospital. Remember to keep the reference art in mind and with the 3x4 facing the camera style.")
The 14 hospital bodies were generated with the approved `hospital-01` attached as the reference (one failed the model's image filter on the first try and passed on retry). Each cadaver card now has `art: "<deck>-NN"` from its row index in `CADAVERS`, and `cadaverArt()` shows the image when `art/cadavers/<deck>-NN.png` exists, else the seeded SVG face, so Cemetery, Morgue and Public Square still draw faces until their sets are made. Old saves lack the key and fall back the same way; no save version bump. The pixel card back (`art/frames/card-tall-back.png`, jar sitting on a blank brass plaque) replaces the wooden one; the plate text sits at 54% height. Game copies are 384x512 at 32 colours, about 80KB each; the page is 4.8MB, which GitHub Pages serves fine but is past the claude.ai Artifact limit's comfort zone, so the Artifact preview is retired.

**D64. Every cadaver gets an explicit identity; the reference is for style only.** (Bruno: "01 and 08 are repeated faces. Also, use different races. The eyes are quite repeated and the faces too. Give me more variation")
Attaching one body as the style reference made the model echo her face. Each hospital subject now states origin, age, build, hair and one distinctive feature (a North African porter, a South Asian woman with a braid, an East Asian woman, a Black coal porter, a Black woman with tight curls, an Irish washerwoman, and so on), and the style block says "a completely different person: do not copy the reference's face, age, hair or features, only its palette, lighting, dithering and framing". Bodies 2 to 14 were regenerated; the previous set is in `art/source/cadavers/v3/`. The same identity rule applies to the remaining 38 cadavers and the 16 scoundrels before they are generated.

**D65. Cemetery cadavers generated: grey grave skin, stage III clearly rotting, skulls at portrait scale.** (Bruno: "Do cemetery now. do 3 examples before you commit to all... make the skins a bit more greys for the cemetery. The skull should respect the same zoom level... 09 is barely dead... make it more decomposed... make her eye hollow... Create the rest of the cemetery bodies.")
Three examples were approved first (01 stage IV, 05 bones, 09 stage III), then the other 11. Cemetery prompts carry a "grave skin" line (ashen grey and grey-green, gold only in highlights) and the bones-only cards a "same zoom as a face portrait" line plus "only bone: no face, no skin". Stage III wording for all 12 stage III cards (cemetery and morgue) now describes bloating, blotching, marbled veins, slipping skin and lips drawn back; a mention of maggots made the model refuse and was removed. Bodies use the grey washerwoman (`cemetery-01`) as the style reference, bones use the skull (`cemetery-05`); the hospital woman as reference had been leaking a warm cast and a neck bandage. Two cards were refused once by the model's image filter and passed on a plain retry. Earlier attempts are in `art/source/cadavers/v4/`.

**D66. Cemetery bodies: each with its own eye state and more exposed bone; skulls 06 and 08 recast.** (Bruno: "the eyes are very similar, make them more varied... upward maybe. One closed other opened... missing one eye or two... There should be less flesh showing and with more skull or torn muscles. 06 - change skull type. break a jaw, or something. 08 - same thing, change skull type, make it different.")
Each of the ten cemetery bodies now has an EYES line (both sockets empty; one rolled upward and one sunken; half-open clouded; one open one swollen shut; one bulging one torn; both bulging; one closed one off to the side; shreds of eyelid; one collapsed) and a DECAY line naming where bone and muscle show (cheekbone through a hole in the cheek, jawbone through split skin, scalp peeled to the skull, nose rotted to the nasal bone). Skull 06 is long and narrow with the lower jaw broken off; 08 is broad with thick brow ridges and a caved-in cranium, tilted on the bones. All twelve were regenerated with the previous washerwoman as reference (kept in `art/source/cadavers/v5/`). The hanged man was refused twice by the image filter and passed on the third plain retry.

**D67. The four cemetery skulls differ in angle, colour and damage.** (Bruno: "the skulls are still very much similar. Make them different from one another. Maybe broken parts, different colors, maybe they are not looking totally forward...")
Each bones-only card now states an ANGLE and a COLOUR: 05 straight on, bleached white, cracked crown, sockets packed with soil; 06 turned three-quarters left, peat-brown, the whole lower jaw gone, rosary hand at the side; 07 lying on its side in profile, yellowed ivory with moss, the back of the cranium smashed to shards; 08 green-grey with verdigris, a hole in the cranium, beside the name plate. The "same zoom" line now says to follow the given angle and not the reference's pose. The skulls were generated with the grey washerwoman as style reference rather than another skull, which had been copying the pose. 08 was asked for a from-below view twice and came back facing forward both times; its colour and damage carry the difference instead. 07 was refused once by the image filter and passed on retry. Earlier skulls are in `art/source/cadavers/v6/`.

**D68. Skulls lie on the pillow seen from above, like every other cadaver; colour and damage keep them apart.** (Bruno: "the perspective should always be as I'm looking down at a coffin. Leave the pillow as the other cadavers.")
D67's per-skull angles are withdrawn. All four bones-only cards use the same top-down view onto the coffin pillow as the bodies, skull facing up at the camera from the top of the skull to the collarbones. Variation comes from bone colour (bleached white, peat brown, yellowed ivory with moss, green-grey with verdigris) and damage (cracked crown with soil-packed sockets, missing lower jaw with the rosary beside it, the side of the cranium smashed into shards, a hole in the cranium beside the name plate). Previous skulls are in `art/source/cadavers/v7/`.

**D69. Morgue cadavers generated.** (Bruno: "Let's go to the morgue now!" then "go ahead. I like it")
Three examples (01 drowned stage II, 06 river stage III, 11 rat-eaten stage II) were approved, then the other 11 with the drowned woman as the style reference. Each of the 14 states origin, age, face shape and its own EYES line, lying on the stone slab with the sheet at the chest. One card, a young woman with a cut throat, was refused twice; changing "girl of twenty" to "woman in her mid-twenties" and "slashed neck" to "a deep cut across the throat already dark and dry" got it through. Lesson: the image filter reacts to youth words next to violence more than to the violence itself.

**D70. Morgue 10 and 14 regenerated as plainly dead.** (Bruno: "change 14 and 10. 14 seems alive, wtf")
Open staring eyes on a fresh body read as alive. The carter now has a slack open mouth, grey-white skin with lividity under the jaw, and eyes half open, filmed and rolled up with no focus; the frozen woman has her eyes closed and frosted shut, waxy blue-grey skin and black cracked lips. Rule for the stage I and II cards still to come: "open eyes" must always be paired with dull, filmed, rolled or unfocused, never a direct gaze. Previous versions in `art/source/cadavers/v8/`.

**D71. Public Square cadavers generated; all 52 cadavers now have portraits.** (Bruno: "do public square cadavers now" then "good. go ahead.")
Ten fresh stage I bodies on straw against the stone wall of the square, framed from the top of the head to the collarbones so the throat wound sits at the lower edge. Each states origin, age, face and a dead EYES line (filmed, rolled, half-lidded or closed; never a direct gaze). Big Gustave (10) was the first to pass and became the set's style reference. The model's image filter refused "executed", "scaffold" and "blade" repeatedly, so the prompts say "dead", "straw and cobblestones" and "a dark dried line at the base of the throat"; the highwayman needed a "thin dark bruised line low on the neck" to get through. With this deck every cadaver card shows a generated portrait; the seeded SVG face remains only as a fallback.

**D72. Images live beside the page instead of inside it.** (Bruno: "Do it.", after the page reached 9MB with 65 embedded images.)
`build.py` now copies every image under `art/` (except `source/`) to `dist/art/<set>/` and `IMG` maps each file stem to that relative path; the HTML is back to about 220KB and the browser fetches images on demand and caches them. `python3 build.py --embed` still produces the old single-file build for anyone who wants one file. Consequence: `dist/` must be served or opened as a folder, not pasted as raw HTML, so both Playwright tests now start a tiny local HTTP server on `dist/`. The gh-pages branch is the whole `dist/` folder, so GitHub Pages is unaffected. The claude.ai Artifact route would need `--embed`.

**D73. Cadaver cards use the physical game's layout: full-bleed portrait with a numbers strip at the foot.** (Bruno, with a photo of an original card: "Change the ratio of the cards to fit the image. Use this reference of the original game. Our layout is very different.")
A cadaver card is now a 3:4 card at 190px wide whose portrait fills it edge to edge. The deck name and the body's name sit over the top of the image; a small row above the strip carries the expertise option and any humanity or franc cost; the strip at the foot holds five boxes: the stage numeral, then muscle, organ, blood and bone counts in the material colours, zeros dimmed. The engraved parchment frame is no longer used for cadavers (research cards keep it). Mini cards on the board show the same portrait with a thin five-box strip instead of a name. The seeded SVG fallback keeps the old paper card. A `<meta charset="utf-8">` was added to the page head so it renders correctly under any server.

**D74. Scoundrel portraits generated and wired in.** (Bruno: "Let's work with scoundrels now", "all should follow scoundrel 02 format", "lovely. go ahead")
Sixteen living portraits in the style of the hard-faced nurse (02): facing the camera almost straight on, a hard closed-mouth stare, muted umber and grey-brown, dark except the face, one lantern in a dim 1819 night scene behind. The first three-quarter, smiling attempts were rejected and are in `art/source/scoundrels/v1/`. Each subject has its own identity and origin. Scoundrel cards (Docks popup, Docks encounter, catalog) and mini cards on the board show the portrait by template index (`scoundrel-NN` from `tpl`), with the seeded SVG face as fallback. Card layout unchanged otherwise.

**D75. Location and lab-space scenes generated and shown in the place popups.** (Bruno: "do the next one", "Commit rest. All good.")
Sixteen 16:9 night scenes in the dithered style (umber and charcoal, one lantern, one blue accent): the 12 places and the 4 lab spaces. The first three (Cemetery, Hospital, Charge Jars) were approved, the rest generated with the Cemetery as reference; all passed first time. `placeArt()` shows `art/locations/location-<id>.png` or `lab-<id>.png` in the place and lab popups, 640px wide, with the SVG drawing as fallback. The Hospital scene is the street outside rather than the ward the prompt asked for; kept. Bruno's own pixel-board file that had landed in `art/locations/` moved to `art/source/ui/board-bruno-pixel.png`.

**D76. Event scenes generated and shown on the event card.** (Bruno: "ok, do events." then "do it.")
Nineteen 4:3 scenes in the dithered style, one moment each, blue kept to lightning and sparks. Three examples (the anonymous letter, the cholera ward, the stitched body) were approved, the rest generated with the letter as reference. Two cards echoed the letter instead of their subject (Fire at the Academy, Loyalty Pledges) and were reworded and rerun with the ward as reference; earlier versions in `art/source/events/v1/`. `eventArt()` maps an event to `art/events/event-NN.png` by its position in `EVENTS`, with the old SVG place drawing as fallback; the day modal, the Today popup and the catalog all use it. Lesson: a reference image of a single object (the letter) leaks that object into other subjects; a scene reference leaks less.

**D77. Six event scenes redone with tighter subjects.** (Bruno: "event 03 has a floating hand. event 05 is all weird and wrong. event 9 artwork is out of style. event 15 is weird. redo it. event 16 - weird, it's not clear what this is. Same with event 18.")
Hard Times is now a padlocked bakery door with a woman on the step; Patrols at the Graves two gendarmes with a lantern among tombstones under lightning; Student Parade students with torches passing the Academy's columns; The Captain's Wrath the captain's face as his pistol butt shatters the jar; Opening Night the theatre front with couples on the steps and a carriage; Storm from the Sea the quay with a pitching barge and lightning over the bridge. Each subject now names whole figures, a vantage and one focal point; all six passed first time with the ward as reference. Earlier versions in `art/source/events/v2/`.

**D78. Student Riots redone as a barricade scene.** (Bruno: "event 11 is weird, redo.")
Three students with torches and a flag on a barricade of carts, barrels and paving stones, seen from street level. Same prompt rule as D77: whole figures, a vantage, one focal point.

**D79. Scoundrel cards follow the physical game's layout, built on the cadaver card.** (Bruno, with a photo of the original scoundrel sheet: "make the scoundrel cards similar to the cadaver cards. look how they work and are layouted.")
A scoundrel card is the same 3:4 full-bleed portrait as a cadaver, with the franc cost and any humanity cost as marks top left, a slanted parchment band across the middle with the name and the flavour line, a benefit row (expertise, humanity, materials) above the foot, and the stage and material counts strip at the foot. Hospital Thieves have no materials, so their foot is a text panel ("Draw N from the Hospital stack") like the original. The seeded SVG fallback keeps the paper card.

**D80. Event cards are landscape.** (Bruno: "the cards for events are great... but let's make them horizontal this time.")
The event card is 360px wide with the 4:3 scene across the top, the day range top left, the lightning and execution marks top right, the name over the bottom of the scene, and the text in a parchment panel below. Used in the Day modal, the Today popup and the catalog.

**D81. Scoundrel card marks as icons, name on top, mini cards with the strip; place popups with a hero scene; Docks acts directly.** (Bruno, five points: hearts and coins as icons not numbers; buttons that look like buttons and no "Hire a scoundrel" step; the name in white at the top with no flavour subtitle; the small cards in the same layout; generate heart, broken heart and coin icons. Then: big white location title top left over a flush image, no real-place subtitle, no description text, the section heading is the action, option rows without a sub-line.)
Three pixel icons were generated (coin with a fleur-de-lis, whole heart, broken heart) and keyed to transparency by flood-filling the black background from the edges (`art/icons/`, 64px). A scoundrel card shows one coin per franc and one broken heart per humanity point under the name, the name in white at the top like a cadaver, a benefit row with heart icons, and the strip; the flavour line is gone. Mini scoundrel cards on the board use the portrait and strip (thieves: "Draw N"). Every place popup opens with the scene flush to the modal's top and sides and the name large in white over it; the real-place line and the description text are gone. The Docks popup lists the cards with proper buttons (Materials primary, the alternatives below) and hiring happens from the card itself through `dockPick`, so there is no separate "Hire a scoundrel" option. The modal renderer omits the `h2` for hero popups, and the UI test now detects a popup by `.modal` rather than `h2` (the old check stalled the run). A CSS rule that stretched every image inside a card to full bleed was scoped to the portrait only; it had been swallowing the icons.

**D82. Icons are hand-set pixel art, not generated.** (Bruno: "not a literal heart. the symbolic one. Also, make them bigger... the coin has white background. Where's the transparency?")
The generated icons were anatomical hearts, and the coin's pale backdrop would not key out. The three icons (coin with a fleur-de-lis, symbolic heart, broken heart with a jagged crack) are now drawn pixel by pixel in `tools`-free Python with a true alpha channel (`art/icons/`, 4x nearest-neighbour from a 14 to 16 pixel grid). On the scoundrel card they show at 28px, 18px in the benefit row. Generated attempts kept in `art/source/icons/generated/`.

**D83. Icons redrawn on a 48-pixel grid.** (Bruno: "The resolution of the coin seems bad...")
The 14-pixel coin doubled every pixel at 28px and the emblem turned to mush. The coin and both hearts are now drawn at 48px: the coin has a dark rim, a lit upper-left and shaded lower-right, and a bold serif F for francs instead of the fleur-de-lis that read as a trident; the hearts are the emoji silhouette with a highlight, the broken one split by a jagged transparent crack.

**D84. Docks popup: no sideways scroll, no duplicate benefit row, marks lower under the name.** (Bruno: "No horizontal slider. On top of the image there's 2 blocks with +2 exp and materials. Those are redundant. Remove them. Give more space between the name of the card and the coins+heart")
Hero popups clip horizontally (the flush scene's negative margins had produced a 2px scrollbar). The benefit row on a scoundrel card is shown only when the card has no action buttons (catalog, board mini); in the Docks popup the buttons say the same thing. The coin and heart marks sit 44px from the top, clear of the name.

**D85. The Slaughterhouse popup offers its two choices directly.** (Bruno: "don't give me the button and then another screen to select what animal parts I want. Just give me the two buttons right on the first screen.")
The place popup's options are "Take 4 animal at stage II" and "Take 3 animal at stage I", each with its cost note and the occupant line; choosing one places the meeple and resolves at once. The Docks pre-pick became a general `prePick` that `humanPre` honours for any space, so other places with a single follow-up question can get the same treatment.

**D86. Encounter scenes generated; encounter cards use the landscape layout.** (Bruno: "proceed with the other encounters.")
Fifteen 4:3 scenes. The Creature (towering, stitched brow and wrists, yellowish skin, long black hair, black lips, ragged greatcoat; no green skin, no neck bolts) and Captain Walton (white whiskers, bicorne, navy greatcoat, flintlock) have fixed descriptions repeated in every card they appear in, so they look like the same two figures across the set. Three examples (the bleeding Creature, the hooded stranger, the Captain by the bed) were approved, the rest generated with the Creature card as reference; all passed first time. `encounterArt()` maps a card to `art/encounters/encounter-NN.png` by its position in `ENCOUNTERS`, with the seeded face as fallback; the card uses the same landscape frame as events, the visitor's name over the scene and the story, trigger, test and choices in the panel below.

**D87. Designed meeples: two mono-colour silhouettes, scientist and assistant.** (Bruno: "I also want to design meeples for the game... Maybe they have to be 2D. Make them mono color." and "differentiate scientist meeple from assistant meeple.")
Each meeple is a flat single-colour silhouette drawn on a 14x20 pixel grid and rendered as one SVG path of unit squares, so it stays crisp at any size and takes the player's colour as its fill. The scientist wears a top hat, has narrow shoulders and split coat tails; the assistant wears a flat cap with a brim and has round shoulders and a solid apron-shaped body. They replace the coloured dots on the board's place slots and the lab strip, and the same drawing serves the send buttons, bump track and rival rows. A first freehand attempt read as blobs and was replaced by the grid version.

**D88. Scientist meeples are drawn 1.5x the height of assistants.** (Bruno: "Make the scientist meeple bigger (1.5x) than assistant. That way we can ID it easier.")
`meeple()` scales a scientist by 1.5 wherever it is drawn; board slots give scientists the taller box and align the row to the baseline.

**D89. Slaughterhouse options side by side without explanations; the Market trades from its place popup.** (Bruno: "remove subtitles from animal buttons... Make buttons in the same line." and "market... offer the options right on the first screen. No need for the 'Buy and sell'")
The two animal options sit on one row with only the material line under each (plus the Glut of Meat bonus and the occupant when relevant). The Market place popup shows the trade steppers and the running "francs after" total directly, with a Trade button that places the meeple and applies the trades through `prePick`; the standalone market modal remains for the Burning the Candle re-use. Options can be flagged `row:true` to share a line.

**D90. Research scenes generated; research cards use the landscape frame.** (Bruno: "Do research!" then "love it! Do them all")
Sixteen 4:3 scenes of objects and moments on the laboratory bench (pickling jars, the sealed letter and dagger, the galvanised man on the table, the stitched seam, the rich pupil, the lecture theatre, salve and bandages, the burnt candle over the skull, flowers on a coffin, the pinned dissection, the sleeping scholar, the pinned cat, the heart in the electrolysis dish, the dancing dog before the crowd, the transfusion tube, the hand press with pages drying). Three approved, the rest generated with the jars as reference; all passed first time. `researchArt()` maps a card to `art/research/research-NN.png` by its position in `RESEARCH`, with the small SVG icon as fallback. Research cards use the landscape event frame at 280px with the name over the scene and text, gain and dice mitigation below; the parchment frame is no longer used anywhere. The hand list shows a thumbnail beside each research card; mini cards on the board show the scene.

**D91. Research and humanity cards are text cards on a frosted pixel-art face, after the physical game.** (Bruno, with photos of the original sheets: "research cards are like this: I think we just need to re-create the background that goes in all research cards... pixel art." and "Humanity cards are the same... change the colour slightly for humanity.")
A frosted parchment face with corner filigree was generated as pixel art (`art/frames/card-research-bg.png`, 384x512); the humanity face is the same image tinted warmer and greener (`card-humanity-bg.png`). Both cards show the name, a "Research" or "Humanity" rule, the text, and a gain row of numbers with icons (expertise brain, reputation medal, coin, heart or broken heart); a research card adds a dark strip below with a gray or blue die and the dice effect. New icons `icon-expertise` and `icon-reputation` were hand-drawn on the 48px grid. The generated research scenes stay for the board's mini cards and the hand thumbnails, where a text card would be unreadable; the humanity scene prompts are in the sheet but only three examples were generated and are not used.

**D92. Francs are always written out.** (Bruno: "instead of writing 'f', always write 'francs' or 'franc' if it's singular.")
A `fr(n)` helper gives "1 franc" or "N francs"; every literal and template in data, engine and UI was swept (72 spots). Gain lines, option sub-lines, the Market panel, the dawn and log messages and the card texts all use the words. The scoundrel card's coin marks remain icons.

**D93. Cemetery, Morgue and Dark Alley popups simplified.** (Bruno: "Remove the deck image and cemetery deck, 14 of 14... On the button, write 'Dig up to 3 cadavers'. Remove the subtitle." "Morgue, same thing: 'Buy up to 2 cadavers', put franc icon here, remove subtitle." "Dark alley: make icons for each of the gain." "police icon: just make a police sheriff badge.")
The deck back and count are gone from both popups; each has one option whose label carries the draw count (plus 1 under Cholera), the Morgue's with a coin icon, and only the occupant line beneath when someone is there. The Dark Alley option shows its gain as a row of material cubes, a broken heart with 3, and a six-point sheriff-star police icon with 1 (`icon-police`, hand-drawn).

**D94. First Player option reads "Become first player for the next day", sub-line "(can't be bumped)".** (Bruno.)

**D95. Card face regenerated as true pixel art with a clear middle; stat icons beside the bars and counters.** (Bruno: "the background isn't pixel art. Also, can you see the writing goes on top of the line art? Fix that." and "if you are proposing icons for expertise, humanity and reputation, put them beside the text on the table and bar.")
The frosted face was regenerated with a chunky-pixel prompt (big pixels, coarse dithering, blocky ice crystals at the edges only, the middle two thirds empty) and snapped to a 96x128 grid before a 4x hard-pixel upscale, so the pixels are real; the humanity tint derives from it. Text on these cards now sits inside 16% side and 12% top padding, clear of the corner crystals. The humanity, expertise and reputation icons sit beside the labels on your stat bars and in the rival rows; the francs and police counters carry the coin and the badge.

**D96. Image URLs carry a content hash so browsers never show a stale file.** (Bruno saw the old card face after the new one was deployed: "The background of the card still isn't pixel art.")
The new face was on the server, but the file name had not changed and GitHub Pages serves images with a 10-minute cache, so his browser showed its cached copy. `build.py` now appends `?v=<8-char md5>` to every image path in `IMG`; a changed image gets a new URL and is refetched, an unchanged one stays cached.

**D97. Saint-Roch: take the humanity card from the popup.** (Bruno: "Now do you for humanity, the church")
The Saint-Roch popup shows the three humanity cards on the tinted pixel face with a Take button on each; the heading reads "Take a humanity card" with a +1 heart when the meeple sent is a scientist. Taking a card places the meeple and resolves through `prePick`; the separate Atone option is gone.

**D98. Research and humanity faces are faded scenes: a scholar's desk and a church altar.** (Bruno: "Do a completely art for research AND church. Research should be kind of a faded out desk and books... the church... an altar with cross. Really faded, low contrast, so we can write text on top of it.")
Both faces are generated as pale, low-contrast pixel engravings (12 colours asked, 16 kept) and snapped to the 96x128 grid: an open book, a stack of books, quill and candlestick on a desk for research; a stone altar with a tall cross, two candles and an arched window for humanity. An extra fade pass in the pipeline washed them to white and was removed; the generator's own contrast is what ships. Card text is darker and medium weight to sit on the scenes. The frosted faces are kept in `art/source/frames/v3/`.

**D99. Card faces faded further.** (Bruno: "I like both. Make them even more faded out")
Contrast at 62% and brightness at 107% before the pixel snap; the darkest pixel on either face is now about 225 of 255, so the desk and altar read as a ghost behind the text.

**D100. Research and humanity cards: plain parchment with a pixel emblem at the top, a book and a cross.** (Bruno: "let's try something different. Make a pixel art book on the top center of the card for research, a cross for church.")
The faces are plain hand-made parchment (a speckled 96x128 grid with a faint edge vignette; the humanity one a touch greener), and each card carries a 44px emblem above its name: an open book with a red ribbon for research, a bevelled stone cross for humanity, both drawn on the 48px icon grid (`icon-book`, `icon-cross`). The faded desk and altar scenes (D98, D99) are kept in `art/source/frames/` and in the prompt sheet.

**D101. A pixel line-art border on the research and humanity faces.** (Bruno: "Add a border to both of these cards. Again, pixel art. Make it like a line art, in pixel art, a card decoration")
Drawn on the 96x128 parchment grid in one ink colour (warm brown for research, grey-green for humanity): a double rule two and five pixels in from the edge, tick marks between the rules every eight pixels, a small diamond ornament in each corner, and a short flourish centred on the top and bottom rails. Card padding moved inside the border.

**D102. Border ink lightened.** (Bruno: "make the details you just did lighter.")
The border, ticks, corner diamonds and flourishes are drawn in an ink about halfway between the previous brown or green and the parchment, so they decorate without competing with the text.

**D103. Hospital retrieval below reputation 7 checked and found correct; icons on every gain; the occupant's meeple at the left of its option; scientist tag inline.** (Bruno: "I saw players getting hospital cadavers without 7 of reputation. Where are the icons in the buttons? Hospital doesn't have it. I want the meeple to appear in the button, when someone has put there... on the left side, with a good size. 'Scientist' has a space before the word. Why?")
Thirty AI games ran with an assertion that throws if anyone resolves Retrieve below reputation 7 outside the Porter for Hire event: no violation. Hospital bodies below 7 come from a Hospital Thief hired at the Docks (by design) or the Porter event; the thief's chronicle line now says "who steals N bodies from the Hospital (no reputation needed)" so it is not mistaken for a Retrieve. `spaceGain` returns icon rows for every space (coin, heart, broken heart, expertise, reputation, police, material cubes), with short text only where there is no icon. Option rows carry a `lead` slot: when a space is occupied, the occupant's meeple is drawn at 30px (45px for a scientist) at the left of the button, and the sub-line keeps the name and bump cost. The scientist tag had been rendered as a block with a left margin, which read as a leading space; it is inline after the label now.

**D104. Every option row carries two dotted meeple slots; rows are always full width.** (Bruno: "leave a space in all buttons with a dotted line of the meeples. If it allows scientist and assistant, leave 2 spaces... Always keep 2 meeple spaces for all buttons. Now that we are following this rule, all buttons in pop ups need to be 100% width.")
Each option in a place or lab popup starts with two dashed slots, scientist then assistant, each showing a faint silhouette; the occupant's meeple fills the slot of its kind in the player's colour. Scientist-only spaces keep both slots so every row lines up. The side-by-side layout for the Slaughterhouse is withdrawn; all option rows span the popup.

**D105. No hover tooltip on places; the place's explanation sits on a scrap of paper inside its popup.** (Bruno: "let's remove the tooltip when mouse over. Give the explanation inside the popup of what the location does. Create a scrap of paper (pixel, of course), where the text of this goes. Bottom left of the image, with some margin. Occupies 25% of the image.")
The board places and the four lab places no longer show a tooltip on mouse-over. Every place and lab popup draws a hand-drawn pixel scrap of parchment (`art/ui/scrap.png`, torn edges, a pin hole, a faint crease, true alpha) over the bottom-left corner of the scene, about a quarter of its width (never narrower than 150px so phones can read it), slightly tilted, with the place's one-line explanation in dark italic type. The threshold squares on the expertise and reputation bars keep their tooltips.

**D106. The scrap is drawn like the research card face; text upright, regular and larger; wide popups fit three cards.** (Bruno: "The paper is too torn apart. Make it similar to the cards we had on research. Don't tilt the text. Don't make it italic. Increase font size." and "layout problem with academy. There should be 3 columns of cards, and it's being tossed below.")
The scrap is redrawn on the research face's palette and grammar: speckled parchment, a double rule, ticks, corner marks and a centred flourish, straight edges. No tilt, body type instead of italic, 12 to 14px with fixed padding (percentage padding was measured against the popup and squeezed the text). The scrap is about 30% of the scene's width, 200px at least. Wide popups grow from 640 to 664px because the vertical scrollbar had been eating the few pixels three 190px cards need, which wrapped the third research or humanity card onto a second row.

**D107. The scrap is half the scene's width.** (Bruno: "Make it wider. 50% of the location image width.")
Redrawn on a 2:1 grid so the border keeps its proportions, set to 50% of the scene's width (240px at least on phones), type 13 to 15px.

**D108. Jar and ice icons.** (Bruno: "Can you create icons for the Jars and Ice?")
Two more hand-drawn icons on the 24px grid at 2x (`art/icons/icon-jar.png`, `icon-ice.png`, true alpha): a Leyden jar with a brass cap, rod and ball, foil bands and a blue charge in the lower half (alive blue, as on the dice), and a pale blue ice slab with a lighter top, a darker side and a white crack. They appear beside the Jars and Ice counters, in the Charge jars gain row, in the Market's Buy a Leyden jar and Buy an ice block rows, on the throw buttons and on the Zoologist's eel chip. Inline icons inside option titles, buttons and chips are 20px.

**D109. Side panel loses the Open lab hint and the body line; the chronicle no longer logs who read the dead man's notes.** (Bruno: "remove Open Lab, R Leg L Leg R Arm L Arm Torso Head. From chronicle, remove the dead man's note.")
The operating table button in the side column keeps its eyebrow only; the row of six part names under it is gone (the table itself shows the parts). The A Dead Man's Notes event still asks each player and applies the trade, but writes nothing to the chronicle.

**D110. The game is called Second Spark, with a pixel-art logo.** (Bruno: "the second spark title is not pixel. Propose a pixelated one." then "make the name only 'Second Spark' without the 'The'.")
The painted logo is retired (kept in `art/source/ui/`). The new logo (`art/ui/title.png`, 320px wide, 32 colours, transparent) is generated with Nano Banana 2 from the character style reference: two lines of tall blackletter in bronze wood with stitched seams and vines, a blue lightning bolt down the S of Spark. The slim header uses a one-line sibling (`art/ui/title-wide.png`, 400px wide) so the name stays readable at 58px tall. Enclosed counters are keyed out by component size so highlights inside the letters survive. The page title, logo alt text and the doc headings drop the article; file and repo names stay second-spark.

**D111. One-line logo everywhere, with clean transparency; the place explanation is centred white text over the scene, the paper scrap is withdrawn.** (Bruno: "make the sentence in one line. Also, the transparency is all wrong." and "the text on the image, with the paper... it sucks. Let's just do a centralized white text on top of the image.")
The logo is regenerated on one line (`art/ui/title.png`, 480px wide) and keyed from a white ground: background components are removed by size, edge pixels get alpha from their lightness, and the downscale runs on premultiplied alpha so no light halo survives. The same file serves the title screen (560px) and the header. The scrap of paper (D105 to D107) is gone; the place's one-line explanation sits centred near the bottom of the scene in white body type with a dark glow.

**D112. The page's stone wall is pixel art.** (Bruno: "can you make those background bricks pixel art too?")
The painted seamless tile (kept in `art/source/ui/bg-wall-painted.jpg`) is reduced to a 128px tile in 14 colours with no dither (`art/ui/bg-wall.png`) and drawn at 512px with pixelated rendering, so each wall pixel is four screen pixels. The uniform reduction keeps the tile seamless. A 256px version was tried and looked too fine next to the scene art.

**D113. The logo is text in the display font.** (Bruno: "the alpha channel is sucking. Can you make it with a font only? The same we're using for titles and cards.")
No logo image. "Second Spark" is set in Amarante, the face of every title and card name, parchment with Spark in the alive blue and its glow, a hard black drop under the letters. Title screen at up to 84px, header at 30px. The generated pixel logos stay in `art/source/ui/` for reference.

**D114. Research and humanity mini cards use the card faces and the book or cross icon.** (Bruno: "the miniature for the research... just use the icon book. Same thing for church. Use our background in academy miniature. That looks awful. Same thing for church.")
The mini cards beside the Academy and Saint-Roch no longer show the small line drawings on white. They sit on the research or humanity parchment face (the same image as the full cards) with the book or cross icon centred above the name.

**D115. The title screen is centred and the scientist cards follow the physical game's layout.** (Bruno: "centralize everything here. Let's work on the description cards on the first page... I want you to do something similar, and same card proportion.")
Tagline, logo, name and rivals fields, buttons and the picker are centred. Each scientist is a landscape card at 2.35:1 like the physical one: portrait on the left third, a parchment text panel (`art/frames/card-scientist-bg.png`, drawn in the research face's style at 1.6:1 so nothing stretches) with the name between short rules at the top, the ability text in the middle and the role in small capitals at the foot. Under the card a dark strip holds the three dotted home slots (scientist, two assistants) as on the physical card. Two columns on desktop, one under 760px. The random pick is the same card with a die for a portrait.

**D116. No home slots under the scientist cards.** (Bruno: "let's remove the meeples from the cards. That never made too much sense.")
The strip of three dotted meeple slots under each scientist card on the title screen is gone; the card ends at its parchment panel.

**D117. Bigger emblem and name on the research and humanity mini cards.** (Bruno: "make the miniature text and book icon bigger in academy. Same for Church.")
The book or cross fills 62% of the mini card's width (was 54%) and the name runs at up to 9px (was 7px), with less padding around them.

**D118. A bar under the map holds the meeple picker and the rivals; rival strips are horizontal.** (Bruno: "let's create a bar below the map. That bar should have the meeples and the rivals. Update rivals layout to be more horizontal.")
The Who do you send box leaves its corner of the board and heads a bar directly under the map, in page type rather than board-relative sizes. The three rivals sit beside it as horizontal strips: portrait on the left with the player's colour as a left rule, then name and role on one line, the Muscle / Skin / Alive counts and the Humanity / Expertise / Reputation icons on the lines below. The side column keeps the table, counters, bars, buttons and the chronicle. Under 900px the bar stacks: picker, then one rival per row.

**D119. The picker reads "Pick meeple then location".** (Bruno: "Kill 'your move' and change title to 'Pick meeple then location'.")
The Your move eyebrow and the Then click a place hint are gone; the box is the title and the two meeple buttons.

**D120. "Today's note" with a note icon; objective chips with more contrast and larger type.** (Bruno: "put a note icon on the left of 'Today: A Widow's Bequest'. Instead of today, say 'Today's note:'. The objectives... can you make them more apparent? More contrast? And the text can be a bit bigger.")
A hand-drawn pixel note icon (`art/icons/icon-note.png`, folded corner, three ink lines) sits before "Today's note: <card>" in the toolbar. Objective chips go from 12.5px dim text on a faint outline to 14px parchment text on a light outline with a faint fill; a claimed one fills brass.

**D121. Your laboratory sits between the stat bars and the chronicle, drawn tall and graphic.** (Bruno: "Move 'your laboratory' between play bars and the chronicle. Make it more graphical and more vertical like.")
The side column reads: buttons, stat bars with Laboratory and Cards, then Your laboratory, then the chronicle. The panel stacks: the operating table figure large and centred (click it to open the lab), the four counters with their icons, and a decomposition grid where each material row holds four stage cells; a cell with material is a solid cube in that material's colour with the count inside, an empty cell is a dashed outline, a cell that rots at the next dawn has a red rim. Bone, preserved and ice are a short line beneath. The old numbers table stays in the Laboratory popup.

**D122. Counters under the bars; Laboratory button under the table; a cards icon with a hand tooltip.** (Bruno: "move the francs, jar, ice and police below the humanity, expertise and reputation bar. Move Laboratory button under the operating table. Create icon for the cards, instead of card buttons. Show what the card content is with a tooltip.")
The stat bars panel ends with the four counters and a fifth tile: a hand-drawn pixel icon of two fanned cards (`art/icons/icon-cards.png`) with the count in a blue badge; it still opens the hand, and hovering it shows a tooltip naming every card in hand with its text (the one tooltip outside the threshold squares, by request). The Laboratory button, with End the night at night, sits under the operating table in the Your laboratory panel.

**D123. Your cards shows the real card faces; no italics anywhere.** (Bruno: "on 'Your cards', use the same card layout here. You can make the card as big as the church or academy. Avoid using italic in this game, it's hard to read.")
The hand, wherever it appears (the Cards popup, the Laboratory popup, Your character), lays out research and humanity cards exactly as the Academy and Saint-Roch popups do, full size in a row, each with its Play button when playable and a short note on where the card is used. Every italic style is gone: flavour lines, costs, owners, the cadaver quote band and inline emphasis use the regular face, kept softer by colour only.

**D124. Pixel-art operating table and body parts replace the SVG figure.** (Bruno: "we need to think of a new art now. We need muscled, skin and alive head, arms, torso, legs. Remember to use pixels. We also need an operating metal table.")
Three full bodies of the companion were generated with Nano Banana 2 in the character style, lying on her back seen from above on a flat green ground: raw muscle, stitched skin with long dark hair, and alive (skin with a blue glow, lightning along the stitches, open glowing eyes). Skin was generated from the muscle image and alive from the skin image so the pose stays identical. `tools/body_parts.py` keys out the green, brings each to a 160x240 canvas and cuts it into head, torso, arms and legs from the muscle silhouette (neck at the narrowest row, arms by the torso's width at the armpits, legs below the crotch); hair and glow join the nearest part. The 18 parts and the riveted iron table (`art/body/`) overlay in the side panel and both lab popups: empty slots show a faint ghost of the muscle part, damage badges sit at each part's centre (`BODY_CENTRES` in data.js), alive parts glow. The SVG figure stays as a fallback when the images are missing.

**D125. Fix: closing tags broken by the italics pass.** (Found while wiring D124.)
D123's removal of `<i>` tags also rewrote the `</i>` closings of the board slot dots and the material cubes, which left those elements open and nested the whole side column inside a board slot. The closings are restored; `<i class=...>` stays as a styling hook with no italics.

**D126. How to play centred on the title screen.** (Bruno: "Centralize how to play button as well.")
The How to play link sits centred above the tagline instead of in the top-left corner.

**D127. Event and encounter text over the picture.** (Bruno: "Event cards... Use the text over image. Don't use the cream background.")
The cream text strip under the scene is gone. The name and the text sit over the lower part of the picture on a dark gradient, in parchment and white. Encounter cards share the layout.

**D128. Minimum font size 12px.** (Bruno: "new rule. Minimum font size: 12.")
Every font size below 12px (164 declarations, from 4px strip digits on the board's mini cards to 11.5px labels) is raised to 12px; clamps keep their fluid middle but floor and cap at 12px or more. To hold 12px type the mini cards on the board grow from about 48px to 56 to 76px wide and their number strip cells to 16px tall. The build now fails if any font size below 12px reaches the page, like it does for an em dash.

**D129. The Laboratory popup loses the cards-in-hand section and the body line.** (Bruno: "remove 'cards in hand'. remove R Leg L Leg R Arm L Arm Torso Head.")
Cards are reached from the Cards tile; the table shows the parts. The Your character popup keeps its cards section.

**D130. Minimum font size is 11px.** (Bruno: "miniature cards can be done in 11px font. The minimum fonts can be 11 again.")
The floor of D128 moves from 12px to 11px: sizes that were 11 or 11.5px before the rule return, anything smaller stays at 11px, and the build guard checks for 11px. The mini cards on the board settle at 52 to 70px wide with 15px strip cells.

**D131. Counter icons beside the number; wider label column on the stat bars.** (Bruno: "Put the icons next to the number, text below. The reputation text is under the bars... can you put the bars a bit more to the right?")
In every counter tile the icon sits left of the number and the label alone runs beneath. The stat bars' label column grows from 92 to 118px (72 to 100px in the compact variant) so Reputation and its icon no longer run under the bar.

**D132. Operating table and decomposition grid side by side.** (Bruno: "Put the operating table and the decomposition table right next to each other. You can reduce the size of the operating table. Put the Laboratory button below the operating table.")
The Your laboratory panel is two columns: the table at 112px wide with the Laboratory button (and End the night at night) stacked under it on the left, the decomposition grid on the right with 30px cells.

**D133. Mini research and humanity cards show only their emblem; a taken card leaves a dotted slot.** (Bruno: "remove name of the card in miniature version, leave icon only. When I buy a card in the day, the column doesn't refill until next day. When I buy, leave it empty, with a dotted line or something.")
The board's mini research and humanity cards are the parchment face with the book or cross, no name (the name is in the popup and on hover). The Academy, Saint-Roch and Docks rows always show three slots: a card taken during the day leaves a dashed outline until the dawn refill. The Decomposition label sits above its grid instead of in the header row.

**D134. Scoundrel name left-aligned under the kind label.** (Bruno: "the name positioning is bugged. Fix this. All aligned to the left.")
The name on a scoundrel card had inherited a centred alignment and sat on the Scoundrel label. It is left-aligned now and starts 22px down, clear of the label.

**D135. Mini card text at 10px.** (Bruno: "miniature card text, leave at 10px.")
The board's mini cards (deck plate and count, number strips, names) use 10px, the one exception to the 11px floor; those declarations carry a `/*mini*/` mark the build guard honours. The mini cards shrink back to 48 to 64px wide with 14px strip cells.

**D136. Your people: the meeples themselves, in the sidebar under Your laboratory.** (Bruno: "Instead of having those buttons, let's move this whole part below the 'your laboratory' in the sidebar. Instead of having a button for assistant and scientist, I want you to visually show all the meeples. When they are used, create a status or have a dotted line where they were supposed to be.")
The Pick meeple box leaves the bar under the map (which now holds only the rivals). A Your people panel sits under Your laboratory: one figure per meeple you own (scientists first, then assistants, growing with reputation). A meeple at home is solid in your colour inside a slot and is the button that picks what to send; the chosen one glows blue. A placed meeple leaves a dotted slot with a faint silhouette and the name of the place it went to. The heading reads Pick a meeple, then a location on your turn, otherwise who is choosing or the phase.

**D137. The Cemetery is the Graveyard; its deck plate says Grave.** (Bruno: "Cemetery text still doesn't fit the card art. Instead of cemetery, call it graveyard. The card, only say grave.")
Every player-facing Cemetery becomes Graveyard (place name, event and card texts, popup titles, the SPEC). The mini deck on the board carries the short plate Grave so it fits the brass. Ids, file names and the Tabletop reference keep cemetery.

**D138. Night buttons side by side under the laboratory panel; the night prompt lives only in the sidebar.** (Bruno: "when the night is over, lab phase, only display on side bar. Button should be next to laboratory, not under it.")
The Laboratory button sits on its own row under the table and the decomposition grid; at night End the night joins it beside, not below. The night prompt that used to sit under the map is gone with the old picker box; the Your people panel says Night N.

**D139. Cadaver resolution cards: room between kind and name, icons for the tags, real buttons, no stage lesson.** (Bruno: "The card title and subtitle are too close. Instead of +2 exp, use icon. The check boxes below are terrible: make them bigger, good contrast, breathing space. Remove the text 'Stage I is freshest...'. In the button +2 expertise, just put icon and number.")
The name on a cadaver card starts 24px down, clear of the place label. The tags on the picture read +2 with the expertise icon, the humanity cost with the broken heart, the price with the coin. The choices under each card (Materials, +N with the expertise icon, Leave, research cards) are proper buttons: dark panel, parchment type at 14px, 8px apart, the chosen one filled blue. The sentence about stages is gone; only the flat cost and All Saints notes remain when they apply.

**D140. A closed place is crossed out in red and shows nothing else.** (Bruno: "when a location isn't available, just cross with red and put tooltip 'Closed'. No need to reduce opacity. If the place is closed, don't show any cards and actions. If it's closed, you can't see anything and that's it.")
A closed place keeps full colour; a red X covers its chip and hovering it says Closed. Its meeple slots, its card row and its popup are not shown while it is closed.

**D141. Option rows without a meeple lead have no left margin; card options carry the cards icon and say Use card "Name"; costs as icons.** (Bruno: "I didn't understand why the buttons have such a left side margin. Decrease the margin, but whenever you have a card, add the card icon. The card text should be 'Use card "Card name"'. The do it, just put what is the cost, in this case humanity, police.")
The two dotted meeple slots appear only on placement options; a plain question (Dark Alley, Give Blood, Donate) starts its rows at the edge. Every option or button that plays a card reads Use card "Name" after the cards icon. Do it at the Dark Alley shows its cost as 3 broken hearts and 1 police star; Use card "Unethical Experiment" shows the jar, the expertise, the heart and no materials; Give Blood shows 3 blood cubes and Use card "Transfusion" its three gains; the scoundrel buttons show +N with the expertise or heart icon.

**D142. The toolbar sits flush on the map and close under the objectives row.** (Bruno: "leave no margin between the map and the black bar that has Day 1 · City phase. Also reduce the margin between the bar and the top bar with bonus objectives.")
The Day and Today's note bar touches the map (the map loses its top rule) and the objectives row keeps only the column's 16px gap above the bar.

**D143. Your laboratory is one place on the map, under the Hospital, with its four spaces as buttons in its popup.** (Bruno: "Make 'Your laboratory' a location on the map. Make the options as buttons on the pop-up. Leave the laboratory below the hospital.")
The strip of four small lab places at the foot of the map is gone. One place chip, Your laboratory, sits under the Hospital (`LAB_POS` in data.js) with four slot dots that fill with your meeple as each space is used. Its popup shows a generated attic laboratory scene (`art/locations/location-lab.png`) and one option row per space (Practice, Give Blood, Repair, Charge Jars) with the dotted meeple slots, the scientist tag, the gain as icons and "used today" once spent.

**D144. Bigger emblems on the mini research and humanity cards.** (Bruno: "increase card icon size for church and cross. Also for academy.")
The book and the cross fill 92% of the mini card.

**D145. When night falls, a prompt offers the laboratory or the end of the night.** (Bruno: "when all players run out of meeples, propose a pop-up asking the player if he wants to finish the night or go to the laboratory.")
As the lab phase begins, a Night N popup asks: Go to the laboratory (opens the Laboratory popup) or End the night (with the usual warning if you could still build or throw).

**D146. Motion: meeples land, night falls, dice tumble, cards are dealt, counters tick.** (Bruno: "I want to add a few animations, like meeples appearing, when the night comes... could we plan some animations to make this a bit more interactive?" He chose all four moments, a slow cinematic pace for rivals and reduced-motion support without an in-game toggle.)
Every render rebuilds the page from strings, so ui.js keeps a snapshot of the last render (`seen`) and marks only what is new (`diffForRender`, `isNew`): a meeple that just landed on a slot drops in with a small bounce; a meeple that just left shows its slot in Your people fading to the dotted state and the ones that return at dawn rise back in one after another; cards new to a row slide in staggered and a deck lifts when its count changes; a changed counter or stat number scales up in blue (or crimson when it fell) with a floating delta, and the newly lit bar cells flash; a part that comes alive pulses blue three times and a damage badge shakes. A persistent veil outside the page (`#veil`) fades to a blue night over 1.2s while the lab phase lasts, with a warm lamp glow on the place chips and the toolbar, and the Night N prompt arrives 1.1s later. Dice tumble one after another and show their face only at the end; after a re-roll only the dice that changed roll again. The rival whose turn it is glows in their colour, with 1.2s before each rival move and 0.35s after it. A `PACE` multiplier scales the delays (the UI test sets it near zero, fast mode zeroes it). The existing reduced-motion rule disables all of it.

**D147. A rival's move shows in a toast at the bottom middle of the map.** (Bruno: "Each time the opponent is doing their moves, show their moves in a small toast bar, in the bottom middle of the map. You can take more time to display the animations. The toast should have this format: Player name (in bold and its colour) did x, in location y. Make it visible enough.")
After each rival placement a toast rises over the lower edge of the map: the rival's name in bold in their colour, then "sends their scientist (or an assistant) to <space>, in <place>", with the chronicle's detail of what they got on a second line. Dark panel, brass border, the player's colour as a left rule, 16px type. It stays about 2.3s; each rival move now takes 1.2s before and 2.4s after, scaled by `PACE`.

**D148. The move toast is one short line above the place.** (Bruno: "leave it for more time. Make it smaller and less text. All I want is 'Player X does Y, in Z'. Be specific about the action, e.g. 'Dr Ambrose Pell sends an assistant to hire a Cutthroat, in the Docks'. Make it closer to the location (above it). Text can be a bit smaller, but the whole text the same size.")
One line at 14px, name in bold in the rival's colour, no detail line. The action is taken from the chronicle line of that move and put in the infinitive (hires a Cutthroat becomes hire a Cutthroat), falling back to the space name. The toast sits just above the place chip with a small pointer, stays about 4.2s, and each rival move now waits 3.6s after placing.

**D149. Rival toasts stay until you place; cadaver moves say how many.** (Bruno: "What if the toast doesn't go away in the player's turn, just goes away after the player goes? It always shows the moves before yours.")
Each rival keeps one toast, above the place they last went to, through your turn; they clear once you place a meeple and whenever the day ends. Two toasts over the same place stack upward. Graveyard, Morgue, Public Square and Hospital moves read dig up, buy or retrieve N cadavers instead of a single body's name. Rival moves wait 2.4s after placing again.

**D150. A card taken from the Academy or Saint-Roch is not replaced until dawn.** (Bruno: "If someone buys a card during the day, that card does not get replaced. We had 3 cards, now we will have 2 until the next day. Next day, 3 again.")
D133 only drew the dotted slot; the engine still dealt a replacement at once. Taking a research or humanity card now leaves the row one shorter until the dawn deal of three. With the research row empty, Take a research card cannot be chosen; with the humanity row empty, only a scientist may still atone (for the +1 humanity).

**D151. Move toasts stay inside the map.** (Bruno: "careful so that the tooltip does not leave the map area.")
A toast is clamped to the map's width with 6px to spare, its pointer slides to stay over the place, and when there is no room above the chip it hangs below it with the pointer on top.

**D152. Bigger type in the Laboratory's decomposition and points tables; full-width switch buttons.** (Bruno: "Make font bigger in decomposition and points per quality. The throw the switch is weird. Put label as 'ICON Use 1 jars'. Each button should occupy the whole line.")
The decomposition track and the points-per-part table go from 12 to 14px (headers 13px, roomier cells). The switch offers one full-width button per line reading the jar icon and Use 1 jar, Use 2 jars, Use 3 jars.

**D153. Fix: cards in a popup deal in once.** (Bruno: "There's an animation bug on my cards. Looks like the animation blinks after it ends and replays.")
Live popups (Your cards, Laboratory, Your character) are rebuilt on every refresh, which restarted the card deal-in. A popup now carries a firstdraw class only on its first draw (not `.fresh`, which is the freshness dots and broke the popup layout for a moment), and only then do its cards animate.

**D154. A Your turn toast.** (Bruno: "when it's the player's turn, display a toast in the middle bottom, and slowly fade it out in 3 seconds. Motion bottom to up, quick fade in.")
When your day turn begins, "Your turn, pick a meeple, then a location." rises from below at the bottom middle of the map in a quarter second, holds briefly, then fades out over about 3 seconds. Blue rim and glow, your colour as the left rule.

**D155. The Your turn toast uses one type size.** (Bruno: "keep font size of the toast to one size.")
"Your turn" is bold blue in the same 16px body type as the rest of the line.

**D156. A Godot 4 diorama in `godot/`.** (Bruno: "I wanna try Godot, just for the sake of it!" He chose a folder in this repo, a 3D table diorama as the first slice, and installing Godot with Homebrew.)
Godot 4.7.2 is installed with Homebrew. `godot/` holds a self-contained project built in code (`scripts/main.gd`): the painted map on a wooden table, each place a disc with its name and one ring per space (gold for scientist only), 3D meeples (top hat scientist, flat-cap assistants) in each player's colour along the table edges. You click a meeple, then a glowing place; it hops along an arc and lands with a squash. Three rivals then place at random legal spaces with a toast each. Once everyone is out, night falls (sun dims to blue, lanterns light at each place) and at dawn everyone hops home. Right-drag orbits, the wheel zooms. No game rules beyond placement and scientist-only spaces; the browser game stays the real game. The web build and tests are unaffected.

**D157. The Godot table reads the real data, places by space, and deals the card rows.** (Bruno: "this is amazing!! Continue.")
`tools/export_godot_data.js` writes `godot/data/game.json` from `src/data.js` (places, spaces, card decks, rival names and colours), so the table no longer keeps its own copy of the numbers. Each ring is now its own target: you choose the exact action space, and hovering a space or a card shows what it does in a panel at the top left. The Research row sits beside the Academy, the Humanity row beside Saint-Roch and three Scoundrels beside the Docks, each with its face-down deck; cards flip in from the deck. Research, advanced research and atoning take the first card of the row and leave an empty spot until dawn, as in the web game (D150); a hired scoundrel is replaced at once. Your cards land in a fan along the front edge, a rival's fly to them. Rival toasts name the action and the card ("sends an assistant to research, taking Evening Study, at the Academy."). The spaces still have no other effect.

**D158. Godot becomes the real game, in the pixel look.** (Bruno: "godot becomes the real game. let's keep as pixel look.")
The rules are ported from `src/engine.js` to `godot/scripts/rules/game.gd` line by line, without drawing code, so the rules have one home in Godot. The AI, events, encounters, cards, the laboratory, the switch and scoring are all included. A headless simulation of 20 AI games matches the web build: no stuck games, endings on Days 9 to 12, about 4 parts alive on average. A 200-game run produced no errors. `tools/export_godot_data.js` now exports every data table and copies the art (minus `art/source`), so `src/data.js` stays the single place to change numbers. The Godot screen: the 3D table on the left, drawn at half resolution and scaled up without smoothing for the pixel look; the side column on the right (day, Captain's track, today's note, objectives, your stats and resources, your laboratory at a glance, your people, rivals, chronicle); popups for every choice the web game asks (places with their scene, cards to pick, the Hospital, the Market steppers, cadavers, scoundrels, the switch with its dice, dawn, events, encounters, your cards, your character, rival laboratories, the end). Amarante and EB Garamond are bundled (Open Font License). An autoplay mode plays a full game as the human through the real buttons, like `tests/ui.js`. The web page stays as the reference until the Godot version is approved.

**D159. Legible text, a finer board, and your own board below the map.** (Bruno: "The pixelled text is horrible to read. Can we make the text more legible? everything is too pixelated. let's increase the resolution a bit. I want to build an actual board for the Operating room, decomposition table, point per part, GOLD, Leiden jars, ice, cards and police badges... all of those should be in one extra board, smaller, below the main boardgame.")
Text is never pixelated any more: the place names that were 3D labels inside the low-resolution board are now 2D labels kept over their place, and the fonts use smooth, lightly hinted rendering with linear filtering (pixel art keeps nearest filtering). The board renders at 1/1.5 of the screen instead of 1/2 (`RENDER` in `main.gd`). A player board sits on the table below the map with the Operating room, the Decomposition table, Points per part and Supplies (gold, Leiden jars, ice, police badges, cards), all built from 3D pieces that follow the state; your hand moved there from the front edge. The camera is a little steeper and further back to show both boards. The side column drops the resource tiles, the operating table and the decay grid, which now live on that board, and the Cards tooltip becomes the hover panel of the cards on your board.

**D160. The board stays fine on a big window, and place names sit on nameplates.** (Bruno: "The text of the board is still bad...", and a crash when clicking the Docks.)
On a window larger than 1600 x 900 the layout stretches, and the board's low-resolution picture was stretched with it, so the map got coarser the bigger the window. The board now keeps 1.5 screen pixels per board pixel whatever the window size (`_fit_board` undoes the window stretch). Place names on the map sit on a small dark nameplate with a brass rim, so they read over the busy painted map. Fixed: clicking the Docks crashed because only the first scoundrel option said whether it is the main button. Screenshots can be taken at another window size with `-- --shot --size=2560x1400`.

**D161. Your board follows the original player board's layout, wide, in front of the map.** (Bruno: "Hmmm not sure I liked that board. Where do you think its better? this is the one from the original game... an extra board." Then: board in front of the map, lab spaces move onto it, "keep the stats dials on the left or next to the board", "Make the board wider, since screen real state takes better advantage of horizontal spaces", gold, police and cards as loose piles beside it, points per part not on it.)
The D159 board is replaced. One wide board runs along the front of the table, left to right: Laboratory (the four lab spaces as small cards with their rings; "Your laboratory" is gone from the map and you place meeples here), Decomposition (four stage columns with a cube per material, red bars where blood rots after II and everything rots after IV), Stores (ice, preserved flesh n/9, bone n/12), Jars (four slots, a blue core when charged), Operating table (the body figure, alive glow, damage bolts). Three dials stand on the table to its left: Humanity, Reputation and Expertise, a ring of ticks lit up to your value, thresholds marked, the value in the middle; hovering one lists its thresholds, which replaces the side column's bars and their tooltips. Gold, police badges and your cards lie loose on the table to its right. Points per part stays in the laboratory popup. Only the layout idea comes from the physical board; the art is our own.

**D162. A painted board and table, supplies on the board, no side column, notes that fade, meeples that read apart.** (Bruno: "Can you generate a texture for that board? Also, extend the board for the gold, police, etc... I want you to create placeholders. Also... any ideas on eliminating the side board? I also want the tooltips to dissapear within 4 seconds, fadeout. Make the meeples more identifiable from one to another. I also want a dark wood texture for the table the boardgame is on." Then: "rivals: let's make the as a sidebar, really small one, on the right. Just leave icons for expertrise, humanty and reputation, on top of their portrait. the chronicle can you an expandable, but standard 2 linebar on the bottom.")
- Your board has a face of its own, drawn by `tools/make_board_textures.py` (pixel look, 40 px per unit scaled x2): a stone wall, a wooden shelf under the lab cards, four purple decomposition columns, stone trays for the stores, small wooden jar boxes, a dark red operating slab, and a Supplies zone at the right end with a gold tray, two police badge spots and four dashed card placeholders. Gold, police and cards now sit on the board instead of loose on the table. The table top is a tiling dark wood from the same script.
- The side column is gone. A thin top bar holds the day, today's note, the Captain's track, the objectives and the buttons (Laboratory, End the night, Your character, Help, New game). A narrow strip on the right shows each rival as a portrait with humanity, expertise and reputation on top (click for their laboratory), and your people below them. The chronicle is a two-line bar along the bottom; "Chronicle" opens it upwards, "Less" closes it. The board uses the freed width.
- The hover panel and every note over the table (rival moves, messages, your turn) fade out within 4 seconds.
- Each player's meeples stand on a base of their own shape and a darker shade of their colour (you a disc, the rivals a square, a hexagon and a triangle), and glow faintly in their colour.

**D163. Portrait cards in the strip, meeples that pulse on your turn, rival laboratories on the board texture, a full-width top bar.** (Bruno: "Make the name in white on top of a background with a black (50% opacity) gradient to 0% opacity of image height, on the top of the imagem. bring the icons down, to the bottom of the portrait. remove the meeples in "your move"... we already have that on the board. When it's the players move, make a glowing animation looped on the meeples until the player clicks on them. Rival's laboatory... Let's make it similar to the player board. Make it with a texture, etc... remove: Body parts boxes, Points per part, muscle 0 - organs 0 - alive 0 - damaged text, repeated info on top." Then: "remove the "your laboratory" and "your character" from the top. make the top occupy the whole screen. include the player's picture next to the rivals. Just say "Player" or the player's name.")
- The right strip is a column of portrait cards: you first (your name; click for your character), then each rival (surname; click for their laboratory). The name is white on a black fade (50% to 0%) at the top of the picture; humanity, expertise and reputation sit on a fade at the bottom. The meeple buttons are gone: you pick a meeple on the table.
- On your turn your meeples at home glow in a slow loop until you click one; the chosen one then glows steadily.
- A rival's laboratory is their board in 2D on the same painted face as yours (lab cards with a meeple where used today, decomposition chips with red rims where they rot next, stores, jars, operating table, gold, police, card backs), under their portrait, character text and stat bars. The body part boxes, the points table, the parts legend and the repeated resources line are gone.
- The top bar runs the full width; it no longer has Laboratory or Your character (the operating table on your board opens the laboratory, your portrait opens your character). End the night shows there at night.

**D164. Rivals centred in the strip; no lab actions on a rival's board.** (Bruno: "vertically centralize the rivals." and "remove the laboratory actions from rivals. No need for them to be there...")
The portrait cards sit in the vertical middle of the right strip. A rival's laboratory popup shows their board from Decomposition onwards: the four lab action cards are cut off, so the rest is drawn larger.

**D165. One lamp over the table.** (Bruno: "can you add a light? Like... centralized spot light with a good fade on sides (penumbra)? Make it more eerie...")
A warm spotlight hangs over the middle of the table (map and your board), with a soft wide edge that fades into darkness; the room light (sun and ambient) is turned far down and cooled, so the corners of the table sink into the dark. At night the lamp dims and turns cold blue while the place lanterns light up. Also: screenshot mode answers any popup before your first move, as autoplay does, so it no longer stalls on a Day 1 encounter.

**D166. The table becomes an endless stone floor.** (Bruno: "caxn you switch the tabl ebelow to infine stones?")
The wooden table box is gone. The map and your board now lie on a 400 x 400 plane of tiling flagstones (`art/ui/floor-stone.png`, from `tools/make_board_textures.py`: staggered courses of warm grey stones, dark mortar, worn blotches, a few hairline cracks; one tile covers 4 units). No edge is ever in view: the lamp's pool fades the stones into darkness, and a depth fog in the background colour (from 24 to 42 units) melts the far floor away when you zoom out. `table-wood.png` is removed.

**D167. The floor is a pixel cobbled street from Nano Banana.** (Bruno: "use nano banana and create a pixel one, with texture... it should be more rough, like the streets of paris duing 1800s.")
Three candidates came from Nano Banana (`gemini-3.1-flash-image`) for a seamless top-down pixel-art texture of rough early 1800s Paris paving: uneven rounded granite pavés, grimy dark gaps, chipped and sunk stones, dark muted palette. The roughest one was picked and checked tiled 2 x 2 (no seams). The original is `art/source/ui/floor-cobbles.png` (1024px); the game copy `art/ui/floor-cobbles.png` is 256px at 32 colours, one tile per 4.5 units. The procedural `floor-stone.png` and its code in `tools/make_board_textures.py` are removed.
