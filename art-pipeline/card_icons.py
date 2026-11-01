"""The card icons (D202): finished hand-drawn icons in ink and watercolour, one per gain and die.

zsh -c "source ~/.zshrc >/dev/null 2>&1; python3 art-pipeline/card_icons.py [names]"

Writes art/source/ui/cards/icon-<name>.png on a white page; art-pipeline/cards.py cuts them out. Existing files are
overwritten, so name the ones to redo.
"""
import os, sys
sys.path.insert(0, 'tools')
from gen_gemini import call
S = 'art/source/ui/cards'
key = os.environ['GEMINI_API_KEY']
# Finished, carefully drawn icons for the cards (Bruno: "Artefacts should be well done"; rough pencil stays on the map).
B = ("A single small icon, centred on a plain pure white background with wide empty margins: {what}. A finished, "
 "carefully drawn hand illustration in the style of an early nineteenth century natural history plate: confident clean "
 "dark sepia ink outline, fine engraved hatching for the shading, and soft watercolour washes of colour, {col}. "
 "Bold, simple silhouette so it reads well when small. No text, no letters, no frame, no background, no shadow on the "
 "ground.")
EYE = 'a six-sided die seen at a slight angle, its front face showing a single open eye instead of pips'
jobs = {
 'heart': B.format(what='the classic symbol heart shape, a plain love heart like on playing cards, not an anatomical organ',
   col='a deep warm red'),
 'heartbroken': B.format(what='the classic symbol heart shape, a plain love heart like on playing cards, broken in two by '
   'a jagged zigzag crack down the middle, the halves slightly apart', col='a dull dark red going grey'),
 'brain': B.format(what='a human brain seen from the side', col='a pale pink and soft rose'),
 'rep': B.format(what='a round medal hanging from a short ribbon, a laurel wreath on the medal', col='a gold medal on a deep '
   'blue and red ribbon'),
 'coin': B.format(what='one plain old coin seen face on with a simple profile head on it, no lettering on the coin',
   col='a warm gold'),
 'jar': B.format(what='a small Leyden jar: a glass jar with a foil band, a cork and a brass rod with a ball on top',
   col='pale glass, silver foil, brass and cork brown'),
 'die-gray': B.format(what=EYE, col='ivory bone white and cool grey'),
 'die-blue': B.format(what=EYE, col='a strong clear blue all over the die'),
}
for name in (sys.argv[1:] or list(jobs)):
    try:
        open(f'{S}/icon-{name}.png', 'wb').write(call(jobs[name], None, key, style_prefix=False, aspect='1:1'))
        print('ok', name)
    except Exception as e:
        print('fail', name, str(e)[:200].replace(key, '***'))
