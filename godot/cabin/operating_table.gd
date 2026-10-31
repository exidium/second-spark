class_name OperatingTable
extends Node3D
## Your operating table (D186): a small steel table on the cabin table with the companion lying on it, part by part.
## Each of the six parts (head, torso, armL, armR, legL, legR) is empty (a faint outline etched in the steel), muscle
## (raw red), skin (sewn-on sallow skin) or alive (blue veins and sparks). Built in code, metres, the body's head
## toward local +x. `set_part(slot, look)` with look "", "muscle", "skin" or "alive".

const TOP := 0.075                     # height of the table top
const LEN := 0.32
const WID := 0.13
const ARC_EVERY := 0.06                # seconds between new sparks

## Each part: its pieces, in metres from the table top's middle, the body's length along x, head toward +x.
## ["ell", centre, half extents (along the body, up, across), stitched]: a rounded piece (skull, chest, hand, foot).
## ["limb", from, to, radius at from, radius at to, stitched]: a tapered segment with a round joint at each end.
const BODY := {
	"head": [["ell", Vector3(0.112, 0.016, 0), Vector3(0.019, 0.015, 0.0145), true],
		["ell", Vector3(0.099, 0.010, 0), Vector3(0.012, 0.009, 0.011), false],
		["limb", Vector3(0.094, 0.008, 0), Vector3(0.077, 0.009, 0), 0.0068, 0.0076, true]],
	"torso": [["ell", Vector3(0.056, 0.015, 0), Vector3(0.027, 0.015, 0.033), true],
		["ell", Vector3(0.022, 0.013, 0), Vector3(0.03, 0.012, 0.024), false],
		["ell", Vector3(-0.012, 0.012, 0), Vector3(0.02, 0.012, 0.026), true]],
	"armL": [["limb", Vector3(0.072, 0.009, 0.04), Vector3(0.03, 0.009, 0.045), 0.0085, 0.0066, true],
		["limb", Vector3(0.03, 0.009, 0.045), Vector3(-0.012, 0.007, 0.047), 0.0066, 0.0052, true],
		["ell", Vector3(-0.025, 0.005, 0.048), Vector3(0.012, 0.0045, 0.0075), false]],
	"armR": [["limb", Vector3(0.072, 0.009, -0.04), Vector3(0.03, 0.009, -0.045), 0.0085, 0.0066, true],
		["limb", Vector3(0.03, 0.009, -0.045), Vector3(-0.012, 0.007, -0.047), 0.0066, 0.0052, true],
		["ell", Vector3(-0.025, 0.005, -0.048), Vector3(0.012, 0.0045, 0.0075), false]],
	"legL": [["limb", Vector3(-0.02, 0.012, 0.015), Vector3(-0.08, 0.011, 0.015), 0.0125, 0.0085, true],
		["limb", Vector3(-0.08, 0.011, 0.015), Vector3(-0.132, 0.008, 0.015), 0.0085, 0.0058, true],
		["ell", Vector3(-0.139, 0.012, 0.015), Vector3(0.006, 0.012, 0.0075), false]],
	"legR": [["limb", Vector3(-0.02, 0.012, -0.015), Vector3(-0.08, 0.011, -0.015), 0.0125, 0.0085, true],
		["limb", Vector3(-0.08, 0.011, -0.015), Vector3(-0.132, 0.008, -0.015), 0.0085, 0.0058, true],
		["ell", Vector3(-0.139, 0.012, -0.015), Vector3(0.006, 0.012, 0.0075), false]],
}

var looks := {}                        # slot -> "", "muscle", "skin", "alive"
var parts := {}                        # slot -> {body: Node3D, ghost: Node3D, mats: Array[ShaderMaterial]}
var arcs: MeshInstance3D
var arc_mesh := ImmediateMesh.new()
var glow: OmniLight3D
var t_arc := 0.0
var surge := 0.0                       # extra sparks for a moment after a part comes alive
var flesh: Shader
var pick: StaticBody3D


func _init() -> void:
	flesh = load("res://cabin/flesh.gdshader")
	_table()
	for slot: String in BODY:
		_part(slot)
		looks[slot] = ""
		parts[slot].body.visible = false
	arcs = MeshInstance3D.new()
	arcs.mesh = arc_mesh
	var am := ShaderMaterial.new()
	am.shader = Shader.new()
	am.shader.code = """
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, shadows_disabled, cull_disabled;
void fragment() { ALBEDO = vec3(0.45, 0.75, 1.0) * 6.0; }
"""
	arcs.material_override = am
	arcs.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(arcs)
	glow = OmniLight3D.new()
	glow.light_color = Color("#7fb2ff")
	glow.omni_range = 0.3
	glow.omni_attenuation = 2.0
	glow.light_energy = 0.0
	glow.position = Vector3(0.02, TOP + 0.1, 0)
	add_child(glow)


# ---------------------------------------------------------------- the table

func _steel(c := Color("#8c9194"), rough := 0.32) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.metallic = 0.85
	m.roughness = rough
	return m

func _add(mesh: Mesh, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	(parent if parent != null else self).add_child(mi)
	return mi

func _boxm(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b

func _cylm(r: float, h: float, seg := 12) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = seg
	return c

func _table() -> void:
	var steel := _steel()
	var dark := _steel(Color("#4a4e50"), 0.5)
	# The top: a steel slab with a raised lip all round, a drain at the foot.
	_add(_boxm(Vector3(LEN, 0.006, WID)), steel, Vector3(0, TOP - 0.003, 0))
	for s: float in [-1.0, 1.0]:
		_add(_boxm(Vector3(LEN, 0.006, 0.004)), steel, Vector3(0, TOP + 0.002, s * (WID / 2 - 0.002)))
		_add(_boxm(Vector3(0.004, 0.006, WID)), steel, Vector3(s * (LEN / 2 - 0.002), TOP + 0.002, 0))
	_add(_cylm(0.006, 0.001, 16), _steel(Color("#1a1a1a"), 0.6), Vector3(-LEN / 2 + 0.014, TOP + 0.0005, 0))
	# A curved headrest.
	var rest := _add(_cylm(0.012, 0.05, 16), dark, Vector3(LEN / 2 - 0.013, TOP + 0.002, 0))
	rest.rotation_degrees.x = 90
	rest.scale = Vector3(1, 1, 0.35)
	# Legs on small casters, a slatted shelf below.
	for sx: float in [-1.0, 1.0]:
		for sz: float in [-1.0, 1.0]:
			var at := Vector3(sx * (LEN / 2 - 0.015), 0, sz * (WID / 2 - 0.014))
			_add(_cylm(0.0045, TOP - 0.012), steel, at + Vector3(0, (TOP - 0.012) / 2 + 0.009, 0))
			_add(_cylm(0.007, 0.006, 12), dark, at + Vector3(0, 0.007, 0)).rotation_degrees.x = 90
	for i in 5:
		var z := -WID / 2 + 0.02 + i * (WID - 0.04) / 4.0
		_add(_boxm(Vector3(LEN - 0.03, 0.002, 0.006)), dark, Vector3(0, 0.024, z))
	for sz: float in [-1.0, 1.0]:
		_add(_boxm(Vector3(LEN - 0.03, 0.004, 0.004)), steel, Vector3(0, 0.024, sz * (WID / 2 - 0.014)))
	# Leather straps with brass buckles across the wrists and ankles hang off the sides.
	var leather := StandardMaterial3D.new()
	leather.albedo_color = Color("#3b2618")
	leather.roughness = 0.8
	var brass := _steel(Color("#a07c3a"), 0.35)
	for x: float in [-0.12, 0.0]:
		for s: float in [-1.0, 1.0]:
			_add(_boxm(Vector3(0.008, 0.001, 0.02)), leather, Vector3(x, TOP + 0.0055, s * (WID / 2 - 0.004)))
			_add(_boxm(Vector3(0.008, 0.03, 0.0012)), leather, Vector3(x, TOP - 0.012, s * (WID / 2 + 0.0008)))
			_add(_boxm(Vector3(0.01, 0.008, 0.0015)), brass, Vector3(x, TOP - 0.022, s * (WID / 2 + 0.0015)))
	# For clicks.
	pick = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(LEN, TOP + 0.04, WID)
	shape.shape = bs
	shape.position = Vector3(0, (TOP + 0.04) / 2, 0)
	pick.add_child(shape)
	add_child(pick)


# ---------------------------------------------------------------- the body

var ball: SphereMesh

func _ball(parent: Node3D, mat: Material, centre: Vector3, half: Vector3) -> void:
	var mi := MeshInstance3D.new()
	mi.mesh = ball
	mi.material_override = mat
	parent.add_child(mi)
	mi.position = centre
	mi.rotation_degrees.z = -90            # the sphere's poles along the body, so its stitches ring the piece
	mi.scale = Vector3(half.y, half.x, half.z)

## One piece into `parent`, positions as given (the parent lifts it onto the table top).
func _piece(parent: Node3D, piece: Array, mat: Material, joint: Material) -> void:
	if piece[0] == "ell":
		_ball(parent, mat, piece[1], piece[2])
		return
	var a: Vector3 = piece[1]
	var b: Vector3 = piece[2]
	var ra: float = piece[3]
	var rb: float = piece[4]
	var c := CylinderMesh.new()
	c.bottom_radius = ra
	c.top_radius = rb
	c.height = a.distance_to(b)
	c.radial_segments = 20
	c.rings = 3
	c.cap_top = false
	c.cap_bottom = false
	var y := (b - a).normalized()
	var z := y.cross(Vector3.UP).normalized()
	var mi := MeshInstance3D.new()
	mi.mesh = c
	mi.material_override = mat
	parent.add_child(mi)
	mi.transform = Transform3D(Basis(y.cross(z), y, z), (a + b) / 2)
	_ball(parent, joint, a, Vector3.ONE * ra)
	_ball(parent, joint, b, Vector3.ONE * rb)

func _part(slot: String) -> void:
	if ball == null:
		ball = SphereMesh.new()
		ball.radius = 1.0
		ball.height = 2.0
		ball.radial_segments = 28
		ball.rings = 14
	var body := Node3D.new()
	body.position.y = TOP
	add_child(body)
	# Empty: the part's outline, the same pieces pressed almost flat into the steel.
	var ghost := Node3D.new()
	ghost.position.y = TOP + 0.0003
	ghost.scale = Vector3(1, 0.04, 1)
	add_child(ghost)
	var etch := StandardMaterial3D.new()
	etch.albedo_color = Color("#2c2e30")
	etch.metallic = 0.6
	etch.roughness = 0.7
	var mats: Array[ShaderMaterial] = []
	var joint := ShaderMaterial.new()
	joint.shader = flesh
	joint.set_shader_parameter("stitch", 0.0)
	mats.append(joint)
	for piece: Array in BODY[slot]:
		var m := ShaderMaterial.new()
		m.shader = flesh
		m.set_shader_parameter("stitch", 1.0 if piece[piece.size() - 1] else 0.0)
		mats.append(m)
		_piece(body, piece, m, joint)
		_piece(ghost, piece, etch, etch)
	for m in mats:
		m.set_shader_parameter("seed", float(slot.hash() % 97))
	for g in ghost.get_children():
		(g as MeshInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parts[slot] = {"body": body, "ghost": ghost, "mats": mats}

## Show one part as "", "muscle", "skin" or "alive". A new or changed part settles onto the table with a little bounce.
func set_part(slot: String, look: String, animate := true) -> void:
	if looks.get(slot, "") == look:
		return
	var was: String = looks.get(slot, "")
	looks[slot] = look
	var p: Dictionary = parts[slot]
	var body: Node3D = p.body
	body.visible = look != ""
	(p.ghost as Node3D).visible = look == ""
	var state := {"muscle": 0, "skin": 1, "alive": 2}.get(look, 0) as int
	for m: ShaderMaterial in p.mats:
		m.set_shader_parameter("state", state)
	if look == "alive" and was != "alive":
		surge = 0.8
	if animate and look != "" and is_inside_tree():
		body.position.y = TOP + 0.012
		body.scale = Vector3.ONE * 0.92
		var tw := create_tween().set_parallel()
		tw.tween_property(body, "position:y", TOP, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## From the rules' table: slot -> null or {side: "muscle"|"skin", alive: bool}.
func show_table(table: Dictionary) -> void:
	for slot: String in BODY:
		var t = table.get(slot)
		set_part(slot, "" if t == null else "alive" if t.alive else String(t.side))


# ---------------------------------------------------------------- sparks

func _process(delta: float) -> void:
	var alive: Array[String] = []
	for slot: String in looks:
		if looks[slot] == "alive":
			alive.append(slot)
	surge = maxf(0.0, surge - delta)
	glow.light_energy = 0.0 if alive.is_empty() else (0.008 + 0.004 * alive.size()) * (0.7 + 0.3 * sin(Time.get_ticks_msec() * 0.008) + randf_range(-0.15, 0.15)) + surge * 0.04
	t_arc -= delta
	if t_arc > 0.0:
		return
	t_arc = ARC_EVERY
	arc_mesh.clear_surfaces()
	if alive.is_empty():
		return
	var n := 0
	arc_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	for slot in alive:
		var tries := 1 + (2 if surge > 0.0 else 0)
		for i in tries:
			if randf() > 0.45 and surge <= 0.0:
				continue
			var piece: Array = BODY[slot][randi() % 2]
			var a := _on_part(piece)
			# Half the sparks jump to the steel, half crawl over the part.
			var b := _on_part(piece) if randf() < 0.5 else Vector3(a.x + randf_range(-0.02, 0.02), TOP + 0.001, signf(a.z if absf(a.z) > 0.001 else 1.0) * (WID / 2 - 0.004))
			_bolt(a, b)
			n += 1
	if n == 0:
		arc_mesh.surface_add_vertex(Vector3.ZERO)
		arc_mesh.surface_add_vertex(Vector3.ZERO)
	arc_mesh.surface_end()

func _on_part(piece: Array) -> Vector3:
	var d := Vector3(randf_range(-1, 1), randf_range(0.2, 1), randf_range(-1, 1)).normalized()
	if piece[0] == "ell":
		return piece[1] + Vector3(0, TOP, 0) + d * (piece[2] as Vector3) * 1.05
	var t := randf()
	return (piece[1] as Vector3).lerp(piece[2], t) + Vector3(0, TOP, 0) + d * lerpf(piece[3], piece[4], t) * 1.1

func _bolt(a: Vector3, b: Vector3) -> void:
	var steps := 6
	var prev := a
	var side := (b - a).cross(Vector3.UP).normalized()
	for i in range(1, steps + 1):
		var t := float(i) / steps
		var p := a.lerp(b, t)
		if i < steps:
			p += side * randf_range(-1, 1) * 0.004 + Vector3(0, randf_range(0, 0.005), 0)
		arc_mesh.surface_add_vertex(prev)
		arc_mesh.surface_add_vertex(p)
		prev = p
