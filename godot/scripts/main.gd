extends Node3D
## Second Spark, Godot diorama: the painted Paris map as a 3D table, clickable places,
## 3D meeples that hop onto their slots, rivals that take turns, and night falling once
## everyone is placed. No full rules yet: only placement, scientist-only spaces and turns.

const BOARD_W := 16.0
const BOARD_H := 9.0
const CARD_W := 0.56
const CARD_D := 0.78
const CARD_STEP := 0.62

# Card rows on the table. Research and humanity rows refill at dawn; a hired scoundrel is replaced at once.
const ROWS := {
	"academy": {"deck": "RESEARCH", "kind": "Research", "rim": "#9fd0ff", "refill": "dawn"},
	"church": {"deck": "HUMANITY", "kind": "Humanity", "rim": "#cda65c", "refill": "dawn"},
	"docks": {"deck": "SCOUNDRELS", "kind": "Scoundrel", "rim": "#d6675f", "refill": "now"},
}
# Spaces that take the first card of a row.
const TAKES := {"academy.adv": "academy", "academy.research": "academy", "church.atone": "church", "docks.hire": "docks"}

# Everything else comes from src/data.js through godot/data/game.json (node tools/export_godot_data.js).
var G: Dictionary
var PLACES := []
var PLAYERS := []

var places := {}          # id -> {data, slots: [Vector3], occ: [meeple or null], disc, rings, radius}
var rows := {}            # id -> {cfg, deck, cards: [Node3D or null], slots: [Vector3], deck_pos}
var hands := [[], [], [], []]   # card dictionaries each player holds
var hover := ["", -1]
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
var info: PanelContainer
var info_text: RichTextLabel
var toast: PanelContainer
var toast_text: RichTextLabel


func _ready() -> void:
	_load_data()
	_build_world()
	_build_table()
	_build_places()
	_build_rows()
	_build_meeples()
	_build_hud()
	_update_camera()
	await _deal_rows()
	_begin_turn()
	if "--shot" in OS.get_cmdline_user_args():
		_screenshot_run()


func _load_data() -> void:
	var f := FileAccess.open("res://data/game.json", FileAccess.READ)
	G = JSON.parse_string(f.get_as_text())
	for l in G.LOCS:
		if l.has("event"):
			continue   # event-only places like the Odeon are not on the table yet
		var pos: Dictionary = G.BOARD_POS[l.id]
		var sci := []
		var names := []
		var keys := []
		for sp in l.spaces:
			sci.append(sp.get("sci", 0) == 1)
			names.append(sp.n)
			keys.append(sp.k)
		PLACES.append({"id": l.id, "name": l.name, "x": pos.x, "y": pos.y, "side": pos.get("cards"),
			"sci": sci, "spaces": names, "keys": keys, "text": l.text})
	PLAYERS.append({"name": "You", "color": Color(G.YOU_COLOR), "ai": false})
	for r in G.RIVALS:
		PLAYERS.append({"name": r.name, "color": Color(r.color), "ai": true})


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

		# Slots in a row across the disc. Each ring is its own click target: one ring, one action space.
		var slots: Array[Vector3] = []
		var rings := []
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
			rings.append(rm)
			var ra := Area3D.new()
			var rs := CollisionShape3D.new()
			var rc := CylinderShape3D.new()
			rc.radius = 0.15
			rc.height = 0.7
			rs.shape = rc
			rs.position = Vector3(off, 0.35, 0)
			ra.add_child(rs)
			root.add_child(ra)
			ra.input_event.connect(_on_slot_input.bind(d.id, k))
			ra.mouse_entered.connect(_hover_enter.bind(d.id, k))
			ra.mouse_exited.connect(_hover_exit.bind(d.id, k))

		# The disc itself: clicking it uses the first free space you may take.
		var area := Area3D.new()
		var shape := CollisionShape3D.new()
		var cs := CylinderShape3D.new()
		cs.radius = cyl.top_radius + 0.1
		cs.height = 0.3
		shape.shape = cs
		shape.position.y = 0.15
		area.add_child(shape)
		root.add_child(area)
		area.input_event.connect(_on_place_input.bind(d.id))
		area.mouse_entered.connect(_hover_enter.bind(d.id, -1))
		area.mouse_exited.connect(_hover_exit.bind(d.id, -1))

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
		places[d.id] = {"data": d, "slots": slots, "occ": occ, "disc": dm, "rings": rings, "radius": cyl.top_radius}


# ---------------------------------------------------------------- card rows

func _build_rows() -> void:
	for id in ROWS:
		var cfg: Dictionary = ROWS[id]
		var pl: Dictionary = places[id]
		var side := -1.0 if pl.data.side == "left" else 1.0
		var c := map_to_world(pl.data.x, pl.data.y)
		var start: float = c.x + side * (pl.radius + 0.15 + CARD_W / 2.0)
		var slots := []
		for k in 3:
			var at := Vector3(start + side * k * CARD_STEP, 0.012, c.z)
			slots.append(at)
			# A faint empty spot, seen when a card has been taken and the row waits for dawn.
			var spot := MeshInstance3D.new()
			var pm := PlaneMesh.new()
			pm.size = Vector2(CARD_W, CARD_D)
			spot.mesh = pm
			var sm := StandardMaterial3D.new()
			sm.albedo_color = Color(0.93, 0.88, 0.78, 0.22)
			sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			spot.material_override = sm
			spot.position = at - Vector3(0, 0.008, 0)
			add_child(spot)
		# The face-down deck at the end of the row.
		var deck_pos := Vector3(start + side * 3 * CARD_STEP, 0.0, c.z)
		var deck_mesh := MeshInstance3D.new()
		var db := BoxMesh.new()
		db.size = Vector3(CARD_W, 0.12, CARD_D)
		deck_mesh.mesh = db
		var dmat := StandardMaterial3D.new()
		dmat.albedo_color = Color("#2a2030")
		dmat.emission_enabled = true
		dmat.emission = Color(cfg.rim)
		dmat.emission_energy_multiplier = 0.12
		deck_mesh.material_override = dmat
		deck_mesh.position = deck_pos + Vector3(0, 0.06, 0)
		add_child(deck_mesh)
		var deck: Array = G[cfg.deck].duplicate(true)
		deck.shuffle()
		rows[id] = {"cfg": cfg, "deck": deck, "cards": [null, null, null], "slots": slots, "deck_pos": deck_pos + Vector3(0, 0.14, 0)}


func _row_count(id: String) -> int:
	return rows[id].cards.filter(func(c): return c != null).size()


func _gain_text(g: Dictionary) -> String:
	var parts := []
	for k in [["exp", "expertise"], ["rep", "reputation"], ["hum", "humanity"], ["coin", "francs"]]:
		if g.has(k[0]) and g[k[0]] != 0:
			parts.append("%+d %s" % [int(g[k[0]]), k[1]])
	return ", ".join(parts)


func _card_lines(cfg: Dictionary, c: Dictionary) -> String:
	if cfg.kind == "Scoundrel":
		var t := "Costs %d franc%s" % [int(c.cost), "" if int(c.cost) == 1 else "s"]
		if int(c.hcost) > 0:
			t += ", %d humanity" % int(c.hcost)
		return t
	return _gain_text(c.get("gain", {}))


func _flat_label(text: String, size: int, at: Vector3, width := 0.0) -> Label3D:
	var l := Label3D.new()
	l.text = text
	l.font_size = size
	l.pixel_size = 0.0022
	l.modulate = Color("#1a1410")
	l.outline_size = 0
	l.rotation_degrees = Vector3(-90, 0, 0)   # lies on the card, readable from the near side
	l.position = at
	if width > 0.0:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.width = width / l.pixel_size
	return l


func _make_card(cfg: Dictionary, c: Dictionary) -> Node3D:
	var n := Node3D.new()
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CARD_W, 0.016, CARD_D)
	body.mesh = bm
	var m := StandardMaterial3D.new()
	m.albedo_color = Color("#e9dcc0")
	m.roughness = 0.9
	body.material_override = m
	n.add_child(body)
	var band := MeshInstance3D.new()
	var bb := BoxMesh.new()
	bb.size = Vector3(CARD_W, 0.018, 0.13)
	band.mesh = bb
	band.position.z = -CARD_D / 2.0 + 0.065
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color(cfg.rim)
	bmat.emission_enabled = true
	bmat.emission = Color(cfg.rim)
	bmat.emission_energy_multiplier = 0.35
	band.material_override = bmat
	n.add_child(band)
	n.add_child(_flat_label(cfg.kind.to_upper(), 22, Vector3(0, 0.011, -CARD_D / 2.0 + 0.065)))
	n.add_child(_flat_label(c.name, 34, Vector3(0, 0.009, -0.05), CARD_W - 0.06))
	var sub := _flat_label(_card_lines(cfg, c), 22, Vector3(0, 0.009, CARD_D / 2.0 - 0.12), CARD_W - 0.06)
	sub.modulate = Color("#5a4630")
	n.add_child(sub)
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(CARD_W, 0.08, CARD_D)
	shape.shape = bs
	area.add_child(shape)
	n.add_child(area)
	area.mouse_entered.connect(_card_hover.bind(n, true))
	area.mouse_exited.connect(_card_hover.bind(n, false))
	n.set_meta("card", c)
	n.set_meta("cfg", cfg)
	return n


## Fills the empty spots of every row (or one row) from its deck, each card flipping over as it lands.
func _deal_rows(only := "") -> void:
	var delay := 0.0
	for id in rows:
		if only != "" and id != only:
			continue
		var r: Dictionary = rows[id]
		for k in 3:
			if r.cards[k] != null or r.deck.is_empty():
				continue
			var c: Dictionary = r.deck.pop_back()
			var card := _make_card(r.cfg, c)
			card.position = r.deck_pos
			card.rotation_degrees = Vector3(0, 0, 180)
			add_child(card)
			r.cards[k] = card
			_fly(card, r.slots[k], 0.5, delay, 0.9, Vector3.ZERO)
			delay += 0.12
	if delay > 0.0:
		await get_tree().create_timer(delay + 0.5).timeout


func _fly(n: Node3D, to: Vector3, t: float, delay: float, height: float, rot: Vector3) -> void:
	var from := n.position
	var from_rot := n.rotation_degrees
	var tw := create_tween()
	tw.tween_interval(delay)
	tw.tween_method(func(f: float):
		var p := from.lerp(to, f)
		p.y += sin(f * PI) * height
		n.position = p
		n.rotation_degrees = from_rot.lerp(rot, f), 0.0, 1.0, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


## Player i takes the first card of a row. Yours lands in a fan along the front edge; a rival's flies to them and vanishes.
func _take_card(i: int, id: String) -> Dictionary:
	var r: Dictionary = rows[id]
	for k in 3:
		var card: Node3D = r.cards[k]
		if card == null:
			continue
		r.cards[k] = null
		var c: Dictionary = card.get_meta("card")
		hands[i].append(c)
		if i == 0:
			var j: int = hands[0].size() - 1
			_fly(card, Vector3(1.4 + j * 0.42, 0.02 + j * 0.004, BOARD_H / 2.0 + 0.42), 0.7, 0.0, 1.6, Vector3(0, -6 + j * 2, 0))
		else:
			var home: Vector3 = meeples.filter(func(m): return m.get_meta("player") == i)[0].get_meta("home")
			_fly(card, home + Vector3(0.5, 0.3, -0.2), 0.7, 0.0, 1.6, Vector3.ZERO)
			var tw := create_tween()
			tw.tween_interval(0.55)
			tw.tween_property(card, "scale", Vector3(0.05, 0.05, 0.05), 0.25)
			tw.tween_callback(card.queue_free)
		if r.cfg.refill == "now":
			get_tree().create_timer(0.6).timeout.connect(_deal_rows.bind(id))
		_update_title()
		return c
	return {}


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

	# Hover panel, bottom left: what a space or card does.
	info = PanelContainer.new()
	var ib := StyleBoxFlat.new()
	ib.bg_color = Color(0.055, 0.043, 0.063, 0.94)
	ib.border_color = Color("#3a3446")
	ib.set_border_width_all(1)
	ib.set_corner_radius_all(6)
	ib.content_margin_left = 14
	ib.content_margin_right = 14
	ib.content_margin_top = 10
	ib.content_margin_bottom = 10
	info.add_theme_stylebox_override("panel", ib)
	info_text = RichTextLabel.new()
	info_text.bbcode_enabled = true
	info_text.fit_content = true
	info_text.custom_minimum_size = Vector2(340, 0)
	info_text.add_theme_font_size_override("normal_font_size", 15)
	info_text.add_theme_font_size_override("bold_font_size", 17)
	info_text.add_theme_color_override("default_color", Color("#ece0c6"))
	info.add_child(info_text)
	info.position = Vector2(24, 86)
	info.visible = false
	layer.add_child(info)

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


func _show_info(bb: String) -> void:
	info_text.text = bb
	info.reset_size()
	info.visible = true


func _hover_enter(id: String, k: int) -> void:
	hover = [id, k]
	var pl: Dictionary = places[id]
	var d: Dictionary = pl.data
	var bb := "[b]%s[/b]" % d.name
	if k >= 0:
		bb += "  ·  " + d.spaces[k]
		if d.sci[k]:
			bb += "\n[color=#c9a24a]Scientist only.[/color]"
		var who = pl.occ[k]
		if who != null:
			bb += "\n[color=#9a8f80]Taken by %s.[/color]" % PLAYERS[who.get_meta("player")].name
	bb += "\n" + d.text
	_show_info(bb)
	if k >= 0 and selected != null and _can_use(id, k, selected.get_meta("kind")):
		pl.rings[k].emission_energy_multiplier = 2.5


func _hover_exit(id: String, k: int) -> void:
	if hover == [id, k]:
		hover = ["", -1]
		info.visible = false
	_set_glow(not PLAYERS[turn].ai and not busy)


func _card_hover(card: Node3D, on: bool) -> void:
	if not is_instance_valid(card):
		return
	if on:
		var c: Dictionary = card.get_meta("card")
		var cfg: Dictionary = card.get_meta("cfg")
		var bb := "[b]%s[/b]  ·  [color=%s]%s[/color]" % [c.name, cfg.rim, cfg.kind]
		var lines := _card_lines(cfg, c)
		if lines != "":
			bb += "\n" + lines
		if c.has("text"):
			bb += "\n" + c.text
		_show_info(bb)
		create_tween().tween_property(card, "position:y", card.position.y + 0.06, 0.1)
	else:
		info.visible = false
		create_tween().tween_property(card, "position:y", max(0.012, card.position.y - 0.06), 0.1)


func _update_title() -> void:
	var p: Dictionary = PLAYERS[turn]
	var cards := "  ·  Your cards: %d" % hands[0].size()
	if p.ai:
		hud_title.text = "Day %d  ·  %s is choosing" % [day, p.name] + cards
	else:
		hud_title.text = "Day %d  ·  Pick a meeple, then a space" % day + cards


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
	_update_title()
	if p.ai:
		_set_glow(false)
		await get_tree().create_timer(1.0).timeout
		await _ai_move(turn)
		turn = (turn + 1) % PLAYERS.size()
		_begin_turn()
	else:
		show_toast("[b][color=#9fd0ff]Your turn[/color][/b], pick a meeple, then a space.", Color("#9fd0ff"))
		fade_toast(0.8, 2.5)
		if selected == null:
			_select(home_meeples(0)[0])
		_set_glow(true)


func _set_glow(on: bool) -> void:
	for id in places:
		var pl: Dictionary = places[id]
		var can := on and selected != null
		pl.disc.emission_energy_multiplier = 0.3 if can and _free_slot(id, selected.get_meta("kind")) >= 0 else 0.0
		for k in pl.rings.size():
			pl.rings[k].emission_energy_multiplier = 1.2 if can and _can_use(id, k, selected.get_meta("kind")) else 0.25


## The same checks as canPlace in src/engine.js, for the parts the table knows about.
func _can_use(id: String, k: int, kind: String) -> bool:
	var pl: Dictionary = places[id]
	if pl.occ[k] != null:
		return false
	if pl.data.sci[k] and kind != "scientist":
		return false
	var key: String = id + "." + pl.data.keys[k]
	if key == "academy.research" and _row_count("academy") == 0:
		return false
	if key == "church.atone" and _row_count("church") == 0 and kind != "scientist":
		return false
	if key == "docks.hire" and _row_count("docks") == 0:
		return false
	return true


func _free_slot(id: String, kind: String) -> int:
	for k in places[id].occ.size():
		if _can_use(id, k, kind):
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
	if selected != null:
		_on_slot_input(_cam, event, _pos, _n, _idx, id, _free_slot(id, selected.get_meta("kind")))


func _on_slot_input(_cam, event, _pos, _n, _idx, id: String, k: int) -> void:
	if busy or not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	if PLAYERS[turn].ai or selected == null or k < 0 or not _can_use(id, k, selected.get_meta("kind")):
		return
	busy = true
	var m := selected
	selected = null
	_set_glow(false)
	await _place(m, id, k)
	busy = false
	turn = (turn + 1) % PLAYERS.size()
	_begin_turn()


func _where(name: String) -> String:
	return name if name == "Saint-Roch" else "the " + name


func _action_text(id: String, k: int, card: Dictionary) -> String:
	var key: String = id + "." + places[id].data.keys[k]
	var cn: String = card.get("name", "")
	match key:
		"academy.adv":
			return "do advanced research" + (", taking " + cn if cn != "" else "")
		"academy.research":
			return "research, taking " + cn
		"church.atone":
			return "atone" + (", taking " + cn if cn != "" else "")
		"docks.hire":
			return "hire " + cn
	var n: String = places[id].data.spaces[k]
	n = n.split(" (")[0]
	return n.substr(0, 1).to_lower() + n.substr(1)


func _ai_move(i: int) -> void:
	var options := []
	for m in home_meeples(i):
		for id in places:
			for k in places[id].occ.size():
				if _can_use(id, k, m.get_meta("kind")):
					options.append([m, id, k])
	if options.is_empty():
		for m in home_meeples(i):
			m.set_meta("placed", true)   # nowhere to go: they stay home
		return
	var pick: Array = options.pick_random()
	var card := await _place(pick[0], pick[1], pick[2])
	var p: Dictionary = PLAYERS[i]
	var who := "their scientist" if pick[0].get_meta("kind") == "scientist" else "an assistant"
	show_toast("[b][color=#%s]%s[/color][/b] sends %s to %s, at %s." % [p.color.to_html(false), p.name, who,
		_action_text(pick[1], pick[2], card), _where(places[pick[1]].data.name)], p.color)
	fade_toast(1.2, 1.5)
	await get_tree().create_timer(1.6).timeout


## A meeple hops along an arc to its slot, then lands with a little squash.
func _place(m: Node3D, id: String, k: int) -> Dictionary:
	var pl: Dictionary = places[id]
	pl.occ[k] = m
	m.set_meta("placed", true)
	m.set_meta("at", [id, k])
	await _hop(m, pl.slots[k], 0.65)
	var key: String = id + "." + pl.data.keys[k]
	if TAKES.has(key):
		return _take_card(m.get_meta("player"), TAKES[key])
	return {}


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
	info.visible = false
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
	await _deal_rows()
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
	_hover_enter("academy", 1)
	await _save("res://../tests/godot-1-start.png")
	_hover_exit("academy", 1)
	_on_slot_input(null, _fake_click(), Vector3.ZERO, Vector3.ZERO, 0, "academy", 1)
	await get_tree().create_timer(9.0).timeout
	await get_tree().create_timer(0.3).timeout
	await _save("res://../tests/godot-2-rivals.png")
	dist = 6.5
	pitch = deg_to_rad(-62.0)
	cam_rig.position = Vector3(1.5, 0, 2.6)
	cam_rig.rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, dist)
	await get_tree().create_timer(0.3).timeout
	await _save("res://../tests/godot-3-academy.png")
	get_tree().quit()


func _fake_click() -> InputEventMouseButton:
	var e := InputEventMouseButton.new()
	e.button_index = MOUSE_BUTTON_LEFT
	e.pressed = true
	return e


func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
