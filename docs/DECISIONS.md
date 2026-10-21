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
