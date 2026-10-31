class_name OperatingTable
extends Node3D
## Your operating table (D186): a small steel table on the cabin table with the companion lying on it, part by part.
## Each of the six parts (head, torso, armL, armR, legL, legR) is empty (a faint outline etched in the steel), muscle
## (raw red), skin (sewn-on sallow skin) or alive (the skin with blue veins and sparks). The parts are low-poly models
## (D187, `art-pipeline/body_parts.py`, assets/cabin/body/<part>-<look>.glb); the table is built in code. Metres, the
## body's head toward local +x. `set_part(slot, look)` with look "", "muscle", "skin" or "alive".

const TOP := 0.075                     # height of the table top
const LEN := 0.32
const WID := 0.13
const ARC_EVERY := 0.06                # seconds between new sparks

## Each part: its model, where its joint end lies on the table top (metres, head toward +x), and whether it is
## mirrored (the models are of the left arm and leg; left is +z).
const BODY := {
	"head": ["head", Vector3(0.083, 0, 0), false],
	"torso": ["torso", Vector3(0.088, 0, 0), false],
	"armL": ["arm", Vector3(0.076, 0, 0.041), false],
	"armR": ["arm", Vector3(0.076, 0, -0.041), true],
	"legL": ["leg", Vector3(-0.016, 0, 0.016), false],
	"legR": ["leg", Vector3(-0.016, 0, -0.016), true],
}

var looks := {}                        # slot -> "", "muscle", "skin", "alive"
var parts := {}                        # slot -> {body, muscle, skin, ghost: Node3D, box: AABB}
var arcs: MeshInstance3D
var arc_mesh := ImmediateMesh.new()
var glow: OmniLight3D
var t_arc := 0.0
var surge := 0.0                       # extra sparks for a moment after a part comes alive
var alive_mat: ShaderMaterial
var pick: StaticBody3D


func _init() -> void:
	alive_mat = ShaderMaterial.new()
	alive_mat.shader = load("res://cabin/alive.gdshader")
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

func _model(look: String, kind: String, parent: Node3D) -> Node3D:
	var n := (load("res://assets/cabin/body/%s-%s.glb" % [kind, look]) as PackedScene).instantiate() as Node3D
	parent.add_child(n)
	return n

func _meshes(n: Node) -> Array[MeshInstance3D]:
	var out: Array[MeshInstance3D] = []
	for c in n.find_children("*", "MeshInstance3D", true, false):
		out.append(c as MeshInstance3D)
	return out

func _part(slot: String) -> void:
	var kind: String = BODY[slot][0]
	var at: Vector3 = BODY[slot][1]
	var mirror: bool = BODY[slot][2]
	var body := Node3D.new()
	body.position = at + Vector3(0, TOP, 0)
	if mirror:
		body.scale.z = -1
	add_child(body)
	var muscle := _model("muscle", kind, body)
	var skin := _model("skin", kind, body)
	# Empty: the skin model pressed almost flat into the steel, dark, as an outline of where the part goes.
	var ghost := Node3D.new()
	ghost.position = at + Vector3(0, TOP + 0.0003, 0)
	ghost.scale = Vector3(1, 0.03, -1 if mirror else 1)
	add_child(ghost)
	var etch := StandardMaterial3D.new()
	etch.albedo_color = Color("#2c2e30")
	etch.metallic = 0.6
	etch.roughness = 0.7
	var flat := _model("skin", kind, ghost)
	for mi in _meshes(flat):
		mi.material_override = etch
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Where sparks can start: the skin model's box, in table space.
	var box := AABB()
	var first := true
	for mi in _meshes(skin):
		var b: AABB = mi.transform * mi.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	box = body.transform * box
	parts[slot] = {"body": body, "muscle": muscle, "skin": skin, "ghost": ghost, "box": box}

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
	(p.muscle as Node3D).visible = look == "muscle"
	(p.skin as Node3D).visible = look == "skin" or look == "alive"
	for mi in _meshes(p.skin):
		mi.material_overlay = alive_mat if look == "alive" else null
	if look == "alive" and was != "alive":
		surge = 0.8
	if animate and look != "" and is_inside_tree():
		var full := body.scale
		body.position.y = TOP + 0.012
		body.scale = full * 0.92
		var tw := create_tween().set_parallel()
		tw.tween_property(body, "position:y", TOP, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "scale", full, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

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
			var box: AABB = parts[slot].box
			var a := _on_part(box)
			# Half the sparks jump to the steel, half crawl over the part.
			var b := _on_part(box) if randf() < 0.5 else Vector3(a.x + randf_range(-0.02, 0.02), TOP + 0.001, signf(a.z if absf(a.z) > 0.001 else 1.0) * (WID / 2 - 0.004))
			_bolt(a, b)
			n += 1
	if n == 0:
		arc_mesh.surface_add_vertex(Vector3.ZERO)
		arc_mesh.surface_add_vertex(Vector3.ZERO)
	arc_mesh.surface_end()

## A point on the upper skin of a part, roughly: inside its box, toward the top.
func _on_part(box: AABB) -> Vector3:
	var c := box.get_center()
	var h := box.size / 2
	return Vector3(c.x + randf_range(-0.9, 0.9) * h.x, box.position.y + box.size.y * randf_range(0.55, 1.0), c.z + randf_range(-0.6, 0.6) * h.z)

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
