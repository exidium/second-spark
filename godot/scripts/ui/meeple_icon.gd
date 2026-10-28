class_name MeepleIcon
extends Control
## The pixel meeple silhouettes from src/ui.js (MEEPLE_GRID), drawn as squares so they stay crisp.

const GRID := {
	"scientist": ["....######....", "....######....", "....######....", "..##########..", ".....####.....", "....######....", "....######....", ".....####.....",
		"...########...", "..##########..", "..##########..", "..##########..", "..##########..", "..##########..", "..####..####..", "..####..####..", "..####..####.."],
	"assistant": ["..............", "..............", "....######....", "...#########..", ".....####.....", "....######....", "....######....", ".....####.....",
		"...########...", "..##########..", ".############.", ".############.", ".############.", ".############.", ".############.", ".############.", "..##########.."],
}

var kind := "assistant":
	set(v):
		kind = v
		queue_redraw()
var color := Color.WHITE:
	set(v):
		color = v
		queue_redraw()


func _draw() -> void:
	var rows: Array = GRID[kind]
	var cell: float = minf(size.x / 14.0, size.y / rows.size())
	var off := Vector2((size.x - cell * 14) / 2.0, (size.y - cell * rows.size()) / 2.0)
	for y in rows.size():
		var r: String = rows[y]
		for x in r.length():
			if r[x] == "#":
				draw_rect(Rect2(off + Vector2(x, y) * cell, Vector2(cell, cell)), color)
