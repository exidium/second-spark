extends Node3D
## The city sandbox (D169): the town at dusk, an orbit camera, and a name over each landmark.
## Right-drag turns, middle-drag or WASD moves, the wheel zooms. `-- --shot` saves views to tests/ and quits.

var town: Town
var cam_rig: Node3D
var cam: Camera3D
var target := Vector3(0, 0, 10)
var yaw := deg_to_rad(18.0)
var pitch := deg_to_rad(-36.0)
var dist := 360.0
var turning := false
var panning := false
var label_layer: CanvasLayer
var label_nodes := []


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--size="):
			var wh := a.substr(7).split("x")
			DisplayServer.window_set_size(Vector2i(int(wh[0]), int(wh[1])))
	get_viewport().msaa_3d = Viewport.MSAA_4X
	_build_world()
	town = Town.new()
	var t0 := Time.get_ticks_msec()
	town.build(self)
	print("TOWN built: %d houses, %d trees, %d ms" % [town.houses, town.trees.size(), Time.get_ticks_msec() - t0])
	for l in town.lights:
		var o := OmniLight3D.new()
		o.light_color = l.col
		o.light_energy = l.energy
		o.omni_range = l.range
		o.position = l.pos
		add_child(o)
	_build_labels()
	_update_camera()
	if "--shot" in OS.get_cmdline_user_args():
		_shots()


func _build_world() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("#0b1222")
	sm.sky_horizon_color = Color("#4a3a44")
	sm.sky_curve = 0.12
	sm.ground_horizon_color = Color("#2a2430")
	sm.ground_bottom_color = Color("#0d0d12")
	sm.sun_angle_max = 0.0
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.65
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.05
	env.glow_enabled = true
	env.glow_intensity = 0.6
	env.glow_bloom = 0.05
	env.ssao_enabled = true
	env.ssao_radius = 2.5
	env.ssao_intensity = 2.0
	env.fog_enabled = true
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_light_color = Color("#2c2836")
	env.fog_density = 1.0
	env.fog_depth_begin = 420.0
	env.fog_depth_end = 1500.0
	env.fog_depth_curve = 1.4
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.92
	we.environment = env
	add_child(we)
	# Moonlight, cold and high, casting the shadows.
	var moon := DirectionalLight3D.new()
	moon.light_color = Color("#c4c9de")
	moon.light_energy = 1.05
	moon.shadow_enabled = true
	moon.directional_shadow_max_distance = 1100.0
	moon.rotation_degrees = Vector3(-42, -35, 0)
	add_child(moon)
	# The last of the sunset, low from the west, warm.
	var dusk := DirectionalLight3D.new()
	dusk.light_color = Color("#ff9a5c")
	dusk.light_energy = 0.45
	dusk.rotation_degrees = Vector3(-12, 100, 0)
	add_child(dusk)
	cam_rig = Node3D.new()
	add_child(cam_rig)
	cam = Camera3D.new()
	cam.fov = 34
	cam.near = 1.0
	cam.far = 6000.0
	cam_rig.add_child(cam)
	var ink := MeshInstance3D.new()
	var q := QuadMesh.new()
	q.size = Vector2(2, 2)
	ink.mesh = q
	var im := ShaderMaterial.new()
	im.shader = load("res://town/ink.gdshader")
	ink.material_override = im
	ink.extra_cull_margin = 16384
	ink.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	cam.add_child(ink)


func _build_labels() -> void:
	label_layer = CanvasLayer.new()
	add_child(label_layer)
	var font: Font = load("res://assets/fonts/Amarante-Regular.ttf")
	for l in town.labels:
		var pc := PanelContainer.new()
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0.05, 0.04, 0.06, 0.78)
		sb.border_color = Color(l.col, 0.7)
		sb.set_border_width_all(1)
		sb.content_margin_left = 8
		sb.content_margin_right = 8
		sb.content_margin_top = 1
		sb.content_margin_bottom = 2
		pc.add_theme_stylebox_override("panel", sb)
		var lab := Label.new()
		lab.text = l.text
		lab.add_theme_font_override("font", font)
		lab.add_theme_font_size_override("font_size", 18)
		lab.add_theme_color_override("font_color", l.col)
		pc.add_child(lab)
		pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label_layer.add_child(pc)
		label_nodes.append([l, pc])


func _process(delta: float) -> void:
	var mv := Vector3.ZERO
	if Input.is_key_pressed(KEY_W): mv.z -= 1
	if Input.is_key_pressed(KEY_S): mv.z += 1
	if Input.is_key_pressed(KEY_A): mv.x -= 1
	if Input.is_key_pressed(KEY_D): mv.x += 1
	if mv != Vector3.ZERO:
		target += mv.rotated(Vector3.UP, yaw).normalized() * dist * 0.8 * delta
		_update_camera()
	for pair in label_nodes:
		var l: Dictionary = pair[0]
		var pc: Control = pair[1]
		var behind := cam.is_position_behind(l.pos)
		pc.visible = not behind
		if not behind:
			var sp := cam.unproject_position(l.pos)
			pc.position = sp - pc.size / 2


func _update_camera() -> void:
	cam_rig.position = target
	cam_rig.rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, dist)


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_RIGHT:
			turning = e.pressed
		elif e.button_index == MOUSE_BUTTON_MIDDLE or e.button_index == MOUSE_BUTTON_LEFT:
			panning = e.pressed
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			dist = maxf(25.0, dist * 0.9)
			_update_camera()
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			dist = minf(1400.0, dist / 0.9)
			_update_camera()
	elif e is InputEventMouseMotion:
		if turning:
			yaw -= e.relative.x * 0.005
			pitch = clampf(pitch - e.relative.y * 0.005, deg_to_rad(-88.0), deg_to_rad(-8.0))
			_update_camera()
		elif panning:
			var r := Vector3(-e.relative.x, 0, -e.relative.y) * dist * 0.0018
			target += r.rotated(Vector3.UP, yaw)
			_update_camera()


func _view(t: Vector3, y: float, p: float, d: float) -> void:
	target = t
	yaw = deg_to_rad(y)
	pitch = deg_to_rad(p)
	dist = d
	_update_camera()


func _save(path: String) -> void:
	for i in 6:
		await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png(path)
	print("saved ", path)


func _shots() -> void:
	await get_tree().create_timer(1.0).timeout
	await _save("res://../tests/town-1.png")
	_view(Vector3(10, 0, -30), 30, -30, 170)
	await _save("res://../tests/town-2.png")
	_view(Vector3(10, 0, 160), -20, -28, 150)
	await _save("res://../tests/town-3.png")
	_view(Vector3(0, 0, 0), 0, -62, 760)
	await _save("res://../tests/town-4.png")
	get_tree().quit()
