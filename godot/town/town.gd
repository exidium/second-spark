class_name Town
extends RefCounted
## The city (D170): a dense gothic Victorian city on a grid of wet streets, terraces wall to wall round every block,
## a wide river with embankments and bridges, the landmarks the game needs, and blocks that run on until the rain and
## fog take them. Built from a fixed seed. Units are metres; the centre is the origin, +z is south (towards the camera).

const STOREY := 3.4
const BX := 46.0                    # block size between pavements
const BZ := 36.0
const SW := 10.0                    # street width (pavements included)
const PAVE := 2.4
const PX := BX + SW
const PZ := BZ + SW
const NI := 8                       # blocks each way from the centre
const NJ := 8
const DETAIL := 300.0               # beyond this, houses lose chimneys, windows and extras
const GRID := 1.0
const HALF := 600.0
const PITCH := 1.25                 # gothic roofs: rise per metre of half span
const RIVER_Z := 205.0
const RIVER_W := 70.0
const BRIDGES := [-2, 1, 4]         # the north-south streets that cross the river

# Each landmark: name, colour, the block it stands in (i, j), and how high its name floats.
const PLACES := {
	"church": {"name": "Saint-Roch", "col": "#e6c15a", "block": Vector2i(1, -2), "h": 92},
	"square": {"name": "Public Square", "col": "#e0605a", "block": Vector2i(0, 0), "h": 22},
	"first": {"name": "First Player", "col": "#ece4cf", "block": Vector2i(-1, -1), "h": 82},
	"market": {"name": "Market", "col": "#e8964a", "block": Vector2i(-2, 0), "h": 30},
	"academy": {"name": "Academy", "col": "#7cc4ff", "block": Vector2i(2, 0), "h": 46},
	"hospital": {"name": "Hospital", "col": "#bcd8f0", "block": Vector2i(-2, 2), "h": 36},
	"odeon": {"name": "Odéon", "col": "#d98cc0", "block": Vector2i(1, 1), "h": 36},
	"alley": {"name": "Dark Alley", "col": "#b48ae0", "block": Vector2i(3, -1), "h": 30},
	"cemetery": {"name": "Graveyard", "col": "#8fbf6a", "block": Vector2i(-3, -2), "h": 26},
	"slaughter": {"name": "Slaughterhouse", "col": "#c0503f", "block": Vector2i(4, 1), "h": 40},
	"docks": {"name": "Docks", "col": "#f08a3c", "block": Vector2i(2, 3), "h": 30},
	"morgue": {"name": "Morgue", "col": "#5fc4b8", "block": Vector2i(-1, 3), "h": 24},
}

var rng := RandomNumberGenerator.new()
var mats := {}
var occ := PackedByteArray()        # 1 m cells: 0 free, 1 street, 2 built, 3 water, 4 kept open
var streets := []                    # [Vector2 a, Vector2 b, float width]
var labels := []                     # {text, col, pos: Vector3}
var lights := []                     # {pos: Vector3, col, energy, range}
var trees := []                      # [Vector3 pos, float size, Color]
var lamps := []                      # Vector3 lamp bases
var houses := 0


# ---------------------------------------------------------------- materials

func _tex(file: String, rough := 0.9, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/art/town/%s.webp" % file)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	m.vertex_color_use_as_albedo = true
	m.roughness = rough
	m.metallic = metal
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _col(c: Color, e := 0.0, rough := 0.85) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.vertex_color_use_as_albedo = true
	m.roughness = rough
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if e > 0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = e
	return m

func _make_mats() -> void:
	mats["stone"] = _tex("gothic-stone")
	mats["brick"] = _tex("gothic-brick")
	mats["shop"] = _tex("gothic-shop")
	mats["slate"] = _tex("slate", 0.35, 0.1)
	mats["street"] = _tex("wet-cobbles", 0.12, 0.25)
	mats["pave"] = _tex("flagstones", 0.22, 0.15)
	mats["grass"] = _tex("grass")
	mats["water"] = _tex("water", 0.04, 0.5)
	mats["iron"] = _col(Color("#15161a"), 0.0, 0.4)
	mats["wood"] = _col(Color("#2c241f"))
	mats["glass"] = _col(Color("#5d6c74"), 0.0, 0.05)
	mats["glass"].metallic = 0.7
	mats["win"] = _col(Color("#ffbf6e"), 1.3)
	mats["gas"] = _col(Color("#ffd49a"), 4.0)
	for id in PLACES:
		mats["glow:" + id] = _col(Color(PLACES[id].col), 3.0)


# ---------------------------------------------------------------- occupancy grid

func _i(p: Vector2) -> int:
	var n := int(2 * HALF / GRID)
	var x := int(floor((p.x + HALF) / GRID))
	var z := int(floor((p.y + HALF) / GRID))
	if x < 0 or z < 0 or x >= n or z >= n:
		return -1
	return z * n + x

func cell(p: Vector2) -> int:
	var i := _i(p)
	return 255 if i < 0 else occ[i]

func _obb_cells(c: Vector2, ang: float, hx: float, hz: float) -> Array:
	var out := []
	var ax := Vector2(cos(ang), sin(ang))
	var az := Vector2(-ax.y, ax.x)
	var ex := absf(ax.x) * hx + absf(az.x) * hz
	var ez := absf(ax.y) * hx + absf(az.y) * hz
	var x := floorf(c.x - ex)
	while x <= c.x + ex:
		var z := floorf(c.y - ez)
		while z <= c.y + ez:
			var q := Vector2(x + 0.5, z + 0.5) - c
			if absf(q.dot(ax)) <= hx and absf(q.dot(az)) <= hz:
				out.append(_i(Vector2(x + 0.5, z + 0.5)))
			z += GRID
		x += GRID
	return out

func mark(c: Vector2, ang: float, hx: float, hz: float, v: int) -> void:
	for i in _obb_cells(c, ang, hx, hz):
		if i >= 0:
			occ[i] = maxi(occ[i], v)

func is_free(c: Vector2, ang: float, hx: float, hz: float) -> bool:
	for i in _obb_cells(c, ang, hx, hz):
		if i < 0 or occ[i] != 0:
			return false
	return true

func block_center(b: Vector2i) -> Vector2:
	return Vector2(b.x * PX, b.y * PZ)

func river_z(x: float) -> float:
	return RIVER_Z + 22.0 * sin(x / 140.0) + 8.0 * sin(x / 53.0)

func in_water(p: Vector2, margin := 0.0) -> bool:
	return absf(p.y - river_z(p.x)) < RIVER_W / 2 + margin


# ---------------------------------------------------------------- streets and the river

func _street_quad(k: Kit, a: Vector2, b: Vector2, w: float) -> void:
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var len := a.distance_to(b)
	# Carriageway, then a raised pavement either side.
	var cw := w / 2 - PAVE
	k.quad("street", Vector3(a.x + n.x * cw, 0.05, a.y + n.y * cw), Vector3(b.x + n.x * cw, 0.05, b.y + n.y * cw), Vector3(b.x - n.x * cw, 0.05, b.y - n.y * cw), Vector3(a.x - n.x * cw, 0.05, a.y - n.y * cw),
		Vector2(0, 0), Vector2(len / 7, 0), Vector2(len / 7, cw * 2 / 7), Vector2(0, cw * 2 / 7))
	for s: float in [-1.0, 1.0]:
		var o0 := n * s * cw
		var o1 := n * s * (w / 2)
		k.quad("pave", Vector3(a.x + o0.x, 0.2, a.y + o0.y), Vector3(b.x + o0.x, 0.2, b.y + o0.y), Vector3(b.x + o1.x, 0.2, b.y + o1.y), Vector3(a.x + o1.x, 0.2, a.y + o1.y),
			Vector2(0, 0), Vector2(len / 5, 0), Vector2(len / 5, PAVE / 5), Vector2(0, PAVE / 5))
		k.quad("pave", Vector3(a.x + o0.x, 0.05, a.y + o0.y), Vector3(b.x + o0.x, 0.05, b.y + o0.y), Vector3(b.x + o0.x, 0.2, b.y + o0.y), Vector3(a.x + o0.x, 0.2, a.y + o0.y),
			Vector2(0, 0), Vector2(len / 5, 0), Vector2(len / 5, 0.03), Vector2(0, 0.03), Color(0.7, 0.7, 0.7))

func street(k: Kit, a: Vector2, b: Vector2, w: float) -> void:
	streets.append([a, b, w])
	_street_quad(k, a, b, w)
	var d := b - a
	for ii in _obb_cells((a + b) / 2, d.angle(), d.length() / 2, w / 2):
		if ii >= 0 and occ[ii] == 0:
			occ[ii] = 1
	# Gas lamps along the pavements near the centre.
	if (a + b).length() / 2 < DETAIL:
		var n := d.normalized().orthogonal()
		var t := 8.0
		while t < d.length() - 4:
			for s: float in [-1.0, 1.0]:
				var p := a + d.normalized() * t + n * s * (w / 2 - 0.6)
				if not in_water(p, 2):
					lamps.append(Vector3(p.x, 0.2, p.y))
			t += 24.0

func _build_streets(k: Kit) -> void:
	# East-west streets, cut at the river.
	for j in range(-NJ, NJ + 2):
		var z := (j - 0.5) * PZ
		if absf(z - RIVER_Z) < RIVER_W / 2 + 30:
			continue
		for i in range(-NI, NI + 1):
			street(k, Vector2((i - 0.5) * PX, z), Vector2((i + 0.5) * PX, z), SW + (4.0 if j == 0 else 0.0))
	# North-south streets, stopping at the river (the bridges carry three of them over).
	for i in range(-NI, NI + 2):
		var x := (i - 0.5) * PX
		for j in range(-NJ, NJ + 1):
			var a := Vector2(x, (j - 0.5) * PZ)
			var b := Vector2(x, (j + 0.5) * PZ)
			if in_water(a, 8) or in_water(b, 8) or in_water((a + b) / 2, 8):
				continue
			street(k, a, b, SW + (4.0 if i == 0 else 0.0))
	# Two diagonal avenues cutting through the blocks, as the old roads did.
	street(k, Vector2(-7.5 * PX, -6.5 * PZ), Vector2(-0.5 * PX, -0.5 * PZ), 14.0)
	street(k, Vector2(0.5 * PX, -0.5 * PZ), Vector2(6.5 * PX, -6.5 * PZ), 12.0)
	# Embankment roads along both banks.
	var x := -(NI + 0.5) * PX
	while x < (NI + 0.5) * PX:
		for s: float in [-1.0, 1.0]:
			var a := Vector2(x, river_z(x) + s * (RIVER_W / 2 + 7))
			var b := Vector2(x + 20, river_z(x + 20) + s * (RIVER_W / 2 + 7))
			street(k, a, b, 12.0)
		x += 20

func _build_river(k: Kit) -> void:
	var x := -2000.0
	while x < 2000.0:
		var x2 := x + 10
		var za := river_z(x)
		var zb := river_z(x2)
		var h := RIVER_W / 2
		k.quad("water", Vector3(x, -1.2, za - h), Vector3(x2, -1.2, zb - h), Vector3(x2, -1.2, zb + h), Vector3(x, -1.2, za + h),
			Vector2(x / 30, (za - h) / 30), Vector2(x2 / 30, (zb - h) / 30), Vector2(x2 / 30, (zb + h) / 30), Vector2(x / 30, (za + h) / 30), Color(0.55, 0.6, 0.6))
		for s: float in [-1.0, 1.0]:
			# Stone embankment walls down to the water, a parapet on top.
			var e0 := Vector2(x, za + s * h)
			var e1 := Vector2(x2, zb + s * h)
			k.wall("stone", e0, e1, -1.2, 0.2, 4, 4, Color(0.6, 0.62, 0.64))
			k.box("stone", (e0 + e1) / 2 + Vector2(0, -s * 0.4), 10.0, 0.6, 0.2, 1.2, 3, 3, Color(0.7, 0.72, 0.74))
		x = x2
	var xx := -HALF
	while xx < HALF:
		mark(Vector2(xx, river_z(xx)), 0.0, 1.0, RIVER_W / 2 + 1, 3)
		xx += 1.0
	# Bridges: a stone deck on piers, lamps along the parapets.
	for i in BRIDGES:
		var bx: float = (i - 0.5) * PX
		var cz := river_z(bx)
		var len := RIVER_W + 30
		k.box("stone", Vector2(bx, cz), 16, len, -1.2, 1.6, 4, 4, Color(0.72, 0.73, 0.75), "street")
		for s: float in [-1.0, 1.0]:
			k.box("stone", Vector2(bx + s * 7.6, cz), 0.8, len, 1.6, 2.8, 3, 3, Color(0.65, 0.66, 0.68))
			for t in 5:
				var p := Vector2(bx + s * 7.6, cz - len / 2 + 10 + t * (len - 20) / 4)
				lamps.append(Vector3(p.x, 2.8, p.y))
		for t in 3:
			k.box("stone", Vector2(bx, cz - RIVER_W / 2 + 12 + t * 23), 13, 5, -1.2, -0.2, 3, 3)
		mark(Vector2(bx, cz), 0.0, 9, len / 2, 1)


# ---------------------------------------------------------------- houses

## Window tile width for a wall of this span: one window per tile, centred.
func _tw(span: float) -> float:
	return span / maxf(1.0, round(span / 3.2))

## A gothic terrace house in its own frame: frontage w along x, depth d, the street on +z.
func gothic_house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int, detail: bool, corner := false) -> void:
	var saved := k.xf
	k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
	var brick := rng.randf() < 0.45
	var kw := "brick" if brick else "stone"
	var t := rng.randf_range(0.8, 1.0)
	var cw := Color(t, t * rng.randf_range(0.95, 1.0), t * rng.randf_range(0.95, 1.05))
	var h := floors * STOREY
	var twf := _tw(w)
	var twd := _tw(d)
	var shop := detail and rng.randf() < 0.4
	# Front and back, then the sides (party walls, mostly hidden).
	var y0 := STOREY if shop else 0.0
	if shop:
		k.wall("shop", Vector2(-w / 2, d / 2), Vector2(w / 2, d / 2), 0, STOREY, twf, STOREY, cw)
	k.wall(kw, Vector2(-w / 2, d / 2), Vector2(w / 2, d / 2), y0, h, twf, STOREY, cw)
	k.wall(kw, Vector2(w / 2, -d / 2), Vector2(-w / 2, -d / 2), 0, h, twf, STOREY, cw)
	k.wall(kw, Vector2(w / 2, d / 2), Vector2(w / 2, -d / 2), 0, h, twd, STOREY, cw)
	k.wall(kw, Vector2(-w / 2, -d / 2), Vector2(-w / 2, d / 2), 0, h, twd, STOREY, cw)
	# A stone cornice.
	k.box("stone", Vector2.ZERO, w + 0.3, d + 0.3, h - 0.35, h, 2, 2, cw * 0.85)
	var cr := Color(0.8, 0.82, 0.88) * rng.randf_range(0.65, 1.0)
	var roll := rng.randf()
	var rh := 0.0
	if roll < 0.62:
		# Steep pointed gable facing the street, a finial on its point.
		rh = w / 2 * PITCH * rng.randf_range(0.9, 1.3)
		var s2 := k.xf
		k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
		k.gable("slate", kw, Vector2.ZERO, d, w, h, rh, 0.4, 4.0, twf, STOREY, cr, cw)
		k.xf = s2
		if detail:
			k.pinnacle("stone", Vector2(0, d / 2 + 0.2), 0.35, h + rh - 0.4, 2.6, cw)
			k.pinnacle("stone", Vector2(0, -d / 2 - 0.2), 0.3, h + rh - 0.4, 1.8, cw)
	elif roll < 0.85:
		# Steep mansard with gabled dormers.
		rh = rng.randf_range(4.0, 6.0)
		k.hip("slate", Vector2.ZERO, w, d, h, rh, 0.3, 4.0, cr)
		if detail:
			var nd := maxi(1, int(w / 3.6))
			for j in nd:
				var dx := -w / 2 + (j + 0.5) * w / nd
				var s3 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
				k.walls(kw, Vector2(-(d / 2 - 0.9), dx), 1.6, 1.8, h, h + 2.2, 1.8, STOREY, cw)
				k.gable("slate", kw, Vector2(-(d / 2 - 0.9), dx), 1.8, 2.0, h + 2.2, 1.6, 0.15, 2.0, 1.8, STOREY, cr, cw)
				k.xf = s3
				if rng.randf() < 0.3:
					k.pane("win", Vector3(dx, h + 1.1, d / 2 - 0.05), Vector3.BACK, 0.7, 1.2)
	else:
		# Ridge along the street with a tall pointed cross-gable over the middle.
		rh = d / 2 * 0.95
		k.gable("slate", kw, Vector2.ZERO, w, d, h, rh, 0.4, 4.0, twd, STOREY, cr, cw)
		if detail and w >= 5.5:
			var s4 := k.xf
			k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
			k.walls(kw, Vector2(-d / 4, 0), d / 2, 2.8, h, h + 1.2, 2.8, STOREY, cw)
			k.gable("slate", kw, Vector2(-d / 4, 0), d / 2, 2.8, h + 1.2, 3.4, 0.25, 3.0, 2.8, STOREY, cr, cw)
			k.xf = s4
			k.pinnacle("stone", Vector2(0, d / 2), 0.3, h + 4.2, 1.8, cw)
	if detail:
		# Chimney stacks on the party walls, with pots.
		for s: float in [-1.0, 1.0]:
			if rng.randf() < 0.75:
				var cz := rng.randf_range(-d / 4, d / 6)
				var top := h + rh * 0.75 + rng.randf_range(0.5, 2.0)
				k.box("brick", Vector2(s * (w / 2 - 0.4), cz), 0.8, 1.8, h, top, 1.6, 1.6, cw * 0.8)
				for p in 3:
					k.cylinder("brick", Vector2(s * (w / 2 - 0.4), cz - 0.6 + p * 0.6), 0.16, top, top + 0.5, 6, 1, 1, Color(0.6, 0.45, 0.4))
		# A bay window rising through the upper floors.
		if floors >= 3 and w >= 5 and rng.randf() < 0.35:
			var bw := 2.4
			k.walls(kw, Vector2(0, d / 2 + 0.45), bw, 0.9, STOREY, h - STOREY * 0.4, 1.2, STOREY, cw)
			k.hip("slate", Vector2(0, d / 2 + 0.45), bw, 0.9, h - STOREY * 0.4, 0.8, 0.1, 2.0, cr)
			for f in range(1, floors):
				if rng.randf() < 0.35:
					k.pane("win", Vector3(0, f * STOREY + STOREY * 0.55, d / 2 + 0.92), Vector3.BACK, 0.8, 1.6)
		# A corner turret.
		if corner and rng.randf() < 0.55:
			k.turret(kw, "slate", Vector2(w / 2 - 0.4, d / 2 - 0.4), 1.9, STOREY, h + 2.0, 6.5, 2.0, STOREY, cw, cr)
		# Lit windows on the street front.
		var n := int(round(w / twf))
		for f in range(1 if shop else 0, floors):
			for j in n:
				if rng.randf() < 0.18:
					k.pane("win", Vector3(-w / 2 + (j + 0.5) * twf, f * STOREY + STOREY * 0.56, d / 2), Vector3.BACK, 0.62, 1.25)
		if shop and rng.randf() < 0.6:
			k.pane("win", Vector3(-w / 2 + twf * 0.62, STOREY * 0.48, d / 2), Vector3.BACK, twf * 0.38, STOREY * 0.5)
	k.xf = saved
	houses += 1

func _try_house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int, corner := false) -> bool:
	if not is_free(c, ang, w / 2 - 0.05, d / 2 - 0.05):
		return false
	gothic_house(k, c, ang, w, d, floors, c.length() < DETAIL, corner)
	mark(c, ang, w / 2, d / 2, 2)
	return true

## Line every street with terraces, wall to wall, facing it; then the yards behind.
func _build_houses(k: Kit) -> void:
	for s in streets:
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		var sw: float = s[2]
		var dir := (b - a).normalized()
		var len := a.distance_to(b)
		var ang := dir.angle()
		for side: float in [-1.0, 1.0]:
			var n := Vector2(-dir.y, dir.x) * side
			var t := 0.0
			var first := true
			while t < len:
				var w: float = [4.6, 5.4, 6.2, 7.0][rng.randi_range(0, 3)]
				var d := rng.randf_range(10.0, 14.0)
				var c := a + dir * (t + w / 2) + n * (sw / 2 + 0.1 + d / 2)
				var floors := rng.randi_range(3, 5) if c.length() < 220 else rng.randi_range(3, 4)
				var face := ang + (PI if side > 0 else 0.0)
				var ok := _try_house(k, c, face, w, d, floors, first or t + w >= len - 6)
				first = false
				t += w if ok else 1.5
	# Back yards: sheds and workshops, a tree now and then.
	for i in 14000:
		var c := Vector2(rng.randf_range(-(NI + 0.5) * PX, (NI + 0.5) * PX), rng.randf_range(-(NJ + 0.5) * PZ, (NJ + 0.5) * PZ))
		if cell(c) != 0:
			continue
		var ang := snappedf(rng.randf_range(-PI, PI), PI / 2)
		if rng.randf() < 0.7:
			_try_house(k, c, ang, rng.randf_range(3.5, 6.0), rng.randf_range(3.0, 5.0), rng.randi_range(1, 2))
		elif c.length() < DETAIL and is_free(c, 0, 2, 2):
			trees.append([Vector3(c.x, 0, c.y), rng.randf_range(2.5, 3.5), _leaf()])
			mark(c, 0, 2, 2, 4)

func _leaf() -> Color:
	var t := rng.randf_range(0.6, 1.0)
	return Color(0.3 * t, 0.36 * t, 0.28 * t)


# ---------------------------------------------------------------- landmarks

## Bruno's models: godot/assets/models/<id>.glb replaces the drawn landmark when it exists.
func _model(id: String) -> Node3D:
	var path := "res://assets/models/%s.glb" % id
	if ResourceLoader.exists(path):
		return (load(path) as PackedScene).instantiate()
	return null

func _label(id: String, c: Vector2) -> void:
	labels.append({"text": PLACES[id].name, "col": Color(PLACES[id].col), "pos": Vector3(c.x, PLACES[id].h, c.y)})
	lights.append({"pos": Vector3(c.x, 10.0, c.y + BZ / 2 + 2), "col": Color(PLACES[id].col), "energy": 9.0, "range": 40.0})

func _yard(k: Kit, c: Vector2, w: float, d: float, kind: String) -> void:
	k.flat(kind, c, w, d, 0.22, 5.0 if kind == "pave" else 8.0, Color(0.75, 0.75, 0.75))

func _build_landmarks(root: Node3D, k: Kit) -> void:
	var st := Color(0.78, 0.8, 0.82)
	var sl := Color(0.75, 0.78, 0.85)
	for id in PLACES:
		var c := block_center(PLACES[id].block)
		mark(c, 0, BX / 2, BZ / 2, 4)
		_label(id, c)
		var m := _model(id)
		if m != null:
			m.position = Vector3(c.x, 0, c.y)
			root.add_child(m)
			continue
		k.xf = Transform3D(Basis.IDENTITY, Vector3(c.x, 0, c.y))
		var g: String = "glow:" + id
		match id:
			"church":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				# Nave along x, aisles, buttresses with pinnacles, a west tower and spire, a rose window, an apse.
				k.walls("stone", Vector2(2, 0), 34, 11, 0, 20, 3.4, 4.0, st)
				k.gable("slate", "stone", Vector2(2, 0), 34, 11, 20, 9, 0.4, 4, 3.4, 4, sl, st)
				for s: float in [-1.0, 1.0]:
					k.walls("stone", Vector2(2, s * 8.5), 34, 6, 0, 10, 3.4, 4.0, st)
					k.hip("slate", Vector2(2, s * 8.5), 34, 6, 10, 2.5, 0.3, 4, sl)
					for j in 6:
						var bxp := -12.0 + j * 5.6
						k.box("stone", Vector2(bxp, s * 11.8), 1.0, 1.4, 0, 14, 2, 2, st)
						k.pinnacle("stone", Vector2(bxp, s * 11.8), 0.8, 14, 3.5, st)
						k.pane(g, Vector3(bxp + 2.8, 14.5, s * 5.55), Vector3(0, 0, s), 1.4, 5.0)
				k.box("stone", Vector2(-18, 0), 10, 10, 0, 34, 3.4, 4.0, st)
				for cx: float in [-1.0, 1.0]:
					for cz: float in [-1.0, 1.0]:
						k.pinnacle("stone", Vector2(-18 + cx * 4.6, cz * 4.6), 1.0, 34, 6, st)
				k.pyramid("slate", Vector2(-18, 0), 8.4, 8.4, 34, 38, 4, sl)
				k.pane(g, Vector3(-23.05, 22, 0), Vector3.LEFT, 5.5, 5.5)
				k.pane(g, Vector3(-23.05, 6, 0), Vector3.LEFT, 3.0, 7.0)
				k.turret("stone", "slate", Vector2(19, 0), 5.5, 0, 18, 7, 3.4, 4, st, sl)
			"first":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				# A clock tower: tall square shaft, lit faces, pinnacles and a spire, a hall at its foot.
				k.box("stone", Vector2(0, 0), 9, 9, 0, 46, 3.0, 4.0, st)
				k.box("stone", Vector2(0, 0), 10.5, 10.5, 46, 53, 3.0, 3.5, st)
				for nv in [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]:
					k.pane(g, Vector3(0, 49.5, 0) + nv * 5.25, nv, 5.0, 5.0)
				for cx: float in [-1.0, 1.0]:
					for cz: float in [-1.0, 1.0]:
						k.pinnacle("stone", Vector2(cx * 4.9, cz * 4.9), 1.0, 53, 5, st)
				k.pyramid("slate", Vector2.ZERO, 9.5, 9.5, 53, 20, 4, sl)
				k.walls("stone", Vector2(0, 10), 30, 9, 0, 12, 3.4, 4, st)
				k.gable("slate", "stone", Vector2(0, 10), 30, 9, 12, 6, 0.4, 4, 3.4, 4, sl, st)
				for j in 7:
					k.pane("win", Vector3(-12 + j * 4, 7, 14.55), Vector3.BACK, 1.0, 2.6)
			"square":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				k.flat("grass", Vector2.ZERO, BX - 14, BZ - 14, 0.25, 8, Color(0.6, 0.65, 0.6))
				k.box("stone", Vector2(0, 0), 3, 3, 0, 3, 2, 2, st)
				k.cylinder("iron", Vector2(0, 0), 0.6, 3, 7, 8, 1, 1)
				k.box(g, Vector2(0, 0), 1.2, 1.2, 7, 8.2, 1, 1)
				# The scaffold.
				k.box("wood", Vector2(10, -6), 7, 6, 0, 2.4, 2, 2)
				k.box("wood", Vector2(8, -6), 0.5, 0.5, 2.4, 9, 1, 1)
				k.box("wood", Vector2(9.6, -6), 3.6, 0.4, 8.6, 9.0, 1, 1)
				k.box("iron", Vector2(11.1, -6), 0.08, 0.08, 6.0, 8.6, 1, 1)
				for j in 8:
					var a := TAU * j / 8
					trees.append([Vector3(c.x + cos(a) * 14, 0, c.y + sin(a) * 10), 3.2, _leaf()])
			"market":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				# An iron-and-glass hall on iron columns, a raised glass lantern along the ridge.
				for x in range(-18, 19, 6):
					for z: float in [-12.0, 12.0]:
						k.box("iron", Vector2(x, z), 0.6, 0.6, 0, 9, 1, 1)
				k.hip("glass", Vector2.ZERO, 40, 26, 9, 7, 0.6, 6, Color(0.9, 0.95, 1.0))
				k.walls("iron", Vector2.ZERO, 40.4, 26.4, 8.4, 9.0, 2, 2)
				k.box("glass", Vector2.ZERO, 8, 26, 16, 18.5, 4, 4)
				k.pane(g, Vector3(0, 4, 12.0), Vector3.BACK, 30, 2.5)
				for j in 6:
					k.box("wood", Vector2(-15 + j * 6, 4), 3.5, 2, 0, 1.0, 1, 1)
			"academy":
				_yard(k, Vector2.ZERO, BX, BZ, "grass")
				# A gothic college round a quad, a gate tower with four turrets on the front.
				for wing in [[Vector2(0, -13), 42.0, 9.0], [Vector2(0, 13), 42.0, 9.0], [Vector2(-17, 0), 8.0, 18.0], [Vector2(17, 0), 8.0, 18.0]]:
					var wc: Vector2 = wing[0]
					var ww: float = wing[1]
					var wd: float = wing[2]
					k.walls("stone", wc, ww, wd, 0, 13.6, _tw(ww), STOREY, st)
					k.hip("slate", wc, ww, wd, 13.6, 5, 0.3, 4, sl)
				for j in 11:
					k.pane(g if j % 3 == 0 else "win", Vector3(-19 + j * 3.8, 5 + (j % 2) * 3.4, 17.55), Vector3.BACK, 0.8, 1.8)
				k.box("stone", Vector2(0, 13), 9, 11, 0, 30, 3, 4, st)
				for cx: float in [-1.0, 1.0]:
					for cz: float in [-1.0, 1.0]:
						k.turret("stone", "slate", Vector2(cx * 4.5, 13 + cz * 5.5), 1.4, 0, 33, 5, 2, 4, st, sl)
				k.pane(g, Vector3(0, 22, 18.55), Vector3.BACK, 3.0, 5.0)
			"hospital":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				for wing in [[Vector2(0, -13), 44.0, 10.0], [Vector2(0, 13), 44.0, 10.0], [Vector2(-18, 0), 8.0, 16.0], [Vector2(18, 0), 8.0, 16.0]]:
					var wc: Vector2 = wing[0]
					var ww: float = wing[1]
					var wd: float = wing[2]
					k.walls("brick", wc, ww, wd, 0, 17, _tw(ww), STOREY, Color(0.85, 0.8, 0.78))
					k.hip("slate", wc, ww, wd, 17, 6, 0.3, 4, sl)
				for f in 5:
					for j in 12:
						if rng.randf() < 0.45:
							k.pane(g, Vector3(-20 + j * 3.6, 1.9 + f * STOREY, 18.05), Vector3.BACK, 0.65, 1.3)
				k.box("brick", Vector2(0, 18), 8, 3, 0, 22, 2, 4, Color(0.85, 0.8, 0.78))
				k.pyramid("slate", Vector2(0, 18), 8, 3.4, 22, 6, 4, sl)
			"odeon":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				k.walls("stone", Vector2(0, -3), 36, 26, 0, 20, 3.4, 4, st)
				k.hip("slate", Vector2(0, -3), 36, 26, 20, 7, 0.4, 4, sl)
				for j in 5:
					var ax := -12.0 + j * 6
					k.box("stone", Vector2(ax, 12), 1.2, 1.2, 0, 11, 2, 2, st)
					k.pinnacle("stone", Vector2(ax, 12), 1.0, 11, 3.5, st)
				k.box("stone", Vector2(0, 12), 26, 1.6, 9, 11, 3, 3, st)
				for j in 4:
					k.pane(g, Vector3(-9 + j * 6, 4.5, 10.05), Vector3.BACK, 3.0, 6.5)
				k.pane(g, Vector3(0, 15, 10.05), Vector3.BACK, 6.0, 4.0)
			"alley":
				# A narrow lane through the block between tall, crooked houses.
				k.xf = Transform3D.IDENTITY
				_yard(k, c, BX, BZ, "pave")
				k.flat("street", c, 3.0, BZ, 0.26, 6, Color(0.5, 0.5, 0.55))
				for side: float in [-1.0, 1.0]:
					var z := -BZ / 2
					while z < BZ / 2 - 3:
						var w := rng.randf_range(4.0, 5.5)
						var hc := c + Vector2(side * (1.5 + 6.5), z + w / 2)
						var face := PI / 2 + (PI if side < 0 else 0.0)
						gothic_house(k, hc, face, w, 13, rng.randi_range(4, 6), true)
						z += w
				k.box("iron", c + Vector2(0, 2), 0.25, 0.25, 0, 5.5, 1, 1)
				k.box(g, c + Vector2(0, 2), 0.9, 0.9, 5.5, 6.5, 1, 1)
			"cemetery":
				_yard(k, Vector2.ZERO, BX, BZ, "grass")
				for s: float in [-1.0, 1.0]:
					k.box("iron", Vector2(s * (BX / 2 - 0.5), 0), 0.2, BZ - 1, 0, 2.4, 1, 1)
					k.box("iron", Vector2(0, s * (BZ / 2 - 0.5)), BX - 1, 0.2, 0, 2.4, 1, 1)
				k.walls("stone", Vector2(0, -9), 9, 15, 0, 9, 3, 4, st)
				var s1 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
				k.gable("slate", "stone", Vector2(9, 0), 15, 9, 9, 6.5, 0.3, 4, 3, 4, sl, st)
				k.xf = s1
				k.box("stone", Vector2(0, -1), 3, 3, 0, 15, 2, 3, st)
				k.pyramid("slate", Vector2(0, -1), 3.4, 3.4, 15, 7, 3, sl)
				k.pane(g, Vector3(0, 4, 0.55), Vector3.BACK, 1.4, 3.0)
				for j in 90:
					var hp := Vector2(rng.randf_range(-BX / 2 + 2, BX / 2 - 2), rng.randf_range(-BZ / 2 + 2, BZ / 2 - 2))
					if absf(hp.x) < 7 and hp.y < 2:
						continue
					k.box("stone", hp, 0.9, 0.3, 0, rng.randf_range(0.9, 1.8), 1, 1, Color(0.7, 0.7, 0.72))
				for j in 7:
					trees.append([Vector3(c.x + rng.randf_range(-20, 20), 0, c.y + rng.randf_range(-15, 15)), 3.0, Color(0.2, 0.22, 0.2)])
			"slaughter":
				_yard(k, Vector2.ZERO, BX, BZ, "pave")
				for s: float in [-1.0, 1.0]:
					k.walls("brick", Vector2(0, s * 11), 42, 10, 0, 8, 3.2, 4, Color(0.7, 0.62, 0.6))
					k.gable("slate", "brick", Vector2(0, s * 11), 42, 10, 8, 5, 0.4, 4, 3.2, 4, sl, Color(0.7, 0.62, 0.6))
					for j in 7:
						k.pane(g, Vector3(-18 + j * 6, 3, s * 16.05), Vector3(0, 0, s), 1.4, 1.6)
				k.cylinder("brick", Vector2(17, 0), 2.0, 0, 34, 10, 2, 4, Color(0.6, 0.5, 0.48))
				for j in 6:
					k.box("wood", Vector2(-14 + j * 5, 0), 4, 0.2, 0, 1.3, 1, 1)
			"docks":
				# On the north embankment: warehouses on the quay, cranes over the water, barges.
				k.xf = Transform3D.IDENTITY
				var qz := river_z(c.x) - RIVER_W / 2
				var qc := Vector2(c.x, qz - 26)
				for j in 3:
					var wc := qc + Vector2(-30 + j * 30, 0)
					k.walls("brick", wc, 24, 16, 0, 15, _tw(24), STOREY, Color(0.75, 0.68, 0.62))
					var s5 := k.xf
					k.xf = Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(wc.x, 0, wc.y))
					k.gable("slate", "brick", Vector2.ZERO, 16, 24, 15, 7, 0.4, 4, 3.2, STOREY, sl, Color(0.75, 0.68, 0.62))
					k.xf = s5
					k.pane(g, Vector3(wc.x, 4, wc.y + 8.05), Vector3.BACK, 4.0, 6.0)
					mark(wc, 0, 12, 8, 2)
				for j in 2:
					var cp := Vector2(c.x - 20 + j * 40, qz + 1)
					k.box("wood", cp, 1.2, 1.2, 0, 16, 1, 1)
					k.box("wood", cp + Vector2(0, 5), 0.8, 11, 15, 16, 1, 1)
					k.box("iron", cp + Vector2(0, 10), 0.08, 0.08, 6, 15, 1, 1)
					var bc := Vector2(c.x - 26 + j * 46, qz + 10)
					k.box("wood", bc, 26, 7, -1.4, 0.6, 2, 2)
					k.box("wood", bc + Vector2(-6, 0), 6, 4.5, 0.6, 2.4, 2, 2)
			"morgue":
				k.xf = Transform3D.IDENTITY
				var mz := river_z(c.x) - RIVER_W / 2 - 26
				var mc := Vector2(c.x, mz)
				k.walls("stone", mc, 18, 12, 0, 9, 3, 4, Color(0.7, 0.75, 0.76))
				k.hip("slate", mc, 18, 12, 9, 5, 0.3, 4, sl)
				k.turret("stone", "slate", mc + Vector2(8, 5), 1.6, 0, 13, 5, 2, 4, Color(0.7, 0.75, 0.76), sl)
				k.pane(g, Vector3(mc.x, 2.5, mc.y + 6.05), Vector3.BACK, 2.2, 4.0)
				k.pane(g, Vector3(mc.x - 5, 5, mc.y + 6.05), Vector3.BACK, 1.0, 2.0)
				k.pane(g, Vector3(mc.x + 5, 5, mc.y + 6.05), Vector3.BACK, 1.0, 2.0)
				mark(mc, 0, 10, 7, 2)
	k.xf = Transform3D.IDENTITY


# ---------------------------------------------------------------- lamps and trees

func _build_lamps(root: Node3D, k: Kit) -> void:
	var lit := 0
	lamps.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.length_squared() < b.length_squared())
	for p: Vector3 in lamps:
		var c := Vector2(p.x, p.z)
		if cell(c) == 2:
			continue
		k.box("iron", c, 0.22, 0.22, p.y, p.y + 4.6, 1, 1)
		k.box("gas", c, 0.6, 0.6, p.y + 4.6, p.y + 5.3, 1, 1)
		k.pyramid("iron", c, 0.8, 0.8, p.y + 5.3, 0.5, 1)
		if lit < 90:
			var o := OmniLight3D.new()
			o.light_color = Color("#ffc27a")
			o.light_energy = 2.2
			o.omni_range = 14.0
			o.position = p + Vector3(0, 5.0, 0)
			root.add_child(o)
			lit += 1

func _build_trees(root: Node3D) -> void:
	if trees.is_empty():
		return
	var crown := SphereMesh.new()
	crown.radius = 1.0
	crown.height = 1.8
	crown.radial_segments = 8
	crown.rings = 4
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.1
	trunk.bottom_radius = 0.18
	trunk.height = 1.0
	trunk.radial_segments = 5
	var lm := StandardMaterial3D.new()
	lm.albedo_color = Color(0.3, 0.36, 0.28)
	lm.roughness = 1.0
	lm.metallic_specular = 0.1
	crown.material = lm
	trunk.material = mats["wood"]
	var mc := MultiMesh.new()
	mc.transform_format = MultiMesh.TRANSFORM_3D
	mc.use_colors = true
	mc.mesh = crown
	mc.instance_count = trees.size()
	var mt := MultiMesh.new()
	mt.transform_format = MultiMesh.TRANSFORM_3D
	mt.mesh = trunk
	mt.instance_count = trees.size()
	for i in trees.size():
		var p: Vector3 = trees[i][0]
		var s: float = trees[i][1]
		mc.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(s, s * 1.2, s)), p + Vector3(0, s * 2.0, 0)))
		mc.set_instance_color(i, trees[i][2])
		mt.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(s * 0.6, s * 1.6, s * 0.6)), p + Vector3(0, s * 0.8, 0)))
	var a := MultiMeshInstance3D.new()
	a.multimesh = mc
	root.add_child(a)
	var b := MultiMeshInstance3D.new()
	b.multimesh = mt
	root.add_child(b)


# ---------------------------------------------------------------- build

func build(root: Node3D) -> void:
	rng.seed = 1819
	occ.resize(int(2 * HALF / GRID) * int(2 * HALF / GRID))
	occ.fill(0)
	_make_mats()
	var k := Kit.new(mats)
	# The ground: paving either side of the river, out past the fog.
	var x := -2000.0
	while x < 2000.0:
		var x2 := x + 10.0
		var za := river_z(x) - RIVER_W / 2
		var zb := river_z(x2) - RIVER_W / 2
		var gc := Color(0.5, 0.5, 0.52)
		k.quad("pave", Vector3(x, 0, -2000), Vector3(x2, 0, -2000), Vector3(x2, 0, zb), Vector3(x, 0, za), Vector2(x, -2000) / 6, Vector2(x2, -2000) / 6, Vector2(x2, zb) / 6, Vector2(x, za) / 6, gc)
		k.quad("pave", Vector3(x, 0, za + RIVER_W), Vector3(x2, 0, zb + RIVER_W), Vector3(x2, 0, 2000), Vector3(x, 0, 2000), Vector2(x, za + RIVER_W) / 6, Vector2(x2, zb + RIVER_W) / 6, Vector2(x2, 2000) / 6, Vector2(x, 2000) / 6, gc)
		x = x2
	_build_river(k)
	_build_landmarks(root, k)
	_build_streets(k)
	_build_houses(k)
	_build_lamps(root, k)
	k.finish(root)
	_build_trees(root)
