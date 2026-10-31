class_name StatsBoard
extends Node3D
## Your stats board (D199, after Bruno's concept `art/source/ui/stats_board_concept.png`): a flat oak panel in an iron
## frame, its painted face the concept with our numbers on the dials (`assets/cabin/stats_board.webp`, made by
## `art-pipeline/stats_board.py`). Three dials with brass needles: humanity -10 to 10 (0 at the top), reputation 0 to
## 23 and expertise 0 to 27 (clockwise from the lower left). In the middle band: a pewter dish of francs, four small
## sockets for Leyden jars on a copper wire that ends at a terminal on the left edge (the cabin runs the wire on to the
## operating table), and two shields for police badges. Below, three card spaces for your hand.
## `show_stats(p)` sets everything from a player: hum, rep, exp, coin, jars (array of charged flags), police, hand.
## Hover (`hover_at(point)`) shows what is under it; `pick` carries id "stats". Built in code over the painted face;
## metres; positions in the concept's pixels, as in the art script.

const CROP := Rect2(118, 84, 1060, 1058)   # the face's rectangle in the concept, pixels
const SIZE := Vector2(DecayTray.SIZE.y * 1060.0 / 1058.0, DecayTray.SIZE.y)   # as deep as the decomposition board (D200)
const THICK := 0.006
const FACE_R := 113.0
const SWEEP := 140.0
## name, centre, lowest and highest value; the angle runs clockwise from the top (as `stats_board.py`).
const DIALS := [["humanity", Vector2(334, 262), -10, 10], ["reputation", Vector2(644, 262), 0, 23],
	["expertise", Vector2(958, 262), 0, 27]]
const DISH := Vector2(257, 545)
const DISH_R := 52.0
const JARS := [Vector2(476, 545), Vector2(562, 545), Vector2(650, 545), Vector2(738, 545)]
const TERMINAL := Vector2(358, 545)
const BADGES := [Vector2(945, 547), Vector2(1067, 547)]
const CARDS := [Rect2(172, 640, 298, 450), Rect2(502, 640, 286, 450), Rect2(822, 640, 296, 450)]
const BLUE := Color("#8fbcff")             # alive and charged (the colour meanings)

var font: Font
var needles := {}                          # dial name -> Node3D, turned about its pivot
var values := {"humanity": 0, "reputation": 0, "expertise": 0}
var coins := 0
var coin_root: Node3D
var jars: Array = []                       # charged flags
var jar_nodes: Array[Node3D] = []
var jar_glows: Array[MeshInstance3D] = []
var jar_lights: Array[OmniLight3D] = []
var police := 0
var badge_nodes: Array[Node3D] = []
var hand: Array = []                       # card dictionaries from game.json
var card_nodes: Array[Node3D] = []
var pick: StaticBody3D
var count_label: Label3D
var hover_key := ""
var brass: StandardMaterial3D


func _init() -> void:
	font = load("res://assets/fonts/Amarante-Regular.ttf")
	brass = _mat(Color("#d4a750"), 0.4, 0.55)
	_board()
	_needles()
	coin_root = Node3D.new()
	coin_root.position = px(DISH)
	add_child(coin_root)
	_jars()
	_badges()
	for i in 3:
		var n := Node3D.new()
		n.position = px(CARDS[i].get_center())
		add_child(n)
		card_nodes.append(n)
	_hover_bits()


## A point on the concept (pixels) as a point on the board's top (metres).
func px(p: Vector2, y := 0.0) -> Vector3:
	return Vector3(((p.x - CROP.position.x) / CROP.size.x - 0.5) * SIZE.x, THICK + y,
		((p.y - CROP.position.y) / CROP.size.y - 0.5) * SIZE.y)

func _len(pixels: float) -> float:
	return pixels / CROP.size.x * SIZE.x

func _mat(c: Color, rough := 0.5, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
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

func _cylm(r: float, h: float, seg := 16, top := -1.0) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.bottom_radius = r
	c.top_radius = r if top < 0.0 else top
	c.height = h
	c.radial_segments = seg
	c.rings = 1
	return c

## The oak slab and its painted face.
func _board() -> void:
	_add(_boxm(Vector3(SIZE.x, THICK, SIZE.y)), _mat(Color("#2a1c12"), 0.8), Vector3(0, THICK / 2, 0))
	var face := PlaneMesh.new()
	face.size = SIZE
	var fm := StandardMaterial3D.new()
	fm.albedo_texture = load("res://assets/cabin/stats_board.webp")
	fm.roughness = 0.75
	fm.emission_enabled = true                 # as the decay board: its colours survive the candlelight
	fm.emission_texture = fm.albedo_texture
	fm.emission_energy_multiplier = 0.18
	_add(face, fm, Vector3(0, THICK + 0.0002, 0))


# ---------------------------------------------------------------- dials

## Degrees clockwise from the top for a value on a dial.
static func dial_angle(dial: Array, v: int) -> float:
	var lo: int = dial[2]
	var hi: int = dial[3]
	if lo < 0:
		return v * SWEEP / 10.0
	return -SWEEP + (v - lo) * 2.0 * SWEEP / (hi - lo)

func _needles() -> void:
	var dark := _mat(Color("#2a1d12"), 0.4, 0.7)
	for d: Array in DIALS:
		var n := Node3D.new()
		n.position = px(d[1], 0.0016)
		add_child(n)
		var r := _len(FACE_R)
		# A slim blued-steel pointer reaching the ticks, a short tail and the brass cap over the pivot.
		var ptr := _add(_boxm(Vector3(0.0011, 0.0005, r * 0.86)), dark, Vector3(0, 0, -r * 0.43), n)
		ptr.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		_add(_cylm(0.0012, 0.0005, 3), dark, Vector3(0, 0, -r * 0.86), n).rotation_degrees.y = 30
		_add(_boxm(Vector3(0.0018, 0.0005, r * 0.22)), dark, Vector3(0, 0, r * 0.11), n)
		_add(_cylm(0.0026, 0.0018, 16), brass, Vector3(0, 0.0006, 0), n)
		needles[d[0]] = n
		_turn(d, 0, false)

func _turn(d: Array, v: int, animate := true) -> void:
	v = clampi(v, d[2], d[3])
	values[d[0]] = v
	var n: Node3D = needles[d[0]]
	var to := -dial_angle(d, v)              # clockwise seen from above is a negative turn about +y
	if animate and is_inside_tree():
		create_tween().tween_property(n, "rotation_degrees:y", to, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	else:
		n.rotation_degrees.y = to


# ---------------------------------------------------------------- francs

func set_coins(n: int, animate := true) -> void:
	var was := coins
	coins = maxi(n, 0)
	for c in coin_root.get_children():
		c.free()
	var face := _cylm(0.0036, 0.0008, 20)
	var silver := _mat(Color("#d8d2c2"), 0.4, 0.5)
	var gold := _mat(Color("#e0b050"), 0.35, 0.55)
	var rng := RandomNumberGenerator.new()
	rng.seed = 1819
	# Stacks of up to five: one in the middle, six round it.
	var spots: Array[Vector2] = [Vector2.ZERO]
	for k in 6:
		spots.append(Vector2.from_angle(k * TAU / 6.0 + 0.3) * _len(DISH_R) * 0.55)
	for i in coins:
		var spot := spots[i % spots.size()]
		var level := i / spots.size()
		var mi := _add(face, gold if i % 5 == 4 else silver, Vector3(spot.x + rng.randf_range(-0.0005, 0.0005),
			0.0004 + level * 0.0008, spot.y + rng.randf_range(-0.0005, 0.0005)), coin_root)
		mi.rotation_degrees = Vector3(rng.randf_range(-4, 4), rng.randf_range(0, 360), rng.randf_range(-4, 4))
		if i >= was and animate and is_inside_tree():
			var y := mi.position.y
			mi.position.y = y + 0.02
			create_tween().tween_property(mi, "position:y", y, 0.25).set_delay(0.04 * (i - was)).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- Leyden jars

## Four small jars, each a glass bottle with a foil coat, a cork and a brass rod with a ball. Charged, the ball and the
## foil glow blue and cast a little blue light.
func _jars() -> void:
	var glass := _mat(Color(0.82, 0.88, 0.84, 0.18), 0.05)
	glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glass.rim_enabled = true
	glass.rim = 0.5
	var foil := _mat(Color("#8a8a84"), 0.45, 0.7)
	var cork := _mat(Color("#6b4a2c"), 0.8)
	var glow_mat := StandardMaterial3D.new()
	glow_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_mat.albedo_color = BLUE
	glow_mat.emission_enabled = true
	glow_mat.emission = BLUE
	glow_mat.emission_energy_multiplier = 1.2
	glow_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_mat.albedo_color.a = 0.45
	var r := 0.0042
	for p: Vector2 in JARS:
		var n := Node3D.new()
		n.position = px(p)
		n.visible = false
		add_child(n)
		_add(_cylm(r * 0.94, 0.006, 16), foil, Vector3(0, 0.003, 0), n)
		_add(_cylm(r, 0.011, 16), glass, Vector3(0, 0.0055, 0), n).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_add(_cylm(r * 0.7, 0.0025, 12, r * 0.75), cork, Vector3(0, 0.0122, 0), n)
		_add(_cylm(0.0004, 0.006, 6), brass, Vector3(0, 0.0155, 0), n)
		_add(_sphere(0.0013), brass, Vector3(0, 0.019, 0), n)
		var glow := _add(_sphere(0.0018), glow_mat, Vector3(0, 0.019, 0), n)
		glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var light := OmniLight3D.new()
		light.light_color = BLUE
		light.light_energy = 0.015
		light.omni_range = 0.025
		light.position = Vector3(0, 0.02, 0)
		n.add_child(light)
		jar_nodes.append(n)
		jar_glows.append(glow)
		jar_lights.append(light)

func _sphere(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2
	s.radial_segments = 12
	s.rings = 6
	return s

## Jars from the rules: an array of charged flags, up to four.
func set_jars(list: Array, animate := true) -> void:
	var was := jars.size()
	jars = list.slice(0, 4)
	for i in 4:
		var n := jar_nodes[i]
		var have := i < jars.size()
		n.visible = have
		jar_glows[i].visible = have and bool(jars[i])
		jar_lights[i].visible = have and bool(jars[i])
		if have and i >= was and animate and is_inside_tree():
			n.position.y = THICK + 0.02
			create_tween().tween_property(n, "position:y", THICK, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

## Where the copper wire comes out from under the board's left edge, in line with the terminal (the cabin runs it on
## to the table; the coin dish sits between, so the wire goes under the board).
func wire_exit_global() -> Vector3:
	var t := px(TERMINAL)
	return to_global(Vector3(-SIZE.x / 2, THICK * 0.4, t.z))


# ---------------------------------------------------------------- police

## A small brass badge in each shield: a six-pointed star on a round plate.
func _badges() -> void:
	var star := PackedVector2Array()
	for k in 12:
		star.append(Vector2.from_angle(k * TAU / 12.0 - PI / 2) * (0.0062 if k % 2 == 0 else 0.0036))
	var mesh := _extrude(star, 0.0012)
	var dark := _mat(Color("#5a3f1c"), 0.6, 0.4)
	for p: Vector2 in BADGES:
		var n := Node3D.new()
		n.position = px(p)
		n.visible = false
		add_child(n)
		_add(mesh, brass, Vector3.ZERO, n)
		_add(_cylm(0.0022, 0.0004, 16), dark, Vector3(0, 0.0014, 0), n)
		badge_nodes.append(n)

## A flat prism from a 2D outline (x, z), standing h tall from y 0.
func _extrude(poly: PackedVector2Array, h: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tris := Geometry2D.triangulate_polygon(poly)
	st.set_normal(Vector3.UP)
	for i in range(0, tris.size(), 3):
		# The triangulation's winding follows the outline's, so face the top both ways rather than guess.
		for k: int in [0, 2, 1, 0, 1, 2]:
			var q := poly[tris[i + k]]
			st.add_vertex(Vector3(q.x, h, q.y))
	for i in poly.size():
		var a := poly[i]
		var b := poly[(i + 1) % poly.size()]
		var nrm := Vector3(b.y - a.y, 0, -(b.x - a.x)).normalized()
		st.set_normal(nrm)
		for v: Vector3 in [Vector3(a.x, 0, a.y), Vector3(b.x, h, b.y), Vector3(b.x, 0, b.y),
				Vector3(a.x, 0, a.y), Vector3(a.x, h, a.y), Vector3(b.x, h, b.y)]:
			st.add_vertex(v)
	return st.commit()

func set_police(n: int, animate := true) -> void:
	var was := police
	police = clampi(n, 0, 2)
	for i in 2:
		badge_nodes[i].visible = i < police
		if i < police and i >= was and animate and is_inside_tree():
			badge_nodes[i].position.y = THICK + 0.02
			create_tween().tween_property(badge_nodes[i], "position:y", THICK, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- cards

## Up to three cards in the hand, face up, each the browser game's card for its id (D201): rendered with its
## rounded corners by `tools/card_faces.js` into assets/cabin/cards/<id>.png.
func set_hand(cards: Array) -> void:
	hand = cards.slice(0, 3)
	for i in 3:
		for c in card_nodes[i].get_children():
			c.free()
		if i < hand.size():
			_card(card_nodes[i], hand[i], CARDS[i])

func _card(parent: Node3D, card: Dictionary, slot: Rect2) -> void:
	var path := "res://assets/cabin/cards/%s.png" % String(card.get("id", ""))
	if not ResourceLoader.exists(path):
		return
	var tex: Texture2D = load(path)
	# As wide as the space allows, or as tall: the card keeps its own proportions.
	var w := _len(slot.size.x) * 0.92
	var h := w * tex.get_height() / tex.get_width()
	var hmax := _len(slot.size.y) * 0.95
	if h > hmax:
		w *= hmax / h
		h = hmax
	var q := PlaneMesh.new()
	q.size = Vector2(w, h)
	var m := StandardMaterial3D.new()
	m.albedo_texture = tex
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR    # the rounded corners
	m.alpha_scissor_threshold = 0.5
	m.roughness = 0.85
	m.emission_enabled = true                  # as the boards' faces: the card stays readable in the candlelight
	m.emission_texture = tex
	m.emission_energy_multiplier = 0.15
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	_add(q, m, Vector3(0, 0.0006, 0), parent)
	if is_inside_tree():
		parent.position.y = THICK + 0.015
		create_tween().tween_property(parent, "position:y", THICK, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


# ---------------------------------------------------------------- all at once

## From the rules' player: hum, rep, exp, coin, jars, police, hand (cards with id and name).
func show_stats(p: Dictionary, animate := true) -> void:
	_turn(DIALS[0], int(p.get("hum", 0)), animate)
	_turn(DIALS[1], int(p.get("rep", 0)), animate)
	_turn(DIALS[2], int(p.get("exp", 0)), animate)
	set_coins(int(p.get("coin", 0)), animate)
	set_jars(p.get("jars", []), animate)
	set_police(int(p.get("police", 0)), animate)
	set_hand(p.get("hand", []))


# ---------------------------------------------------------------- hover

func _hover_bits() -> void:
	pick = StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SIZE.x, 0.02, SIZE.y)
	shape.shape = box
	shape.position.y = 0.01
	pick.add_child(shape)
	pick.set_meta("id", "stats")
	add_child(pick)
	count_label = Label3D.new()
	count_label.font = font
	count_label.font_size = 48
	count_label.pixel_size = 0.0002
	count_label.outline_size = 14
	count_label.outline_modulate = Color(0.05, 0.03, 0.02, 0.85)
	count_label.modulate = Color(1, 1, 1)      # as the decay board's count (D198)
	count_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	count_label.no_depth_test = true
	count_label.visible = false
	add_child(count_label)

## What a point on the board is over, with where to show it: [key, centre in pixels] or ["", ...].
func spot_at(local: Vector3) -> Array:
	var p := Vector2((local.x / SIZE.x + 0.5) * CROP.size.x + CROP.position.x, (local.z / SIZE.y + 0.5) * CROP.size.y + CROP.position.y)
	for d: Array in DIALS:
		if p.distance_to(d[1]) < FACE_R + 14:
			return [d[0], d[1] + Vector2(0, -FACE_R - 10)]
	if p.distance_to(DISH) < DISH_R + 12:
		return ["coin", DISH + Vector2(0, -DISH_R)]
	if p.y > 500 and p.y < 590 and p.x > TERMINAL.x - 10 and p.x < JARS[3].x + 30:
		return ["jars", Vector2((JARS[1].x + JARS[2].x) / 2, 510)]
	if p.y > 485 and p.y < 610 and p.x > BADGES[0].x - 50 and p.x < BADGES[1].x + 50:
		return ["police", Vector2((BADGES[0].x + BADGES[1].x) / 2, 490)]
	for i in 3:
		if CARDS[i].has_point(p):
			return ["card%d" % i, CARDS[i].get_center() - Vector2(0, CARDS[i].size.y * 0.3)]
	return ["", Vector2.ZERO]

func hover_at(point: Variant) -> void:
	var spot := ["", Vector2.ZERO] if point == null else spot_at(to_local(point))
	var key: String = spot[0]
	if key == hover_key:
		return
	hover_key = key
	var text := ""
	match key:
		"humanity", "reputation", "expertise":
			var v: int = values[key]
			text = "%s %s" % [key, ("+%d" % v) if key == "humanity" and v > 0 else str(v)]
		"coin":
			text = "%d franc%s" % [coins, "" if coins == 1 else "s"]
		"jars":
			var charged := jars.count(true)
			text = "%d jar%s, %d charged" % [jars.size(), "" if jars.size() == 1 else "s", charged]
		"police":
			text = "police %d of 2" % police
		"":
			pass
		_:
			var i := int(key.substr(4))
			text = String(hand[i].get("name", "")) if i < hand.size() else "no card"
	count_label.visible = text != ""
	count_label.text = text
	count_label.position = px(spot[1], 0.025)
