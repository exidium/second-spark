class_name Town
extends RefCounted
## Paris, 1819 (D171): the city of the original board, built in 3D. The Seine splits round two islands, quays and
## bridges, winding districts of tall pale houses with steep slate roofs, the landmarks where the board puts them,
## and streets that run on into the night until the fog takes them. Built from a fixed seed.
## Units are metres; the board's centre is the origin, +z is south (towards the camera). Positions are given in
## board percent (x right, y down) and converted with P().

const SCALE := 12.0                 # metres per board percent: the board is 1.2 km across
const STOREY := 3.3
const DETAIL := 520.0               # beyond this, houses lose chimneys, windows and extras
const BUILT := 950.0               # no streets or houses beyond this radius
const GRID := 1.0
const HALF := 1000.0
const PITCH := 1.25
const PAVE := 2.0

# The river, as polygons in board percent, extended past the board's edges so it never ends in view.
const WATER := [
	# North-west arm: the basin, the long bridge, the channel down the west of the big island.
	[Vector2(31, -40), Vector2(44, -40), Vector2(44, 8), Vector2(42, 14), Vector2(40, 20), Vector2(38, 26), Vector2(40, 30), Vector2(40, 36), Vector2(42, 42), Vector2(46, 50), Vector2(50, 56), Vector2(54, 61), Vector2(44, 63), Vector2(39, 58), Vector2(34, 52), Vector2(30, 46), Vector2(28, 40), Vector2(27, 34), Vector2(23, 30), Vector2(19, 27), Vector2(18, 22), Vector2(18, 18), Vector2(31, 16)],
	# North-east arm, bending east round the Morgue's island.
	[Vector2(48, -40), Vector2(52, -40), Vector2(52, 5), Vector2(55, 16), Vector2(58, 26), Vector2(62, 34), Vector2(67, 42), Vector2(73, 50), Vector2(79, 56), Vector2(85, 61), Vector2(68, 61), Vector2(65, 55), Vector2(61, 48), Vector2(57, 40), Vector2(54, 30), Vector2(51, 20), Vector2(48, 8)],
	# The channel between the Hospital's island and the Morgue's.
	[Vector2(51, 34), Vector2(55, 34), Vector2(57, 42), Vector2(58, 50), Vector2(60, 58), Vector2(61, 61), Vector2(54, 61), Vector2(53, 56), Vector2(52, 48), Vector2(51, 40)],
	# The basin below the long bridge, with the docks, running out to the south.
	[Vector2(45, 61), Vector2(86, 61), Vector2(80, 70), Vector2(78, 80), Vector2(80, 90), Vector2(80, 140), Vector2(64, 140), Vector2(60, 90), Vector2(56, 80), Vector2(52, 72), Vector2(48, 66)],
]
# Bridges: from, to (board percent), width.
const BRIDGES := [
	[Vector2(23, 33), Vector2(41, 29), 12.0], [Vector2(54, 33), Vector2(63, 32), 10.0], [Vector2(46, 64), Vector2(82, 65), 14.0],
	[Vector2(28, 44), Vector2(43, 41), 9.0], [Vector2(50, 47), Vector2(58, 46), 8.0], [Vector2(63, 55), Vector2(78, 52), 9.0], [Vector2(49, 21), Vector2(57, 19), 9.0],
]
# Main roads between the landmarks and the bridges: polylines in board percent, width.
const ROADS := [
	[[Vector2(-30, 24), Vector2(0, 24), Vector2(12, 26), Vector2(23, 33)], 12.0],
	[[Vector2(41, 29), Vector2(46, 36), Vector2(50, 44), Vector2(54, 52), Vector2(57, 60)], 10.0],
	[[Vector2(12, 26), Vector2(14, 40), Vector2(12, 55), Vector2(12, 70), Vector2(12, 85), Vector2(14, 130)], 12.0],
	[[Vector2(23, 33), Vector2(30, 45), Vector2(33, 58), Vector2(40, 62), Vector2(46, 64)], 11.0],
	[[Vector2(46, 64), Vector2(44, 72), Vector2(40, 80), Vector2(36, 90), Vector2(30, 130)], 11.0],
	[[Vector2(46, 64), Vector2(50, 74), Vector2(54, 84), Vector2(58, 92), Vector2(60, 130)], 11.0],
	[[Vector2(82, 65), Vector2(90, 70), Vector2(93, 80), Vector2(96, 92), Vector2(100, 130)], 11.0],
	[[Vector2(63, 32), Vector2(72, 26), Vector2(82, 20), Vector2(90, 8), Vector2(96, -30)], 12.0],
	[[Vector2(63, 32), Vector2(70, 40), Vector2(76, 48), Vector2(82, 56), Vector2(86, 62)], 11.0],
	[[Vector2(54, 33), Vector2(52, 24), Vector2(48, 14), Vector2(46, 2), Vector2(46, -40)], 10.0],
	[[Vector2(33, 66), Vector2(24, 66), Vector2(14, 70)], 10.0],
	[[Vector2(57, 10), Vector2(64, 10), Vector2(72, 14), Vector2(82, 20)], 10.0],
	[[Vector2(-30, 45), Vector2(0, 45), Vector2(10, 48), Vector2(22, 46), Vector2(28, 44)], 10.0],
	[[Vector2(78, 52), Vector2(84, 42), Vector2(88, 30), Vector2(90, 8)], 10.0],
	[[Vector2(57, 19), Vector2(62, 12), Vector2(70, -40)], 10.0],
	[[Vector2(43, 41), Vector2(47, 36), Vector2(49, 30), Vector2(49, 21)], 9.0],
	[[Vector2(96, 92), Vector2(130, 100)], 10.0],
	[[Vector2(14, 70), Vector2(-30, 76)], 10.0],
]
# Each landmark: name, colour, position (board percent), facing (radians, 0 faces south), name height.
const PLACES := {
	"square": {"name": "Public Square", "col": "#e0605a", "pos": Vector2(12, 21), "ang": 0.0, "h": 46},
	"cemetery": {"name": "Graveyard", "col": "#8fbf6a", "pos": Vector2(14, 36), "ang": 0.0, "h": 28},
	"hospital": {"name": "Hospital", "col": "#bcd8f0", "pos": Vector2(46.5, 43), "ang": 0.35, "h": 38},
	"morgue": {"name": "Morgue", "col": "#5fc4b8", "pos": Vector2(60.7, 52), "ang": 0.3, "h": 24},
	"slaughter": {"name": "Slaughterhouse", "col": "#c0503f", "pos": Vector2(58, 10), "ang": -0.2, "h": 40},
	"first": {"name": "First Player", "col": "#ece4cf", "pos": Vector2(90, 7), "ang": 0.0, "h": 82},
	"academy": {"name": "Academy", "col": "#7cc4ff", "pos": Vector2(84, 47), "ang": -0.6, "h": 46},
	"market": {"name": "Market", "col": "#e8964a", "pos": Vector2(33, 68), "ang": 0.1, "h": 30},
	"church": {"name": "Saint-Roch", "col": "#e6c15a", "pos": Vector2(12, 77), "ang": 0.0, "h": 66},
	"docks": {"name": "Docks", "col": "#f08a3c", "pos": Vector2(52.5, 80), "ang": -PI / 2 + 0.3, "h": 30},
	"alley": {"name": "Dark Alley", "col": "#b48ae0", "pos": Vector2(92, 80), "ang": 0.4, "h": 32},
	"odeon": {"name": "Odéon", "col": "#d98cc0", "pos": Vector2(27, 90), "ang": 0.0, "h": 36},
}
const CATHEDRAL := Vector2(45.5, 19)
# Quarters: the nearest one gives a house its walls, roof, height and window light.
const QUARTERS := [
	{"pos": Vector2(48, 40), "walls": {"stucco": 3, "blackstone": 3, "limestone": 2, "stone": 1}, "roofs": {"slate": 4, "fishscale": 2}, "floors": Vector2i(4, 6), "win": "win", "soot": 0.5},
	{"pos": Vector2(22, 14), "walls": {"limestone": 3, "stucco": 3, "stockbrick": 1}, "roofs": {"slate": 5, "fishscale": 1}, "floors": Vector2i(4, 5), "win": "win", "soot": 0.3},
	{"pos": Vector2(72, 18), "walls": {"brownbrick": 3, "blackstone": 2, "stockbrick": 2, "brick": 1}, "roofs": {"claytile": 2, "fishscale": 2, "slate": 1}, "floors": Vector2i(3, 5), "win": "win_dim", "soot": 0.6},
	{"pos": Vector2(90, 45), "walls": {"limestone": 4, "stucco": 2}, "roofs": {"slate": 4, "fishscale": 1}, "floors": Vector2i(5, 6), "win": "win_pale", "soot": 0.2},
	{"pos": Vector2(20, 75), "walls": {"limestone": 3, "stucco": 4}, "roofs": {"slate": 5}, "floors": Vector2i(4, 6), "win": "win", "soot": 0.3},
	{"pos": Vector2(62, 92), "walls": {"blackstone": 3, "brownbrick": 2, "stucco": 1}, "roofs": {"fishscale": 3, "claytile": 1}, "floors": Vector2i(3, 5), "win": "win_dim", "soot": 0.6},
	{"pos": Vector2(6, 50), "walls": {"stucco": 3, "blackstone": 2, "limestone": 1}, "roofs": {"slate": 3, "fishscale": 2}, "floors": Vector2i(3, 5), "win": "win", "soot": 0.45},
	{"pos": Vector2(92, 85), "walls": {"blackstone": 3, "brownbrick": 2, "stone": 2}, "roofs": {"fishscale": 3, "slate": 1}, "floors": Vector2i(4, 6), "win": "win_dim", "soot": 0.65},
]

var rng := RandomNumberGenerator.new()
var mats := {}
var occ := PackedByteArray()        # 1 m cells: 0 free, 1 street, 2 built, 3 water, 4 kept open, 5 a boat
var water_polys: Array[PackedVector2Array] = []
var streets := []                    # [Vector2 a, Vector2 b, float width]
var labels := []                     # {text, col, pos: Vector3}
var lights := []                     # {pos: Vector3, col, energy, range}
var trees := []                      # [Vector3 pos, float size, Color]
var lamps := []                      # Vector3 lamp bases
var houses := 0
var model_houses := 0
# Bruno's house models (D174): godot/assets/models/house-N.glb, each {mesh, size}, and the transforms placed per kind.
var house_kinds := []
var house_xf := []
const MODEL_HOUSES_WITHIN := 640.0   # model houses on the whole board (+-600 m) and a little round it; beyond, drawn (cheaper, in the fog)


static func P(b: Vector2) -> Vector2:
	return (b - Vector2(50, 50)) * SCALE


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
	mats["limestone"] = _tex("wall-limestone")
	mats["blackstone"] = _tex("wall-blackstone")
	mats["stockbrick"] = _tex("wall-stockbrick")
	mats["brownbrick"] = _tex("wall-brownbrick")
	mats["stucco"] = _tex("wall-stucco")
	mats["shop"] = _tex("gothic-shop")
	mats["slate"] = _tex("slate", 0.5, 0.05)
	mats["fishscale"] = _tex("roof-fishscale", 0.5, 0.05)
	mats["claytile"] = _tex("roof-claytile", 0.8)
	mats["street"] = _tex("wet-cobbles", 0.45, 0.1)
	mats["pave"] = _tex("flagstones", 0.5, 0.05)
	mats["grass"] = _tex("grass")
	mats["water"] = _tex("water", 0.15, 0.3)
	mats["water"].albedo_color = Color(0.62, 0.7, 0.78)
	mats["iron"] = _col(Color("#15161a"), 0.0, 0.4)
	mats["wood"] = _col(Color("#2c241f"))
	mats["glass"] = _col(Color("#5d6c74"), 0.0, 0.05)
	mats["glass"].metallic = 0.7
	mats["win"] = _col(Color("#ffbf6e"), 1.4)
	mats["win_pale"] = _col(Color("#e9efd2"), 1.1)
	mats["win_dim"] = _col(Color("#c98a3e"), 0.9)
	mats["gas"] = _col(Color("#ffd49a"), 4.0)
	for id in PLACES:
		mats["glow:" + id] = _col(Color(PLACES[id].col), 3.0)
	mats["glow:cathedral"] = _col(Color("#ffd27a"), 2.6)


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

func in_water(p: Vector2) -> bool:
	var v := cell(p)
	return v == 3 or v == 5

## Scanline fill of a polygon into the grid.
func _fill_poly(poly: PackedVector2Array, v: int) -> void:
	var n := int(2 * HALF / GRID)
	var minz := INF
	var maxz := -INF
	for p in poly:
		minz = minf(minz, p.y)
		maxz = maxf(maxz, p.y)
	var z := maxf(floorf(minz), -HALF)
	while z <= minf(maxz, HALF - 1):
		var zc := z + 0.5
		var xs := []
		for i in poly.size():
			var p := poly[i]
			var q := poly[(i + 1) % poly.size()]
			if (p.y <= zc) != (q.y <= zc):
				xs.append(p.x + (zc - p.y) * (q.x - p.x) / (q.y - p.y))
		xs.sort()
		var row := int((zc + HALF) / GRID) * n
		for k in range(0, xs.size() - 1, 2):
			var x0 := maxi(int(floor((xs[k] + HALF) / GRID)), 0)
			var x1 := mini(int(floor((xs[k + 1] + HALF) / GRID)), n - 1)
			for xi in range(x0, x1 + 1):
				occ[row + xi] = v
		z += GRID


# ---------------------------------------------------------------- the river and the ground

func _build_water(k: Kit) -> void:
	for wp in WATER:
		var poly := PackedVector2Array()
		for b in wp:
			poly.append(P(b))
		water_polys.append(poly)
		_fill_poly(poly, 3)
		# The water surface.
		var tris := Geometry2D.triangulate_polygon(poly)
		for t in range(0, tris.size(), 3):
			var a := poly[tris[t]]
			var b := poly[tris[t + 1]]
			var c := poly[tris[t + 2]]
			k.tri("water", Vector3(a.x, -1.4, a.y), Vector3(b.x, -1.4, b.y), Vector3(c.x, -1.4, c.y), a / 22, b / 22, c / 22, Color(0.95, 1.0, 1.05))
		# Stone embankments down to the water, a parapet along the top, a quay road behind it.
		for i in poly.size():
			var a := poly[i]
			var b := poly[(i + 1) % poly.size()]
			if a.length() > BUILT + 200 and b.length() > BUILT + 200:
				continue
			k.wall("stone", a, b, -1.6, 0.25, 4, 4, Color(0.55, 0.57, 0.6))
			var d := (b - a).normalized()
			var nrm := Vector2(-d.y, d.x)
			if Geometry2D.is_point_in_polygon(a + d * 2 + nrm * 3, poly):
				nrm = -nrm
			var len := a.distance_to(b)
			k.box("stone", (a + b) / 2 + nrm * 0.5, len, 0.7, 0.25, 1.2, 3, 3, Color(0.62, 0.64, 0.68))
			var qa := a + nrm * 7.5
			var qb := b + nrm * 7.5
			if (a + b).length() / 2 < BUILT:
				street(k, qa, qb, 12.0, true)

## Boats on the river: barges and small craft, moored along the quays or out on the water.
func _build_boats(k: Kit) -> void:
	var placed := 0
	var tries := 0
	while placed < 70 and tries < 4000:
		tries += 1
		var c := Vector2(rng.randf_range(-DETAIL, DETAIL), rng.randf_range(-DETAIL, DETAIL))
		if not in_water(c):
			continue
		var ang := rng.randf_range(-PI, PI)
		var len := rng.randf_range(7.0, 18.0)
		var wid := len * 0.28
		if not is_free_water(c, ang, len / 2 + 4, wid / 2 + 4):
			continue
		var saved := k.xf
		k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
		var hull := Color(0.35, 0.3, 0.26) * rng.randf_range(0.7, 1.1)
		k.box("wood", Vector2.ZERO, len, wid, -1.9, -0.6, 2, 2, hull)
		k.box("wood", Vector2(0, 0), len * 0.9, wid * 0.8, -0.6, -0.3, 2, 2, hull * 0.8)
		if len > 11:
			k.box("wood", Vector2(-len * 0.2, 0), len * 0.3, wid * 0.7, -0.3, 1.2, 2, 2, hull * 0.9)
		if rng.randf() < 0.6:
			k.box("wood", Vector2(len * 0.15, 0), 0.35, 0.35, -0.3, len * 0.7, 1, 1)
		k.xf = saved
		for ii in _obb_cells(c, ang, len / 2 + 3, wid / 2 + 3):
			if ii >= 0:
				occ[ii] = 5
		placed += 1

func is_free_water(c: Vector2, ang: float, hx: float, hz: float) -> bool:
	for i in _obb_cells(c, ang, hx, hz):
		if i < 0 or occ[i] != 3:
			return false
	return true

## The land surface: one quad per run of dry cells on each grid row.
func _build_land(k: Kit) -> void:
	var n := int(2 * HALF / GRID)
	var gc := Color(0.42, 0.43, 0.46)
	for zi in n:
		var z := -HALF + zi * GRID
		var row := zi * n
		var xi := 0
		while xi < n:
			if occ[row + xi] == 3 or occ[row + xi] == 5:
				xi += 1
				continue
			var x0 := xi
			while xi < n and occ[row + xi] != 3 and occ[row + xi] != 5:
				xi += 1
			var a := -HALF + x0 * GRID
			var b := -HALF + xi * GRID
			k.quad("pave", Vector3(a, 0, z + GRID), Vector3(b, 0, z + GRID), Vector3(b, 0, z), Vector3(a, 0, z), Vector2(a, z + GRID) / 6, Vector2(b, z + GRID) / 6, Vector2(b, z) / 6, Vector2(a, z) / 6, gc)
	# Beyond the grid, plain ground out to the fog.
	for q in [[-3000.0, -3000.0, 3000.0, -HALF], [-3000.0, HALF, 3000.0, 3000.0], [-3000.0, -HALF, -HALF, HALF], [HALF, -HALF, 3000.0, HALF]]:
		k.quad("pave", Vector3(q[0], -0.02, q[3]), Vector3(q[2], -0.02, q[3]), Vector3(q[2], -0.02, q[1]), Vector3(q[0], -0.02, q[1]), Vector2(q[0], q[3]) / 6, Vector2(q[2], q[3]) / 6, Vector2(q[2], q[1]) / 6, Vector2(q[0], q[1]) / 6, gc)

func _build_bridges(k: Kit) -> void:
	for br in BRIDGES:
		var a := P(br[0])
		var b := P(br[1])
		var w: float = br[2]
		var d := (b - a).normalized()
		var ang := d.angle()
		var len := a.distance_to(b) + 12
		var c := (a + b) / 2
		var saved := k.xf
		k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
		k.box("stone", Vector2.ZERO, len, w, -1.4, 1.3, 4, 4, Color(0.66, 0.67, 0.7), "street")
		for s: float in [-1.0, 1.0]:
			k.box("stone", Vector2(0, s * (w / 2 - 0.4)), len, 0.7, 1.3, 2.4, 3, 3, Color(0.6, 0.61, 0.64))
		var piers := maxi(2, int(len / 18))
		for t in piers:
			var x := -len / 2 + (t + 0.5) * len / piers
			k.box("stone", Vector2(x, 0), 4, w + 2, -1.6, -0.3, 3, 3, Color(0.5, 0.52, 0.55))
		k.xf = saved
		for t in piers + 1:
			var p := a + d * (t * (len - 12) / piers)
			for s: float in [-1.0, 1.0]:
				lamps.append(Vector3(p.x + (-d.y) * s * (w / 2 - 0.6), 1.3, p.y + d.x * s * (w / 2 - 0.6)))
		mark(c, ang, len / 2, w / 2 + 0.5, 1)
		streets.append([a, b, w])


# ---------------------------------------------------------------- streets

func _street_quad(k: Kit, a: Vector2, b: Vector2, w: float) -> void:
	var d := (b - a).normalized()
	var n := Vector2(-d.y, d.x)
	var len := a.distance_to(b)
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

## A street from a to b: drawn and marked only where it crosses land, with gas lamps when `lit`.
func street(k: Kit, a: Vector2, b: Vector2, w: float, lit := false) -> void:
	var len := a.distance_to(b)
	if len < 4.0:
		return
	var d := (b - a) / len
	var step := 6.0
	var t := 0.0
	var run_start := -1.0
	while true:
		var at_end := t >= len - 0.001
		var mid := a + d * minf(t + step / 2, len)
		var dry := not at_end and not in_water(mid) and mid.length() < BUILT
		if dry and run_start < 0:
			run_start = t
		if (not dry or t >= len) and run_start >= 0:
			var ra := a + d * run_start
			var rb := a + d * minf(t, len)
			if ra.distance_to(rb) > 3.0:
				streets.append([ra, rb, w])
				_street_quad(k, ra, rb, w)
				var dd := rb - ra
				for ii in _obb_cells((ra + rb) / 2, dd.angle(), dd.length() / 2, w / 2):
					if ii >= 0 and occ[ii] == 0:
						occ[ii] = 1
				if lit and (ra + rb).length() / 2 < DETAIL:
					var n := d.orthogonal()
					var u := 10.0
					while u < dd.length() - 4:
						for s: float in [-1.0, 1.0]:
							var p := ra + d * u + n * s * (w / 2 - 0.6)
							lamps.append(Vector3(p.x, 0.2, p.y))
						u += 26.0
			run_start = -1.0
		if at_end:
			break
		t = minf(t + step, len)   # the last step stops at the end, so short segments are drawn too

func _build_roads(k: Kit) -> void:
	for r in ROADS:
		var pts: Array = r[0]
		for i in pts.size() - 1:
			street(k, P(pts[i]), P(pts[i + 1]), r[1], true)

## Paris before Haussmann (D175): the Grands Boulevards as a tree-lined ring on the line of the old wall, quays along
## every bank, small squares, then medieval lanes that wander off the streets already there and end on another street
## (a T-junction) or in a dead end. Dense and crooked inside the ring, sparser and straighter in the faubourgs outside.
const RING := 470.0

func _ring_r(a: float) -> float:
	return RING + 38.0 * sin(3.0 * a + 1.0) + 22.0 * sin(5.0 * a + 2.0)

func _inside_ring(p: Vector2) -> bool:
	return p.length() < _ring_r(p.angle())

func _build_paris(k: Kit) -> void:
	_build_boulevards(k)
	_build_quays(k)
	_build_placettes(k)
	_build_lanes(k)

func _build_boulevards(k: Kit) -> void:
	var n := 96
	for i in n:
		var a0 := TAU * i / n
		var a1 := TAU * (i + 1) / n
		var p0 := Vector2(cos(a0), sin(a0)) * _ring_r(a0)
		var p1 := Vector2(cos(a1), sin(a1)) * _ring_r(a1)
		var before := streets.size()
		street(k, p0, p1, 24.0, true)
		for si in range(before, streets.size()):   # a row of trees on each side of the carriageway
			var a: Vector2 = streets[si][0]
			var b: Vector2 = streets[si][1]
			var d := (b - a).normalized()
			var nn := d.orthogonal()
			var u := 4.0
			while u < a.distance_to(b):
				for sd: float in [-1.0, 1.0]:
					var t := a + d * u + nn * sd * 8.5
					trees.append([Vector3(t.x, 0.2, t.y), rng.randf_range(2.4, 3.0), _leaf()])
				u += 9.0

func _build_quays(k: Kit) -> void:
	for poly in WATER:
		var pts: Array = poly
		for i in pts.size():
			var a := P(pts[i])
			var b := P(pts[(i + 1) % pts.size()])
			var d := (b - a).normalized()
			var nn := d.orthogonal()
			if in_water((a + b) / 2 + nn * 3.0):
				nn = -nn
			street(k, a + nn * 7.0, b + nn * 7.0, 12.0, true)

func _build_placettes(k: Kit) -> void:
	var done := []
	for attempt in 4000:
		if done.size() >= 16:
			break
		var c := Vector2(rng.randf_range(-560, 560), rng.randf_range(-560, 560))
		if not _inside_ring(c) or not is_free(c, 0, 12, 12):
			continue
		var far := true
		for q: Vector2 in done:
			if q.distance_to(c) < 140.0:
				far = false
		for id in PLACES:
			if P(PLACES[id].pos).distance_to(c) < 90.0:
				far = false
		if not far:
			continue
		var ang := rng.randf_range(0, PI)
		var hw := rng.randf_range(9, 14)
		var hd := rng.randf_range(8, 12)
		k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
		_yard(k, Vector2.ZERO, hw * 2, hd * 2, "pave")
		k.xf = Transform3D.IDENTITY
		mark(c, ang, hw, hd, 4)
		trees.append([Vector3(c.x, 0.2, c.y), rng.randf_range(3.0, 3.8), _leaf()])
		lamps.append(Vector3(c.x + hw - 1.5, 0.2, c.y))
		done.append(c)

## True when the next `dist` metres from p along d have no street, water or open ground.
func _clear_ahead(p: Vector2, d: Vector2, dist: float) -> bool:
	var u := 2.0
	while u <= dist:
		if cell(p + d * u) != 0:
			return false
		u += 2.0
	return true

func _build_lanes(k: Kit) -> void:
	var made := 0
	for attempt in 26000:
		var s: Array = streets[rng.randi() % streets.size()]
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		var w: float = s[2]
		var d0 := (b - a).normalized()
		var side := 1.0 if rng.randf() < 0.5 else -1.0
		var dir := d0.orthogonal() * side
		var root := a + (b - a) * rng.randf_range(0.15, 0.85)
		var start := root + dir * (w / 2 + 1.0)
		if start.length() > BUILT - 30 or cell(start) != 0:
			continue
		var inner := _inside_ring(start)
		var spacing := rng.randf_range(44, 64) if inner else rng.randf_range(60, 90)
		if not _clear_ahead(start, dir, spacing):
			continue
		var turn := 0.16 if inner else 0.06
		var lw := rng.randf_range(4.5, 6.5) if inner else rng.randf_range(6.0, 8.0)
		var pts := [root, start]
		var cur := start
		var dd := dir.rotated(rng.randf_range(-0.25, 0.25))
		var walked := 0.0
		var max_len := rng.randf_range(70, 240) if inner else rng.randf_range(120, 320)
		while walked < max_len:
			dd = dd.rotated(rng.randf_range(-turn, turn))
			var nxt := cur + dd * 8.0
			var ahead := cell(cur + dd * 11.0)
			if ahead == 1:   # meets a street: a T-junction
				pts.append(cur + dd * 11.0)
				break
			if ahead != 0 or nxt.length() > BUILT - 10:
				break   # water, a square, a landmark: a dead end
			# Too close alongside another street: stop rather than run parallel to it.
			var nn := dd.orthogonal()
			if walked > 12.0 and (cell(nxt + nn * 13.0) == 1 or cell(nxt - nn * 13.0) == 1):
				break
			pts.append(nxt)
			cur = nxt
			walked += 8.0
		if walked < 20.0:
			continue
		var lit := rng.randf() < (0.25 if inner else 0.15)
		for pi in pts.size() - 1:
			street(k, pts[pi], pts[pi + 1], lw, lit)
		made += 1
	print("TOWN lanes: %d" % made)


# ---------------------------------------------------------------- houses

func _tw(span: float) -> float:
	return span / maxf(1.0, round(span / 3.2))

func _pick(weights: Dictionary) -> String:
	var total := 0.0
	for key in weights:
		total += weights[key]
	var r := rng.randf() * total
	for key in weights:
		r -= weights[key]
		if r <= 0:
			return key
	return weights.keys()[0]

func quarter_of(c: Vector2) -> Dictionary:
	var best: Dictionary = QUARTERS[0]
	var bd := INF
	for q in QUARTERS:
		var d := P(q.pos).distance_squared_to(c)
		if d < bd:
			bd = d
			best = q
	return best

## A tall Paris house in its own frame: frontage w along x, depth d, the street on +z. Walls, roof and lights
## come from its quarter; a steep mansard with dormers, a pointed gable, or a ridge with a cross-gable.
func gothic_house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int, detail: bool, corner := false) -> void:
	if not house_kinds.is_empty() and absf(c.x) < MODEL_HOUSES_WITHIN and absf(c.y) < MODEL_HOUSES_WITHIN:
		_model_house(c, ang, w, d, floors)
		houses += 1
		return
	var q := quarter_of(c)
	var saved := k.xf
	k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
	var kw: String = _pick(q.walls)
	var kr: String = _pick(q.roofs)
	var t := rng.randf_range(0.72, 1.0)
	var cw := Color(t, t * rng.randf_range(0.95, 1.0), t * rng.randf_range(0.93, 1.03))
	var h := floors * STOREY
	var twf := _tw(w)
	var twd := _tw(d)
	var shop := detail and rng.randf() < 0.35
	k.soot = q.soot * rng.randf_range(0.6, 1.2)
	var y0 := STOREY if shop else 0.0
	if shop:
		k.wall("shop", Vector2(-w / 2, d / 2), Vector2(w / 2, d / 2), 0, STOREY, twf, STOREY, cw)
	k.wall(kw, Vector2(-w / 2, d / 2), Vector2(w / 2, d / 2), y0, h, twf, STOREY, cw)
	k.wall(kw, Vector2(w / 2, -d / 2), Vector2(-w / 2, -d / 2), 0, h, twf, STOREY, cw)
	k.wall(kw, Vector2(w / 2, d / 2), Vector2(w / 2, -d / 2), 0, h, twd, STOREY, cw)
	k.wall(kw, Vector2(-w / 2, -d / 2), Vector2(-w / 2, d / 2), 0, h, twd, STOREY, cw)
	k.soot = 0.0
	k.box("stone", Vector2.ZERO, w + 0.3, d + 0.3, h - 0.35, h, 2, 2, cw * 0.85)
	var rt := rng.randf_range(0.6, 1.0)
	var cr := Color(rt, rt * rng.randf_range(0.95, 1.0), rt * rng.randf_range(0.95, 1.08))
	k.uv_off = Vector2(rng.randf(), rng.randf())
	var roll := rng.randf()
	var rh := 0.0
	if roll < 0.5:
		# A steep mansard with dormers: the Paris roof.
		rh = rng.randf_range(4.0, 6.5)
		k.hip(kr, Vector2.ZERO, w, d, h, rh, 0.3, 5.0, cr)
		if detail:
			var nd := maxi(1, int(w / 3.4))
			for j in nd:
				var dx := -w / 2 + (j + 0.5) * w / nd
				var s3 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
				k.walls(kw, Vector2(-(d / 2 - 0.9), dx), 1.6, 1.7, h, h + 2.1, 1.7, STOREY, cw)
				k.gable(kr, kw, Vector2(-(d / 2 - 0.9), dx), 1.8, 1.9, h + 2.1, 1.4, 0.15, 2.0, 1.7, STOREY, cr, cw)
				k.xf = s3
				if rng.randf() < 0.3:
					k.pane(q.win, Vector3(dx, h + 1.0, d / 2 - 0.05), Vector3.BACK, 0.7, 1.1)
	elif roll < 0.82:
		# A steep pointed gable to the street, a finial on its point.
		rh = w / 2 * PITCH * rng.randf_range(0.9, 1.3)
		var s2 := k.xf
		k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
		k.gable(kr, kw, Vector2.ZERO, d, w, h, rh, 0.4, 5.0, twf, STOREY, cr, cw)
		k.xf = s2
		if detail:
			k.pinnacle("stone", Vector2(0, d / 2 + 0.2), 0.35, h + rh - 0.4, 2.4, cw)
	else:
		rh = d / 2 * 0.95
		k.gable(kr, kw, Vector2.ZERO, w, d, h, rh, 0.4, 5.0, twd, STOREY, cr, cw)
		if detail and w >= 5.5:
			var s4 := k.xf
			k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
			k.walls(kw, Vector2(-d / 4, 0), d / 2, 2.8, h, h + 1.2, 2.8, STOREY, cw)
			k.gable(kr, kw, Vector2(-d / 4, 0), d / 2, 2.8, h + 1.2, 3.4, 0.25, 3.0, 2.8, STOREY, cr, cw)
			k.xf = s4
			k.pinnacle("stone", Vector2(0, d / 2), 0.3, h + 4.2, 1.8, cw)
	k.uv_off = Vector2.ZERO
	if detail:
		for s: float in [-1.0, 1.0]:
			if rng.randf() < 0.8:
				var cz := rng.randf_range(-d / 4, d / 6)
				var top := h + rh * 0.75 + rng.randf_range(0.6, 2.2)
				k.box("brownbrick", Vector2(s * (w / 2 - 0.4), cz), 0.8, 1.8, h, top, 1.6, 1.6, cw * 0.8)
				for p in 3:
					k.cylinder("brownbrick", Vector2(s * (w / 2 - 0.4), cz - 0.6 + p * 0.6), 0.16, top, top + 0.5, 6, 1, 1, Color(0.6, 0.45, 0.4))
		if floors >= 3 and w >= 5 and rng.randf() < 0.25:
			var bw := 2.4
			k.walls(kw, Vector2(0, d / 2 + 0.45), bw, 0.9, STOREY, h - STOREY * 0.4, 1.2, STOREY, cw)
			k.hip(kr, Vector2(0, d / 2 + 0.45), bw, 0.9, h - STOREY * 0.4, 0.8, 0.1, 2.0, cr)
			for f in range(1, floors):
				if rng.randf() < 0.35:
					k.pane(q.win, Vector3(0, f * STOREY + STOREY * 0.55, d / 2 + 0.92), Vector3.BACK, 0.8, 1.6)
		if corner and rng.randf() < 0.4:
			k.turret(kw, kr, Vector2(w / 2 - 0.4, d / 2 - 0.4), 1.8, STOREY, h + 2.0, 6.0, 2.0, STOREY, cw, cr)
		var n := int(round(w / twf))
		for f in range(1 if shop else 0, floors):
			for j in n:
				if rng.randf() < 0.2:
					k.pane(q.win, Vector3(-w / 2 + (j + 0.5) * twf, f * STOREY + STOREY * 0.56, d / 2), Vector3.BACK, 0.62, 1.25)
		if shop and rng.randf() < 0.6:
			k.pane(q.win, Vector3(-w / 2 + twf * 0.62, STOREY * 0.48, d / 2), Vector3.BACK, twf * 0.38, STOREY * 0.5)
	k.xf = saved
	houses += 1

## Load the house models once: the mesh of each and its size in metres (finish.py puts the origin on the ground).
func _load_house_models() -> void:
	for i in range(1, 9):
		var path := "res://assets/models/house-%d.glb" % i
		if not ResourceLoader.exists(path):
			continue
		var scene := (load(path) as PackedScene).instantiate()
		var mis := scene.find_children("*", "MeshInstance3D", true, false)
		if mis.is_empty():
			scene.free()
			continue
		var mi := mis[0] as MeshInstance3D
		var mesh: Mesh = mi.mesh.duplicate()
		for sfc in mesh.get_surface_count():   # a grey tint per house through the instance colour, like the drawn walls
			var m := mesh.surface_get_material(sfc)
			if m is StandardMaterial3D:
				var sm := (m as StandardMaterial3D).duplicate() as StandardMaterial3D
				sm.vertex_color_use_as_albedo = true
				mesh.surface_set_material(sfc, sm)
		house_kinds.append({"mesh": mesh, "size": mesh.get_aabb().size, "xf": mi.transform})
		house_xf.append([])
		scene.free()

## A model house on the lot: the kind whose width-to-height suits the lot best (one of the closest three), stretched to
## the lot's frontage and depth and to its storeys plus a roof.
func _model_house(c: Vector2, ang: float, w: float, d: float, floors: int) -> void:
	var h := floors * STOREY + 5.0
	var order := range(house_kinds.size())
	order.sort_custom(func(a: int, b: int) -> bool:
		var sa: Vector3 = house_kinds[a].size
		var sb: Vector3 = house_kinds[b].size
		return absf(sa.x / sa.y - w / h) < absf(sb.x / sb.y - w / h))
	var i: int = order[rng.randi_range(0, mini(2, order.size() - 1))]
	var sz: Vector3 = house_kinds[i].size
	# Each model stands on its concept's plinth, about 2% of its height and wider than its walls: sink the plinth into the
	# street and widen the house a little so the walls meet the neighbours'.
	var basis := Basis(Vector3.UP, -ang) * Basis.from_scale(Vector3(w * 1.08 / sz.x, h / sz.y, d * 1.08 / sz.z))
	var t := rng.randf_range(0.7, 1.0)
	house_xf[i].append([Transform3D(basis, Vector3(c.x, -0.025 * h, c.y)) * house_kinds[i].xf, Color(t, t, t * rng.randf_range(0.96, 1.04))])
	model_houses += 1

## One MultiMesh per house kind and 200 m tile, so the camera skips the tiles it does not see.
func _build_house_models(root: Node3D) -> void:
	for i in house_kinds.size():
		var tiles := {}
		for e: Array in house_xf[i]:
			var o: Vector3 = (e[0] as Transform3D).origin
			var key := Vector2i(floori(o.x / 200.0), floori(o.z / 200.0))
			if not tiles.has(key):
				tiles[key] = []
			tiles[key].append(e)
		for key: Vector2i in tiles:
			_house_tile(root, i, tiles[key])

func _house_tile(root: Node3D, i: int, list: Array) -> void:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.use_colors = true
	mm.mesh = house_kinds[i].mesh
	mm.instance_count = list.size()
	for j in list.size():
		mm.set_instance_transform(j, list[j][0])
		mm.set_instance_color(j, list[j][1])
	var mi := MultiMeshInstance3D.new()
	mi.multimesh = mm
	root.add_child(mi)

func _try_house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int, corner := false) -> bool:
	if c.length() > BUILT or not is_free(c, ang, w / 2 - 0.05, d / 2 - 0.05):
		return false
	gothic_house(k, c, ang, w, d, floors, c.length() < DETAIL, corner)
	mark(c, ang, w / 2, d / 2, 2)
	return true

## Line every street with houses, wall to wall, facing it; then sheds in the yards.
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
				var w: float = [4.6, 5.4, 6.2, 7.0, 7.8][rng.randi_range(0, 4)]
				var d := rng.randf_range(9.0, 13.0)
				if _inside_ring(a):   # old Paris: deep narrow houses
					d = rng.randf_range(12.0, 17.0)
				var c := a + dir * (t + w / 2) + n * (sw / 2 + 0.1 + d / 2)
				var q := quarter_of(c)
				var floors := rng.randi_range(q.floors.x, q.floors.y)
				var face := ang + (PI if side > 0 else 0.0)
				var ok := _try_house(k, c, face, w, d, floors, first or t + w >= len - 6)
				first = false
				t += w if ok else 1.5
	# Inside the ring, back buildings fill the blocks round small courtyards, at the angle of the nearest street front.
	for i in 40000:
		var c := Vector2(rng.randf_range(-RING - 60, RING + 60), rng.randf_range(-RING - 60, RING + 60))
		if not _inside_ring(c) or cell(c) != 0:
			continue
		_try_house(k, c, _street_angle_near(c), rng.randf_range(6.0, 10.0), rng.randf_range(6.0, 10.0), rng.randi_range(3, 4))
	for i in 30000:
		var c := Vector2(rng.randf_range(-BUILT, BUILT), rng.randf_range(-BUILT, BUILT))
		if c.length() > BUILT or cell(c) != 0:
			continue
		var ang := rng.randf_range(-PI, PI)
		if rng.randf() < 0.75:
			_try_house(k, c, ang, rng.randf_range(3.5, 6.0), rng.randf_range(3.0, 5.0), rng.randi_range(1, 2))
		elif c.length() < DETAIL and rng.randf() < 0.3 and is_free(c, 0, 2, 2):
			trees.append([Vector3(c.x, 0, c.y), rng.randf_range(2.5, 3.5), _leaf()])
			mark(c, 0, 2, 2, 4)

## The angle of the street nearest to p (within 30 m), so a back building lines up with its block.
func _street_angle_near(p: Vector2) -> float:
	var best := INF
	var ang := rng.randf_range(-PI, PI)
	for r: float in [6.0, 12.0, 20.0, 30.0]:
		for k8 in 8:
			var q := p + Vector2.from_angle(TAU * k8 / 8) * r
			if cell(q) == 1 and r < best:
				best = r
				ang = (q - p).angle() + PI / 2
		if best < INF:
			break
	return ang

func _leaf() -> Color:
	var t := rng.randf_range(0.5, 0.9)
	return Color(0.22 * t, 0.26 * t, 0.22 * t)


# ---------------------------------------------------------------- landmarks

## Bruno's models: godot/assets/models/<id>.glb replaces the drawn landmark when it exists.
func _model(id: String) -> Node3D:
	var path := "res://assets/models/%s.glb" % id
	if ResourceLoader.exists(path):
		return (load(path) as PackedScene).instantiate()
	return null

## Half the width (x) and depth (z) of a model's meshes, in metres.
func _half_size(m: Node3D) -> Vector2:
	var box := AABB()
	var first := true
	for n in m.find_children("*", "MeshInstance3D", true, false):
		var mi := n as MeshInstance3D
		var b: AABB = mi.transform * mi.mesh.get_aabb()
		box = b if first else box.merge(b)
		first = false
	return Vector2(maxf(absf(box.position.x), absf(box.end.x)), maxf(absf(box.position.z), absf(box.end.z)))

func _label(id: String, c: Vector2) -> void:
	labels.append({"text": PLACES[id].name, "col": Color(PLACES[id].col), "pos": Vector3(c.x, PLACES[id].h, c.y)})
	lights.append({"pos": Vector3(c.x, 12.0, c.y + 14), "col": Color(PLACES[id].col), "energy": 10.0, "range": 48.0})

func _yard(k: Kit, c: Vector2, w: float, d: float, kind: String) -> void:
	k.flat(kind, c, w, d, 0.24, 5.0 if kind == "pave" else 8.0, Color(0.72, 0.72, 0.72))

## A gothic church: nave with aisles, buttresses and pinnacles, a west tower with a spire (or twin towers), a rose
## window, an apse. Drawn with the nave along local x and the west front at -x.
func _church(k: Kit, sc: float, g: String, st: Color, sl: Color, twin := false) -> void:
	k.walls("stone", Vector2(2, 0) * sc, 34 * sc, 11 * sc, 0, 20 * sc, 3.4, 4.0, st)
	k.gable("slate", "stone", Vector2(2, 0) * sc, 34 * sc, 11 * sc, 20 * sc, 9 * sc, 0.4, 5, 3.4, 4, sl, st)
	for s: float in [-1.0, 1.0]:
		k.walls("stone", Vector2(2, s * 8.5) * sc, 34 * sc, 6 * sc, 0, 10 * sc, 3.4, 4.0, st)
		k.hip("slate", Vector2(2, s * 8.5) * sc, 34 * sc, 6 * sc, 10 * sc, 2.5 * sc, 0.3, 5, sl)
		for j in 6:
			var bxp := (-12.0 + j * 5.6) * sc
			k.box("stone", Vector2(bxp, s * 11.8 * sc), 1.0 * sc, 1.4 * sc, 0, 14 * sc, 2, 2, st)
			k.pinnacle("stone", Vector2(bxp, s * 11.8 * sc), 0.8 * sc, 14 * sc, 3.5 * sc, st)
			k.pane(g, Vector3(bxp + 2.8 * sc, 14.5 * sc, s * 5.55 * sc), Vector3(0, 0, s), 1.4 * sc, 5.0 * sc)
	if twin:
		for s: float in [-1.0, 1.0]:
			k.box("stone", Vector2(-18 * sc, s * 5.5 * sc), 9 * sc, 9 * sc, 0, 40 * sc, 3.4, 4.0, st)
			for cx: float in [-1.0, 1.0]:
				for cz: float in [-1.0, 1.0]:
					k.pinnacle("stone", Vector2(-18 * sc + cx * 4.1 * sc, s * 5.5 * sc + cz * 4.1 * sc), 1.0 * sc, 40 * sc, 5 * sc, st)
			k.pane(g, Vector3(-22.55 * sc, 30 * sc, s * 5.5 * sc), Vector3.LEFT, 2.0 * sc, 5.0 * sc)
		k.pane(g, Vector3(-22.55 * sc, 20 * sc, 0), Vector3.LEFT, 7 * sc, 7 * sc)
		k.pane(g, Vector3(-22.55 * sc, 6 * sc, 0), Vector3.LEFT, 4 * sc, 9 * sc)
		k.box("stone", Vector2(-2 * sc, 0), 5 * sc, 5 * sc, 20 * sc, 30 * sc, 3, 3, st)
		k.pyramid("slate", Vector2(-2 * sc, 0), 5.4 * sc, 5.4 * sc, 30 * sc, 36 * sc, 4, sl)
	else:
		k.box("stone", Vector2(-18 * sc, 0), 10 * sc, 10 * sc, 0, 34 * sc, 3.4, 4.0, st)
		for cx: float in [-1.0, 1.0]:
			for cz: float in [-1.0, 1.0]:
				k.pinnacle("stone", Vector2(-18 * sc + cx * 4.6 * sc, cz * 4.6 * sc), 1.0 * sc, 34 * sc, 6 * sc, st)
		k.pyramid("slate", Vector2(-18 * sc, 0), 8.4 * sc, 8.4 * sc, 34 * sc, 38 * sc, 4, sl)
		k.pane(g, Vector3(-23.05 * sc, 22 * sc, 0), Vector3.LEFT, 5.5 * sc, 5.5 * sc)
		k.pane(g, Vector3(-23.05 * sc, 6 * sc, 0), Vector3.LEFT, 3.0 * sc, 7.0 * sc)
	k.turret("stone", "slate", Vector2(19 * sc, 0), 5.5 * sc, 0, 18 * sc, 7 * sc, 3.4, 4, st, sl)

func _build_landmarks(root: Node3D, k: Kit) -> void:
	var st := Color(0.78, 0.8, 0.82)
	var sl := Color(0.75, 0.78, 0.85)
	# The cathedral on the island's north tip: no place of the game, the city's crown.
	var cc := P(CATHEDRAL)
	k.xf = Transform3D(Basis(Vector3.UP, -PI / 2 - 0.15), Vector3(cc.x, 0, cc.y))
	_yard(k, Vector2.ZERO, 70, 46, "pave")
	_church(k, 1.35, "glow:cathedral", st, sl, true)
	mark(cc, -PI / 2 - 0.15, 36, 24, 4)
	lights.append({"pos": Vector3(cc.x, 20, cc.y + 30), "col": Color("#ffd27a"), "energy": 8.0, "range": 60.0})
	for id in PLACES:
		var c := P(PLACES[id].pos)
		var ang: float = PLACES[id].ang
		var m := _model(id)
		var half := Vector2(30, 24)
		if m != null:   # keep the model's own footprint clear, plus a 4 m pavement round it
			half = _half_size(m) + Vector2(4, 4)
		mark(c, ang, half.x, half.y, 4)
		_label(id, c)
		if m != null:
			m.position = Vector3(c.x, 0, c.y)
			m.rotation.y = -ang
			root.add_child(m)
			continue
		k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
		var g: String = "glow:" + id
		match id:
			"church":
				_yard(k, Vector2.ZERO, 60, 46, "pave")
				var s0 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, -PI / 2), Vector3.ZERO)
				_church(k, 0.9, g, st, sl)
				k.xf = s0
			"first":
				_yard(k, Vector2.ZERO, 56, 44, "pave")
				# A clock tower: tall square shaft, lit faces, pinnacles and a spire, a hall at its foot.
				k.box("stone", Vector2(0, 0), 9, 9, 0, 46, 3.0, 4.0, st)
				k.box("stone", Vector2(0, 0), 10.5, 10.5, 46, 53, 3.0, 3.5, st)
				for nv in [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]:
					k.pane(g, Vector3(0, 49.5, 0) + nv * 5.25, nv, 5.0, 5.0)
				for cx: float in [-1.0, 1.0]:
					for cz: float in [-1.0, 1.0]:
						k.pinnacle("stone", Vector2(cx * 4.9, cz * 4.9), 1.0, 53, 5, st)
				k.pyramid("slate", Vector2.ZERO, 9.5, 9.5, 53, 20, 4, sl)
				k.walls("limestone", Vector2(0, 10), 30, 9, 0, 12, 3.4, 4, st)
				k.gable("slate", "limestone", Vector2(0, 10), 30, 9, 12, 6, 0.4, 5, 3.4, 4, sl, st)
				for j in 7:
					k.pane("win", Vector3(-12 + j * 4, 7, 14.55), Vector3.BACK, 1.0, 2.6)
			"square":
				_yard(k, Vector2.ZERO, 60, 46, "pave")
				k.flat("grass", Vector2(-8, 4), 30, 26, 0.26, 8, Color(0.5, 0.55, 0.5))
				# A small church on the north side, the scaffold on the square.
				var s1 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(0, 0, -12))
				_church(k, 0.5, g, st, sl)
				k.xf = s1
				k.box("wood", Vector2(14, 8), 7, 6, 0, 2.4, 2, 2)
				k.box("wood", Vector2(12, 8), 0.5, 0.5, 2.4, 9, 1, 1)
				k.box("wood", Vector2(13.6, 8), 3.6, 0.4, 8.6, 9.0, 1, 1)
				k.box("iron", Vector2(15.1, 8), 0.08, 0.08, 6.0, 8.6, 1, 1)
				for j in 6:
					var a := TAU * j / 6
					trees.append([Vector3(c.x + cos(a) * 11 - 8, 0, c.y + sin(a) * 9 + 4), 3.0, _leaf()])
			"market":
				_yard(k, Vector2.ZERO, 56, 40, "pave")
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
				_yard(k, Vector2.ZERO, 58, 46, "grass")
				for wing in [[Vector2(0, -13), 44.0, 9.0], [Vector2(0, 13), 44.0, 9.0], [Vector2(-17.5, 0), 9.0, 18.0], [Vector2(17.5, 0), 9.0, 18.0]]:
					var wc: Vector2 = wing[0]
					var ww: float = wing[1]
					var wd: float = wing[2]
					k.walls("limestone", wc, ww, wd, 0, 13.6, _tw(ww), STOREY, st)
					k.hip("slate", wc, ww, wd, 13.6, 5, 0.3, 5, sl)
				for j in 11:
					k.pane(g if j % 3 == 0 else "win_pale", Vector3(-19 + j * 3.8, 5 + (j % 2) * 3.4, 17.55), Vector3.BACK, 0.8, 1.8)
				k.box("limestone", Vector2(0, 13), 9, 11, 0, 30, 3, 4, st)
				for cx: float in [-1.0, 1.0]:
					for cz: float in [-1.0, 1.0]:
						k.turret("limestone", "slate", Vector2(cx * 4.5, 13 + cz * 5.5), 1.4, 0, 33, 5, 2, 4, st, sl)
				k.pane(g, Vector3(0, 22, 18.55), Vector3.BACK, 3.0, 5.0)
			"hospital":
				_yard(k, Vector2.ZERO, 58, 44, "pave")
				for wing in [[Vector2(0, -13), 46.0, 10.0], [Vector2(0, 13), 46.0, 10.0], [Vector2(-18, 0), 8.0, 16.0], [Vector2(18, 0), 8.0, 16.0]]:
					var wc: Vector2 = wing[0]
					var ww: float = wing[1]
					var wd: float = wing[2]
					k.walls("stucco", wc, ww, wd, 0, 17, _tw(ww), STOREY, Color(0.85, 0.84, 0.82))
					k.hip("slate", wc, ww, wd, 17, 6, 0.3, 5, sl)
				for f in 5:
					for j in 13:
						if rng.randf() < 0.45:
							k.pane(g, Vector3(-21 + j * 3.5, 1.9 + f * STOREY, 18.05), Vector3.BACK, 0.65, 1.3)
				k.box("stone", Vector2(0, 18), 8, 3, 0, 24, 2, 4, st)
				k.pyramid("slate", Vector2(0, 18), 8, 3.4, 24, 8, 4, sl)
			"odeon":
				_yard(k, Vector2.ZERO, 56, 44, "pave")
				k.walls("limestone", Vector2(0, -3), 36, 26, 0, 20, 3.4, 4, st)
				k.hip("slate", Vector2(0, -3), 36, 26, 20, 7, 0.4, 5, sl)
				for j in 5:
					var ax := -12.0 + j * 6
					k.box("stone", Vector2(ax, 12), 1.2, 1.2, 0, 11, 2, 2, st)
					k.pinnacle("stone", Vector2(ax, 12), 1.0, 11, 3.5, st)
				k.box("stone", Vector2(0, 12), 26, 1.6, 9, 11, 3, 3, st)
				for j in 4:
					k.pane(g, Vector3(-9 + j * 6, 4.5, 10.05), Vector3.BACK, 3.0, 6.5)
				k.pane(g, Vector3(0, 15, 10.05), Vector3.BACK, 6.0, 4.0)
			"alley":
				# A narrow lane between tall, crooked houses, one lamp.
				var s2 := k.xf
				_yard(k, Vector2.ZERO, 44, 44, "pave")
				k.flat("street", Vector2.ZERO, 3.0, 44, 0.28, 6, Color(0.5, 0.5, 0.55))
				for side: float in [-1.0, 1.0]:
					var z := -22.0
					while z < 19.0:
						var w := rng.randf_range(4.0, 5.5)
						var hc := Vector2(side * 8.0, z + w / 2)
						var hw := s2 * Vector3(hc.x, 0, hc.y)
						var face := ang + PI / 2 + (PI if side < 0 else 0.0)
						gothic_house(k, Vector2(hw.x, hw.z), face, w, 13, rng.randi_range(4, 6), true)
						z += w
				k.xf = s2
				k.box("iron", Vector2(0, 2), 0.25, 0.25, 0, 5.5, 1, 1)
				k.box(g, Vector2(0, 2), 0.9, 0.9, 5.5, 6.5, 1, 1)
			"cemetery":
				_yard(k, Vector2.ZERO, 60, 46, "grass")
				for s: float in [-1.0, 1.0]:
					k.box("iron", Vector2(s * 29.5, 0), 0.2, 45, 0, 2.4, 1, 1)
					k.box("iron", Vector2(0, s * 22.5), 59, 0.2, 0, 2.4, 1, 1)
				var s1 := k.xf
				k.xf = k.xf * Transform3D(Basis(Vector3.UP, -PI / 2), Vector3(0, 0, -8))
				_church(k, 0.55, g, st, sl)
				k.xf = s1
				for j in 110:
					var hp := Vector2(rng.randf_range(-28, 28), rng.randf_range(-21, 21))
					if absf(hp.x) < 15 and hp.y < 2 and hp.y > -16:
						continue
					k.box("stone", hp, 0.9, 0.3, 0, rng.randf_range(0.9, 1.8), 1, 1, Color(0.7, 0.7, 0.72))
				for j in 8:
					var tp := k.xf * Vector3(rng.randf_range(-26, 26), 0, rng.randf_range(4, 20))
					trees.append([Vector3(tp.x, 0, tp.z), 3.0, Color(0.2, 0.22, 0.2)])
			"slaughter":
				_yard(k, Vector2.ZERO, 58, 44, "pave")
				for s: float in [-1.0, 1.0]:
					k.walls("brownbrick", Vector2(0, s * 11), 44, 10, 0, 8, 3.2, 4, Color(0.7, 0.62, 0.6))
					k.gable("claytile", "brownbrick", Vector2(0, s * 11), 44, 10, 8, 5, 0.4, 5, 3.2, 4, sl, Color(0.7, 0.62, 0.6))
					for j in 7:
						k.pane(g, Vector3(-18 + j * 6, 3, s * 16.05), Vector3(0, 0, s), 1.4, 1.6)
				k.cylinder("brownbrick", Vector2(18, 0), 2.0, 0, 34, 10, 2, 4, Color(0.6, 0.5, 0.48))
				for j in 6:
					k.box("wood", Vector2(-14 + j * 5, 0), 4, 0.2, 0, 1.3, 1, 1)
			"docks":
				# Warehouses facing the basin, cranes on the quay, barges moored below it.
				_yard(k, Vector2(0, -6), 70, 44, "pave")
				for j in 3:
					var wc := Vector2(-24 + j * 24, -10)
					k.walls("brownbrick", wc, 20, 16, 0, 15, _tw(20), STOREY, Color(0.75, 0.68, 0.62))
					var s5 := k.xf
					k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3(wc.x, 0, wc.y))
					k.gable("claytile", "brownbrick", Vector2.ZERO, 16, 20, 15, 7, 0.4, 5, 3.2, STOREY, sl, Color(0.75, 0.68, 0.62))
					k.xf = s5
					k.pane(g, Vector3(wc.x, 4, wc.y + 8.05), Vector3.BACK, 4.0, 6.0)
				for j in 2:
					var cp := Vector2(-16 + j * 32, 12)
					k.box("wood", cp, 1.2, 1.2, 0, 16, 1, 1)
					k.box("wood", cp + Vector2(0, 5), 0.8, 11, 15, 16, 1, 1)
					k.box("iron", cp + Vector2(0, 10), 0.08, 0.08, 6, 15, 1, 1)
				for j in 8:
					k.box("wood", Vector2(-20 + j * 5.5, 6 + (j % 2) * 3), 1.6, 1.6, 0, 2.4, 1, 1)
				for j in 3:
					var bc := Vector2(-24 + j * 24, 52)
					k.box("wood", bc, 20, 6, -1.8, -0.2, 2, 2)
					k.box("wood", bc + Vector2(-5, 0), 5, 4, -0.2, 1.8, 2, 2)
					k.box("wood", bc + Vector2(4, 0), 0.4, 0.4, -0.2, 12, 1, 1)
			"morgue":
				_yard(k, Vector2.ZERO, 36, 30, "pave")
				k.walls("blackstone", Vector2.ZERO, 18, 12, 0, 9, 3, 4, Color(0.8, 0.84, 0.86))
				k.hip("slate", Vector2.ZERO, 18, 12, 9, 5, 0.3, 5, sl)
				k.turret("blackstone", "slate", Vector2(8, 5), 1.6, 0, 13, 5, 2, 4, Color(0.8, 0.84, 0.86), sl)
				k.pane(g, Vector3(0, 2.5, 6.05), Vector3.BACK, 2.2, 4.0)
				k.pane(g, Vector3(-5, 5, 6.05), Vector3.BACK, 1.0, 2.0)
				k.pane(g, Vector3(5, 5, 6.05), Vector3.BACK, 1.0, 2.0)
	k.xf = Transform3D.IDENTITY


# ---------------------------------------------------------------- lamps and trees

func _build_lamps(root: Node3D, k: Kit) -> void:
	var lit := 0
	lamps.sort_custom(func(a: Vector3, b: Vector3) -> bool: return a.length_squared() < b.length_squared())
	var placed := []
	for p: Vector3 in lamps:
		var c := Vector2(p.x, p.z)
		if cell(c) == 2 or cell(c) == 3:
			continue
		var near := false
		for q: Vector2 in placed:
			if q.distance_squared_to(c) < 36.0:
				near = true
				break
		if near:
			continue
		placed.append(c)
		k.box("iron", c, 0.22, 0.22, p.y, p.y + 4.6, 1, 1)
		k.box("gas", c, 0.6, 0.6, p.y + 4.6, p.y + 5.3, 1, 1)
		k.pyramid("iron", c, 0.8, 0.8, p.y + 5.3, 0.5, 1)
		if lit < 110:
			var o := OmniLight3D.new()
			o.light_color = Color("#ffc27a")
			o.light_energy = 2.6
			o.omni_range = 16.0
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
	lm.vertex_color_use_as_albedo = true
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
	_build_water(k)
	_build_boats(k)
	_build_land(k)
	_build_bridges(k)
	_load_house_models()
	_build_landmarks(root, k)
	_build_roads(k)
	_build_paris(k)
	_build_houses(k)
	_build_lamps(root, k)
	k.finish(root)
	_build_house_models(root)
	_build_trees(root)
