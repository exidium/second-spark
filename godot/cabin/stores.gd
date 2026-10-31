class_name Stores
extends Node3D
## What keeps without rotting (D190), in front of the decomposition tray: a brine jar of preserved flesh (left) and a
## wooden bone box (right), each with a paper tag. One piece or one bone per unit, so they count by eye.
## `show_stores(preserved, bone)` takes the rules' `p.preserved` and `p.bone` (bone caps at 12).

const JAR_AT := Vector3(-0.055, 0, 0)
const BOX_AT := Vector3(0.06, 0, 0)
const JAR_R := 0.03
const JAR_H := 0.078
const BOX := Vector3(0.1, 0.016, 0.065)   # outside, x by height by z
const BOARD := 0.004

var jar_pieces: Node3D
var bones: Node3D
var shown_pres := -1
var shown_bone := -1
var font: Font
var bone_mesh: Mesh
var bone_mat: StandardMaterial3D
var pres_mat: ShaderMaterial
var lump: Array = []


func _init() -> void:
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	_jar()
	_box()
	bone_mesh = _bone_mesh()
	bone_mat = StandardMaterial3D.new()
	bone_mat.albedo_color = Color("#eee6d0")
	bone_mat.roughness = 0.55
	pres_mat = DecayTray.piece_mat("muscle", 0.0)
	pres_mat.set_shader_parameter("fresh", Color("#a88272"))
	pres_mat.set_shader_parameter("kind", 4)
	for k in 3:
		var s := SphereMesh.new()
		s.radius = 0.0042
		s.height = 0.0058
		s.radial_segments = 10
		s.rings = 6
		lump.append(DecayTray.lumpy(s, 0.0016, 40 + k, 260.0))


func _mat(c: Color, rough := 0.6, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	return m

func _mesh(mesh: Mesh, mat: Material, pos: Vector3, parent: Node3D = self) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	parent.add_child(mi)
	return mi

func _cyl(r: float, h: float, seg := 28) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = h
	c.radial_segments = seg
	return c

func _tag(text: String, pos: Vector3, turn: float) -> void:
	var paper := BoxMesh.new()
	paper.size = Vector3(0.012 + text.length() * 0.0062, 0.0006, 0.014)
	var p := _mesh(paper, _mat(Color("#cbbf9f"), 0.95), pos)
	p.rotation_degrees.y = turn
	var l := Label3D.new()
	l.text = text
	l.font = font
	l.font_size = 40
	l.pixel_size = 0.00018
	l.modulate = Color("#2a1d14")
	l.shaded = true
	l.rotation_degrees = Vector3(-90, turn, 0)
	l.position = pos + Vector3(0, 0.0005, 0)
	add_child(l)

## A brine jar: the liquid tinted and see-through, a cork and a string round the neck.
func _jar() -> void:
	var brine := _mat(Color(0.62, 0.66, 0.42, 0.38), 0.05)
	brine.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	brine.rim_enabled = true
	brine.rim = 0.7
	brine.rim_tint = 0.3
	brine.specular_mode = BaseMaterial3D.SPECULAR_SCHLICK_GGX
	var body := _mesh(_cyl(JAR_R, JAR_H), brine, JAR_AT + Vector3(0, JAR_H / 2, 0))
	body.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# the cork lets the candle light into the brine: no shadow
	for c: Array in [[_cyl(JAR_R * 0.72, 0.016), "#8a6a48", 0.007], [_cyl(JAR_R * 0.76, 0.003), "#6b5a3e", 0.001]]:
		var cork := _mesh(c[0], _mat(Color(c[1]), 0.9), JAR_AT + Vector3(0, JAR_H + c[2], 0))
		cork.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	jar_pieces = Node3D.new()
	jar_pieces.position = JAR_AT
	add_child(jar_pieces)
	_tag("PRESERVED", JAR_AT + Vector3(0, 0.0003, JAR_R + 0.016), 0)

## An open box of dark boards for the bones.
func _box() -> void:
	var wood := _mat(Color("#4a3322"), 0.85)
	_mesh(_boxm(Vector3(BOX.x, BOARD, BOX.z)), wood, BOX_AT + Vector3(0, BOARD / 2, 0))
	for s: float in [-1.0, 1.0]:
		_mesh(_boxm(Vector3(BOX.x, BOX.y, BOARD)), wood, BOX_AT + Vector3(0, BOX.y / 2, s * (BOX.z - BOARD) / 2))
		_mesh(_boxm(Vector3(BOARD, BOX.y, BOX.z)), wood, BOX_AT + Vector3(s * (BOX.x - BOARD) / 2, BOX.y / 2, 0))
	bones = Node3D.new()
	bones.position = BOX_AT + Vector3(0, BOARD, 0)
	add_child(bones)
	_tag("BONE", BOX_AT + Vector3(0, 0.0003, BOX.z / 2 + 0.014), 0)

func _boxm(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b

## A long bone along x: a shaft with a knuckle of two knobs at each end.
func _bone_mesh() -> Mesh:
	var st := SurfaceTool.new()
	var shaft := CylinderMesh.new()
	shaft.top_radius = 0.0017
	shaft.bottom_radius = 0.0017
	shaft.height = 0.024
	shaft.radial_segments = 8
	shaft.rings = 1
	st.append_from(shaft, 0, Transform3D(Basis(Vector3.BACK, PI / 2), Vector3.ZERO))
	var knob := SphereMesh.new()
	knob.radius = 0.0024
	knob.height = 0.0048
	knob.radial_segments = 8
	knob.rings = 4
	for x: float in [-0.012, 0.012]:
		for z: float in [-0.0016, 0.0016]:
			st.append_from(knob, 0, Transform3D(Basis(), Vector3(x, 0, z)))
	return st.commit()

## From the rules: preserved flesh floats in the jar, bones lie in the box, six to a layer.
func show_stores(preserved: int, bone: int) -> void:
	preserved = mini(preserved, 12)
	bone = mini(bone, 12)
	if preserved != shown_pres:
		shown_pres = preserved
		for c in jar_pieces.get_children():
			c.queue_free()
		for i in preserved:
			var rng := RandomNumberGenerator.new()
			rng.seed = ("pres:%d" % i).hash()
			var a := i * 2.4
			var r := (JAR_R - 0.009) * sqrt((i % 4 + 0.5) / 4.0)
			var mi := _mesh(lump[i % 3], pres_mat, Vector3(cos(a) * r, 0.008 + i * 0.0055 + rng.randf_range(-0.001, 0.001), sin(a) * r), jar_pieces)
			mi.set_instance_shader_parameter("seed", 60.0 + i)
			mi.rotation = Vector3(rng.randf_range(-1, 1), rng.randf_range(0, TAU), rng.randf_range(-1, 1))
			mi.scale = Vector3.ONE * 1.3
	if bone != shown_bone:
		var was := maxi(shown_bone, 0)
		shown_bone = bone
		for c in bones.get_children():
			c.queue_free()
		for i in bone:
			var rng := RandomNumberGenerator.new()
			rng.seed = ("bone:%d" % i).hash()
			var layer := i / 6
			var k := i % 6
			var mi := _mesh(bone_mesh, bone_mat, Vector3(rng.randf_range(-0.012, 0.012), 0.0025 + layer * 0.0045, -0.024 + k * 0.0096), bones)
			mi.rotation = Vector3(rng.randf_range(-0.08, 0.08), rng.randf_range(-0.25, 0.25) + (PI if rng.randf() < 0.5 else 0.0), 0)
			mi.scale = Vector3.ONE * (1.25 + rng.randf_range(-0.12, 0.12))
			if i >= was and is_inside_tree():
				var y := mi.position.y
				mi.position.y = y + 0.04
				create_tween().tween_property(mi, "position:y", y, 0.35).set_delay(0.05 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
