class_name DecayTray
extends Node3D
## Your decomposition board (D193, after Bruno's concept `art/source/ui/decay_board_concept.png`): a flat oak panel in an
## iron frame, its painted face the concept itself (`assets/cabin/decay_board.webp`). Four tall fields are the stages I
## to IV, velvet ageing from purple to mouldy grey-green, brass strips with arrows between them; a red-stained strip
## between II and III where blood rots; an iron gutter with a drain down the right where everything rots after IV.
## Each stage field holds four bands, muscle, organ, blood and animal from the back, one piece per unit (up to 15).
## Below, three fields: ice (frosted blocks), preserved flesh (pale lumps) and bone (white cubes).
## `show_mats(p.mats)`, `show_stores(p.preserved, p.bone)`, `set_ice(p.ice)`, `dawn(after, ice_after)` (await it):
## every band slides one stage right, blood at II soaks into the red strip, stage IV tips into the gutter; with ice
## a block melts instead. Hover (`hover_at(point)`) lights a band or field and shows its count; `pick` carries id
## "tray". Built in code over the painted face; metres.

const MATS := ["muscle", "organ", "blood", "animal"]
const KEEP := ["preserved", "bone"]
const TEX := Vector2(1190, 1010)       # the painted face, pixels
const W := 0.26                        # the board's width, metres
const SIZE := Vector2(W, W * 1010.0 / 1190.0)
const THICK := 0.006
## Where things are on the painted face, in its pixels.
const STAGE_PX := [Rect2(39, 83, 224, 637), Rect2(306, 83, 221, 637), Rect2(590, 83, 210, 637), Rect2(845, 83, 225, 637)]
const BLOOD_STRIP_X := 559.0
const GUTTER_X := 1122.0
const PLATE_PX := [Vector2(164, 59), Vector2(424, 59), Vector2(689, 59), Vector2(947, 59)]
const ICE_PX := Rect2(34, 741, 344, 232)
const PRES_PX := Rect2(383, 741, 391, 232)
const BONE_PX := Rect2(779, 741, 375, 232)
const FRAME_PX := 30.0                 # the painted iron frame's width
## Each material's colour when fresh, and when it has rotted to stage IV (SPEC 6.3: muscle brown, organ purple,
## blood red, animal orange); preserved flesh and bone keep.
const FRESH := {"muscle": Color("#8a3b2a"), "organ": Color("#6b3a6e"), "blood": Color("#7a0710"), "animal": Color("#b8682c"),
	"preserved": Color("#a88272"), "bone": Color("#e6dcc2")}
const ROTTEN := {"muscle": Color("#3c3420"), "organ": Color("#2f2633"), "blood": Color("#2a0d0c"), "animal": Color("#4a3a22"),
	"preserved": Color("#a88272"), "bone": Color("#e6dcc2")}

var cells := {}                        # "material:stage" -> Node3D holding its pieces
var shown := {}                        # "material:stage" -> count
var cell_mats := {}                    # "material:stage" -> ShaderMaterial (piece.gdshader), one per band
var meshes := {}                       # material -> [Mesh, ...], a few lumpy variants
var ice := 0
var ice_blocks: Array[MeshInstance3D] = []
var keep_nodes := {}
var keep_shown := {"preserved": 0, "bone": 0}
var keep_mats := {}
var pick: StaticBody3D
var count_label: Label3D
var hover_key := ""
var font: Font


func _init() -> void:
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	_board()
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


## A point on the painted face (pixels) as a point on the board's top (metres).
func px(p: Vector2, y := 0.0) -> Vector3:
	return Vector3((p.x / TEX.x - 0.5) * SIZE.x, THICK + y, (p.y / TEX.y - 0.5) * SIZE.y)

func _px_rect(r: Rect2) -> Rect2:
	var a := px(r.position)
	var b := px(r.end)
	return Rect2(a.x, a.z, b.x - a.x, b.z - a.z)

## The band of one material in one stage field, in metres (x, z).
func _band(row: int, stage: int) -> Rect2:
	var f := _px_rect(STAGE_PX[stage])
	var h := f.size.y / 4.0
	return Rect2(f.position.x, f.position.y + row * h, f.size.x, h)

func _cell_centre(row: int, stage: int) -> Vector3:
	var c := _band(row, stage).get_center()
	return Vector3(c.x, THICK, c.y)

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

## The oak slab, its painted face, a raised iron frame over the painted one, the numerals I to IV in white.
func _board() -> void:
	var iron := _mat(Color("#2b2a28"), 0.55, 0.6)
	_box(Vector3(SIZE.x, THICK, SIZE.y), _mat(Color("#2a1c12"), 0.8), Vector3(0, THICK / 2, 0))
	var face := PlaneMesh.new()
	face.size = SIZE
	var fm := StandardMaterial3D.new()
	fm.albedo_texture = load("res://assets/cabin/decay_board.webp")
	fm.roughness = 0.75
	# A faint glow of its own, so the velvet's colours survive the candlelight.
	fm.emission_enabled = true
	fm.emission_texture = fm.albedo_texture
	fm.emission_energy_multiplier = 0.18
	var top := MeshInstance3D.new()
	top.mesh = face
	top.material_override = fm
	top.position.y = THICK + 0.0002
	add_child(top)
	var fw := FRAME_PX / TEX.x * SIZE.x
	for s: float in [-1.0, 1.0]:
		_box(Vector3(SIZE.x, 0.002, fw), iron, Vector3(0, THICK + 0.001, s * (SIZE.y - fw) / 2))
		_box(Vector3(fw, 0.002, SIZE.y), iron, Vector3(s * (SIZE.x - fw) / 2, THICK + 0.001, 0))
	# The stage numerals, white straight on the wood (D197: the brass plates are painted out of the face).
	for st in 4:
		var at := px(PLATE_PX[st])
		var l := Label3D.new()
		l.text = ["I", "II", "III", "IV"][st]
		l.font = font
		l.font_size = 80
		l.pixel_size = 0.00016
		l.modulate = Color(1.7, 1.7, 1.7)   # over white, as the hover count (D196)
		l.rotation_degrees.x = -90
		l.position = at + Vector3(0, 0.0004, 0)
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
		var chunk := BoxMesh.new()
		chunk.size = Vector3(0.0072, 0.0042, 0.0055)
		chunk.subdivide_width = 3
		chunk.subdivide_height = 2
		chunk.subdivide_depth = 3
		for pair: Array in [["muscle", lump, 0.0016, 260.0], ["organ", organ, 0.0012, 200.0], ["animal", chunk, 0.0011, 280.0]]:
			if not meshes.has(pair[0]):
				meshes[pair[0]] = []
			meshes[pair[0]].append(lumpy(pair[1], pair[2], 17 * k + MATS.find(pair[0]), pair[3]))
	meshes["blood"] = [_vial()]

## Blood is a small corked glass vial of red (D195), lying along local z: surface 0 the glass, 1 the blood (its
## band's material, so it darkens as it ages), 2 the cork.
static func _vial() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var along := Basis(Vector3.RIGHT, PI / 2)
	for part: Array in [[0.0022, 0.0095, 0.0], [0.0018, 0.0068, -0.0011], [0.0019, 0.002, 0.0052]]:
		var c := CylinderMesh.new()
		c.top_radius = part[0]
		c.bottom_radius = part[0]
		c.height = part[1]
		c.radial_segments = 12
		c.rings = 1
		var st := SurfaceTool.new()
		st.append_from(c, 0, Transform3D(along, Vector3(0, 0.0022, part[2])))
		if mesh.get_surface_count() < 2:
			# a round bottom on the glass and on the blood
			var cap := SphereMesh.new()
			cap.radius = part[0]
			cap.height = part[0] * 2
			cap.radial_segments = 12
			cap.rings = 6
			st.append_from(cap, 0, Transform3D(Basis(), Vector3(0, 0.0022, part[2] - part[1] / 2)))
		st.commit(mesh)
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.85, 0.9, 0.92, 0.16)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.roughness = 0.05
	glass.rim_enabled = true
	glass.rim = 0.3
	mesh.surface_set_material(0, glass)
	var cork := StandardMaterial3D.new()
	cork.albedo_color = Color("#8a6a48")
	cork.roughness = 0.9
	mesh.surface_set_material(2, cork)
	return mesh

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

## Where the i-th of n pieces of a material lies in its band (five to a line, lines centred), and how it is turned: the
## same in every stage, so a band that slides on at dawn is already laid out as the next one is.
func _place(mat: String, i: int, n: int) -> Transform3D:
	var rng := RandomNumberGenerator.new()
	rng.seed = ("%s:%d" % [mat, i]).hash()
	var col := i % 5
	var row := i / 5
	var rows := (n + 4) / 5
	var pos := Vector3((col - 2) * 0.0092 + rng.randf_range(-0.0008, 0.0008), 0.002, (row - (rows - 1) / 2.0) * 0.0102 + rng.randf_range(-0.0008, 0.0008))
	var b := Basis.from_euler(Vector3(rng.randf_range(-0.4, 0.4), rng.randf_range(0, TAU), rng.randf_range(-0.4, 0.4)))
	return Transform3D(b.scaled(Vector3.ONE * rng.randf_range(0.88, 1.12)), pos)

func _shrink(stage: int) -> float:
	return lerpf(1.05, 0.85, stage / 3.0)

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
		mi.set_instance_shader_parameter("seed", float(i) + MATS.find(mat) * 20.0)
		var t := _place(mat, i, n)
		if mat == "blood":
			# a vial lies flat along the band's depth, a little askew; the blood inside takes the band's material
			mi.set_surface_override_material(1, cell_mats[key])
			t.basis = Basis(Vector3.UP, (t.basis.get_euler().y - PI) * 0.12)
			t.origin.y = 0.0
		else:
			mi.material_override = cell_mats[key]
		mi.transform = Transform3D(t.basis.scaled(Vector3.ONE * _shrink(stage)), t.origin)
		cell.add_child(mi)

## From the rules: material -> [I, II, III, IV]. Changed bands refill; new pieces drop in.
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

## Ice: frosted blocks in the ice field, two the day it is bought (ice 2), one after a dawn (ice 1). While there is
## ice the pieces are rimed with frost.
func _ice() -> void:
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.82, 0.9, 1.0, 0.6)
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	m.roughness = 0.12
	m.rim_enabled = true
	m.rim = 0.7
	m.rim_tint = 0.2
	m.emission_enabled = true
	m.emission = Color(0.25, 0.35, 0.5)
	m.emission_energy_multiplier = 0.25
	var c := _px_rect(ICE_PX).get_center()
	for i in 2:
		var b := BoxMesh.new()
		b.size = Vector3(0.022, 0.016, 0.02)
		b.subdivide_width = 2
		b.subdivide_height = 2
		b.subdivide_depth = 2
		var mi := MeshInstance3D.new()
		mi.mesh = lumpy(b, 0.0015, 90 + i, 90.0)
		mi.material_override = m
		mi.position = Vector3(c.x + (i - 0.5) * 0.03, THICK + 0.008, c.y + (0.004 if i == 0 else -0.003))
		mi.rotation = Vector3(0, 0.3 - i * 0.5, 0)
		mi.scale = Vector3.ZERO
		mi.visible = false
		add_child(mi)
		ice_blocks.append(mi)

## From the rules' `p.ice` (0, 1 or 2): blocks grow in or melt away.
func set_ice(n: int, animate := true) -> void:
	ice = n
	var tw: Tween = create_tween().set_parallel() if animate and is_inside_tree() else null
	for i in 2:
		var c := ice_blocks[i]
		var s := 1.0 if i < n else 0.0
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

## Dawn: with ice, a block melts and nothing moves. Without, every band lifts into the next stage field, the rightmost
## first: blood at II soaks into the red strip, stage IV tips into the gutter and is gone. Then the board shows
## `after` (the rules' mats after dawn). Await it.
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
			var gx := px(Vector2(GUTTER_X if st == 3 else BLOOD_STRIP_X, 0)).x
			var to := Vector3(gx if gone else _cell_centre(MATS.find(mat), st + 1).x, from.y, from.z)
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
	for key in cells:
		var cell: Node3D = cells[key]
		cell.position = _cell_centre(MATS.find(key.split(":")[0]), int(key.split(":")[1]))
		cell.scale = Vector3.ONE
		(cell_mats[key] as ShaderMaterial).set_shader_parameter("rot", int(key.split(":")[1]) / 3.0)
		shown[key] = -1
	show_mats(after, false)


# ---------------------------------------------------------------- what keeps, and the counts

func _keep_rect(kind: String) -> Rect2:
	return _px_rect(PRES_PX if kind == "preserved" else BONE_PX)

## Preserved flesh (pale lumps) and bone (white cubes) in their fields.
func _keep_rows() -> void:
	var cube := BoxMesh.new()
	cube.size = Vector3.ONE * 0.0052
	cube.subdivide_width = 2
	cube.subdivide_height = 2
	cube.subdivide_depth = 2
	meshes["bone"] = [lumpy(cube, 0.0006, 70, 300.0), lumpy(cube, 0.0006, 71, 300.0)]
	meshes["preserved"] = meshes["muscle"]
	for kind: String in KEEP:
		var n := Node3D.new()
		var c := _keep_rect(kind).get_center()
		n.position = Vector3(c.x, THICK, c.y)
		add_child(n)
		keep_nodes[kind] = n
		keep_mats[kind] = piece_mat(kind, 0.0)

## From the rules: `p.preserved` and `p.bone`, one piece each, six to a line (up to 12).
func show_stores(preserved: int, bone: int) -> void:
	for kind: String in KEEP:
		var n := mini(preserved if kind == "preserved" else bone, 12)
		if keep_shown[kind] == n:
			continue
		var was: int = keep_shown[kind]
		keep_shown[kind] = n
		var node: Node3D = keep_nodes[kind]
		for c in node.get_children():
			node.remove_child(c)
			c.queue_free()
		var lines := (n + 5) / 6
		for i in n:
			var rng := RandomNumberGenerator.new()
			rng.seed = ("%s:%d" % [kind, i]).hash()
			var mi := MeshInstance3D.new()
			mi.mesh = meshes[kind][i % meshes[kind].size()]
			mi.material_override = keep_mats[kind]
			mi.set_instance_shader_parameter("seed", 100.0 + i)
			mi.position = Vector3((i % 6 - 2.5) * 0.012 + rng.randf_range(-0.001, 0.001), 0.0026, (i / 6 - (lines - 1) / 2.0) * 0.014 + rng.randf_range(-0.001, 0.001))
			mi.rotation = Vector3(rng.randf_range(-0.15, 0.15), rng.randf_range(0, TAU), rng.randf_range(-0.15, 0.15))
			mi.scale = Vector3.ONE * (1.25 if kind == "preserved" else 1.1) * rng.randf_range(0.9, 1.1)
			node.add_child(mi)
			if i >= was and is_inside_tree():
				var y := mi.position.y
				mi.position.y = y + 0.03
				create_tween().tween_property(mi, "position:y", y, 0.3).set_delay(0.03 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

## The pick box (id "tray") and the count shown over the hovered band or field, white, nothing behind it (D196).
func _hover_bits() -> void:
	pick = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, 0.014, SIZE.y)
	shape.shape = box
	shape.position.y = 0.007
	pick.add_child(shape)
	pick.set_meta("id", "tray")
	add_child(pick)
	count_label = Label3D.new()
	count_label.font = font
	count_label.font_size = 48                 # smaller and white (D195)
	count_label.pixel_size = 0.0002
	count_label.outline_size = 10
	count_label.outline_modulate = Color(0, 0, 0, 0.8)
	count_label.modulate = Color(1.7, 1.7, 1.7)  # over white: the filmic tone map would turn plain white cream (D196)
	count_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	count_label.no_depth_test = true
	count_label.visible = false
	add_child(count_label)

## Which band or field a point on the board is over: "material:stage", "ice", "preserved", "bone" or "".
func square_at(local: Vector3) -> String:
	var p := Vector2(local.x, local.z)
	for st in 4:
		for r in 4:
			if _band(r, st).has_point(p):
				return "%s:%d" % [MATS[r], st]
	if _px_rect(ICE_PX).has_point(p):
		return "ice"
	for kind: String in KEEP:
		if _keep_rect(kind).has_point(p):
			return kind
	return ""

## Hover at a point in the world (or null to clear): show the count of what is under it, above it.
func hover_at(point: Variant) -> void:
	var key := "" if point == null else square_at(to_local(point))
	if key == hover_key:
		return
	hover_key = key
	count_label.visible = key != ""
	if key == "":
		return
	var r: Rect2
	var text: String
	if key == "ice":
		r = _px_rect(ICE_PX)
		text = "ice %d" % ice
	elif key in KEEP:
		r = _keep_rect(key)
		text = "%d %s" % [keep_shown[key], key]
	else:
		var mat: String = key.split(":")[0]
		r = _band(MATS.find(mat), int(key.split(":")[1]))
		text = "%d %s" % [maxi(shown[key], 0), mat]
	var c := r.get_center()
	count_label.text = text
	count_label.position = Vector3(c.x, THICK + 0.025, c.y)
