class_name DecayTray
extends Node3D
## Your decomposition tray (D189): a white enamel dissecting tray with a dark blue rim, divided by tin walls into a
## 4 x 4 grid. Columns are the stages I to IV, freshest on the left; rows are muscle, organ, blood and animal, from the
## back. Each cell holds one small piece per unit of material (up to 15, so the count can be read by eye), darker and
## more shrunken the older the stage. Blood rots after II: a lead bar closes the blood row there and its last two cells
## are stained. Everything rots after IV: a deep gutter runs along the right end. Built in code, metres.
## `show_mats(mats)` takes the rules' `p.mats` (material -> [I, II, III, IV]).

const MATS := ["muscle", "organ", "blood", "animal"]
const CELL := Vector2(0.06, 0.045)     # one cell, x by z
const WALL := 0.0025
const RIM := 0.014                     # the blue rim round the tray
const DEPTH := 0.016
const GUTTER := 0.018
const SIZE := Vector2(CELL.x * 4 + WALL * 5 + RIM * 2 + GUTTER, CELL.y * 4 + WALL * 5 + RIM * 2)
## Each material's colour when fresh, and when it has rotted to stage IV (SPEC 6.3: muscle brown, organ purple,
## blood red, animal orange).
const FRESH := {"muscle": Color("#8a3b2a"), "organ": Color("#6b3a6e"), "blood": Color("#8e0f12"), "animal": Color("#b8682c")}
const ROTTEN := {"muscle": Color("#3c3420"), "organ": Color("#2f2633"), "blood": Color("#2a0d0c"), "animal": Color("#4a3a22")}

var cells := {}                        # "material:stage" -> Node3D holding its pieces
var shown := {}                        # "material:stage" -> count
var meshes := {}                       # material -> Mesh
var font: Font


func _init() -> void:
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	_tray()
	_piece_meshes()
	for r in 4:
		for st in 4:
			var n := Node3D.new()
			n.position = _cell_centre(r, st)
			add_child(n)
			cells["%s:%d" % [MATS[r], st]] = n
			shown["%s:%d" % [MATS[r], st]] = 0


func _mat(c: Color, rough := 0.5, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	return m

func _box(size: Vector3, mat: Material, pos: Vector3) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = b
	mi.material_override = mat
	mi.position = pos
	add_child(mi)
	return mi

## Left edge of the grid, x; back edge, z.
func _x0() -> float:
	return -SIZE.x / 2 + RIM

func _z0() -> float:
	return -SIZE.y / 2 + RIM

func _cell_centre(row: int, stage: int) -> Vector3:
	return Vector3(_x0() + WALL + stage * (CELL.x + WALL) + CELL.x / 2, 0.0035, _z0() + WALL + row * (CELL.y + WALL) + CELL.y / 2)

func _label(text: String, pos: Vector3, size: int, col: Color) -> void:
	var l := Label3D.new()
	l.text = text
	l.font = font
	l.font_size = size
	l.pixel_size = 0.00018
	l.modulate = col
	l.shaded = true
	l.rotation_degrees.x = -90
	l.position = pos
	add_child(l)

func _tray() -> void:
	var enamel := _mat(Color("#e6e1d4"), 0.35)
	var blue := _mat(Color("#1d2b4a"), 0.3)
	var tin := _mat(Color("#9a9c98"), 0.4, 0.7)
	var lead := _mat(Color("#3d3f42"), 0.6, 0.5)
	var stain := _mat(Color("#4a1612"), 0.8)
	# Floor and the blue rim walls.
	_box(Vector3(SIZE.x, 0.003, SIZE.y), enamel, Vector3(0, 0.0015, 0))
	for s: float in [-1.0, 1.0]:
		_box(Vector3(SIZE.x, DEPTH, RIM * 0.5), blue, Vector3(0, DEPTH / 2, s * (SIZE.y / 2 - RIM * 0.25)))
		_box(Vector3(RIM * 0.5, DEPTH, SIZE.y), blue, Vector3(s * (SIZE.x / 2 - RIM * 0.25), DEPTH / 2, 0))
		# the rim's flat top, where the labels are
		_box(Vector3(SIZE.x, 0.002, RIM), blue, Vector3(0, DEPTH, s * (SIZE.y / 2 - RIM / 2)))
		_box(Vector3(RIM, 0.002, SIZE.y), blue, Vector3(s * (SIZE.x / 2 - RIM / 2), DEPTH, 0))
	# The grid: tin walls between the cells.
	var grid_w := CELL.x * 4 + WALL * 5
	var grid_d := CELL.y * 4 + WALL * 5
	var h := DEPTH * 0.7
	for i in 5:
		var x := _x0() + WALL / 2 + i * (CELL.x + WALL)
		_box(Vector3(WALL, h, grid_d), tin, Vector3(x, h / 2, _z0() + grid_d / 2))
		var z := _z0() + WALL / 2 + i * (CELL.y + WALL)
		_box(Vector3(grid_w, h, WALL), tin, Vector3(_x0() + grid_w / 2, h / 2, z))
	# Blood rots after II: a lead bar across the blood row between II and III, its III and IV cells stained.
	var blood := MATS.find("blood")
	var bz := _cell_centre(blood, 0).z
	_box(Vector3(WALL * 2.4, DEPTH * 0.95, CELL.y + WALL), lead, Vector3(_x0() + WALL / 2 + 2 * (CELL.x + WALL), DEPTH * 0.95 / 2, bz))
	for st in [2, 3]:
		var c := _cell_centre(blood, st)
		var s2 := _box(Vector3(CELL.x * 0.86, 0.0006, CELL.y * 0.8), stain, Vector3(c.x, 0.0033, c.z))
		s2.rotation_degrees.y = 4.0 if st == 2 else -6.0
	# Everything rots after IV: a dark gutter along the right end, with a drain hole.
	var gx := _x0() + grid_w + GUTTER / 2
	var gutter := _box(Vector3(GUTTER, 0.002, grid_d), _mat(Color("#2a1a14"), 0.7), Vector3(gx, 0.0035, _z0() + grid_d / 2))
	gutter.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var drain := CylinderMesh.new()
	drain.top_radius = GUTTER * 0.3
	drain.bottom_radius = GUTTER * 0.3
	drain.height = 0.001
	var dm := MeshInstance3D.new()
	dm.mesh = drain
	dm.material_override = _mat(Color("#0a0806"), 0.9)
	dm.position = Vector3(gx, 0.0048, _z0() + grid_d - 0.012)
	add_child(dm)
	# Stage numbers along the front rim, material names along the left rim, painted white on the blue enamel.
	var paint := Color("#e6e1d4")
	for st in 4:
		_label(["I", "II", "III", "IV"][st], Vector3(_cell_centre(0, st).x, DEPTH + 0.0012, SIZE.y / 2 - RIM / 2), 56, paint)
	_label("ROT", Vector3(gx, DEPTH + 0.0012, SIZE.y / 2 - RIM / 2), 36, Color("#c9a08a"))
	for r in 4:
		var l := Label3D.new()
		l.text = MATS[r].to_upper()
		l.font = font
		l.font_size = 30
		l.pixel_size = 0.00018
		l.modulate = paint
		l.shaded = true
		l.rotation_degrees = Vector3(-90, 90, 0)
		l.position = Vector3(-SIZE.x / 2 + RIM / 2, DEPTH + 0.0012, _cell_centre(r, 0).z)
		add_child(l)


# ---------------------------------------------------------------- the pieces

func _piece_meshes() -> void:
	# Small low-poly lumps, flat-shaded by their few faces.
	var lump := SphereMesh.new()
	lump.radius = 0.0042
	lump.height = 0.0058
	lump.radial_segments = 6
	lump.rings = 3
	meshes["muscle"] = lump
	var organ := SphereMesh.new()
	organ.radius = 0.0045
	organ.height = 0.0072
	organ.radial_segments = 7
	organ.rings = 4
	meshes["organ"] = organ
	var clot := SphereMesh.new()
	clot.radius = 0.004
	clot.height = 0.0028
	clot.radial_segments = 8
	clot.rings = 2
	meshes["blood"] = clot
	var chunk := BoxMesh.new()
	chunk.size = Vector3(0.0072, 0.0042, 0.0055)
	meshes["animal"] = chunk

## The material of one stage: darker, duller and a little green as it rots.
func _stage_mat(mat: String, stage: int) -> StandardMaterial3D:
	var t := stage / 3.0
	var m := StandardMaterial3D.new()
	m.albedo_color = (FRESH[mat] as Color).lerp(ROTTEN[mat], t)
	m.roughness = lerpf(0.25 if mat != "animal" else 0.6, 0.85, t)
	m.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	return m

## Lay out `n` pieces in a cell, five to a row, a little jumbled; the same cell always jumbles the same way.
func _fill(key: String, n: int) -> void:
	var cell: Node3D = cells[key]
	for c in cell.get_children():
		c.queue_free()
	var mat: String = key.split(":")[0]
	var stage := int(key.split(":")[1])
	var m := _stage_mat(mat, stage)
	var rng := RandomNumberGenerator.new()
	rng.seed = key.hash()
	var shrink := lerpf(1.4, 1.1, stage / 3.0)   # 1.4 times the base lump: big enough to count from the seat
	for i in n:
		var mi := MeshInstance3D.new()
		mi.mesh = meshes[mat]
		mi.material_override = m
		var col := i % 5
		var row := i / 5
		mi.position = Vector3((col - 2) * 0.0112 + rng.randf_range(-0.0012, 0.0012), 0.0025, (row - 1) * 0.0128 + rng.randf_range(-0.0012, 0.0012))
		mi.rotation = Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0, TAU), rng.randf_range(-0.4, 0.4))
		mi.scale = Vector3.ONE * shrink * rng.randf_range(0.85, 1.15)
		cell.add_child(mi)

## From the rules: material -> [I, II, III, IV]. Changed cells refill; new pieces drop in.
func show_mats(mats: Dictionary) -> void:
	for mat: String in MATS:
		var a: Array = mats.get(mat, [0, 0, 0, 0])
		for st in 4:
			var key := "%s:%d" % [mat, st]
			var n := mini(int(a[st]), 15)
			if shown[key] == n:
				continue
			var was: int = shown[key]
			shown[key] = n
			_fill(key, n)
			if n > was and is_inside_tree():
				var cell: Node3D = cells[key]
				for i in range(was, n):
					var p: Node3D = cell.get_child(i)
					var y := p.position.y
					p.position.y = y + 0.03
					create_tween().tween_property(p, "position:y", y, 0.3).set_delay(0.03 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
