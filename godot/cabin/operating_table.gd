class_name OperatingTable
extends Node3D
## Your operating table (D186): a small steel table on the cabin table with the companion lying on it, part by part.
## Each of the six parts (head, torso, armL, armR, legL, legR) is empty (a faint outline etched in the steel), muscle
## (raw red), skin (sewn-on sallow skin) or alive (the skin with a small blue eye over it, D192); a damaged part is washed red. The parts are low-poly models
## (D187, `art-pipeline/body_parts.py`, assets/cabin/body/<part>-<look>.glb); the table is built in code. Metres, the
## body's head toward local +x. `set_part(slot, look, damage)` with look "", "muscle", "skin" or "alive".

const TOP := 0.012                     # height of the top: a low slab on the wood, no legs (D192)
const LEN := 0.32
const WID := 0.13

## Each part: its model, where its joint end lies on the table top (metres, head toward +x), its turn outward in
## degrees, and whether it is mirrored (the models are of the left arm and leg; left is +z). Placed by the full-body
## concept's proportions (D188): she is 27 cm crown to sole, the crown at x 0.135; neck cut 0.17 of her height down,
## shoulders 0.21 down and 0.125 out, hips 0.52 down and 0.067 out; arms 8 and legs 4 degrees out, as she stands.
const BODY := {
	"head": ["head", Vector3(0.089, 0, 0), 0.0, false],
	"torso": ["torso", Vector3(0.089, 0, 0), 0.0, false],
	"armL": ["arm", Vector3(0.078, 0, 0.034), 8.0, false],
	"armR": ["arm", Vector3(0.078, 0, -0.034), -8.0, true],
	"legL": ["leg", Vector3(-0.005, 0, 0.018), 4.0, true],
	"legR": ["leg", Vector3(-0.005, 0, -0.018), -4.0, false],
}

var looks := {}                        # slot -> "", "muscle", "skin", "alive"
var damage := {}                       # slot -> damage on it (0 or 1)
var parts := {}                        # slot -> {body, muscle, skin, ghost: Node3D, eye: MeshInstance3D, overlay: ShaderMaterial}
var overlay_shader: Shader
var eye_mat: StandardMaterial3D
var pick: StaticBody3D


func _init() -> void:
	overlay_shader = load("res://cabin/part_overlay.gdshader")
	eye_mat = StandardMaterial3D.new()
	eye_mat.albedo_texture = _eye_texture()
	eye_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	eye_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_table()
	for slot: String in BODY:
		_part(slot)
		looks[slot] = ""
		parts[slot].body.visible = false


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
	# The top: a solid steel slab lying on the wood, a raised lip all round, a drain at the foot.
	_add(_boxm(Vector3(LEN, TOP, WID)), steel, Vector3(0, TOP / 2, 0))
	for s: float in [-1.0, 1.0]:
		_add(_boxm(Vector3(LEN, 0.006, 0.004)), steel, Vector3(0, TOP + 0.002, s * (WID / 2 - 0.002)))
		_add(_boxm(Vector3(0.004, 0.006, WID)), steel, Vector3(s * (LEN / 2 - 0.002), TOP + 0.002, 0))
	_add(_cylm(0.006, 0.001, 16), _steel(Color("#1a1a1a"), 0.6), Vector3(-LEN / 2 + 0.014, TOP + 0.0005, 0))
	# A curved headrest.
	var rest := _add(_cylm(0.012, 0.05, 16), dark, Vector3(LEN / 2 - 0.013, TOP + 0.002, 0))
	rest.rotation_degrees.x = 90
	rest.scale = Vector3(1, 1, 0.35)
	# Leather straps with brass buckles across the wrists and ankles hang off the sides.
	var leather := StandardMaterial3D.new()
	leather.albedo_color = Color("#3b2618")
	leather.roughness = 0.8
	var brass := _steel(Color("#a07c3a"), 0.35)
	for x: float in [-0.12, 0.0]:
		for s: float in [-1.0, 1.0]:
			_add(_boxm(Vector3(0.008, 0.001, 0.02)), leather, Vector3(x, TOP + 0.0055, s * (WID / 2 - 0.004)))
			_add(_boxm(Vector3(0.008, TOP, 0.0012)), leather, Vector3(x, TOP / 2, s * (WID / 2 + 0.0008)))
			_add(_boxm(Vector3(0.01, 0.006, 0.0015)), brass, Vector3(x, TOP / 2, s * (WID / 2 + 0.0015)))
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
	var turn: float = BODY[slot][2]
	var mirror: bool = BODY[slot][3]
	var body := Node3D.new()
	body.position = at + Vector3(0, TOP, 0)
	body.rotation_degrees.y = turn
	if mirror:
		body.scale.z = -1
	add_child(body)
	var muscle := _model("muscle", kind, body)
	var skin := _model("skin", kind, body)
	# Empty: the skin model pressed almost flat into the steel, dark, as an outline of where the part goes.
	var ghost := Node3D.new()
	ghost.position = at + Vector3(0, TOP + 0.0003, 0)
	ghost.rotation_degrees.y = turn
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
	# Alive (D192): a small blue eye lying flat just over the middle of the part, across the table.
	var box := AABB()
	var first := true
	for mi in _meshes(skin):
		var b: AABB = mi.transform * mi.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	box = body.transform * box
	var quad := QuadMesh.new()
	quad.size = Vector2(0.026, 0.013)
	var eye := MeshInstance3D.new()
	eye.mesh = quad
	eye.material_override = eye_mat
	eye.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	eye.rotation_degrees = Vector3(-90, 90, 0)
	var c := box.get_center()
	eye.position = Vector3(c.x, box.end.y + 0.004, c.z)
	eye.visible = false
	add_child(eye)
	var overlay := ShaderMaterial.new()
	overlay.shader = overlay_shader
	overlay.set_shader_parameter("seed", float(slot.hash() % 97))
	parts[slot] = {"body": body, "muscle": muscle, "skin": skin, "ghost": ghost, "eye": eye, "overlay": overlay}

## Show one part as "", "muscle", "skin" or "alive" (an eye over it), with damage (0 or 1) washing it red. A new or changed part
## settles onto the table with a little bounce.
func set_part(slot: String, look: String, dmg := 0, animate := true) -> void:
	var p: Dictionary = parts[slot]
	var overlay: ShaderMaterial = p.overlay
	damage[slot] = dmg
	overlay.set_shader_parameter("alive", 0.0)
	overlay.set_shader_parameter("damaged", 1.0 if dmg > 0 and look != "" else 0.0)
	(p.eye as MeshInstance3D).visible = look == "alive"
	var on := dmg > 0 and look != ""
	for model: Node3D in [p.muscle, p.skin]:
		for mi in _meshes(model):
			mi.material_overlay = overlay if on else null
	if looks.get(slot, "") == look:
		return
	var was: String = looks.get(slot, "")
	looks[slot] = look
	var body: Node3D = p.body
	body.visible = look != ""
	(p.ghost as Node3D).visible = look == ""
	(p.muscle as Node3D).visible = look == "muscle"
	(p.skin as Node3D).visible = look == "skin" or look == "alive"
	if animate and look != "" and is_inside_tree():
		var full := body.scale
		body.position.y = TOP + 0.012
		body.scale = full * 0.92
		var tw := create_tween().set_parallel()
		tw.tween_property(body, "position:y", TOP, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tw.tween_property(body, "scale", full, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

## From the rules' table: slot -> null or {side: "muscle"|"skin", alive: bool, dmg: int}.
func show_table(table: Dictionary) -> void:
	for slot: String in BODY:
		var t = table.get(slot)
		set_part(slot, "" if t == null else "alive" if t.alive else String(t.side), 0 if t == null else int(t.get("dmg", 0)))


# ---------------------------------------------------------------- the eye

## A plain eye drawn in code: an almond outline, a blue iris and a dark pupil, on clear ground.
static func _eye_texture() -> ImageTexture:
	var w := 128
	var h := 64
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	var blue := Color("#8fbcff")
	var white := Color("#e8f0ff")
	var dark := Color("#0e1630")
	for y in h:
		for x in w:
			var u := (x + 0.5) / w * 2.0 - 1.0
			var v := (y + 0.5) / h * 2.0 - 1.0
			var lid := 0.92 * (1.0 - u * u)          # the almond's half height at u
			var c := Color(0, 0, 0, 0)
			if absf(v) < lid:
				c = white
				var r := Vector2(u * 2.0, v).length()   # round in pixels: u spans twice as many
				if r < 0.62:
					c = blue
				if r < 0.26:
					c = dark
				if absf(v) > lid - 0.16:
					c = blue
			img.set_pixel(x, y, c)
	img.generate_mipmaps()
	return ImageTexture.create_from_image(img)
