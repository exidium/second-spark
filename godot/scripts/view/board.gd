class_name Board
extends Node3D
## The 3D table: the painted map, the places, every player's meeples and the face-up card rows.
## It draws whatever the rules state says (sync) and animates the differences: meeples hop to and from
## their spaces, cards are dealt from their decks and fly to whoever takes them, night falls.

signal place_clicked(id: String)
signal slot_clicked(key: String)
signal meeple_clicked(kind: String)
signal hover_changed(bb: String)
signal mat_clicked(what: String)
signal tags_changed

const BOARD_W := 16.0
const BOARD_H := 9.0
const CARD_W := 0.56
const CARD_D := 0.76
const CARD_STEP := 0.62
# Which state row lies beside which place.
const ROWS := {"academy": "researchRow", "church": "humanityRow", "docks": "docks", "hospital": "hosp", "square": "square"}
# Your player board, a smaller board in front of the map.
const MAT_W := 12.6
const MAT_D := 3.6
const MAT_Z := BOARD_H / 2 + 2.95
const MAT_Y := 0.1
const FIG := Vector2(1.8, 2.7)      # the operating table art is 160 x 240
const CAM_DIST := 20.5
const ROW_RIM := {"researchRow": "#9fd0ff", "humanityRow": "#cda65c", "docks": "#d6675f", "hosp": "#b9ac93", "square": "#b4423c"}

var g: Game
var places := {}        # id -> {root, disc_mat, rings: [mat], slots: [Vector3], radius, cross}
var labs := {}          # player index -> {slots: {spot id: Vector3}}
var homes := {}         # player index -> Vector3 (left end of the home row)
var meeples := {}       # "i:kind:n" -> Node3D
var at := {}            # occupancy key ("academy.research" or "lab:i:practice") -> meeple Node3D
var rows := {}          # state row name -> {slots: [Vector3], deck_pos, cards: {id: Node3D}, anchor}
var tags := []          # 2D labels main.gd draws over the table: {id, kind, text, pos, node, size, color, font}
var mat_dyn: Node3D     # everything on your board that changes: body parts, cubes, coins, jars, ice, badges, cards
var mat_seen := {}      # counts at the last sync, so only new pieces drop in
var last_taker := {}    # state row name -> player index who last used that place
var interactive := false
var legal: Callable     # key -> bool, while it is your turn
var selected_kind := "assistant"
var hover_key := ""
var night := false

var sun: DirectionalLight3D
var env: Environment
var lamps: Array[OmniLight3D] = []
var cam_rig: Node3D
var cam: Camera3D
var yaw := 0.0
var pitch := deg_to_rad(-64.0)
var dist := CAM_DIST
var dragging := false
var _init_done := false


func setup(game: Game) -> void:
	g = game
	_build_world()
	_build_table()
	for l in g.D.LOCS:
		_build_place(l)
	_build_lab_places()
	_build_rows()
	_build_mat()
	_update_camera()


# ---------------------------------------------------------------- world

func map_to_world(x: float, y: float) -> Vector3:
	return Vector3((x / 100.0 - 0.5) * BOARD_W, 0.0, (y / 100.0 - 0.5) * BOARD_H)


func _build_world() -> void:
	var we := WorldEnvironment.new()
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Style.INK
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#3a3446")
	env.ambient_light_energy = 0.9
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.5
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


func _mat(c: Color, rough := 0.8) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	return m


func _build_table() -> void:
	var table := MeshInstance3D.new()
	var box := BoxMesh.new()
	var front := MAT_Z + MAT_D / 2 + 0.6
	var back := -BOARD_H / 2 - 1.0
	box.size = Vector3(BOARD_W + 1.8, 0.7, front - back)
	table.mesh = box
	table.material_override = _mat(Color("#3a2618"))
	table.position = Vector3(0, -0.36, (front + back) / 2)
	add_child(table)
	var board := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(BOARD_W, BOARD_H)
	board.mesh = plane
	var mat := _mat(Color.WHITE, 0.95)
	mat.albedo_texture = Style.art("ui/board.jpg")
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	board.material_override = mat
	board.position.y = 0.002
	add_child(board)


## A crisp 2D label that main.gd keeps over a point of the table (text on the 3D board would be pixelated).
func _tag(id: String, text: String, pos: Vector3, node: Node3D = null, size := 18, color := Style.PARCH, font := "display", kind := "label", plate := false) -> void:
	tags.append({"id": id, "kind": kind, "text": text, "pos": pos, "node": node, "size": size, "color": color, "font": font, "plate": plate})


## A place: a dark disc with its name, one ring per action space, a click target per ring, a lantern for the night.
func _make_place(id: String, name: String, pos: Vector3, keys: Array, sci: Array) -> Dictionary:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	var n := keys.size()
	var disc := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.32 + 0.12 * n
	cyl.bottom_radius = cyl.top_radius
	cyl.height = 0.05
	disc.mesh = cyl
	var dm := _mat(Color(0.07, 0.06, 0.09, 0.85))
	dm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dm.emission_enabled = true
	dm.emission = Style.SPARK
	dm.emission_energy_multiplier = 0.0
	disc.material_override = dm
	disc.position.y = 0.03
	root.add_child(disc)
	_tag("place:" + id, name, pos + Vector3(0, 0.7, 0), root, 20, Style.PARCH, "display", "label", true)
	var slots := []
	var rings := []
	for k in n:
		var off := (k - (n - 1) / 2.0) * 0.32
		slots.append(pos + Vector3(off, 0.06, 0))
		var ring := MeshInstance3D.new()
		var tm := TorusMesh.new()
		tm.inner_radius = 0.09
		tm.outer_radius = 0.12
		ring.mesh = tm
		var rm := _mat(Color("#c9a24a") if sci[k] else Style.PARCH)
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
		var key: String = keys[k]
		ra.input_event.connect(func(_c, e, _p, _n, _s): if _is_click(e): slot_clicked.emit(key))
		ra.mouse_entered.connect(func(): _hover(key))
		ra.mouse_exited.connect(func(): _unhover(key))
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var cs := CylinderShape3D.new()
	cs.radius = cyl.top_radius + 0.1
	cs.height = 0.3
	shape.shape = cs
	shape.position.y = 0.15
	area.add_child(shape)
	root.add_child(area)
	area.input_event.connect(func(_c, e, _p, _n, _s): if _is_click(e): place_clicked.emit(id))
	area.mouse_entered.connect(func(): _hover(id))
	area.mouse_exited.connect(func(): _unhover(id))
	var lamp := OmniLight3D.new()
	lamp.light_color = Color("#ffb35a")
	lamp.light_energy = 0.0
	lamp.omni_range = 2.2
	lamp.position = Vector3(0, 0.8, 0)
	root.add_child(lamp)
	lamps.append(lamp)
	# A red cross shown when the place is closed today.
	var cross := Node3D.new()
	for a in [45, -45]:
		var bar := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(cyl.top_radius * 2.2, 0.03, 0.09)
		bar.mesh = bm
		var xm := _mat(Style.CRIM)
		xm.emission_enabled = true
		xm.emission = Style.CRIM
		xm.emission_energy_multiplier = 0.6
		bar.material_override = xm
		bar.rotation_degrees.y = a
		bar.position.y = 0.09
		cross.add_child(bar)
	cross.visible = false
	root.add_child(cross)
	return {"root": root, "disc": dm, "rings": rings, "slots": slots, "radius": cyl.top_radius, "cross": cross, "keys": keys}


func _build_place(l: Dictionary) -> void:
	var pos: Dictionary = g.D.BOARD_POS[l.id]
	var keys := []
	var sci := []
	for s in l.spaces:
		keys.append(l.id + "." + s.k)
		sci.append(s.get("sci", 0) == 1)
	places[l.id] = _make_place(l.id, l.name, map_to_world(pos.x, pos.y), keys, sci)
	if l.has("event"):
		places[l.id].root.visible = false


## Your laboratory is a place on the map; each rival has a small lab mat by their home row.
func _build_lab_places() -> void:
	var keys := []
	var sci := []
	for s in g.D.LABSPOTS:
		keys.append("lab." + s.id)
		sci.append(s.get("sci", 0) == 1)
	var pos: Vector3 = map_to_world(g.D.LAB_POS.x, g.D.LAB_POS.y)
	places["lab"] = _make_place("lab", "Your laboratory", pos, keys, sci)
	var lab_slots := {}
	for k in keys.size():
		lab_slots[g.D.LABSPOTS[k].id] = places.lab.slots[k]
	labs[0] = lab_slots
	homes[0] = Vector3(-2.6, 0.0, BOARD_H / 2 + 0.55)
	for i in range(1, 4):
		var base := Vector3(-6.4 + (i - 1) * 5.4, 0.0, -BOARD_H / 2 - 0.5)
		homes[i] = base
		var mat_pos := base + Vector3(2.6, 0, 0)
		var mesh := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(1.5, 0.03, 0.5)
		mesh.mesh = pm
		mesh.material_override = _mat(Color("#241f29"))
		mesh.position = mat_pos + Vector3(0, 0.015, 0)
		add_child(mesh)
		var sl := {}
		for k in g.D.LABSPOTS.size():
			sl[g.D.LABSPOTS[k].id] = mat_pos + Vector3(-0.55 + k * 0.37, 0.03, 0)
		labs[i] = sl


func _is_click(e) -> bool:
	return e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT


# ---------------------------------------------------------------- hover info

func _hover(key: String) -> void:
	hover_key = key
	hover_changed.emit(_info_for(key))
	_refresh_glow()

func _unhover(key: String) -> void:
	if hover_key == key:
		hover_key = ""
		hover_changed.emit("")
		_refresh_glow()

func _info_for(key: String) -> String:
	if g.S.is_empty():
		return ""
	if key == "lab":
		return "[b]Your laboratory[/b]\nFour spaces of your own. Each can be used once a day."
	if key.begins_with("lab."):
		var s: Dictionary = g.LABSPOT[key.substr(4)]
		var bb := "[b]Your laboratory[/b]  ·  %s\n%s" % [s.name, s.text]
		if s.get("sci", 0):
			bb += "\n[color=#c9a24a]Scientist only.[/color]"
		if g.S.players[0].labUsed.has(s.id):
			bb += "\n[color=#8e8393]Used today.[/color]"
		return bb
	if g.LOC.has(key):
		var l: Dictionary = g.LOC[key]
		var bb := "[b]%s[/b]\n%s" % [l.name, l.text]
		if g.S.closed.has(key):
			bb += "\n[color=#d6675f]Closed today.[/color]"
		return bb
	var sp: Dictionary = g.SPACE[key]
	var bb := "[b]%s[/b]  ·  %s" % [g.LOC[sp.loc].name, sp.n]
	if sp.get("sci", 0):
		bb += "\n[color=#c9a24a]Scientist only.[/color]"
	if g.S.occ.has(key):
		bb += "\n[color=#b9ac93]%s’s %s is here.[/color]" % [g.S.players[g.S.occ[key].p].name, g.S.occ[key].kind]
	if g.S.closed.has(sp.loc):
		bb += "\n[color=#d6675f]Closed today.[/color]"
	return bb


# ---------------------------------------------------------------- your turn

func set_interactive(on: bool, kind: String, legal_fn: Callable) -> void:
	interactive = on
	selected_kind = kind
	legal = legal_fn
	_refresh_glow()
	_lift_selected()

func _refresh_glow() -> void:
	for id in places:
		var pl: Dictionary = places[id]
		var any := false
		for k in pl.keys.size():
			var key: String = pl.keys[k]
			var ok: bool = interactive and legal.is_valid() and legal.call(key, selected_kind)
			any = any or ok
			pl.rings[k].emission_energy_multiplier = (2.6 if key == hover_key else 1.3) if ok else 0.25
		pl.disc.emission_energy_multiplier = (0.12 if hover_key == id else 0.05) if any else 0.0


# ---------------------------------------------------------------- meeples

func _make_meeple(color: Color, kind: String) -> Node3D:
	var m := Node3D.new()
	var mat := _mat(color, 0.55)
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
		for part in [[0.12, 0.02, 0.4 * s], [0.07, 0.13, 0.47 * s]]:
			var hat := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = part[0]
			cm.bottom_radius = part[0]
			cm.height = part[1]
			hat.mesh = cm
			hat.position.y = part[2]
			hat.material_override = mat
			m.add_child(hat)
	else:
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
	area.input_event.connect(func(_c, e, _p, _n, _s):
		if _is_click(e) and m.get_meta("player") == 0 and m.get_meta("state") == "home":
			meeple_clicked.emit(m.get_meta("kind")))
	return m

func _home_spot(i: int, kind: String, n: int) -> Vector3:
	var base: Vector3 = homes[i]
	var step := 0.55 if i == 0 else 0.42
	var k := n if kind == "scientist" else 2 + n
	return base + Vector3(k * step, 0, 0)

func _meeple(i: int, kind: String, n: int) -> Node3D:
	var id := "%d:%s:%d" % [i, kind, n]
	if not meeples.has(id):
		var m := _make_meeple(Color(g.S.players[i].color), kind)
		m.set_meta("player", i)
		m.set_meta("kind", kind)
		m.set_meta("state", "home")
		m.position = _home_spot(i, kind, n) + Vector3(0, 2.5, 0)
		add_child(m)
		meeples[id] = m
		var tw := create_tween()
		tw.tween_property(m, "position", _home_spot(i, kind, n), 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return meeples[id]

func _key_pos(i: int, key: String) -> Vector3:
	if key.begins_with("lab."):
		return labs[i][key.substr(4)]
	var sp: Dictionary = g.SPACE[key]
	var pl: Dictionary = places[sp.loc]
	return pl.slots[pl.keys.find(key)]

func _occ_list() -> Dictionary:
	# Every placed meeple: key -> {p, kind}. Lab spaces are per player.
	var o := {}
	for k in g.S.occ:
		o[k] = g.S.occ[k]
	for i in g.S.players.size():
		var lu: Dictionary = g.S.players[i].labUsed
		for s in lu:
			o["lab:%d:%s" % [i, s]] = {"p": i, "kind": lu[s], "key": "lab." + s}
	return o

func _lift_selected() -> void:
	for id in meeples:
		var m: Node3D = meeples[id]
		if m.get_meta("player") != 0 or m.get_meta("state") != "home":
			continue
		var up: bool = interactive and m.get_meta("kind") == selected_kind and m == _first_home(0, selected_kind)
		create_tween().tween_property(m, "position:y", 0.18 if up else 0.0, 0.15)

func _first_home(i: int, kind: String):
	for n in 4:
		var id := "%d:%s:%d" % [i, kind, n]
		if meeples.has(id) and meeples[id].get_meta("state") == "home":
			return meeples[id]
	return null


## A meeple hops along an arc to a spot, then lands with a little squash.
func hop(m: Node3D, to: Vector3, t := 0.6, lie := false) -> void:
	var from := m.position
	var r0 := m.rotation_degrees
	var r1 := Vector3(0, 0, 90) if lie else Vector3.ZERO
	var tw := create_tween()
	tw.tween_method(func(f: float):
		var p := from.lerp(to, f)
		p.y += sin(f * PI) * 1.3
		m.position = p
		m.rotation_degrees = r0.lerp(r1, f), 0.0, 1.0, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(m, "scale", Vector3(1.15, 0.8, 1.15), 0.08)
	tw.tween_property(m, "scale", Vector3.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await tw.finished


## Brings the meeples in line with the state: who stands where, who is home, who is out for the day.
func sync_meeples() -> void:
	var occ := _occ_list()
	# Free meeples whose space is no longer theirs (new day, bumped, moved).
	for key in at.keys():
		var m: Node3D = at[key]
		if not occ.has(key) or occ[key].p != m.get_meta("player") or occ[key].kind != m.get_meta("kind"):
			at.erase(key)
			m.set_meta("state", "free")
	for i in g.S.players.size():
		var p: Dictionary = g.S.players[i]
		for kind in ["scientist", "assistant"]:
			var placed := []
			for key in occ:
				if occ[key].p == i and occ[key].kind == kind:
					placed.append(key)
			var home: int = p.left[kind]
			var total: int = maxi(placed.size() + home, _count(i, kind))
			# Make sure enough meeples exist, then assign: placed ones first, then home, then out.
			var mine := []
			for n in total:
				mine.append(_meeple(i, kind, n))
			for key in placed:
				if at.has(key):
					mine.erase(at[key])
			for key in placed:
				if at.has(key):
					continue
				var m: Node3D = _pick_free(mine)
				mine.erase(m)
				at[key] = m
				m.set_meta("state", "placed")
				var target := _key_pos(i, occ[key].get("key", key))
				if m.position.distance_to(target) > 0.05:
					hop(m, target)
			var n_home := 0
			for m in mine:
				var spot := _home_spot(i, kind, _index_of(m))
				var want := "home" if n_home < home else "out"
				if want == "home":
					n_home += 1
				var moved: bool = m.get_meta("state") != want or m.position.distance_to(spot) > 0.3
				m.set_meta("state", want)
				if moved:
					hop(m, spot, 0.55, want == "out")
	_lift_selected()

func _count(i: int, kind: String) -> int:
	var n := 0
	while meeples.has("%d:%s:%d" % [i, kind, n]):
		n += 1
	return n

func _index_of(m: Node3D) -> int:
	for id in meeples:
		if meeples[id] == m:
			return int(id.split(":")[2])
	return 0

func _pick_free(list: Array) -> Node3D:
	# Prefer a meeple standing at home, so the one that hops is the one you see leave.
	for m in list:
		if m.get_meta("state") == "home":
			return m
	return list[0]


## Animates one placement right away (the engine waits for it), then remembers who used the place.
func animate_place(i: int, key: String, _kind: String) -> void:
	if not key.begins_with("lab."):
		var loc: String = g.SPACE[key].loc
		if ROWS.has(loc):
			last_taker[ROWS[loc]] = i
	sync_meeples()
	await get_tree().create_timer(0.65).timeout
	sync_rows()


# ---------------------------------------------------------------- card rows

func _build_rows() -> void:
	for loc in ROWS:
		var row: String = ROWS[loc]
		var pl: Dictionary = places[loc]
		var pos: Dictionary = g.D.BOARD_POS[loc]
		var side := -1.0 if pos.get("cards") == "left" else 1.0
		var c: Vector3 = pl.root.position
		var start: float = c.x + side * (pl.radius + 0.15 + CARD_W / 2.0)
		var slots := []
		for k in 4:
			slots.append(Vector3(start + side * k * CARD_STEP, 0.012, c.z + (0.0 if loc != "hospital" else 0.0)))
		var deck_pos := Vector3(start + side * 3 * CARD_STEP, 0.0, c.z)
		var deck_count := 3 if row in ["researchRow", "humanityRow", "docks"] else 2
		if row in ["researchRow", "humanityRow", "docks"]:
			for k in 3:
				_spot(slots[k])
			var deck := MeshInstance3D.new()
			var db := BoxMesh.new()
			db.size = Vector3(CARD_W, 0.12, CARD_D)
			deck.mesh = db
			var dm := _mat(Color.WHITE)
			dm.albedo_texture = Style.art("frames/card-tall-back.png")
			deck.material_override = dm
			deck.position = deck_pos + Vector3(0, 0.06, 0)
			add_child(deck)
		else:
			deck_pos = c + Vector3(side * 0.3, 0.6, -0.6)
		rows[row] = {"slots": slots, "deck_pos": deck_pos + Vector3(0, 0.14, 0), "cards": {}, "max": deck_count, "loc": loc}

func _spot(at_pos: Vector3) -> void:
	var spot := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(CARD_W, CARD_D)
	spot.mesh = pm
	var sm := _mat(Color(0.93, 0.88, 0.78, 0.22))
	sm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	spot.material_override = sm
	spot.position = at_pos - Vector3(0, 0.008, 0)
	add_child(spot)

func _card_id(c: Dictionary) -> String:
	return str(c.get("uid", c.get("id")))

func _card_face(c: Dictionary) -> Texture2D:
	match c.kind:
		"research":
			return Style.art("research/research-%02d.png" % (g.D.RESEARCH.map(func(r): return r.id).find(c.id) + 1))
		"humanity":
			var k: int = g.D.HUMANITY.map(func(r): return r.id).find(c.id) + 1
			var t := Style.art("humanity/humanity-%02d.png" % k)
			return t if t != null else Style.art("frames/card-humanity-bg.png")
		"scoundrel":
			return Style.art("scoundrels/scoundrel-%02d.png" % (c.tpl + 1))
		"cadaver":
			return Style.art("cadavers/%s.png" % c.art) if c.art != null else null
	return null

## A card lying on the table: parchment frame, its picture, its name.
func make_card(c: Dictionary) -> Node3D:
	var n := Node3D.new()
	var body := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(CARD_W, 0.014, CARD_D)
	body.mesh = bm
	var fm := _mat(Color.WHITE, 0.9)
	var frame := "frames/card-humanity-bg.png" if c.kind == "humanity" else "frames/card-research-bg.png"
	fm.albedo_texture = Style.art(frame)
	body.material_override = fm
	n.add_child(body)
	var pic := MeshInstance3D.new()
	var qm := PlaneMesh.new()
	var portrait: bool = c.kind in ["scoundrel", "cadaver"]
	qm.size = Vector2(CARD_W - 0.08, CARD_D - 0.08) if portrait else Vector2(CARD_W - 0.1, (CARD_W - 0.1) * 0.75)
	pic.mesh = qm
	var pm := _mat(Color.WHITE, 0.9)
	pm.albedo_texture = _card_face(c)
	pic.material_override = pm
	pic.position = Vector3(0, 0.008, 0.0 if portrait else -0.12)
	n.add_child(pic)
	if c.kind == "humanity" and not ResourceLoader.exists("res://assets/art/humanity/humanity-%02d.png" % (g.D.HUMANITY.map(func(r): return r.id).find(c.id) + 1)):
		pm.albedo_texture = Style.icon_tex("cross")
		qm.size = Vector2(0.24, 0.24)
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(CARD_W, 0.08, CARD_D)
	shape.shape = bs
	area.add_child(shape)
	n.add_child(area)
	area.mouse_entered.connect(func(): hover_changed.emit(_card_info(c)))
	area.mouse_exited.connect(func(): hover_changed.emit(""))
	return n

func _card_info(c: Dictionary) -> String:
	match c.kind:
		"research", "humanity":
			var bb := "[b]%s[/b]  ·  %s\n%s" % [c.name, c.kind.capitalize(), c.text]
			var gt: String = g.gain_text(c.get("gain", {}))
			if gt != "":
				bb += "\n" + gt
			if c.kind == "research":
				bb += "\nAfter a throw: " + g.D.MIT_N[c.mit]
			return bb
		"scoundrel":
			var bb := "[b]%s[/b]  ·  Scoundrel, %s" % [c.name, Style.fr(g.sc_cost(c))]
			if g.sc_hcost(c):
				bb += ", -%d humanity" % g.sc_hcost(c)
			bb += "\n" + (("Draw %d cadavers from the Hospital." % c.draw) if c.sk == "thief" else g.mats_text(c.get("mats", [])))
			return bb
		"cadaver":
			var bb := "[b]%s[/b]  ·  %s, %s\n%s" % [c.name, g.LOC[c.src].name, ("stage " + Style.roman(c.stage)) if c.stage else "bones", g.mats_text(c.mats)]
			if c.exp:
				bb += "\nor +%d expertise" % c.exp
			return bb
	return ""

func _fly(n: Node3D, to: Vector3, t: float, delay: float, height: float, rot: Vector3) -> void:
	var from := n.position
	var from_rot := n.rotation_degrees
	var tw := n.create_tween()
	tw.tween_interval(delay)
	tw.tween_method(func(f: float):
		var p := from.lerp(to, f)
		p.y += sin(f * PI) * height
		n.position = p
		n.rotation_degrees = from_rot.lerp(rot, f), 0.0, 1.0, t).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

## Deals new cards into each row and sends taken cards to whoever took them.
func sync_rows() -> void:
	var delay := 0.0
	for row in rows:
		var r: Dictionary = rows[row]
		var state: Array = g.S.get(row, [])
		var ids := state.map(func(c): return _card_id(c))
		for id in r.cards.keys():
			if not ids.has(id):
				var card: Node3D = r.cards[id]
				r.cards.erase(id)
				var taker: int = last_taker.get(row, -1)
				var to: Vector3 = mat_target(row) if taker == 0 else (homes[taker] + Vector3(1.0, 0.4, 0.0)) if taker > 0 else r.deck_pos + Vector3(0, 1.5, 0)
				_fly(card, to, 0.6, 0.0, 1.4, Vector3.ZERO)
				var tw := create_tween()
				tw.tween_interval(0.45)
				tw.tween_property(card, "scale", Vector3(0.05, 0.05, 0.05), 0.2)
				tw.tween_callback(card.queue_free)
		# Cards keep their spot until dawn; new ones fill the first empty spots.
		var used := {}
		for id in r.cards:
			used[r.cards[id].get_meta("slot")] = true
		for k in state.size():
			var id: String = ids[k]
			if r.cards.has(id):
				continue
			var slot := 0
			while used.has(slot) and slot < 3:
				slot += 1
			used[slot] = true
			var card := make_card(state[k])
			card.set_meta("slot", slot)
			card.position = r.deck_pos
			card.rotation_degrees = Vector3(0, 0, 180)
			add_child(card)
			r.cards[id] = card
			_fly(card, r.slots[mini(slot, 3)], 0.5, delay, 0.9, Vector3.ZERO)
			delay += 0.1

# ---------------------------------------------------------------- your board

func _mp(x: float, z: float, y := 0.0) -> Vector3:
	return Vector3(x, MAT_Y + y, MAT_Z + z)

# Zone centres on your board (x along the board, z towards you).
const Z_OR := -4.85        # operating room
const Z_DECAY := -1.35     # decomposition table, first cell column at DECAY_X0
const DECAY_X0 := -2.45
const DECAY_CW := 0.72
const DECAY_ROWS := [-0.75, -0.18, 0.39, 0.96]
const Z_POINTS := 2.15
const SUP := {"coin": Vector2(4.35, -0.95), "jar": Vector2(5.55, -0.95), "ice": Vector2(4.35, 0.35), "police": Vector2(5.55, 0.35), "cards": Vector2(4.95, 1.35)}

func _panel3d(center: Vector3, size: Vector2, col: Color, rim := Color(0, 0, 0, 0)) -> void:
	if rim.a > 0:
		var r := MeshInstance3D.new()
		var rb := BoxMesh.new()
		rb.size = Vector3(size.x + 0.06, 0.01, size.y + 0.06)
		r.mesh = rb
		r.material_override = _mat(rim)
		r.position = center + Vector3(0, 0.004, 0)
		add_child(r)
	var m := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = Vector3(size.x, 0.012, size.y)
	m.mesh = b
	m.material_override = _mat(col)
	m.position = center + Vector3(0, 0.008, 0)
	add_child(m)

func _zone_area(center: Vector3, size: Vector2, what: String) -> void:
	var area := Area3D.new()
	var shape := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(size.x, 0.5, size.y)
	shape.shape = bs
	area.add_child(shape)
	area.position = center + Vector3(0, 0.25, 0)
	add_child(area)
	area.input_event.connect(func(_c, e, _p, _n, _s): if _is_click(e): mat_clicked.emit(what))
	area.mouse_entered.connect(func(): hover_key = "mat:" + what; hover_changed.emit(_mat_info(what)))
	area.mouse_exited.connect(func():
		if hover_key == "mat:" + what:
			hover_key = ""
			hover_changed.emit(""))

## The board itself: a wooden frame, a dark printed face, one inset panel per zone, and the printed words.
func _build_mat() -> void:
	var frame := MeshInstance3D.new()
	var fb := BoxMesh.new()
	fb.size = Vector3(MAT_W + 0.3, MAT_Y + 0.02, MAT_D + 0.3)
	frame.mesh = fb
	frame.material_override = _mat(Color("#24170f"))
	frame.position = Vector3(0, (MAT_Y + 0.02) / 2 - 0.01, MAT_Z)
	add_child(frame)
	_panel3d(_mp(0, 0, -0.01), Vector2(MAT_W, MAT_D), Color("#3a3042"), Color("#8a6a3a"))
	_panel3d(_mp(Z_OR, 0.1), Vector2(2.5, 3.1), Color("#2a2330"), Color("#5a4e62"))
	_panel3d(_mp(Z_DECAY, 0.12), Vector2(3.95, 3.05), Color("#2a2330"), Color("#5a4e62"))
	_panel3d(_mp(Z_POINTS, 0.12), Vector2(3.0, 3.05), Color("#2a2330"), Color("#5a4e62"))
	_panel3d(_mp(4.95, 0.12), Vector2(2.4, 3.05), Color("#2a2330"), Color("#5a4e62"))
	_tag("mat:or", "Operating room", _mp(Z_OR, -1.62), null, 17, Style.BRASS)
	_tag("mat:decay", "Decomposition table", _mp(Z_DECAY, -1.62), null, 17, Style.BRASS)
	_tag("mat:points", "Points per part", _mp(Z_POINTS, -1.62), null, 17, Style.BRASS)
	_tag("mat:sup", "Supplies", _mp(4.95, -1.62), null, 17, Style.BRASS)
	# The decomposition table's printed grid: stage numerals and material names.
	var stages := ["I", "II", "III", "IV"]
	for k in 4:
		_tag("mat:st%d" % k, stages[k], _mp(DECAY_X0 + k * DECAY_CW, -1.2), null, 15, Style.MUTED)
	var mats := ["muscle", "organ", "blood", "animal"]
	for r in 4:
		_tag("mat:m" + mats[r], g.D.MAT_N[mats[r]], _mp(DECAY_X0 - 0.85, DECAY_ROWS[r]), null, 14, Style.MAT_COL[mats[r]].lightened(0.45), "body")
		for k in 4:
			var rot: bool = k == 3 or (mats[r] == "blood" and k == 1)
			_panel3d(_mp(DECAY_X0 + k * DECAY_CW, DECAY_ROWS[r]), Vector2(DECAY_CW - 0.08, 0.5), Color("#1d1922"), Color("#a8443a") if rot else Color("#4b4152"))
	_tag("mat:pointsgrid", "", _mp(Z_POINTS, 0.15), null, 14, Style.PARCH, "body", "points")
	var names := {"coin": "Gold", "jar": "Leiden jars", "ice": "Ice", "police": "Police", "cards": "Cards"}
	for k in SUP:
		_tag("mat:n" + k, names[k], _mp(SUP[k].x, SUP[k].y + 0.5), null, 13, Style.MUTED, "body")
	_zone_area(_mp(Z_OR, 0.1), Vector2(2.5, 3.1), "lab")
	_zone_area(_mp(Z_DECAY, 0.12), Vector2(3.95, 3.05), "decay")
	_zone_area(_mp(Z_POINTS, 0.12), Vector2(3.0, 3.05), "points")
	for k in SUP:
		_zone_area(_mp(SUP[k].x, SUP[k].y + 0.1), Vector2(1.15, 1.0) if k != "cards" else Vector2(2.3, 0.9), k)
	var lamp := OmniLight3D.new()
	lamp.light_color = Color("#ffb35a")
	lamp.light_energy = 0.0
	lamp.omni_range = 4.5
	lamp.position = _mp(-1.5, 0.0, 1.6)
	add_child(lamp)
	lamps.append(lamp)
	mat_dyn = Node3D.new()
	add_child(mat_dyn)

func _mat_info(what: String) -> String:
	if g.S.is_empty():
		return ""
	var p: Dictionary = g.S.players[0]
	match what:
		"lab":
			return "[b]Operating room[/b]\nMuscle %d · skin %d · alive %d · damage %d. %d VP built.\nClick to open your laboratory." % [g.on_table(p).size() - g.complete_count(p), g.complete_count(p) - g.alive_count(p), g.alive_count(p), g.dmg_total(p), p.vp]
		"decay":
			return "[b]Decomposition table[/b]\nEach dawn materials age one stage. Red cells rot at the next dawn. Bone never rots (max 12).\nBone %d · Preserved %d/9%s" % [p.bone, p.preserved, (" · Ice: no decay for %d dawn%s" % [p.ice, "" if p.ice == 1 else "s"]) if p.ice else ""]
		"points":
			return "[b]Points per part[/b]\nEach step scores VP by the stage of the oldest material you use (I is freshest). Alive points count at the end of the game."
		"coin":
			return "[b]Gold[/b]\n%s." % Style.fr(p.coin)
		"jar":
			return "[b]Leiden jars[/b]\n%d of %d charged. Each charged jar rolls 2 shock dice when you throw the switch." % [g.charged(p), p.jars.size()]
		"ice":
			return "[b]Ice[/b]\n%d. Each ice stops your materials decaying for one dawn." % p.ice
		"police":
			return "[b]Police[/b]\n%d of 2 badges. At 2 the police arrest your people." % p.police
		"cards":
			if p.hand.is_empty():
				return "[b]Cards[/b]\nNo cards yet. Research at the Academy, atone at Saint-Roch."
			return "[b]Cards in hand[/b]\n" + "\n".join(p.hand.map(func(c): return "%s (%s)" % [c.name, c.kind])) + "\nClick to see them."
	return ""

func _piece(mesh: Mesh, m: Material, pos: Vector3, fresh: bool, delay := 0.0) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.material_override = m
	mat_dyn.add_child(n)
	n.position = pos
	if fresh:
		n.position = pos + Vector3(0, 1.4, 0)
		var tw := n.create_tween()
		tw.tween_interval(delay)
		tw.tween_property(n, "position", pos, 0.45).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	return n

func _glow(c: Color, e := 0.0, alpha := 1.0) -> StandardMaterial3D:
	var m := _mat(Color(c, alpha), 0.4)
	if alpha < 1.0:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if e > 0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = e
	return m

## Rebuilds the pieces on your board from the state. Pieces that are new since the last sync drop in.
func sync_mat() -> void:
	var p: Dictionary = g.S.players[0]
	for c in mat_dyn.get_children():
		c.queue_free()
	tags = tags.filter(func(t): return not t.id.begins_with("dyn:"))
	var seen := {}
	# Operating room: the table and each part in its state, stacked like the 2D figure.
	var fc := _mp(Z_OR, 0.12, 0.02)
	var layers := [["body/table.png", false]]
	for s in g.D.SLOT6:
		var t = p.table[s]
		if t != null:
			layers.append(["body/%s-%s.png" % ["alive" if t.alive else t.side, s], t.alive])
	for k in layers.size():
		var pm := PlaneMesh.new()
		pm.size = FIG
		var m := _mat(Color.WHITE, 0.9)
		m.albedo_texture = Style.art(layers[k][0])
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		if layers[k][1]:
			m.emission_enabled = true
			m.emission_texture = m.albedo_texture
			m.emission = Style.ALIVE
			m.emission_energy_multiplier = 0.7
		var key: String = layers[k][0]
		seen[key] = 1
		_piece(pm, m, fc + Vector3(0, k * 0.004, 0), k > 0 and mat_seen.get(key, 0) == 0)
	for s in g.D.SLOT6:
		var t = p.table[s]
		if t != null and t.dmg:
			var c: Array = g.D.BODY_CENTRES[s]
			_tag("dyn:dmg:" + s, "ϟ" if t.dmg == 1 else "ϟϟ", fc + Vector3(-FIG.x / 2 + FIG.x * c[0] / 100.0, 0.05, -FIG.y / 2 + FIG.y * c[1] / 100.0), null, 22, Style.DMG)
	# Decomposition table: one cube per material, up to six in a cell, the count beside them.
	var mats := ["muscle", "organ", "blood", "animal"]
	var cube := BoxMesh.new()
	cube.size = Vector3(0.11, 0.11, 0.11)
	for r in 4:
		var cm := _mat(Style.MAT_COL[mats[r]], 0.6)
		for k in 4:
			var n: int = p.mats[mats[r]][k]
			var key := "%s%d" % [mats[r], k]
			seen[key] = n
			var cc := _mp(DECAY_X0 + k * DECAY_CW, DECAY_ROWS[r], 0.075)
			for j in mini(n, 6):
				var off := Vector3(-0.24 + (j % 3) * 0.14, 0, -0.08 + (j / 3) * 0.16)
				_piece(cube, cm, cc + off, j >= mat_seen.get(key, 0), 0.04 * j)
			if n:
				_tag("dyn:n" + key, str(n), cc + Vector3(0.22, 0.05, 0), null, 17, Style.PARCH)
	_tag("dyn:bone", "Bone %d · Preserved %d/9%s" % [p.bone, p.preserved, (" · Ice %d" % p.ice) if p.ice else ""], _mp(Z_DECAY, 1.42), null, 14, Style.PARCH_DIM, "body")
	# Gold: coins in stacks of six.
	var coin := CylinderMesh.new()
	coin.top_radius = 0.12
	coin.bottom_radius = 0.12
	coin.height = 0.035
	var gold := _glow(Color("#d9a93a"), 0.15)
	gold.metallic = 0.8
	seen.coin = p.coin
	for j in mini(p.coin, 15):
		var layer: int = j / 9
		var q: int = j % 9
		var at_pos := _mp(SUP.coin.x - 0.4 + (q % 3) * 0.2 + layer * 0.1, SUP.coin.y - 0.2 + (q / 3) * 0.2 + layer * 0.1, 0.02 + layer * 0.04)
		_piece(coin, gold, at_pos, j >= mat_seen.get("coin", 0), 0.03 * j)
	_tag("dyn:coin", str(p.coin), _mp(SUP.coin.x + 0.42, SUP.coin.y, 0.2), null, 20, Style.PARCH)
	# Leiden jars: glass, brass cap, a blue core when charged.
	var glass := CylinderMesh.new()
	glass.top_radius = 0.075
	glass.bottom_radius = 0.085
	glass.height = 0.3
	var core := CylinderMesh.new()
	core.top_radius = 0.045
	core.bottom_radius = 0.045
	core.height = 0.22
	var cap := CylinderMesh.new()
	cap.top_radius = 0.05
	cap.bottom_radius = 0.06
	cap.height = 0.05
	var nj: int = p.jars.size()
	for j in nj:
		var x: float = SUP.jar.x - 0.18 * (nj - 1) + j * 0.36 * (1.0 if nj < 4 else 0.75)
		var key := "jar%d" % j
		seen[key] = 2 if p.jars[j] else 1
		var fresh: bool = mat_seen.get(key, 0) == 0
		_piece(glass, _glow(Color("#c9d8e8"), 0.0, 0.35), _mp(x, SUP.jar.y, 0.15), fresh)
		_piece(cap, _mat(Style.BRASS, 0.3), _mp(x, SUP.jar.y, 0.32), fresh)
		_piece(core, _glow(Style.ALIVE, 2.2) if p.jars[j] else _mat(Color("#3a3446")), _mp(x, SUP.jar.y, 0.13), fresh)
	_tag("dyn:jar", "%d/%d" % [g.charged(p), nj], _mp(SUP.jar.x, SUP.jar.y + 0.28, 0.1), null, 17, Style.SPARK if g.charged(p) else Style.PARCH)
	# Ice: pale translucent blocks.
	var ice := BoxMesh.new()
	ice.size = Vector3(0.17, 0.14, 0.17)
	seen.ice = p.ice
	for j in mini(p.ice, 6):
		_piece(ice, _glow(Color("#bfe6ff"), 0.4, 0.75), _mp(SUP.ice.x - 0.3 + (j % 3) * 0.22, SUP.ice.y - 0.08 + (j / 3) * 0.22, 0.07), j >= mat_seen.get("ice", 0), 0.05 * j)
	_tag("dyn:ice", str(p.ice), _mp(SUP.ice.x + 0.42, SUP.ice.y, 0.2), null, 20, Style.PARCH)
	# Police: two badge spots, a red badge on each one you have.
	var spot := CylinderMesh.new()
	spot.top_radius = 0.15
	spot.bottom_radius = 0.15
	spot.height = 0.01
	var badge := CylinderMesh.new()
	badge.top_radius = 0.14
	badge.bottom_radius = 0.14
	badge.height = 0.04
	badge.radial_segments = 6
	seen.police = p.police
	for j in 2:
		var bp := _mp(SUP.police.x - 0.2 + j * 0.4, SUP.police.y, 0.0)
		_piece(spot, _mat(Color("#3a3240")), bp, false)
		if j < p.police:
			_piece(badge, _glow(Style.CRIM, 0.5), bp + Vector3(0, 0.03, 0), j >= mat_seen.get("police", 0))
	_tag("dyn:police", "%d/2" % p.police, _mp(SUP.police.x, SUP.police.y + 0.28, 0.1), null, 17, Style.CRIM if p.police else Style.PARCH)
	# Cards: your hand as a small fan, face up.
	var nh: int = p.hand.size()
	seen.cards = nh
	for j in nh:
		var cn := make_card(p.hand[j])
		cn.scale = Vector3(0.75, 1, 0.75)
		mat_dyn.add_child(cn)
		var to := _mp(SUP.cards.x - 0.22 * (nh - 1) + j * 0.44, SUP.cards.y, 0.02 + j * 0.004)
		cn.rotation_degrees = Vector3(0, -4 + j * 2, 0)
		cn.position = to
		if j >= mat_seen.get("cards", 0):
			cn.position = to + Vector3(0, 1.4, -1.0)
			_fly(cn, to, 0.5, 0.1 * j, 0.6, cn.rotation_degrees)
	if nh == 0:
		_tag("dyn:cards", "No cards yet", _mp(SUP.cards.x, SUP.cards.y), null, 14, Style.MUTED, "body")
	mat_seen = seen
	tags_changed.emit()

## Where a card or cadaver you take lands on your board.
func mat_target(row: String) -> Vector3:
	if row in ["researchRow", "humanityRow"]:
		return _mp(SUP.cards.x, SUP.cards.y, 0.4)
	return _mp(Z_DECAY, 0.0, 0.4)


# ---------------------------------------------------------------- day, night, closed places

func sync() -> void:
	if g.S.is_empty():
		return
	sync_meeples()
	sync_rows()
	sync_mat()
	for id in places:
		if id == "lab":
			continue
		places[id].cross.visible = g.S.closed.has(id)
	places.odeon.root.visible = g.S.get("odeonOpen", false)
	var want_night: bool = g.S.phase == "lab"
	if want_night != night:
		set_night(want_night)
	_refresh_glow()

func set_night(on: bool) -> void:
	night = on
	var tw := create_tween().set_parallel(true)
	tw.tween_property(sun, "light_energy", 0.12 if on else 1.25, 1.6)
	tw.tween_property(sun, "light_color", Color("#7b8cc9") if on else Color("#f2d9a6"), 1.6)
	tw.tween_property(env, "ambient_light_energy", 0.25 if on else 0.9, 1.6)
	for lamp in lamps:
		tw.tween_property(lamp, "light_energy", 2.2 if on else 0.0, 1.8)


# ---------------------------------------------------------------- camera

func _update_camera() -> void:
	cam_rig.position = Vector3(0, 0, 2.55)
	cam_rig.rotation = Vector3(pitch, yaw, 0)
	cam.position = Vector3(0, 0, dist)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			dist = max(6.0, dist - 0.8)
			_update_camera()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			dist = min(28.0, dist + 0.8)
			_update_camera()
	elif event is InputEventMouseMotion and dragging:
		yaw -= event.relative.x * 0.005
		pitch = clamp(pitch - event.relative.y * 0.005, deg_to_rad(-85.0), deg_to_rad(-20.0))
		_update_camera()

func world_to_screen(p: Vector3) -> Vector2:
	return cam.unproject_position(p)

func key_screen_pos(i: int, key: String) -> Vector2:
	return world_to_screen(_key_pos(i, key) + Vector3(0, 0.6, 0))

## How much nearer than the default view the camera is, so the 2D labels can grow and shrink with the zoom.
func zoom_k() -> float:
	return clampf(CAM_DIST / dist, 0.6, 1.8)
