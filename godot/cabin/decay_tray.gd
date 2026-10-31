class_name DecayTray
extends Node3D
## Your decomposition tray (D189): a flat white enamel tray with a dark blue rim (flat since D191), low tin strips dividing
## a 4 x 4 grid, and below it two undivided rows for what keeps (D191): preserved flesh and bone (white cubes). Columns are the stages I to IV, freshest on the left; rows are muscle, organ, blood and animal, from the
## back. Each cell holds one small piece per unit of material (up to 15, so the count can be read by eye), darker and
## more shrunken the older the stage. Blood rots after II: a lead bar closes the blood row there and its last two cells
## are stained. Everything rots after IV: a deep gutter runs along the right end. Built in code, metres.
## `show_mats(mats)` takes the rules' `p.mats` (material -> [I, II, III, IV]), `set_ice(n)` the rules' `p.ice` (D190: frosted
## cubes on the crossings of the grid), and `dawn(after, ice_after)` plays the night: every cell slides one stage right,
## blood past II soaks under the lead bar, stage IV tips into the gutter; with ice the cubes melt a size instead.
## `show_stores(preserved, bone)` fills the two lower rows. Hover it (`hover_at(point)`) to see the count in a square;
## `pick` carries id "tray" so the cabin can lean in on a click.

const MATS := ["muscle", "organ", "blood", "animal"]
const CELL := Vector2(0.06, 0.045)     # one cell, x by z
const WALL := 0.0025
const RIM := 0.014                     # the blue rim round the tray
const DEPTH := 0.0065                  # the rim's height: a flat tray (D191)
const WALL_H := 0.0018                 # the tin strips between the cells
const GUTTER := 0.018
const KEEP := ["preserved", "bone"]    # the two undivided rows under the grid (D191)
const KEEP_ROW := 0.032                # their depth
const PER_LINE := 20                   # pieces to a line in those rows, two lines
const SIZE := Vector2(CELL.x * 4 + WALL * 5 + RIM * 2 + GUTTER, CELL.y * 4 + KEEP_ROW * 2 + WALL * 7 + RIM * 2)
## Each material's colour when fresh, and when it has rotted to stage IV (SPEC 6.3: muscle brown, organ purple,
## blood red, animal orange).
const FRESH := {"muscle": Color("#8a3b2a"), "organ": Color("#6b3a6e"), "blood": Color("#8e0f12"), "animal": Color("#b8682c"),
	"preserved": Color("#a88272"), "bone": Color("#e6dcc2")}
const ROTTEN := {"muscle": Color("#3c3420"), "organ": Color("#2f2633"), "blood": Color("#2a0d0c"), "animal": Color("#4a3a22"),
	"preserved": Color("#a88272"), "bone": Color("#e6dcc2")}

var cells := {}                        # "material:stage" -> Node3D holding its pieces
var shown := {}                        # "material:stage" -> count
var cell_mats := {}                    # "material:stage" -> ShaderMaterial (piece.gdshader), one per cell
var meshes := {}                       # material -> [Mesh, ...], a few lumpy variants
var ice := 0
var keep_nodes := {}                   # "preserved" / "bone" -> Node3D holding its pieces
var keep_shown := {"preserved": 0, "bone": 0}
var keep_mats := {}
var pick: StaticBody3D
var count_label: Label3D
var count_glow: MeshInstance3D
var hover_key := ""
var ice_cubes: Array[MeshInstance3D] = []
var _gutter_x := 0.0
var _bar_x := 0.0
var font: Font


func _init() -> void:
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	_tray()
	_piece_meshes()
	_ice()
	_keep_rows()
	_hover_bits()
	for r in 4:
		for st in 4:
			var n := Node3D.new()
			n.position = _cell_centre(r, st)
			add_child(n)
			var key := "%s:%d" % [MATS[r], st]
			cells[key] = n
			shown[key] = 0
			cell_mats[key] = piece_mat(MATS[r], st / 3.0)


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

## The middle of a row, z: the four grid rows, then the two keep rows.
func _row_z(row: int) -> float:
	if row < 4:
		return _z0() + WALL + row * (CELL.y + WALL) + CELL.y / 2
	return _z0() + WALL + 4 * (CELL.y + WALL) + (row - 4) * (KEEP_ROW + WALL) + KEEP_ROW / 2

func _cell_centre(row: int, stage: int) -> Vector3:
	return Vector3(_x0() + WALL + stage * (CELL.x + WALL) + CELL.x / 2, 0.0035, _row_z(row))

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
	# Floor and a low blue rim, flat on top where the labels are painted.
	_box(Vector3(SIZE.x, 0.003, SIZE.y), enamel, Vector3(0, 0.0015, 0))
	for s: float in [-1.0, 1.0]:
		_box(Vector3(SIZE.x, DEPTH, RIM), blue, Vector3(0, DEPTH / 2, s * (SIZE.y / 2 - RIM / 2)))
		_box(Vector3(RIM, DEPTH, SIZE.y), blue, Vector3(s * (SIZE.x / 2 - RIM / 2), DEPTH / 2, 0))
	# The grid: low tin strips. Between the stages only in the four grid rows; across, between every row.
	var grid_w := CELL.x * 4 + WALL * 5
	var grid_d := CELL.y * 4 + WALL * 5
	var all_d := SIZE.y - RIM * 2
	for i in 5:
		var x := _x0() + WALL / 2 + i * (CELL.x + WALL)
		_box(Vector3(WALL, WALL_H, grid_d), tin, Vector3(x, 0.003 + WALL_H / 2, _z0() + grid_d / 2))
	for r in 7:
		var z := _z0() + WALL / 2 + (r * (CELL.y + WALL) if r <= 4 else 4 * (CELL.y + WALL) + (r - 4) * (KEEP_ROW + WALL))
		_box(Vector3(grid_w, WALL_H, WALL), tin, Vector3(_x0() + grid_w / 2, 0.003 + WALL_H / 2, z))
	# Blood rots after II: a lead strip across the blood row between II and III, its III and IV cells stained.
	var blood := MATS.find("blood")
	var bz := _cell_centre(blood, 0).z
	_bar_x = _x0() + WALL / 2 + 2 * (CELL.x + WALL)
	_box(Vector3(WALL * 2.4, WALL_H * 2.2, CELL.y + WALL), lead, Vector3(_bar_x, 0.003 + WALL_H * 1.1, bz))
	for st in [2, 3]:
		var c := _cell_centre(blood, st)
		var s2 := _box(Vector3(CELL.x * 0.86, 0.0006, CELL.y * 0.8), stain, Vector3(c.x, 0.0033, c.z))
		s2.rotation_degrees.y = 4.0 if st == 2 else -6.0
	# Everything rots after IV: a dark gutter beside the four grid rows, with a drain hole.
	var gx := _x0() + grid_w + GUTTER / 2
	_gutter_x = gx
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
	# Stage numbers along the front rim, row names along the left rim, painted white on the blue enamel; ROT under
	# the gutter, on the enamel.
	var paint := Color("#e6e1d4")
	for st in 4:
		_label(["I", "II", "III", "IV"][st], Vector3(_cell_centre(0, st).x, DEPTH + 0.0012, SIZE.y / 2 - RIM / 2), 56, paint)
	var rot_l := Label3D.new()
	rot_l.text = "ROT"
	rot_l.font = font
	rot_l.font_size = 40
	rot_l.pixel_size = 0.00018
	rot_l.modulate = Color("#7a2a1c")
	rot_l.shaded = true
	rot_l.rotation_degrees = Vector3(-90, 90, 0)
	rot_l.position = Vector3(gx, 0.0032, _row_z(4) + KEEP_ROW / 2)
	add_child(rot_l)
	var names: Array = MATS + KEEP
	for r in 6:
		var l := Label3D.new()
		l.text = String(names[r]).to_upper()
		l.font = font
		l.font_size = 30 if r < 4 else 22
		l.pixel_size = 0.00018
		l.modulate = paint
		l.shaded = true
		l.rotation_degrees = Vector3(-90, 90, 0)
		l.position = Vector3(-SIZE.x / 2 + RIM / 2, DEPTH + 0.0012, _row_z(r))
		add_child(l)


# ---------------------------------------------------------------- the pieces

## A primitive pushed in and out by noise along its radius (so the duplicated seam and corner vertices move together),
## then smooth normals again: a lump, not a ball.
static func lumpy(base: PrimitiveMesh, amount: float, seed: int, freq: float) -> ArrayMesh:
	var arr := base.get_mesh_arrays()
	var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
	var fn := FastNoiseLite.new()
	fn.seed = seed
	fn.frequency = freq
	for i in v.size():
		v[i] += v[i].normalized() * fn.get_noise_3dv(v[i]) * amount
	arr[Mesh.ARRAY_VERTEX] = v
	arr[Mesh.ARRAY_NORMAL] = null
	arr[Mesh.ARRAY_TANGENT] = null
	var st := SurfaceTool.new()
	st.create_from_arrays(arr)
	st.generate_normals()
	return st.commit()

func _piece_meshes() -> void:
	for k in 3:
		var lump := SphereMesh.new()
		lump.radius = 0.0042
		lump.height = 0.0058
		lump.radial_segments = 10
		lump.rings = 6
		var organ := SphereMesh.new()
		organ.radius = 0.0045
		organ.height = 0.0072
		organ.radial_segments = 12
		organ.rings = 7
		var clot := SphereMesh.new()
		clot.radius = 0.004
		clot.height = 0.0026
		clot.radial_segments = 16
		clot.rings = 6
		var chunk := BoxMesh.new()
		chunk.size = Vector3(0.0072, 0.0042, 0.0055)
		chunk.subdivide_width = 3
		chunk.subdivide_height = 2
		chunk.subdivide_depth = 3
		for pair: Array in [["muscle", lump, 0.0016, 260.0], ["organ", organ, 0.0012, 200.0], ["blood", clot, 0.0014, 300.0], ["animal", chunk, 0.0011, 280.0]]:
			if not meshes.has(pair[0]):
				meshes[pair[0]] = []
			meshes[pair[0]].append(lumpy(pair[1], pair[2], 17 * k + MATS.find(pair[0]), pair[3]))

## The surface of a piece: textured by piece.gdshader, `rot` 0 fresh to 1 at stage IV.
static func piece_mat(mat: String, rot: float) -> ShaderMaterial:
	var m := ShaderMaterial.new()
	m.shader = preload("res://cabin/piece.gdshader")
	m.set_shader_parameter("fresh", FRESH[mat])
	m.set_shader_parameter("rotten", ROTTEN[mat])
	m.set_shader_parameter("kind", ["muscle", "organ", "blood", "animal", "preserved", "bone"].find(mat))
	m.set_shader_parameter("rot", rot)
	m.set_shader_parameter("frost", 0.0)
	return m

## Where the i-th of n pieces of a material lies in its cell (rows centred), and how it is turned: the same in every
## stage, so a cell that slides on at dawn is already laid out as the next cell is.
func _place(mat: String, i: int, n: int) -> Transform3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s:%d" % [mat, i]).hash()
	var col := i % 5
	var row := i / 5
	var rows := (n + 4) / 5
	var pos := Vector3((col - 2) * 0.0112 + rng.randf_range(-0.0012, 0.0012), 0.0025, (row - (rows - 1) / 2.0) * 0.0128 + rng.randf_range(-0.0012, 0.0012))
	var b := Basis.from_euler(Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0, TAU), rng.randf_range(-0.4, 0.4)))
	return Transform3D(b.scaled(Vector3.ONE * rng.randf_range(0.85, 1.15)), pos)

func _shrink(stage: int) -> float:
	return lerpf(1.4, 1.1, stage / 3.0)   # 1.4 times the base lump: big enough to count from the seat

## Lay out `n` pieces in a cell, five to a row, a little jumbled.
func _fill(key: String, n: int) -> void:
	var cell: Node3D = cells[key]
	for c in cell.get_children():
		cell.remove_child(c)
		c.queue_free()
	var mat: String = key.split(":")[0]
	var stage := int(key.split(":")[1])
	var variants: Array = meshes[mat]
	for i in n:
		var mi := MeshInstance3D.new()
		mi.mesh = variants[i % variants.size()]
		mi.material_override = cell_mats[key]
		mi.set_instance_shader_parameter("seed", float(i) + MATS.find(mat) * 20.0)
		var t := _place(mat, i, n)
		mi.transform = Transform3D(t.basis.scaled(Vector3.ONE * _shrink(stage)), t.origin)
		cell.add_child(mi)

## From the rules: material -> [I, II, III, IV]. Changed cells refill; new pieces drop in.
func show_mats(mats: Dictionary, drop := true) -> void:
	for mat: String in MATS:
		var a: Array = mats.get(mat, [0, 0, 0, 0])
		for st in 4:
			var key := "%s:%d" % [mat, st]
			var n := mini(int(a[st]), 15)
			if shown[key] == n:
				continue
			var was: int = maxi(shown[key], 0)
			shown[key] = n
			_fill(key, n)
			if drop and n > was and is_inside_tree():
				var cell: Node3D = cells[key]
				for i in range(was, n):
					var p: Node3D = cell.get_child(i)
					var y := p.position.y
					p.position.y = y + 0.03
					create_tween().tween_property(p, "position:y", y, 0.3).set_delay(0.03 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- ice and dawn

## Ice (D190): a frosted cube on each inner crossing of the tin walls, full size the day it is bought (ice 2), half
## melted after one dawn (ice 1). While it lies there the pieces are rimed with frost.
func _ice() -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.82, 0.9, 1.0, 0.55)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.12
	m.rim_enabled = true
	m.rim = 0.7
	m.rim_tint = 0.2
	m.emission_enabled = true
	m.emission = Color(0.25, 0.35, 0.5)
	m.emission_energy_multiplier = 0.25
	var top := 0.003 + WALL_H
	var rng := RandomNumberGenerator.new()
	rng.seed = 1819
	for i in range(1, 4):
		for j in range(1, 4):
			var mi := MeshInstance3D.new()
			mi.mesh = lumpy(_ice_box(), 0.0012, i * 7 + j, 120.0)
			mi.material_override = m
			mi.position = Vector3(_x0() + WALL / 2 + i * (CELL.x + WALL), top, _z0() + WALL / 2 + j * (CELL.y + WALL))
			mi.rotation = Vector3(rng.randf_range(-0.2, 0.2), rng.randf_range(0, TAU), rng.randf_range(-0.2, 0.2))
			mi.scale = Vector3.ZERO
			mi.visible = false
			add_child(mi)
			ice_cubes.append(mi)

static func _ice_box() -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3.ONE * 0.013
	b.subdivide_width = 2
	b.subdivide_height = 2
	b.subdivide_depth = 2
	return b

func _ice_scale(n: int) -> float:
	return [0.0, 0.6, 1.0][clampi(n, 0, 2)]

## From the rules' `p.ice` (0, 1 or 2). Cubes grow in or melt away.
func set_ice(n: int, animate := true) -> void:
	ice = n
	var s := _ice_scale(n)
	var tw: Tween = create_tween().set_parallel() if animate and is_inside_tree() else null
	for c in ice_cubes:
		if s > 0:
			c.visible = true
		if tw:
			tw.tween_property(c, "scale", Vector3.ONE * s, 0.9).set_trans(Tween.TRANS_SINE)
		else:
			c.scale = Vector3.ONE * s
			c.visible = s > 0
	for key in cell_mats:
		var m: ShaderMaterial = cell_mats[key]
		if tw:
			tw.tween_property(m, "shader_parameter/frost", 1.0 if n > 0 else 0.0, 0.9)
		else:
			m.set_shader_parameter("frost", 1.0 if n > 0 else 0.0)
	if tw and s == 0:
		tw.chain().tween_callback(func() -> void:
			for c in ice_cubes:
				c.visible = false)

## Dawn: with ice, the cubes melt a size and nothing moves. Without, every cell lifts over the tin wall into the next
## stage, the rightmost first: blood at II soaks away under the lead bar, stage IV tips into the gutter and is gone.
## Then the tray shows `after` (the rules' mats after dawn). Await it.
func dawn(after: Dictionary, ice_after: int) -> void:
	if ice > 0:
		set_ice(ice_after)
		await get_tree().create_timer(1.0).timeout
		show_mats(after, false)
		return
	var last: Tween = null
	for st in range(3, -1, -1):
		for mat: String in MATS:
			var key := "%s:%d" % [mat, st]
			var cell: Node3D = cells[key]
			if cell.get_child_count() == 0:
				continue
			var from := cell.position
			var gone := st == 3 or (mat == "blood" and st == 1)
			var to := Vector3(_gutter_x if st == 3 else (_bar_x if gone else _cell_centre(MATS.find(mat), st + 1).x), from.y, from.z)
			var grow := _shrink(mini(st + 1, 3)) / _shrink(st)
			var tw := create_tween()
			tw.tween_interval(0.35 * (3 - st))
			tw.tween_method(func(s: float) -> void:
				cell.position = from.lerp(to, s) + Vector3.UP * sin(PI * s) * 0.01
				cell.scale = Vector3.ONE * (lerpf(1.0, 0.0, smoothstep(0.4, 1.0, s)) if gone else lerpf(1.0, grow, s)),
				0.0, 1.0, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			if not gone:
				tw.parallel().tween_property(cell_mats[key], "shader_parameter/rot", (st + 1) / 3.0, 0.9)
			last = tw
	if last:
		await last.finished
	# Back to rest: every cell in its place, its own stage's look, then the new counts without a drop.
	for key in cells:
		var cell: Node3D = cells[key]
		cell.position = _cell_centre(MATS.find(key.split(":")[0]), int(key.split(":")[1]))
		cell.scale = Vector3.ONE
		(cell_mats[key] as ShaderMaterial).set_shader_parameter("rot", int(key.split(":")[1]) / 3.0)
		shown[key] = -1
	show_mats(after, false)


# ---------------------------------------------------------------- what keeps, and the counts

## The two undivided rows under the grid: preserved flesh (pale lumps) and bone (white cubes, D191).
func _keep_rows() -> void:
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 0.0052
	cube.subdivide_width = 2
	cube.subdivide_height = 2
	cube.subdivide_depth = 2
	meshes["bone"] = [lumpy(cube, 0.0006, 70, 300.0), lumpy(cube, 0.0006, 71, 300.0)]
	meshes["preserved"] = meshes["muscle"]
	for r in 2:
		var n := Node3D.new()
		n.position = Vector3(_x0() + WALL + (CELL.x * 4 + WALL * 3) / 2, 0.0035, _row_z(4 + r))
		add_child(n)
		keep_nodes[KEEP[r]] = n
		keep_mats[KEEP[r]] = piece_mat(KEEP[r], 0.0)

## From the rules: `p.preserved` and `p.bone`, one piece each, in two lines of up to 20.
func show_stores(preserved: int, bone: int) -> void:
	for kind: String in KEEP:
		var n := mini(preserved if kind == "preserved" else bone, PER_LINE * 2)
		if keep_shown[kind] == n:
			continue
		var was: int = keep_shown[kind]
		keep_shown[kind] = n
		var node: Node3D = keep_nodes[kind]
		for c in node.get_children():
			node.remove_child(c)
			c.queue_free()
		var lines := (n + PER_LINE - 1) / PER_LINE
		for i in n:
			var rng := RandomNumberGenerator.new()
			rng.seed = ("%s:%d" % [kind, i]).hash()
			var mi := MeshInstance3D.new()
			mi.mesh = meshes[kind][i % meshes[kind].size()]
			mi.material_override = keep_mats[kind]
			mi.set_instance_shader_parameter("seed", 100.0 + i)
			var col := i % PER_LINE
			var line := i / PER_LINE
			mi.position = Vector3((col - (PER_LINE - 1) / 2.0) * 0.0118 + rng.randf_range(-0.001, 0.001), 0.0026 if kind == "bone" else 0.0025, (line - (lines - 1) / 2.0) * 0.013 + rng.randf_range(-0.001, 0.001))
			mi.rotation = Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(0, TAU), rng.randf_range(-0.15, 0.15))
			mi.scale = Vector3.ONE * (1.25 if kind == "preserved" else 1.0) * rng.randf_range(0.9, 1.1)
			node.add_child(mi)
			if i >= was and is_inside_tree():
				var y := mi.position.y
				mi.position.y = y + 0.03
				create_tween().tween_property(mi, "position:y", y, 0.3).set_delay(0.03 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

## The pick box (id "tray"), the glow over the hovered square and the count above it.
func _hover_bits() -> void:
	pick = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, 0.012, SIZE.y)
	shape.shape = box
	shape.position.y = 0.006
	pick.add_child(shape)
	pick.set_meta("id", "tray")
	add_child(pick)
	var glow := StandardMaterial3D.new()
	glow.albedo_color = Color(1.0, 0.86, 0.55, 0.16)
	glow.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	count_glow = _box(Vector3(1, 0.0004, 1), glow, Vector3.ZERO)
	count_glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	count_glow.visible = false
	count_label = Label3D.new()
	count_label.font = font
	count_label.font_size = 96
	count_label.pixel_size = 0.0002
	count_label.outline_size = 18
	count_label.outline_modulate = Color("#140c08")
	count_label.modulate = Color("#f3e6c8")
	count_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	count_label.no_depth_test = true
	count_label.visible = false
	add_child(count_label)

## Which square a point on the tray is over: "material:stage", "preserved", "bone" or "".
func square_at(local: Vector3) -> String:
	var x := local.x - _x0() - WALL
	if x < 0 or x > CELL.x * 4 + WALL * 3:
		return ""
	for r in 6:
		var h := CELL.y if r < 4 else KEEP_ROW
		if absf(local.z - _row_z(r)) <= (h + WALL) / 2:
			if r >= 4:
				return KEEP[r - 4]
			return "%s:%d" % [MATS[r], clampi(int(x / (CELL.x + WALL)), 0, 3)]
	return ""

## Hover at a point in the world (or null to clear): light the square under it and show its count above it.
func hover_at(point: Variant) -> void:
	var key := "" if point == null else square_at(to_local(point))
	if key == hover_key:
		return
	hover_key = key
	count_glow.visible = key != ""
	count_label.visible = key != ""
	if key == "":
		return
	var c: Vector3
	var size: Vector2
	var n: int
	if key in KEEP:
		var r := 4 + KEEP.find(key)
		c = Vector3(_x0() + WALL + (CELL.x * 4 + WALL * 3) / 2, 0, _row_z(r))
		size = Vector2(CELL.x * 4 + WALL * 3, KEEP_ROW)
		n = keep_shown[key]
	else:
		var mat: String = key.split(":")[0]
		c = _cell_centre(MATS.find(mat), int(key.split(":")[1]))
		size = Vector2(CELL.x, CELL.y)
		n = maxi(shown[key], 0)
	count_glow.position = Vector3(c.x, 0.0034, c.z)
	count_glow.scale = Vector3(size.x, 1, size.y)
	count_label.text = str(n)
	count_label.position = Vector3(c.x, 0.03, c.z)
