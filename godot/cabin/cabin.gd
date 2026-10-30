extends Node3D
## The cabin (D177): the game as a map on a wooden table in a dark room, lit by two candles, after Inscryption.
## The landmarks are carved miniatures standing on the map.
## Hover a landmark to lift it and read its tag; click it to lean in and send your pawn there; right-click or Esc to
## sit back. `-- --shot` saves tests/cabin-1..3.png and quits.

const MAP := 1.0                       # the map is 1 m across: board percent 0..100
const PLACES := Town.PLACES            # names, colours and facings, shared with the town
const RING := 0.043                    # the inked circles on the drawn map: 44 px of 1024, in metres (D179)
## Where each landmark's circle is on the drawn map, in map percent (D179, measured from map.png).
const SPOTS := {
	"square": Vector2(10.4, 10.2), "cemetery": Vector2(13.9, 27.3), "church": Vector2(12.2, 59.2),
	"odeon": Vector2(15.7, 83.7), "market": Vector2(28.3, 66.9), "docks": Vector2(51.0, 68.4),
	"hospital": Vector2(47.3, 32.6), "slaughter": Vector2(66.4, 22.8), "first": Vector2(91.3, 11.3),
	"academy": Vector2(89.3, 37.4), "morgue": Vector2(82.7, 59.3), "alley": Vector2(90.0, 82.9),
}
const SIT := Vector3(0, 0.92, 0.78)    # your eyes, high over the south edge: a steeper look down, the map fills the screen (D178)
const LOOK := Vector3(0, 0, 0.03)      # the map's middle, a little north

var cam: Camera3D
var minis := {}                        # id -> {node, base_y, body}
var village: Node3D                    # the houses and trees (D180), folded flat until the intro
var hovered := ""
var leaning := ""
var pawn: Node3D
var pawn_at := Vector3(0.12, 0, 0.58)  # on the table, before the map
var candles := []                      # [OmniLight3D, flame MeshInstance3D, base energy, seed, lit 0..1]
var tag: PanelContainer
var tag_label: Label
var cam_from := Transform3D()
var cam_to := Transform3D()
var cam_t := 1.0
var t_total := 0.0
var intro_done := false
var font: Font
var shot_mode := false


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--size="):
			var wh := a.substr(7).split("x")
			DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	get_viewport().msaa_3d = Viewport.MSAA_4X
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	_environment()
	_table()
	_map()
	_miniatures()
	_village()
	_pawn()
	_props()
	_tag()
	_vignette()
	cam = Camera3D.new()
	cam.fov = 50
	cam.near = 0.02
	cam.far = 30
	add_child(cam)
	cam.transform = _seat_view().translated(Vector3(0, 0.12, 0.25))
	cam_from = cam.transform
	cam_to = _seat_view()
	cam_t = 0.0
	_intro()
	if "--shot" in OS.get_cmdline_user_args():
		shot_mode = true
		_shots()


# ---------------------------------------------------------------- the room

func _environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#050404")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#2a2420")
	env.ambient_light_energy = 0.05
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 0.85
	env.glow_enabled = true
	env.glow_intensity = 0.9
	env.glow_bloom = 0.05
	env.glow_hdr_threshold = 1.0
	env.ssao_enabled = true
	env.ssao_radius = 0.08
	env.ssao_intensity = 2.0
	# A faint haze in the candle light.
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.05
	env.volumetric_fog_albedo = Color("#c9a27a")
	env.volumetric_fog_emission_energy = 0.0
	env.volumetric_fog_length = 6.0
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.85
	env.adjustment_contrast = 1.08
	we.environment = env
	add_child(we)

func _tex_mat(path: String, uv: Vector3, rough := 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(path)
	m.uv1_scale = uv
	m.roughness = rough
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return m

func _col_mat(c: Color, rough := 0.8, metal := 0.0, emit := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	if emit > 0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = emit
	return m

func _mesh(mesh: Mesh, mat: Material, pos: Vector3, parent: Node3D = null) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	(parent if parent != null else self).add_child(mi)
	return mi

func _box(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b

func _cyl(r_top: float, r_bot: float, h: float, seg := 24) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = seg
	return c

func _sphere(r: float, h := -1.0) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2 if h < 0 else h
	s.radial_segments = 16
	s.rings = 8
	return s

func _table() -> void:
	var top := _mesh(_box(Vector3(2.8, 0.07, 1.8)), _tex_mat("res://assets/cabin/wood.png", Vector3(2.4, 1.6, 1)), Vector3(0, -0.035, -0.1))
	top.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# The floor far below and the room's back wall, just enough to catch the last of the light.
	_mesh(_box(Vector3(12, 0.1, 12)), _col_mat(Color("#0d0b0a"), 1.0), Vector3(0, -0.8, 0))
	_mesh(_box(Vector3(12, 6, 0.1)), _col_mat(Color("#050403"), 1.0), Vector3(0, 1.5, -3.4))

func _map() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(MAP, MAP)
	var m := _tex_mat("res://assets/cabin/map.png", Vector3(1, 1, 1), 0.95)
	_mesh(plane, m, Vector3(0, 0.001, 0))

## Board percent to a point on the map, in metres on the table.
func on_map(b: Vector2) -> Vector3:
	return Vector3((b.x / 100.0 - 0.5) * MAP, 0.0, (b.y / 100.0 - 0.5) * MAP)


# ---------------------------------------------------------------- the miniatures

func _miniatures() -> void:
	var base_mat := _col_mat(Color("#3a2a1e"), 0.7)
	for id: String in PLACES:
		var path := "res://assets/cabin/%s.glb" % id
		if not ResourceLoader.exists(path):
			continue
		var holder := Node3D.new()
		holder.position = on_map(SPOTS[id])
		holder.rotation.y = -float(PLACES[id].ang)
		add_child(holder)
		var model := (load(path) as PackedScene).instantiate() as Node3D
		var box := _aabb(model)
		# The wooden base fills the inked circle, the ring just showing around it.
		var s := RING * 0.92 / 0.62 / maxf(box.size.x, box.size.z)
		model.scale = Vector3.ONE * s
		model.position = Vector3(0, 0.006, 0)
		holder.add_child(model)
		var r := maxf(box.size.x, box.size.z) * s * 0.62
		var base := _mesh(_cyl(r, r * 1.04, 0.006, 32), base_mat, Vector3(0, 0.003, 0), holder)
		base.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		# A pick box, a little larger than the miniature.
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var bs := BoxShape3D.new()
		bs.size = Vector3(r * 2, box.size.y * s + 0.02, r * 2)
		shape.shape = bs
		shape.position = Vector3(0, bs.size.y / 2, 0)
		body.add_child(shape)
		body.set_meta("id", id)
		holder.add_child(body)
		holder.scale = Vector3(1, 0.001, 1)   # folded flat until the intro pops it up
		minis[id] = {"node": holder, "height": box.size.y * s}

## Houses and trees on the map (D180): white blocks with a pitched roof beside the roads, simple trees in the open.
## Positions come from `art-pipeline/village.py` (village.json, map percent). One MultiMesh per part.
func _village() -> void:
	village = Node3D.new()
	add_child(village)
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/cabin/village.json"))
	var walls: Array[Transform3D] = []
	var roofs: Array[Transform3D] = []
	for h: Dictionary in data.houses:
		var s := float(h.s)
		var w := 0.0135 * s                 # across the ridge
		var l := w * float(h.long)          # along the ridge
		var wall_h := 0.009 * s
		var roof_h := 0.0075 * s
		# The ridge runs along the road: local z turned to the road's direction on the map.
		var b := Basis(Vector3.UP, PI / 2 - float(h.ang))
		var at := on_map(Vector2(float(h.x), float(h.y)))
		walls.append(Transform3D(b * Basis.from_scale(Vector3(w, wall_h, l)), at + Vector3(0, wall_h / 2, 0)))
		roofs.append(Transform3D(b * Basis.from_scale(Vector3(w * 1.18, roof_h, l * 1.1)), at + Vector3(0, wall_h + roof_h / 2, 0)))
	var trunks: Array[Transform3D] = []
	var rounds: Array[Transform3D] = []
	var cones: Array[Transform3D] = []
	for t: Dictionary in data.trees:
		var s := float(t.s) * 1.45           # trees a little larger too
		var at := on_map(Vector2(float(t.x), float(t.y)))
		var b := Basis(Vector3.UP, randf() * TAU)
		trunks.append(Transform3D(b * Basis.from_scale(Vector3.ONE * s), at + Vector3(0, 0.003 * s, 0)))
		if t.kind == "cone":
			cones.append(Transform3D(b * Basis.from_scale(Vector3.ONE * s), at + Vector3(0, 0.0105 * s, 0)))
		else:
			rounds.append(Transform3D(b * Basis.from_scale(Vector3(1, 0.9, 1) * s), at + Vector3(0, 0.0095 * s, 0)))
	var prism := PrismMesh.new()
	prism.size = Vector3.ONE
	var canopy_mat := _col_mat(Color("#4d5638"), 0.9)
	_multi(_box(Vector3.ONE), _col_mat(Color("#e4dccb"), 0.85), walls)
	_multi(prism, _col_mat(Color("#5b4a3e"), 0.8), roofs)
	_multi(_cyl(0.0008, 0.0011, 0.006, 6), _col_mat(Color("#4a3424"), 0.9), trunks)
	_multi(_sphere(0.0048), canopy_mat, rounds)
	_multi(_cyl(0.0, 0.0045, 0.012, 8), canopy_mat, cones)
	village.scale = Vector3(1, 0.001, 1)   # folded flat until the intro

func _multi(mesh: Mesh, mat: Material, xs: Array[Transform3D]) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = xs.size()
	for i in xs.size():
		mm.set_instance_transform(i, xs[i])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	mi.material_override = mat
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	village.add_child(mi)

func _aabb(n: Node3D) -> AABB:
	var box := AABB()
	var first := true
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var mi := c as MeshInstance3D
		var b: AABB = mi.transform * mi.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return box


# ---------------------------------------------------------------- the pawn and the props

func _pawn() -> void:
	pawn = Node3D.new()
	add_child(pawn)
	var bone := _col_mat(Color("#d9cbb0"), 0.55)
	_mesh(_cyl(0.011, 0.016, 0.006), bone, Vector3(0, 0.003, 0), pawn)
	_mesh(_cyl(0.006, 0.011, 0.03), bone, Vector3(0, 0.021, 0), pawn)
	_mesh(_sphere(0.009), bone, Vector3(0, 0.043, 0), pawn)
	pawn.position = pawn_at

func _candle(pos: Vector3, h: float, energy: float) -> void:
	var wax := _col_mat(Color("#d8cdb4"), 0.6)
	_mesh(_cyl(0.05, 0.06, 0.012), _col_mat(Color("#5b4a2e"), 0.4, 0.6), pos + Vector3(0, 0.006, 0))   # brass dish
	_mesh(_cyl(0.022, 0.025, h), wax, pos + Vector3(0, 0.012 + h / 2, 0))
	_mesh(_cyl(0.026, 0.02, 0.02), wax, pos + Vector3(0.006, 0.012 + h - 0.03, 0.004))                  # a wax drip
	var flame := _mesh(_sphere(0.007, 0.026), _col_mat(Color("#ffc46b"), 0.5, 0.0, 9.0), pos + Vector3(0, 0.012 + h + 0.016, 0))
	flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var light := OmniLight3D.new()
	light.light_color = Color("#ffb060")
	light.light_energy = 0.0
	light.omni_range = 2.2
	light.omni_attenuation = 2.2
	light.shadow_enabled = true
	light.shadow_blur = 1.5
	light.shadow_bias = 0.004          # the pieces are centimetres tall: the default bias detaches their shadows
	light.shadow_normal_bias = 0.3
	light.light_volumetric_fog_energy = 1.5
	light.position = pos + Vector3(0, 0.012 + h + 0.03, 0)
	add_child(light)
	flame.scale = Vector3(0.01, 0.01, 0.01)
	candles.append([light, flame, energy, randf() * 100.0, 0.0])

func _props() -> void:
	_candle(Vector3(-0.68, 0, 0.18), 0.17, 0.55)
	_candle(Vector3(0.72, 0, -0.42), 0.24, 0.45)
	# A specimen jar: glass, a dark thing floating in it, a brass lid.
	var jar := Vector3(-0.72, 0, -0.38)
	var glass := _col_mat(Color(0.75, 0.82, 0.7, 0.22), 0.05, 0.0)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mesh(_cyl(0.065, 0.065, 0.18, 32), glass, jar + Vector3(0, 0.09, 0))
	var liquid := _col_mat(Color(0.45, 0.55, 0.3, 0.35), 0.1)
	liquid.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mesh(_cyl(0.06, 0.06, 0.14, 32), liquid, jar + Vector3(0, 0.075, 0))
	_mesh(_sphere(0.032, 0.05), _col_mat(Color("#5a2420"), 0.4), jar + Vector3(0, 0.08, 0)).rotation_degrees = Vector3(20, 0, 35)
	_mesh(_cyl(0.068, 0.068, 0.018, 32), _col_mat(Color("#5b4a2e"), 0.35, 0.7), jar + Vector3(0, 0.189, 0))
	# A brass bell.
	var bell := Vector3(0.62, 0, 0.36)
	var brass := _col_mat(Color("#8a6a32"), 0.3, 0.85)
	_mesh(_cyl(0.035, 0.045, 0.01), _col_mat(Color("#2a1d14"), 0.7), bell + Vector3(0, 0.005, 0))
	_mesh(_cyl(0.012, 0.038, 0.05), brass, bell + Vector3(0, 0.035, 0))
	_mesh(_sphere(0.012), brass, bell + Vector3(0, 0.066, 0))
	# A scrap of notes and a quill near your hand.
	var note := _mesh(_box(Vector3(0.16, 0.002, 0.11)), _col_mat(Color("#cbbf9f"), 0.95), Vector3(0.42, 0.001, 0.52))
	note.rotation_degrees.y = -12
	var quill := _mesh(_cyl(0.002, 0.004, 0.22, 6), _col_mat(Color("#e8e2d4"), 0.6), Vector3(0.5, 0.004, 0.5))
	quill.rotation_degrees = Vector3(0, 30, 88)

# ---------------------------------------------------------------- the paper tag

func _tag() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	tag = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("#d6c9a8")
	sb.border_color = Color("#3a2c1f")
	sb.set_border_width_all(1)
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 4
	sb.content_margin_bottom = 6
	sb.shadow_color = Color(0, 0, 0, 0.6)
	sb.shadow_size = 6
	tag.add_theme_stylebox_override("panel", sb)
	tag_label = Label.new()
	tag_label.add_theme_font_override("font", font)
	tag_label.add_theme_font_size_override("font_size", 22)
	tag_label.add_theme_color_override("font_color", Color("#2a1e14"))
	tag.add_child(tag_label)
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.modulate.a = 0.0
	layer.add_child(tag)

func _vignette() -> void:
	var layer := CanvasLayer.new()
	layer.layer = -1
	add_child(layer)
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture, filter_linear;
void fragment() {
	vec2 d = UV - vec2(0.5);
	float v = smoothstep(0.85, 0.25, length(d * vec2(1.25, 1.0)));
	COLOR = vec4(texture(screen, SCREEN_UV).rgb * mix(0.25, 1.0, v), 1.0);
}
"""
	var mat := ShaderMaterial.new()
	mat.shader = sh
	rect.material = mat
	# Drawn over the 3D view (layer 1), under the tag.
	layer.layer = 1
	tag.get_parent().layer = 2
	layer.add_child(rect)


# ---------------------------------------------------------------- animation

func _seat_view() -> Transform3D:
	return Transform3D(Basis(), SIT).looking_at(LOOK, Vector3.UP)

func _lean_view(id: String) -> Transform3D:
	var p := (minis[id].node as Node3D).position
	var eye := p + Vector3(0, 0.3, 0.32)
	return Transform3D(Basis(), eye).looking_at(p + Vector3(0, 0.02, 0), Vector3.UP)

func _move_camera(to: Transform3D) -> void:
	cam_from = cam.transform
	cam_to = to
	cam_t = 0.0

## Candles light one by one, then the landmarks spring up from the map.
func _intro() -> void:
	var tw := create_tween()
	for i in candles.size():
		var c: Array = candles[i]
		tw.tween_method(func(v: float) -> void: c[4] = v, 0.0, 1.0, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# The village rises with the candle light, before the landmarks.
	var vt := create_tween()
	vt.tween_interval(0.9)
	vt.tween_property(village, "scale", Vector3.ONE, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var order: Array = minis.keys()
	order.sort_custom(func(a: String, b: String) -> bool:
		return (minis[a].node as Node3D).position.z > (minis[b].node as Node3D).position.z)
	var delay := 0.0
	for id: String in order:
		var n: Node3D = minis[id].node
		var pt := create_tween()
		pt.tween_interval(1.2 + delay)
		pt.tween_property(n, "scale", Vector3.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		delay += 0.13
	var done := create_tween()
	done.tween_interval(1.2 + delay + 0.5)
	done.tween_callback(func() -> void: intro_done = true)

func _process(delta: float) -> void:
	t_total += delta
	# Candles: flicker, brighter as each flame finishes lighting.
	for c: Array in candles:
		var light: OmniLight3D = c[0]
		var flame: MeshInstance3D = c[1]
		var s: float = c[3]
		var lit: float = c[4]
		var f := 0.82 + 0.1 * sin(t_total * 7.3 + s) + 0.06 * sin(t_total * 13.1 + s * 2.0) + randf_range(-0.04, 0.04)
		light.light_energy = float(c[2]) * f * maxf(0.0, lit)
		flame.scale = Vector3(lit, lit * (0.8 + 0.25 * f), lit).max(Vector3.ONE * 0.01)
	# The camera: ease toward its goal, then breathe.
	if cam_t < 1.0:
		cam_t = minf(1.0, cam_t + delta / (2.6 if not intro_done and leaning == "" else 0.9))
	var k := cam_t * cam_t * (3.0 - 2.0 * cam_t)
	var tr := cam_from.interpolate_with(cam_to, k)
	tr.origin += Vector3(0, sin(t_total * 0.9) * 0.0025, sin(t_total * 0.6) * 0.002)
	cam.transform = tr
	if intro_done and not shot_mode:
		_update_hover()
	_place_tag()

func _update_hover() -> void:
	var mp := get_viewport().get_mouse_position()
	var from := cam.project_ray_origin(mp)
	var q := PhysicsRayQueryParameters3D.create(from, from + cam.project_ray_normal(mp) * 10.0)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	var id := ""
	if not hit.is_empty() and (hit.collider as Node).has_meta("id"):
		id = String((hit.collider as Node).get_meta("id"))
	set_hover(id)

## Lift a landmark a little, tilt it, show its tag; drop the last one.
func set_hover(id: String) -> void:
	if id == hovered:
		return
	if hovered != "":
		var old: Node3D = minis[hovered].node
		var tw := create_tween().set_parallel()
		tw.tween_property(old, "position:y", 0.0, 0.2)
		tw.tween_property(old, "rotation:z", 0.0, 0.2)
	hovered = id
	var fade := create_tween()
	fade.tween_property(tag, "modulate:a", 1.0 if id != "" else 0.0, 0.15)
	if id == "":
		return
	tag_label.text = String(PLACES[id].name)
	var n: Node3D = minis[id].node
	var tw2 := create_tween().set_parallel()
	tw2.tween_property(n, "position:y", 0.012, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw2.tween_property(n, "rotation:z", deg_to_rad(4.0), 0.18)

func _place_tag() -> void:
	if hovered == "":
		return
	var n: Node3D = minis[hovered].node
	var top := n.position + Vector3(0, float(minis[hovered].height) + 0.025, 0)
	var sp := cam.unproject_position(top)
	tag.position = sp - Vector2(tag.size.x / 2, tag.size.y + 6)
	tag.rotation = deg_to_rad(-2.0)

## Lean in over a landmark and hop the pawn onto it.
func go_to(id: String) -> void:
	leaning = id
	_move_camera(_lean_view(id))
	var n: Node3D = minis[id].node
	var r := 0.0
	for c in n.find_children("*", "MeshInstance3D", true, false):
		var cm := (c as MeshInstance3D).mesh
		if cm is CylinderMesh:
			r = (cm as CylinderMesh).bottom_radius
	var dest := n.position + Vector3(r + 0.018, 0, r * 0.4)
	var start := pawn.position
	var tw := create_tween()
	tw.tween_method(func(t: float) -> void:
		pawn.position = start.lerp(dest, t) + Vector3(0, sin(t * PI) * 0.09, 0)
		pawn.rotation.z = sin(t * TAU) * 0.25, 0.0, 1.0, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(pawn, "scale", Vector3(1.25, 0.7, 1.25), 0.06)
	tw.tween_property(pawn, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func sit_back() -> void:
	leaning = ""
	_move_camera(_seat_view())

func _unhandled_input(e: InputEvent) -> void:
	if not intro_done:
		return
	if e is InputEventMouseButton and e.pressed:
		if e.button_index == MOUSE_BUTTON_LEFT and hovered != "":
			go_to(hovered)
		elif e.button_index == MOUSE_BUTTON_RIGHT:
			sit_back()
	elif e is InputEventKey and e.pressed and e.keycode == KEY_ESCAPE:
		sit_back()


# ---------------------------------------------------------------- screenshots

func _save(path: String) -> void:
	for i in 8:
		await get_tree().process_frame
	RenderingServer.force_draw(false)   # the window may be behind others, when frames are not drawn on their own
	get_viewport().get_texture().get_image().save_png(path)
	print("saved ", path)

func _shots() -> void:
	await get_tree().create_timer(5.0).timeout
	print("CABIN fps %d, minis: %s" % [Engine.get_frames_per_second(), ", ".join(minis.keys().map(func(k: String) -> String: return "%s %.2f" % [k, (minis[k].node as Node3D).scale.y]))])
	await _save("res://../tests/cabin-1.png")
	if OS.get_environment("CABIN_TOP") != "":
		cam_t = 1.0
		cam_from = Transform3D(Basis(), Vector3(0, 1.6, 0.01)).looking_at(Vector3.ZERO, Vector3.UP)
		cam_to = cam_from
		await _save("res://../tests/cabin-top.png")
	set_hover("first")
	await get_tree().create_timer(0.5).timeout
	await _save("res://../tests/cabin-2.png")
	set_hover("")
	go_to("church")
	await get_tree().create_timer(1.6).timeout
	await _save("res://../tests/cabin-3.png")
	get_tree().quit()
