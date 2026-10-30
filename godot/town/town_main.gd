extends Node3D
## The city sandbox (D169): the town at dusk, an orbit camera, and a name over each landmark.
## Right-drag turns, middle-drag or WASD moves, the wheel zooms, F or Home frames every landmark again (the starting view).
## `-- --shot` saves views to tests/ and quits.

var town: Town
var cam_rig: Node3D
var cam: Camera3D
var target := Vector3(-40, 0, -80)
var yaw := deg_to_rad(0.0)
var pitch := deg_to_rad(-38.0)
var dist := 480.0
var turning := false
var panning := false
var label_layer: CanvasLayer
var label_nodes := []
var rain: GPUParticles3D
var env: Environment
var sun: DirectionalLight3D
var framed := true   # still on the starting view: a resized window frames the landmarks again
const RAIN := false   # the board is a dry night; the drizzle stays available


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
	print("TOWN built: %d houses (%d models), %d trees, %d ms" % [town.houses, town.model_houses, town.trees.size(), Time.get_ticks_msec() - t0])
	for l in town.lights:
		var o := OmniLight3D.new()
		o.light_color = l.col
		o.light_energy = l.energy
		o.omni_range = l.range
		o.position = l.pos
		add_child(o)
	_build_labels()
	_update_camera()
	get_viewport().size_changed.connect(func() -> void:
		if framed:
			_frame_landmarks.call_deferred())
	_frame_landmarks.call_deferred()
	if "--shot" in OS.get_cmdline_user_args():
		_shots()


func _build_world() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("#141a28")
	sm.sky_horizon_color = Color("#3e4658")
	sm.sky_curve = 0.18
	sm.ground_horizon_color = Color("#2d3340")
	sm.ground_bottom_color = Color("#141720")
	sm.sun_angle_max = 0.0
	sky.sky_material = sm
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 1.3
	env.reflected_light_source = Environment.REFLECTION_SOURCE_SKY
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.tonemap_exposure = 1.2
	env.glow_enabled = true
	env.glow_intensity = 0.7
	env.glow_hdr_threshold = 1.1
	env.ssao_enabled = true
	env.ssao_radius = 3.0
	env.ssao_intensity = 2.2
	# Wet streets: screen-space reflections of the lamps and windows.
	env.ssr_enabled = true
	env.ssr_max_steps = 48
	env.ssr_fade_in = 0.15
	env.ssr_fade_out = 2.0
	env.fog_enabled = not ("--nofog" in OS.get_cmdline_user_args())
	env.fog_mode = Environment.FOG_MODE_DEPTH
	env.fog_light_color = Color("#2a3140")
	env.fog_density = 1.0
	env.fog_depth_begin = 520.0
	env.fog_depth_end = 1600.0
	env.fog_depth_curve = 1.3
	env.adjustment_enabled = true
	env.adjustment_saturation = 0.72
	env.adjustment_contrast = 1.05
	we.environment = env
	add_child(we)
	# Moonlight: cool, from high up, with soft shadows.
	sun = DirectionalLight3D.new()
	sun.light_color = Color("#b9c4dc")
	sun.light_energy = 1.1
	sun.shadow_enabled = true
	sun.shadow_blur = 4.0
	sun.directional_shadow_max_distance = 1200.0
	sun.rotation_degrees = Vector3(-62, -30, 0)
	add_child(sun)
	cam_rig = Node3D.new()
	add_child(cam_rig)
	cam = Camera3D.new()
	cam.fov = 24
	cam.near = 2.0
	cam.far = 6000.0
	cam_rig.add_child(cam)
	if RAIN:
		_build_rain()


## A light drizzle: thin slanted streaks in a box that follows the camera's target.
func _build_rain() -> void:
	rain = GPUParticles3D.new()
	rain.amount = 6000
	rain.lifetime = 1.6
	rain.preprocess = 2.0
	rain.visibility_aabb = AABB(Vector3(-400, -60, -400), Vector3(800, 400, 800))
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(260, 2, 220)
	pm.direction = Vector3(0.15, -1, 0.05)
	pm.spread = 2.0
	pm.initial_velocity_min = 110.0
	pm.initial_velocity_max = 130.0
	pm.gravity = Vector3.ZERO
	rain.process_material = pm
	var streak := QuadMesh.new()
	streak.size = Vector2(0.04, 2.2)
	var rm := StandardMaterial3D.new()
	rm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	rm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	rm.albedo_color = Color(0.82, 0.86, 0.92, 0.16)
	rm.billboard_mode = BaseMaterial3D.BILLBOARD_FIXED_Y
	rm.cull_mode = BaseMaterial3D.CULL_DISABLED
	streak.material = rm
	rain.draw_pass_1 = streak
	add_child(rain)


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
		framed = false
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
	if rain != null:
		rain.position = target + Vector3(0, 150, 0)
	cam_rig.rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, dist)
	# The fog and the shadows follow the camera's distance, so the far view of the whole board stays clear.
	if env != null:
		env.fog_depth_begin = maxf(520.0, dist * 0.85)
		env.fog_depth_end = maxf(1600.0, dist * 2.4)
	if sun != null:
		sun.directional_shadow_max_distance = clampf(dist * 1.2, 1200.0, 2200.0)


## The starting view: every landmark and its name inside the window, whatever its size. Looks from the south at the
## usual pitch, centres the landmarks on screen, then takes the closest distance that still fits them all.
func _frame_landmarks() -> void:
	var pts: Array[Vector3] = []
	var mid := Vector3.ZERO
	for l in town.labels:
		var top: Vector3 = l.pos
		pts.append(top)
		pts.append(Vector3(top.x, 0, top.z))
		mid += Vector3(top.x, 0, top.z)
	mid /= town.labels.size()
	yaw = 0.0
	pitch = deg_to_rad(-38.0)
	target = mid
	var vp := get_viewport().get_visible_rect().size
	var margin := Vector2(110, 40)   # half a name label, plus a little air
	for pass_i in 3:
		var lo := 150.0
		var hi := 6000.0
		for it in 30:
			dist = (lo + hi) / 2
			_update_camera()
			if _all_inside(pts, vp, margin):
				hi = dist
			else:
				lo = dist
		dist = hi
		_update_camera()
		# Centre the landmarks on screen: move the target to the ground point under the middle of their screen box.
		var bmin := Vector2(INF, INF)
		var bmax := -bmin
		for p in pts:
			var sp := cam.unproject_position(p)
			bmin = bmin.min(sp)
			bmax = bmax.max(sp)
		var c := (bmin + bmax) / 2
		var o := cam.project_ray_origin(c)
		var n := cam.project_ray_normal(c)
		if absf(n.y) > 0.001:
			var hit := o + n * (-o.y / n.y)
			target = Vector3(hit.x, 0, hit.z)
	_update_camera()
	framed = true

func _all_inside(pts: Array[Vector3], vp: Vector2, margin: Vector2) -> bool:
	for p in pts:
		if cam.is_position_behind(p):
			return false
		var sp := cam.unproject_position(p)
		if sp.x < margin.x or sp.y < margin.y or sp.x > vp.x - margin.x or sp.y > vp.y - margin.y:
			return false
	return true


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and (e.keycode == KEY_F or e.keycode == KEY_HOME):
		_frame_landmarks()
		return
	if e is InputEventMouseButton or e is InputEventMouseMotion:
		if (e is InputEventMouseButton and e.pressed) or turning or panning:
			framed = false
	if e is InputEventMouseButton:
		if e.button_index == MOUSE_BUTTON_RIGHT:
			turning = e.pressed
		elif e.button_index == MOUSE_BUTTON_MIDDLE or e.button_index == MOUSE_BUTTON_LEFT:
			panning = e.pressed
		elif e.button_index == MOUSE_BUTTON_WHEEL_UP and e.pressed:
			dist = maxf(60.0, dist * 0.9)
			_update_camera()
		elif e.button_index == MOUSE_BUTTON_WHEEL_DOWN and e.pressed:
			dist = minf(4000.0, dist / 0.9)
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
	_frame_landmarks()
	await _save("res://../tests/town-1.png")   # the starting view: every landmark on screen
	print("TOWN starting view: distance %.0f m" % dist)
	var ms0 := Time.get_ticks_msec()
	for i in 60:
		await get_tree().process_frame
	print("TOWN %.1f fps over 60 frames (view 1)" % [60000.0 / maxf(1.0, Time.get_ticks_msec() - ms0)])
	_view(Vector3(-54, 0, -372), 10, -30, 260)
	await _save("res://../tests/town-2.png")
	_view(Vector3(36, 0, 360), -25, -30, 300)
	await _save("res://../tests/town-3.png")
	_view(Vector3(0, 0, 0), 0, -72, 1150)
	await _save("res://../tests/town-4.png")
	var spot := OS.get_environment("TOWN_SHOT_AT")   # a landmark id: a close view of it as town-5
	if spot != "":
		var p := Town.P(Town.PLACES[spot].pos)
		_view(Vector3(p.x, 0, p.y), 0, -30, 220)
		await _save("res://../tests/town-5.png")
	get_tree().quit()
