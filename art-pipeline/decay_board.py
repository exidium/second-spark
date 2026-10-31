"""The decomposition board's painted face (D193, D197).

python3 art-pipeline/decay_board.py

Crops Bruno's concept (art/source/ui/decay_board_concept.png) to the iron frame and paints out the four brass plates
over the stage columns with the wood around them (the numerals I to IV are drawn white in Godot instead), then
writes godot/assets/cabin/decay_board.webp (1190 x 1010).
"""
from PIL import Image

SRC = "art/source/ui/decay_board_concept.png"
DST = "godot/assets/cabin/decay_board.webp"
CROP = (52, 152, 1242, 1162)
PLATES = [(96, 234), (355, 494), (624, 760), (880, 1014)]   # x ranges on the cropped face
BAND = (38, 81)                                             # their y range
GAP = (244, 350)                                            # plain wood between the first two plates

im = Image.open(SRC).convert("RGB").crop(CROP)
wood = im.crop((GAP[0], BAND[0], GAP[1], BAND[1]))
gw = GAP[1] - GAP[0]
for x0, x1 in PLATES:
    x = x0
    flip = False
    while x < x1:
        w = min(gw, x1 - x)
        piece = wood.crop((0, 0, w, wood.height))
        im.paste(piece.transpose(Image.FLIP_LEFT_RIGHT) if flip else piece, (x, BAND[0]))
        x += w
        flip = not flip
im.save(DST, quality=90)
print("wrote", DST, im.size)
