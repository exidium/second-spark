extends Node3D
## Second Spark, Godot diorama: the painted Paris map as a 3D table, clickable places,
## 3D meeples that hop onto their slots, rivals that take turns, and night falling once
## everyone is placed. No full rules yet: only placement, scientist-only spaces and turns.

const BOARD_W := 16.0
const BOARD_H := 9.0

# Places, positions in % of the map, one entry per action space (true = scientist only).
# Mirrors LOCS and BOARD_POS in src/data.js.
const PLACES := [
	{"id": "cemetery", "name": "Graveyard", "x": 12, "y": 17, "sci": [false]},
	{"id": "square", "name": "Public Square", "x": 26, "y": 31, "sci": [false]},
	{"id": "slaughter", "name": "Slaughterhouse", "x": 55, "y": 15, "sci": [false]},
	{"id": "church", "name": "Saint-Roch", "x": 79, "y": 17, "sci": [false]},
	{"id": "market", "name": "Market", "x": 73, "y": 36, "sci": [false]},
	{"id": "first", "name": "First Player", "x": 48, "y": 45, "sci": [false]},
	{"id": "morgue", "name": "Morgue", "x": 62, "y": 55, "sci": [false]},
	{"id": "hospital", "name": "Hospital", "x": 20, "y": 64, "sci": [false, true, true]},
	{"id": "academy", "name": "Academy", "x": 45, "y": 75, "sci": [true, false, false, true]},
	{"id": "docks", "name": "Docks", "x": 70, "y": 69, "sci": [false]},
	{"id": "alley", "name": "Dark Alley", "x": 84, "y": 84, "sci": [true]},
]

const PLAYERS := [
	{"name": "You", "color": Color("#9fd0ff"), "ai": false},
	{"name": "Dr Ambrose Pell", "color": Color("#d6675f"), "ai": true},
	{"name": "Mme Odile Varnier", "color": Color("#74b393"), "ai": true},
	{"name": "Prof Horace Quill", "color": Color("#cda65c"), "ai": true},
]

var places := {}          # id -> {data, node, slots: [Vector3], occ: [meeple or null], marker}
var meeples := []         # all meeple nodes; meta: player, kind, home (Vector3), placed
var selected: Node3D = null
var turn := 0
var day := 1
var busy := false

var sun: DirectionalLight3D
var env: Environment
var lamps: Array[OmniLight3D] = []
var cam_rig: Node3D
var cam: Camera3D
var yaw := 0.0
var pitch := deg_to_rad(-58.0)
var dist := 14.5
var dragging := false

var hud_title: Label
var toast: PanelContainer
var toast_text: RichTextLabel


func _ready() -> void:
	_build_world()
	_build_table()
	_build_places()
	_build_meeples()
	_build_hud()
	_update_camera()
	_begin_turn()
	if "--shot" in OS.get_cmdline_user_args():
		_screenshot_run()


# ---------------------------------------------------------------- world

func _build_world() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0b0a0e")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#3a3446")
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.6
	we.environment = env
	add_child(we)

	sun = DirectionalLight3D.new()
	sun.light_color = Color("#f2d9a6")
	sun.light_energy = 1.25
	sun.shadow_enabled = true
	sun.rotation_degrees = Vector3(-55, 30, 0)
	add_child(sun)

	cam_rig = Node3D.new()
	add_child(cam_rig)
	cam = Camera3D.new()
	cam.fov = 40
	cam_rig.add_child(cam)


func _build_table() -> void:
	var wood := StandardMaterial3D.new()
	wood.albedo_color = Color("#3a2618")
	wood.roughness = 0.8
	var table := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(BOARD_W + 1.6, 0.7, BOARD_H + 1.6)
	table.mesh = box
	table.material_override = wood
	table.position = Vector3(0, -0.36, 0)
	add_child(table)

	var board := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(BOARD_W, BOARD_H)
	board.mesh = plane
	var mat := StandardMaterial3D.new()
	mat.albedo_texture = load("res://assets/board.jpg")
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	mat.roughness = 0.95
	board.material_override = mat
	board.position = Vector3(0, 0.002, 0)
	add_child(board)


func map_to_world(x: float, y: float) -> Vector3:
	return Vector3((x / 100.0 - 0.5) * BOARD_W, 0.0, (y / 100.0 - 0.5) * BOARD_H)


# ---------------------------------------------------------------- places

func _build_places() -> void:
	for d in PLACES:
		var root := Node3D.new()
		root.position = map_to_world(d.x, d.y)
		add_child(root)

		# A dark disc the place stands on, with a rim that glows when you can use it.
		var disc := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		var n: int = d.sci.size()
		cyl.top_radius = 0.32 + 0.12 * n
		cyl.bottom_radius = cyl.top_radius
		cyl.height = 0.05
		disc.mesh = cyl
		var dm := StandardMaterial3D.new()
		dm.albedo_color = Color(0.07, 0.06, 0.09, 0.85)
		dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		dm.emission_enabled = true
		dm.emission = Color("#9fd0ff")
		dm.emission_energy_multiplier = 0.0
		disc.material_override = dm
		disc.position.y = 0.03
		root.add_child(disc)

		var label := Label3D.new()
		label.text = d.name
		label.font_size = 56
		label.pixel_size = 0.0045
		label.outline_size = 14
		label.outline_modulate = Color(0, 0, 0, 0.9)
		label.modulate = Color("#ece0c6")
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.position = Vector3(0, 0.95, 0)
		root.add_child(label)

		# Slots in a row across the disc; each knows if it is scientist-only.
		var slots: Array[Vector3] = []
		for k in n:
			var off := (k - (n - 1) / 2.0) * 0.32
			slots.append(root.position + Vector3(off, 0.06, 0))
			var ring := MeshInstance3D.new()
			var tm := TorusMesh.new()
			tm.inner_radius = 0.09
			tm.outer_radius = 0.12
			ring.mesh = tm
			var rm := StandardMaterial3D.new()
			rm.albedo_color = Color("#c9a24a") if d.sci[k] else Color("#ece0c6")
			rm.emission_enabled = true
			rm.emission = rm.albedo_color
			rm.emission_energy_multiplier = 0.25
			ring.material_override = rm
			ring.position = Vector3(off, 0.065, 0)
			root.add_child(ring)

		# Click target.
		var area := Area3D.new()
		var shape := CollisionShape3D.new()
		var cs := CylinderShape3D.new()
		cs.radius = cyl.top_radius + 0.1
		cs.height = 1.2
		shape.shape = cs
		shape.position.y = 0.5
		area.add_child(shape)
		root.add_child(area)
		area.input_event.connect(_on_place_input.bind(d.id))

		# A small lantern that lights up at night.
		var lamp := OmniLight3D.new()
		lamp.light_color = Color("#ffb35a")
		lamp.light_energy = 0.0
		lamp.omni_range = 2.2
		lamp.position = Vector3(0, 0.8, 0)
		root.add_child(lamp)
		lamps.append(lamp)

		var occ := []
		occ.resize(n)
		places[d.id] = {"data": d, "slots": slots, "occ": occ, "disc": dm}


# ---------------------------------------------------------------- meeples

func _make_meeple(color: Color, kind: String) -> Node3D:
	var m := Node3D.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.55
	var s := 1.0 if kind == "assistant" else 1.25

	var body := MeshInstance3D.new()
	var bm := CylinderMesh.new()
	bm.top_radius = 0.07 * s
	bm.bottom_radius = 0.13 * s
	bm.height = 0.26 * s
	body.mesh = bm
	body.position.y = 0.13 * s
	body.material_override = mat
	m.add_child(body)

	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.08 * s
	hm.height = 0.16 * s
	head.mesh = hm
	head.position.y = 0.32 * s
	head.material_override = mat
	m.add_child(head)

	if kind == "scientist":
		# Top hat: a brim and a crown.
		var brim := MeshInstance3D.new()
		var br := CylinderMesh.new()
		br.top_radius = 0.12
		br.bottom_radius = 0.12
		br.height = 0.02
		brim.mesh = br
		brim.position.y = 0.4 * s
		brim.material_override = mat
		m.add_child(brim)
		var crown := MeshInstance3D.new()
		var cr := CylinderMesh.new()
		cr.top_radius = 0.07
		cr.bottom_radius = 0.07
		cr.height = 0.13
		crown.mesh = cr
		crown.position.y = 0.47 * s
		crown.material_override = mat
		m.add_child(crown)
	else:
		# Flat cap.
		var cap := MeshInstance3D.new()
		var cp := CylinderMesh.new()
		cp.top_radius = 0.09
		cp.bottom_radius = 0.1
		cp.height = 0.04
		cap.mesh = cp
		cap.position.y = 0.39
		cap.material_override = mat
		m.add_child(cap)

	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var cs := CapsuleShape3D.new()
	cs.radius = 0.16 * s
	cs.height = 0.6 * s
	shape.shape = cs
	shape.position.y = 0.3 * s
	area.add_child(shape)
	m.add_child(area)
	area.input_event.connect(_on_meeple_input.bind(m))
	m.set_meta("mat", mat)
	return m


func _build_meeples() -> void:
	# Each player's home row along the table edge: you in front, rivals behind.
	for i in PLAYERS.size():
		var p: Dictionary = PLAYERS[i]
		var kinds := ["scientist", "assistant", "assistant"]
		for k in kinds.size():
			var m := _make_meeple(p.color, kinds[k])
			var home: Vector3
			if i == 0:
				home = Vector3(-1.2 + k * 0.8, 0.0, BOARD_H / 2 + 0.45)
			else:
				home = Vector3(-6.0 + (i - 1) * 5.0 + k * 0.55, 0.0, -BOARD_H / 2 - 0.45)
			m.position = home
			m.set_meta("player", i)
			m.set_meta("kind", kinds[k])
			m.set_meta("home", home)
			m.set_meta("placed", false)
			add_child(m)
			meeples.append(m)


func home_meeples(i: int) -> Array:
	return meeples.filter(func(m): return m.get_meta("player") == i and not m.get_meta("placed"))


# ---------------------------------------------------------------- HUD

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	hud_title = Label.new()
	hud_title.add_theme_font_size_override("font_size", 22)
	hud_title.add_theme_color_override("font_color", Color("#ece0c6"))
	hud_title.add_theme_color_override("font_outline_color", Color.BLACK)
	hud_title.add_theme_constant_override("outline_size", 6)
	hud_title.position = Vector2(24, 18)
	layer.add_child(hud_title)

	var hint := Label.new()
	hint.text = "Right-drag to turn the table, wheel to zoom."
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color("#9a8f80"))
	hint.position = Vector2(24, 52)
	layer.add_child(hint)

	toast = PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.055, 0.043, 0.063, 0.96)
	sb.border_color = Color("#cda65c")
	sb.set_border_width_all(1)
	sb.border_width_left = 5
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	toast.add_theme_stylebox_override("panel", sb)
	toast_text = RichTextLabel.new()
	toast_text.bbcode_enabled = true
	toast_text.fit_content = true
	toast_text.autowrap_mode = TextServer.AUTOWRAP_OFF
	toast_text.add_theme_font_size_override("normal_font_size", 18)
	toast_text.add_theme_font_size_override("bold_font_size", 18)
	toast.add_child(toast_text)
	toast.modulate.a = 0.0
	layer.add_child(toast)


func show_toast(bbcode: String, rim: Color) -> void:
	var sb: StyleBoxFlat = toast.get_theme_stylebox("panel")
	sb.border_color = rim
	toast_text.text = "[center]" + bbcode + "[/center]"
	toast.reset_size()
	await get_tree().process_frame
	var vp := get_viewport().get_visible_rect().size
	var target := Vector2((vp.x - toast.size.x) / 2.0, vp.y - toast.size.y - 40)
	toast.position = target + Vector2(0, 18)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(toast, "modulate:a", 1.0, 0.2)
	tw.tween_property(toast, "position", target, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func fade_toast(after := 0.8, over := 2.5) -> void:
	var tw := create_tween()
	tw.tween_interval(after)
	tw.tween_property(toast, "modulate:a", 0.0, over)


# ---------------------------------------------------------------- turns

func _begin_turn() -> void:
	if meeples.all(func(m): return m.get_meta("placed")):
		await _night()
		return
	if home_meeples(turn).is_empty():
		turn = (turn + 1) % PLAYERS.size()
		_begin_turn()
		return
	var p: Dictionary = PLAYERS[turn]
	if p.ai:
		hud_title.text = "Day %d  ·  %s is choosing…" % [day, p.name]
		_set_glow(false)
		await get_tree().create_timer(1.0).timeout
		await _ai_move(turn)
		turn = (turn + 1) % PLAYERS.size()
		_begin_turn()
	else:
		hud_title.text = "Day %d  ·  Pick a meeple, then a location" % day
		show_toast("[b][color=#9fd0ff]Your turn[/color][/b], pick a meeple, then a location.", Color("#9fd0ff"))
		fade_toast(0.8, 2.5)
		if selected == null:
			_select(home_meeples(0)[0])
		_set_glow(true)


func _set_glow(on: bool) -> void:
	for id in places:
		var e := 0.0
		if on and selected != null and _free_slot(id, selected.get_meta("kind")) >= 0:
			e = 0.9
		places[id].disc.emission_energy_multiplier = e


func _free_slot(id: String, kind: String) -> int:
	var pl: Dictionary = places[id]
	for k in pl.occ.size():
		if pl.occ[k] == null and (kind == "scientist" or not pl.data.sci[k]):
			return k
	return -1


func _select(m: Node3D) -> void:
	if selected != null:
		create_tween().tween_property(selected, "position:y", 0.0, 0.15)
	selected = m
	create_tween().tween_property(m, "position:y", 0.18, 0.15)
	_set_glow(true)


func _on_meeple_input(_cam, event, _pos, _n, _idx, m: Node3D) -> void:
	if busy or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if PLAYERS[turn].ai or m.get_meta("player") != 0 or m.get_meta("placed"):
		return
	_select(m)


func _on_place_input(_cam, event, _pos, _n, _idx, id: String) -> void:
	if busy or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if PLAYERS[turn].ai or selected == null:
		return
	var k := _free_slot(id, selected.get_meta("kind"))
	if k < 0:
		return
	busy = true
	var m := selected
	selected = null
	_set_glow(false)
	await _place(m, id, k)
	busy = false
	turn = (turn + 1) % PLAYERS.size()
	_begin_turn()


func _ai_move(i: int) -> void:
	var options := []
	for m in home_meeples(i):
		for id in places:
			var k := _free_slot(id, m.get_meta("kind"))
			if k >= 0:
				options.append([m, id, k])
	if options.is_empty():
		for m in home_meeples(i):
			m.set_meta("placed", true)   # nowhere to go: they stay home
		return
	var pick: Array = options.pick_random()
	await _place(pick[0], pick[1], pick[2])
	var p: Dictionary = PLAYERS[i]
	var who := "their scientist" if pick[0].get_meta("kind") == "scientist" else "an assistant"
	show_toast("[b][color=#%s]%s[/color][/b] sends %s to the %s." % [p.color.to_html(false), p.name, who, places[pick[1]].data.name], p.color)
	fade_toast(1.2, 1.5)
	await get_tree().create_timer(1.6).timeout


## A meeple hops along an arc to its slot, then lands with a little squash.
func _place(m: Node3D, id: String, k: int) -> void:
	var pl: Dictionary = places[id]
	pl.occ[k] = m
	m.set_meta("placed", true)
	m.set_meta("at", [id, k])
	await _hop(m, pl.slots[k], 0.65)


func _hop(m: Node3D, to: Vector3, t: float) -> void:
	var from := m.position
	var tw := create_tween()
	tw.tween_method(func(f: float):
		var p := from.lerp(to, f)
		p.y += sin(f * PI) * 1.4
		m.position = p, 0.0, 1.0, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(m, "scale", Vector3(1.15, 0.8, 1.15), 0.08)
	tw.tween_property(m, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished


# ---------------------------------------------------------------- night and dawn

func _night() -> void:
	hud_title.text = "Night %d  ·  The laboratories light their lamps" % day
	show_toast("[b]Night falls.[/b] Everyone is out; the lamps are lit.", Color("#cda65c"))
	var tw := create_tween().set_parallel(true)
	tw.tween_property(sun, "light_energy", 0.12, 1.6)
	tw.tween_property(sun, "light_color", Color("#7b8cc9"), 1.6)
	tw.tween_property(env, "ambient_light_energy", 0.25, 1.6)
	for lamp in lamps:
		tw.tween_property(lamp, "light_energy", 2.2, 1.8)
	await tw.finished
	fade_toast(1.2, 1.5)
	await get_tree().create_timer(3.0).timeout
	await _dawn()


func _dawn() -> void:
	day += 1
	show_toast("[b]Dawn of Day %d.[/b] Your people come home." % day, Color("#9fd0ff"))
	var tw := create_tween().set_parallel(true)
	tw.tween_property(sun, "light_energy", 1.25, 1.4)
	tw.tween_property(sun, "light_color", Color("#f2d9a6"), 1.4)
	tw.tween_property(env, "ambient_light_energy", 0.9, 1.4)
	for lamp in lamps:
		tw.tween_property(lamp, "light_energy", 0.0, 1.2)
	for id in places:
		places[id].occ.fill(null)
	var n := 0
	for m in meeples:
		m.set_meta("placed", false)
		var home: Vector3 = m.get_meta("home")
		get_tree().create_timer(0.08 * n).timeout.connect(_hop.bind(m, home, 0.55))
		n += 1
	await get_tree().create_timer(0.08 * n + 0.8).timeout
	fade_toast(0.5, 1.5)
	turn = 0
	_begin_turn()


# ---------------------------------------------------------------- camera

func _update_camera() -> void:
	cam_rig.position = Vector3(0, 0, 1.1)   # aim a little in front of centre so your home row is in frame
	cam_rig.rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, dist)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			dist = max(6.0, dist - 0.6)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			dist = min(22.0, dist + 0.6)
			_update_camera()
	elif event is InputEventMouseMotion and dragging:
		yaw -= event.relative.x * 0.005
		pitch = clamp(pitch - event.relative.y * 0.005, deg_to_rad(-85.0), deg_to_rad(-20.0))
		_update_camera()


# ---------------------------------------------------------------- headless check

## godot --path godot -- --shot : plays one human move, lets rivals move, saves screenshots, quits.
func _screenshot_run() -> void:
	await get_tree().create_timer(1.0).timeout
	_save("res://../tests/godot-1-start.png")
	var hosp_id := "hospital"
	_on_place_input(null, _fake_click(), Vector3.ZERO, Vector3.ZERO, 0, hosp_id)
	await get_tree().create_timer(9.0).timeout
	_save("res://../tests/godot-2-rivals.png")
	get_tree().quit()


func _fake_click() -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	return e


func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
