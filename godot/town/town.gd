class_name Town
extends RefCounted
## The town, built from a fixed seed: a walled old town on a bend of the river, streets lined with steep-roofed
## houses, the landmarks the game needs, suburbs along the roads, then fields, hedges and trees to the horizon.
## Units are metres; the town centre is the origin, +z is south (towards the default camera).

const STOREY := 3.0
const TILE := 3.0                   # one wall texture tile: one storey, one window
const ROOF_T := 7.0                  # one roof texture tile, in metres
const WALL_A := 160.0                # the town wall, an ellipse
const WALL_B := 120.0
const GRID := 1.0
const HALF := 700.0
const PITCH := 0.62                  # roof rise per metre of half depth (steep, about 50 degrees)

# The river comes down the east side, bends below the town and leaves to the west.
const RIVER := [Vector2(520, -520), Vector2(330, -300), Vector2(225, -120), Vector2(205, 40), Vector2(150, 160), Vector2(40, 205),
	Vector2(-90, 200), Vector2(-210, 175), Vector2(-330, 230), Vector2(-520, 300), Vector2(-760, 330)]
const RIVER_W := 30.0

# Each landmark: name, colour, centre, and where its name floats.
const PLACES := {
	"church": {"name": "Saint-Roch", "col": "#e6c15a", "pos": Vector2(30, -62)},
	"square": {"name": "Public Square", "col": "#e0605a", "pos": Vector2(-6, 6)},
	"first": {"name": "First Player", "col": "#ece4cf", "pos": Vector2(-8, -24)},
	"market": {"name": "Market", "col": "#e8964a", "pos": Vector2(-88, 8)},
	"academy": {"name": "Academy", "col": "#7cc4ff", "pos": Vector2(-82, -46)},
	"hospital": {"name": "Hospital", "col": "#bcd8f0", "pos": Vector2(-40, 80)},
	"odeon": {"name": "Odéon", "col": "#d98cc0", "pos": Vector2(64, 48)},
	"alley": {"name": "Dark Alley", "col": "#b48ae0", "pos": Vector2(108, -10)},
	"cemetery": {"name": "Graveyard", "col": "#8fbf6a", "pos": Vector2(-235, -200)},
	"slaughter": {"name": "Slaughterhouse", "col": "#c0503f", "pos": Vector2(168, -178)},
	"docks": {"name": "Docks", "col": "#f08a3c", "pos": Vector2(40, 178)},
	"morgue": {"name": "Morgue", "col": "#5fc4b8", "pos": Vector2(-62, 172)},
}

var rng := RandomNumberGenerator.new()
var mats := {}
var occ := PackedByteArray()        # 1 m cells: 0 free, 1 street, 2 built, 3 water, 4 kept open
var streets := []                    # [Vector2 a, Vector2 b, float width]
var labels := []                     # {text, col, pos: Vector3}
var lights := []                     # {pos: Vector3, col, energy, range}
var trees := []                      # [Vector3 pos, float size, Color]
var houses := 0


# ---------------------------------------------------------------- materials

func _tex(file: String, rough := 0.95) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/art/town/%s.webp" % file)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	m.vertex_color_use_as_albedo = true
	m.roughness = rough
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _col(c: Color, e := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.vertex_color_use_as_albedo = true
	m.roughness = 0.9
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if e > 0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = e
	return m

func _make_mats() -> void:
	for k in ["roof-tiles", "wall-timber", "wall-stone", "cobbles", "grass", "field"]:
		mats[k] = _tex(k)
	mats["water"] = _tex("water", 0.08)
	mats["water"].metallic = 0.4
	mats["wood"] = _col(Color("#3a2a1e"))
	mats["slate"] = _col(Color("#3b4048"))
	mats["plaster"] = _col(Color("#b9ab8e"))
	mats["cloth-a"] = _col(Color("#7a2f27"))
	mats["cloth-b"] = _col(Color("#b49a62"))
	mats["leaf"] = _col(Color("#3e4d2c"))
	mats["win"] = _col(Color("#ffb35a"), 2.4)
	for id in PLACES:
		mats["glow:" + id] = _col(Color(PLACES[id].col), 2.6)


# ---------------------------------------------------------------- occupancy grid

func _i(p: Vector2) -> int:
	var x := int(floor((p.x + HALF) / GRID))
	var z := int(floor((p.y + HALF) / GRID))
	if x < 0 or z < 0 or x >= int(2 * HALF / GRID) or z >= int(2 * HALF / GRID):
		return -1
	return z * int(2 * HALF / GRID) + x

func cell(p: Vector2) -> int:
	var i := _i(p)
	return 255 if i < 0 else occ[i]

## Visit the cells of a rotated rectangle (centre c, half sizes hx along dir, hz across).
func _obb_cells(c: Vector2, ang: float, hx: float, hz: float) -> Array:
	var out := []
	var ax := Vector2(cos(ang), sin(ang))
	var az := Vector2(-ax.y, ax.x)
	var ext := absf(ax.x) * hx + absf(az.x) * hz
	var exz := absf(ax.y) * hx + absf(az.y) * hz
	var x := floorf(c.x - ext)
	while x <= c.x + ext:
		var z := floorf(c.y - exz)
		while z <= c.y + exz:
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

func inside_wall(p: Vector2, margin := 0.0) -> bool:
	return pow(p.x / (WALL_A - margin), 2) + pow(p.y / (WALL_B - margin), 2) < 1.0


# ---------------------------------------------------------------- river

func _river_pts() -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in RIVER.size() - 1:
		var p0: Vector2 = RIVER[maxi(i - 1, 0)]
		var p1: Vector2 = RIVER[i]
		var p2: Vector2 = RIVER[i + 1]
		var p3: Vector2 = RIVER[mini(i + 2, RIVER.size() - 1)]
		for k in 12:
			var t := k / 12.0
			var t2 := t * t
			var t3 := t2 * t
			pts.append(0.5 * (2.0 * p1 + (p2 - p0) * t + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 + (3.0 * p1 - p0 - 3.0 * p2 + p3) * t3))
	pts.append(RIVER[-1])
	return pts

func _build_river(k: Kit) -> void:
	var pts := _river_pts()
	var dist := 0.0
	for i in pts.size() - 1:
		var a := pts[i]
		var b := pts[i + 1]
		var na := _normal_at(pts, i)
		var nb := _normal_at(pts, i + 1)
		var w := RIVER_W / 2
		var seg := a.distance_to(b)
		k.quad("water", Vector3(a.x + na.x * w, 0.06, a.y + na.y * w), Vector3(b.x + nb.x * w, 0.06, b.y + nb.y * w), Vector3(b.x - nb.x * w, 0.06, b.y - nb.y * w), Vector3(a.x - na.x * w, 0.06, a.y - na.y * w),
			Vector2(dist / 18, 0), Vector2((dist + seg) / 18, 0), Vector2((dist + seg) / 18, RIVER_W / 18), Vector2(dist / 18, RIVER_W / 18))
		# Muddy banks.
		for s: float in [-1.0, 1.0]:
			var a0 := a + na * s * w
			var b0 := b + nb * s * w
			var a1 := a + na * s * (w + 3.5)
			var b1 := b + nb * s * (w + 3.5)
			k.quad("wall-stone", Vector3(a0.x, 0.07, a0.y), Vector3(b0.x, 0.07, b0.y), Vector3(b1.x, 0.09, b1.y), Vector3(a1.x, 0.09, a1.y), Vector2(dist / 6, 0), Vector2((dist + seg) / 6, 0), Vector2((dist + seg) / 6, 0.6), Vector2(dist / 6, 0.6), Color(0.55, 0.5, 0.45))
		for t in range(0, int(seg) + 1, 3):
			var p := a.lerp(b, t / maxf(seg, 0.01))
			var r := w + 4.0
			var x := -r
			while x <= r:
				var z := -r
				while z <= r:
					if x * x + z * z <= r * r:
						var ii := _i(p + Vector2(x, z))
						if ii >= 0:
							occ[ii] = 3
					z += GRID
				x += GRID
		dist += seg

func _normal_at(pts: PackedVector2Array, i: int) -> Vector2:
	var a := pts[maxi(i - 1, 0)]
	var b := pts[mini(i + 1, pts.size() - 1)]
	var d := (b - a).normalized()
	return Vector2(-d.y, d.x)

## Where a line from a to b first meets the river, or Vector2.INF.
func river_crossing(a: Vector2, b: Vector2) -> Vector2:
	var pts := _river_pts()
	for i in pts.size() - 1:
		var hit = Geometry2D.segment_intersects_segment(a, b, pts[i], pts[i + 1])
		if hit != null:
			return hit
	return Vector2.INF


# ---------------------------------------------------------------- streets

func street(pts: Array, w: float, k: Kit, tint := Color(0.8, 0.78, 0.75)) -> void:
	for i in pts.size() - 1:
		var a: Vector2 = pts[i]
		var b: Vector2 = pts[i + 1]
		streets.append([a, b, w])
		var d := (b - a).normalized()
		var n := Vector2(-d.y, d.x) * w / 2
		var a2 := a - d * w * 0.3
		var b2 := b + d * w * 0.3
		var y := 0.1 + 0.01 * (i % 2)
		var len := a2.distance_to(b2)
		k.quad("cobbles", Vector3(a2.x + n.x, y, a2.y + n.y), Vector3(b2.x + n.x, y, b2.y + n.y), Vector3(b2.x - n.x, y, b2.y - n.y), Vector3(a2.x - n.x, y, a2.y - n.y), Vector2(0, 0), Vector2(len / 6, 0), Vector2(len / 6, w / 6), Vector2(0, w / 6), tint)
		var c := (a + b) / 2
		for ii in _obb_cells(c, d.angle(), len / 2, w / 2 + 0.3):
			if ii >= 0 and occ[ii] == 0:
				occ[ii] = 1

func plaza(c: Vector2, w: float, d: float, k: Kit) -> void:
	k.flat("cobbles", c, w, d, 0.12, 6.0, Color(0.85, 0.82, 0.78))
	mark(c, 0.0, w / 2, d / 2, 4)

## A wandering lane between two points.
func _lane(a: Vector2, b: Vector2, wander: float, steps: int) -> Array:
	var pts := [a]
	var n := (b - a).normalized().orthogonal()
	for s in range(1, steps):
		var t := float(s) / steps
		pts.append(a.lerp(b, t) + n * rng.randf_range(-wander, wander))
	pts.append(b)
	return pts

func _build_streets(k: Kit) -> void:
	# Main road: south-west gate, the square, the cathedral close, north-east gate, and on over the river.
	street([Vector2(-760, 420), Vector2(-420, 300), Vector2(-250, 190), Vector2(-150, 95), Vector2(-80, 45), Vector2(-20, 10), Vector2(20, -20), Vector2(60, -30), Vector2(115, -70), Vector2(175, -110), Vector2(290, -200), Vector2(520, -330), Vector2(800, -460)], 9.0, k)
	# Cross road: west gate to east gate, crossing the river eastwards.
	street([Vector2(-800, -30), Vector2(-420, -40), Vector2(-240, -10), Vector2(-160, 0), Vector2(-100, 4), Vector2(-40, 0), Vector2(30, 8), Vector2(100, 20), Vector2(165, 30), Vector2(260, 50), Vector2(420, 40), Vector2(800, 80)], 7.5, k)
	# South road to the docks and over the bridge.
	street([Vector2(-10, 20), Vector2(5, 70), Vector2(25, 130), Vector2(38, 165), Vector2(60, 260), Vector2(120, 480), Vector2(160, 800)], 7.0, k)
	# North road past the academy to the graveyard and beyond.
	street([Vector2(-20, -10), Vector2(-40, -45), Vector2(-90, -100), Vector2(-150, -130), Vector2(-200, -110), Vector2(-280, -150), Vector2(-420, -260), Vector2(-700, -420)], 6.5, k)
	street([Vector2(70, -35), Vector2(78, -100), Vector2(60, -160), Vector2(20, -330), Vector2(-20, -800)], 6.0, k)
	# Ring street just inside the wall.
	var ring := []
	for i in 49:
		var a := TAU * i / 48
		ring.append(Vector2(cos(a) * (WALL_A - 14), sin(a) * (WALL_B - 14)))
	street(ring, 5.0, k)
	# Lanes between the roads.
	for i in 16:
		var a := TAU * rng.randf()
		var p := Vector2(cos(a) * (WALL_A - 14), sin(a) * (WALL_B - 14))
		var q := Vector2(rng.randf_range(-70, 70), rng.randf_range(-55, 55))
		street(_lane(p, p.lerp(q, rng.randf_range(0.45, 0.85)), 6.0, 4), rng.randf_range(3.6, 4.6), k)
	# Riverside quays.
	street([Vector2(-140, 182), Vector2(-60, 182), Vector2(20, 185), Vector2(90, 165), Vector2(135, 140)], 6.0, k)
	# Bridges where roads meet the river.
	for road in [[Vector2(290, -200), Vector2(520, -330)], [Vector2(165, 30), Vector2(260, 50)], [Vector2(38, 165), Vector2(60, 260)], [Vector2(-420, 300), Vector2(-250, 190)]]:
		var hit := river_crossing(road[0], road[1])
		if hit != Vector2.INF:
			bridge(hit, (road[1] - road[0]).angle(), k)

func bridge(c: Vector2, ang: float, k: Kit) -> void:
	var saved := k.xf
	k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
	var len := RIVER_W + 16
	k.box("wall-stone", Vector2.ZERO, len, 9, 0.0, 2.2, 3, 3, Color(0.8, 0.78, 0.72), "cobbles")
	for s: float in [-1.0, 1.0]:
		k.box("wall-stone", Vector2(0, s * 4.3), len, 0.6, 2.2, 3.2, 3, 3, Color(0.75, 0.72, 0.68))
	k.xf = saved
	mark(c, ang, len / 2, 5, 1)


# ---------------------------------------------------------------- houses

## A house in its own frame: frontage w along x, depth d, the street on +z. Timber or stone walls, a steep roof,
## chimneys, sometimes a dormer, a few lit windows.
func house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int, tall_lean := false) -> void:
	var saved := k.xf
	k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
	if tall_lean:
		k.xf.basis = k.xf.basis * Basis(Vector3.FORWARD, rng.randf_range(-0.035, 0.035))
	var stone := rng.randf() < 0.28
	var kw := "wall-stone" if stone else "wall-timber"
	var t := rng.randf_range(0.7, 1.0)
	var cw := Color(t, t * rng.randf_range(0.94, 1.0), t * rng.randf_range(0.86, 0.98))
	var h := floors * STOREY
	if not stone and rng.randf() < 0.5:
		k.walls("wall-stone", Vector2.ZERO, w, d, 0.0, STOREY, TILE, TILE, cw)
		k.walls(kw, Vector2.ZERO, w, d, STOREY, h, TILE, TILE, cw)
	else:
		k.walls(kw, Vector2.ZERO, w, d, 0.0, h, TILE, TILE, cw)
	var rt := rng.randf_range(0.55, 1.0)
	var cr := Color(rt, rt * rng.randf_range(0.78, 0.95), rt * rng.randf_range(0.7, 0.9))
	var roll := rng.randf()
	if roll < 0.15:
		cr = Color(0.55, 0.58, 0.66) * rng.randf_range(0.7, 1.0)   # slate
	elif roll < 0.3:
		cr = Color(0.62, 0.45, 0.36) * rng.randf_range(0.6, 0.9)   # old brown tiles
	var along := rng.randf() < 0.65 or w > d * 1.3
	var rh := 0.0
	if floors >= 3 and rng.randf() < 0.3:
		rh = minf(w, d) / 2 * PITCH * 1.1
		k.hip("roof-tiles", Vector2.ZERO, w, d, h, rh, 0.7, ROOF_T, cr)
		along = false
	elif along:
		rh = d / 2 * PITCH * rng.randf_range(0.9, 1.25)
		k.gable("roof-tiles", kw, Vector2.ZERO, w, d, h, rh, 0.7, ROOF_T, TILE, TILE, cr, cw)
	else:
		rh = w / 2 * PITCH * rng.randf_range(0.9, 1.25)
		var s2 := k.xf
		k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
		k.gable("roof-tiles", kw, Vector2.ZERO, d, w, h, rh, 0.7, ROOF_T, TILE, TILE, cr, cw)
		k.xf = s2
	# Chimneys.
	for i in rng.randi_range(1, 2):
		var cx := rng.randf_range(-w / 2 + 0.8, w / 2 - 0.8)
		var cz := rng.randf_range(-d / 4, d / 4)
		k.box("wall-stone", Vector2(cx, cz), 0.9, 0.9, h, h + rh + rng.randf_range(0.4, 1.6), 1.5, 1.5, Color(0.6, 0.55, 0.5))
	# A dormer on the street side.
	if along and w >= 6 and rng.randf() < 0.45:
		var dz := d / 4
		var dy := h + rh * 0.35
		k.walls(kw, Vector2(0, dz), 1.8, 1.4, dy - 0.2, dy + 1.4, 1.8, 1.8, cw)
		var s3 := k.xf
		k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
		k.gable("roof-tiles", kw, Vector2(-dz, 0), 1.6, 2.0, dy + 1.4, 0.9, 0.2, ROOF_T, 1.8, 1.8, cr, cw)
		k.xf = s3
		if rng.randf() < 0.5:
			k.pane("win", Vector3(0, dy + 0.6, dz + 0.71), Vector3.BACK, 0.6, 0.8)
	# Lit windows, centred on the window of each wall tile.
	for f in floors:
		for side in 4:
			var span := w if side % 2 == 0 else d
			var n := int(round(span / TILE))
			for j in n:
				if rng.randf() > 0.16:
					continue
				var u := -span / 2 + (j + 0.5) * span / n
				var y := f * STOREY + STOREY * 0.48
				var p: Vector3
				var nv: Vector3
				match side:
					0: p = Vector3(u, y, d / 2); nv = Vector3.BACK
					1: p = Vector3(w / 2, y, -u); nv = Vector3.RIGHT
					2: p = Vector3(-u, y, -d / 2); nv = Vector3.FORWARD
					_: p = Vector3(-w / 2, y, u); nv = Vector3.LEFT
				k.pane("win", p, nv, 0.62, 0.95)
	k.xf = saved
	houses += 1

func _try_house(k: Kit, c: Vector2, ang: float, w: float, d: float, floors: int) -> bool:
	if not is_free(c, ang, w / 2 + 0.15, d / 2 + 0.15):
		return false
	house(k, c, ang, w, d, floors)
	mark(c, ang, w / 2 + 0.15, d / 2 + 0.15, 2)
	return true

## Line every street with houses facing it, then fill the backs of the blocks.
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
			var t := rng.randf_range(0.0, 3.0)
			while t < len:
				var w := TILE * rng.randi_range(2, 3)
				var d := TILE * rng.randi_range(3, 4)
				var c := a + dir * (t + w / 2) + n * (sw / 2 + 1.3 + d / 2)
				var inside := inside_wall(c, 6.0)
				var near_town := pow(c.x / (WALL_A + 110), 2) + pow(c.y / (WALL_B + 90), 2) < 1.0
				var keep := inside or (near_town and rng.randf() < 0.55) or rng.randf() < 0.05
				if keep and (inside or not inside_wall(c, -8.0)):
					var floors := rng.randi_range(2, 3) if inside else rng.randi_range(1, 2)
					# The house faces the street: its +z must point back at the street.
					var face := ang + (PI if side > 0 else 0.0)
					_try_house(k, c, face, w, d, floors)
				if inside and rng.randf() < 0.85:
					var d2 := TILE * 2
					var c2 := c + n * (d / 2 + 1.0 + d2 / 2)
					_try_house(k, c2, ang + (PI if side > 0 else 0.0), w, d2, rng.randi_range(1, 2))
				t += w + (0.2 if inside else rng.randf_range(1.0, 8.0))
	# Block interiors: scan a grid twice (the second offset), each house turned to face its nearest street.
	for pass_i in 2:
		_infill(k, pass_i * 1.75)

func _infill(k: Kit, off: float) -> void:
	var z := -WALL_B + off
	while z < WALL_B:
		var x := -WALL_A + off
		while x < WALL_A:
			var c := Vector2(x, z) + Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
			x += 3.5
			if not inside_wall(c, 10.0) or cell(c) != 0:
				continue
			var ang := _street_angle(c)
			var w := TILE * 2
			var d := TILE * rng.randi_range(2, 3)
			if not _try_house(k, c, ang, w, d, rng.randi_range(1, 3)) and rng.randf() < 0.04:
				trees.append([Vector3(c.x, 0, c.y), rng.randf_range(3.0, 4.5), _leaf()])
				mark(c, 0.0, 2, 2, 4)
		z += 3.5


## The direction of the nearest street, turned so a house there faces it.
func _street_angle(p: Vector2) -> float:
	var best := INF
	var ang := 0.0
	for s in streets:
		var a: Vector2 = s[0]
		var b: Vector2 = s[1]
		var q := Geometry2D.get_closest_point_to_segment(p, a, b)
		var dd := q.distance_squared_to(p)
		if dd < best:
			best = dd
			var dir := (b - a).normalized()
			var side := signf(Vector2(-dir.y, dir.x).dot(p - q))
			ang = dir.angle() + (PI if side > 0 else 0.0)
	return ang


# ---------------------------------------------------------------- the wall

func _build_wall(k: Kit) -> void:
	var segs := 64
	var pts := []
	for i in segs + 1:
		var a := TAU * i / segs
		pts.append(Vector2(cos(a) * WALL_A, sin(a) * WALL_B))
	var gates: Array[Vector2] = []
	for i in segs:
		var p0: Vector2 = pts[i]
		var p1: Vector2 = pts[i + 1]
		var mid := (p0 + p1) / 2
		# A gap where a road passes: gate towers stand either side.
		var gate := false
		for s in streets:
			if s[2] >= 6.0 and Geometry2D.segment_intersects_segment(p0, p1, s[0], s[1]) != null:
				gate = true
		if gate:
			var near_gate := false
			for gp in gates:
				if gp.distance_to(mid) < 30.0:
					near_gate = true
			if not near_gate:
				gates.append(mid)
				for q in [p0, p1]:
					_tower(k, q, 6.5, 19.0)
			continue
		var d := (p1 - p0)
		var n := d.normalized().orthogonal() * 1.6
		k.wall("wall-stone", p0 + n, p1 + n, 0.0, 9.0, 4.0, 4.0, Color(0.78, 0.74, 0.68))
		k.wall("wall-stone", p1 - n, p0 - n, 0.0, 9.0, 4.0, 4.0, Color(0.7, 0.66, 0.6))
		k.quad("wall-stone", Vector3(p0.x + n.x, 9, p0.y + n.y), Vector3(p1.x + n.x, 9, p1.y + n.y), Vector3(p1.x - n.x, 9, p1.y - n.y), Vector3(p0.x - n.x, 9, p0.y - n.y), Vector2(0, 0), Vector2(d.length() / 4, 0), Vector2(d.length() / 4, 0.8), Vector2(0, 0.8), Color(0.6, 0.58, 0.55))
		# Crenellations on the outer edge.
		var cn := int(d.length() / 2.4)
		for j in cn:
			var q: Vector2 = p0.lerp(p1, (j + 0.5) / cn) + n * 0.7
			if j % 2 == 0:
				k.box("wall-stone", q, 1.2, 0.8, 9.0, 10.3, 2, 2, Color(0.72, 0.7, 0.65))
		mark(mid, d.angle(), d.length() / 2 + 0.5, 2.5, 2)
		var by_gate := false
		for gp in gates:
			if gp.distance_to(p0) < 24.0:
				by_gate = true
		if i % 4 == 0 and not by_gate:
			_tower(k, p0, 5.0, 15.0)

func _tower(k: Kit, c: Vector2, r: float, h: float) -> void:
	k.cylinder("wall-stone", c, r, 0.0, h, 14, 4.0, 4.0, Color(0.78, 0.74, 0.68))
	k.cone("roof-tiles", c, r + 0.8, h, r * 1.9, 14, ROOF_T, Color(0.85, 0.7, 0.6))
	for j in 3:
		var a := rng.randf() * TAU
		if rng.randf() < 0.5:
			k.pane("win", Vector3(c.x + cos(a) * r, h * 0.62, c.y + sin(a) * r), Vector3(cos(a), 0, sin(a)), 0.6, 1.0)
	mark(c, 0.0, r + 1, r + 1, 2)


# ---------------------------------------------------------------- landmarks

func _at(k: Kit, id: String, ang := 0.0) -> Vector2:
	var c: Vector2 = PLACES[id].pos
	k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
	return c

func _label(id: String, h: float) -> void:
	var c: Vector2 = PLACES[id].pos
	labels.append({"text": PLACES[id].name, "col": Color(PLACES[id].col), "pos": Vector3(c.x, h, c.y)})
	lights.append({"pos": Vector3(c.x, 8.0, c.y + 6.0), "col": Color(PLACES[id].col), "energy": 6.0, "range": 34.0})

func _build_landmarks(k: Kit) -> void:
	var stone := Color(0.8, 0.77, 0.7)
	var slate := Color(0.55, 0.58, 0.65)
	# Saint-Roch: nave, aisles, transept, apse, twin west towers with spires, a crossing spire.
	var c := _at(k, "church", 0.08)
	var g := "glow:church"
	k.walls("wall-stone", Vector2(0, 0), 16, 56, 0, 22, 4, 4, stone)
	k.gable("roof-tiles", "wall-stone", Vector2(0, 0), 56, 16, 22, 11, 0.8, ROOF_T, 4, 4, slate, stone)
	for s: float in [-1.0, 1.0]:
		k.walls("wall-stone", Vector2(s * 12, 2), 8, 46, 0, 11, 4, 4, stone)
		k.hip("roof-tiles", Vector2(s * 12, 2), 8, 46, 11, 3.5, 0.6, ROOF_T, slate)
		for j in 6:
			k.pane(g, Vector3(s * 8.05, 15, -18 + j * 7), Vector3(s, 0, 0), 1.6, 5.0)
	var sv := k.xf
	k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3.ZERO)
	k.walls("wall-stone", Vector2(10, 0), 14, 44, 0, 22, 4, 4, stone)
	k.gable("roof-tiles", "wall-stone", Vector2(10, 0), 44, 14, 22, 10, 0.8, ROOF_T, 4, 4, slate, stone)
	k.xf = sv
	k.cylinder("wall-stone", Vector2(0, -30), 8, 0, 20, 12, 4, 4, stone)
	k.cone("roof-tiles", Vector2(0, -30), 8.6, 20, 9, 12, ROOF_T, slate)
	for s: float in [-1.0, 1.0]:
		k.box("wall-stone", Vector2(s * 7, 30), 9, 9, 0, 40, 4, 4, stone)
		k.pyramid("roof-tiles", Vector2(s * 7, 30), 9.6, 9.6, 40, 20, ROOF_T, slate)
		k.pane(g, Vector3(s * 7, 30, 34.6), Vector3.BACK, 2.0, 4.0)
	k.pane(g, Vector3(0, 16, 28.1), Vector3.BACK, 5.0, 5.0)
	k.pane(g, Vector3(0, 5, 28.1), Vector3.BACK, 3.0, 6.0)
	k.box("wall-stone", Vector2(0, -10), 7, 7, 22, 40, 4, 4, stone)
	k.pyramid("roof-tiles", Vector2(0, -10), 7.6, 7.6, 40, 30, ROOF_T, slate)
	mark(c, 0.08, 22, 40, 2)
	plaza(c + Vector2(0, 46), 40, 22, k)
	_label("church", 74)
	# The square: paving, a fountain and the scaffold.
	c = _at(k, "square")
	k.xf = Transform3D.IDENTITY
	plaza(c, 52, 40, k)
	k.cylinder("wall-stone", c + Vector2(-8, 0), 4.5, 0, 1.0, 16, 3, 3, stone)
	k.disc("water", c + Vector2(-8, 0), 4.2, 0.9, 16, 6)
	k.cylinder("wall-stone", c + Vector2(-8, 0), 0.6, 0, 3.5, 8, 2, 2, stone)
	k.disc("glow:square", c + Vector2(-8, 0), 1.2, 3.5, 8, 2)
	k.box("wood", c + Vector2(12, -4), 8, 6, 0, 2.2, 3, 3)
	k.box("wood", c + Vector2(10.5, -4), 0.5, 0.5, 2.2, 8.5, 3, 3)
	k.box("wood", c + Vector2(12, -4), 3.5, 0.4, 8.2, 8.7, 3, 3)
	_label("square", 14)
	# First Player: the town hall and its belfry, clock faces lit.
	c = _at(k, "first")
	k.walls("wall-stone", Vector2.ZERO, 26, 12, 0, 12, 4, 4, stone)
	k.gable("roof-tiles", "wall-stone", Vector2.ZERO, 26, 12, 12, 6, 0.6, ROOF_T, 4, 4, slate, stone)
	k.box("wall-stone", Vector2(0, 0), 7, 7, 12, 34, 4, 4, stone)
	k.pyramid("roof-tiles", Vector2(0, 0), 7.6, 7.6, 34, 10, ROOF_T, slate)
	for nv in [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]:
		k.pane("glow:first", Vector3(0, 29, 0) + nv * 3.5, nv, 3.6, 3.6)
	for j in 6:
		k.pane("win", Vector3(-10 + j * 4, 6, 6.0), Vector3.BACK, 1.0, 2.2)
	mark(c, 0, 14, 7, 2)
	_label("first", 48)
	# Market hall: a big hipped roof on timber posts, stalls under awnings.
	c = _at(k, "market", 0.05)
	plaza(c, 46, 30, k)
	k.xf = Transform3D(Basis(Vector3.UP, -0.05), Vector3(c.x, 0, c.y))
	for x in range(-12, 13, 6):
		for z in [-7, 7]:
			k.box("wood", Vector2(x, z), 0.7, 0.7, 0, 5.5, 2, 2)
	k.hip("roof-tiles", Vector2.ZERO, 28, 16, 5.5, 6.5, 1.0, ROOF_T, Color(0.85, 0.65, 0.5))
	for j in 5:
		var sc := Vector2(-12 + j * 6, 12)
		k.box("wood", sc, 3.4, 2.0, 0, 1.0, 2, 2)
		k.gable("cloth-a" if j % 2 == 0 else "cloth-b", "wood", sc, 3.8, 2.6, 2.2, 0.6, 0.1, 2, 2, 2)
		k.box("wood", sc + Vector2(-1.6, 1), 0.2, 0.2, 0, 2.2, 1, 1)
		k.box("wood", sc + Vector2(1.6, 1), 0.2, 0.2, 0, 2.2, 1, 1)
	k.pane("glow:market", Vector3(0, 4.2, 8.1), Vector3.BACK, 16, 0.6)
	_label("market", 18)
	# Academy: a stone institute round a court, a portico and a dome.
	c = _at(k, "academy", -0.06)
	k.walls("wall-stone", Vector2.ZERO, 40, 24, 0, 15, 4, 4, Color(0.86, 0.84, 0.8))
	k.hip("roof-tiles", Vector2.ZERO, 40, 24, 15, 5, 0.6, ROOF_T, slate)
	k.cylinder("wall-stone", Vector2(0, -2), 8, 15, 22, 16, 4, 4, Color(0.86, 0.84, 0.8))
	k.cone("roof-tiles", Vector2(0, -2), 8.5, 22, 5.5, 16, ROOF_T, slate)
	k.cylinder("wall-stone", Vector2(0, -2), 1.4, 27, 31, 8, 2, 2)
	k.cone("glow:academy", Vector2(0, -2), 1.8, 31, 2.5, 8, 2)
	for j in 6:
		k.cylinder("wall-stone", Vector2(-10 + j * 4, 15), 0.8, 0, 12, 8, 2, 4, Color(0.9, 0.88, 0.84))
	k.box("wall-stone", Vector2(0, 14), 24, 4, 12, 13.5, 4, 4)
	var sv2 := k.xf
	k.gable("roof-tiles", "wall-stone", Vector2(0, 14), 24, 4.4, 13.5, 3.5, 0.2, ROOF_T, 4, 4, slate, stone)
	k.xf = sv2
	for f in 3:
		for j in 8:
			k.pane("glow:academy" if (j + f) % 3 == 0 else "win", Vector3(-17.5 + j * 5, 2.5 + f * 4.5, 12.05), Vector3.BACK, 1.2, 2.4)
	mark(c, -0.06, 21, 17, 2)
	_label("academy", 40)
	# Hospital: four wings round a court, a chapel at the back.
	c = _at(k, "hospital", 0.04)
	for wing in [[Vector2(0, -18), 50.0, 10.0], [Vector2(0, 18), 50.0, 10.0], [Vector2(-20, 0), 10.0, 26.0], [Vector2(20, 0), 10.0, 26.0]]:
		var wc: Vector2 = wing[0]
		var ww: float = wing[1]
		var wd: float = wing[2]
		k.walls("wall-timber" if wc.y != 0 else "wall-stone", wc, ww, wd, 0, 12, 3, 3, Color(0.92, 0.9, 0.86))
		k.hip("roof-tiles", wc, ww, wd, 12, 5, 0.7, ROOF_T, slate)
	for j in 14:
		k.pane("glow:hospital", Vector3(-23 + j * 3.5, 4.5 + 3 * (j % 2), 23.05), Vector3.BACK, 0.8, 1.4)
	k.flat("grass", Vector2.ZERO, 30, 26, 0.12, 8)
	k.cylinder("wall-stone", Vector2(0, 0), 2.5, 0, 1.2, 10, 2, 2)
	mark(c, 0.04, 26, 24, 2)
	_label("hospital", 26)
	# Odéon: a theatre with a colonnade.
	c = _at(k, "odeon", -0.1)
	k.walls("wall-stone", Vector2.ZERO, 30, 24, 0, 16, 4, 4, Color(0.88, 0.82, 0.78))
	k.hip("roof-tiles", Vector2.ZERO, 30, 24, 16, 6, 0.6, ROOF_T, slate)
	for j in 8:
		k.cylinder("wall-stone", Vector2(-12.25 + j * 3.5, 14), 0.8, 0, 13, 8, 2, 4)
	k.box("wall-stone", Vector2(0, 14), 28, 4, 13, 14.5, 4, 4)
	k.gable("roof-tiles", "wall-stone", Vector2(0, 14), 28, 4.4, 14.5, 4.0, 0.2, ROOF_T, 4, 4, slate, stone)
	for j in 4:
		k.pane("glow:odeon", Vector3(-9 + j * 6, 3.5, 12.05), Vector3.BACK, 2.2, 4.5)
	mark(c, -0.1, 16, 17, 2)
	_label("odeon", 30)
	# Dark Alley: a narrow lane between tall leaning houses, one lamp.
	c = _at(k, "alley", 0.5)
	k.xf = Transform3D.IDENTITY
	var dir := Vector2(cos(0.5), sin(0.5))
	var nrm := dir.orthogonal()
	street([c - dir * 28, c + dir * 28], 2.6, k, Color(0.55, 0.5, 0.5))
	for side: float in [-1.0, 1.0]:
		var t := -26.0
		while t < 26.0:
			var w := TILE * 2
			var hc := c + dir * (t + w / 2) + nrm * side * (1.3 + 0.4 + 4.5)
			var face := dir.angle() + (PI if side > 0 else 0.0)
			house(k, hc, face, w, 9, 4, true)
			mark(hc, face, w / 2 + 0.2, 4.7, 2)
			t += w + 0.1
	k.box("wood", c, 0.3, 0.3, 0, 4.5, 1, 1)
	k.box("glow:alley", c, 0.9, 0.9, 4.5, 5.4, 1, 1)
	_label("alley", 22)
	# Graveyard: a walled yard, a chapel, headstones, cypresses.
	c = _at(k, "cemetery", 0.12)
	for s: float in [-1.0, 1.0]:
		k.box("wall-stone", Vector2(s * 36, 0), 1.2, 52, 0, 2.6, 3, 3)
	k.box("wall-stone", Vector2(0, -26), 72, 1.2, 0, 2.6, 3, 3)
	k.box("wall-stone", Vector2(-21, 26), 30, 1.2, 0, 2.6, 3, 3)
	k.box("wall-stone", Vector2(21, 26), 30, 1.2, 0, 2.6, 3, 3)
	k.flat("grass", Vector2.ZERO, 72, 52, 0.12, 8, Color(0.6, 0.65, 0.55))
	var sv3 := k.xf
	k.xf = k.xf * Transform3D(Basis(Vector3.UP, PI / 2), Vector3(0, 0, 0))
	k.walls("wall-stone", Vector2(14, 0), 18, 10, 0, 8, 3, 3, stone)
	k.gable("roof-tiles", "wall-stone", Vector2(14, 0), 18, 10, 8, 5, 0.5, ROOF_T, 3, 3, slate, stone)
	k.xf = sv3
	k.box("wall-stone", Vector2(0, -6), 3.5, 3.5, 0, 16, 3, 3, stone)
	k.pyramid("roof-tiles", Vector2(0, -6), 4, 4, 16, 6, ROOF_T, slate)
	k.pane("glow:cemetery", Vector3(0, 4, -5.95 + 2.2), Vector3.BACK, 1.6, 3.0)
	for i in 70:
		var hp := Vector2(rng.randf_range(-32, 32), rng.randf_range(-22, 22))
		if hp.distance_to(Vector2(0, -10)) < 12:
			continue
		k.box("wall-stone", hp, 0.9, 0.3, 0, rng.randf_range(0.8, 1.5), 1, 1, Color(0.7, 0.7, 0.68))
	for i in 12:
		var tp := Vector2(rng.randf_range(-33, 33), rng.randf_range(-23, 23))
		k.cylinder("wood", tp, 0.2, 0, 1.2, 5, 1, 1)
		k.cone("leaf", tp, 1.3, 1.0, rng.randf_range(6, 9), 7, 2, Color(0.55, 0.65, 0.5))
	mark(c, 0.12, 37, 27, 2)
	_label("cemetery", 22)
	# Slaughterhouse: long sheds round a yard of pens, a tall chimney.
	c = _at(k, "slaughter", -0.5)
	for s: float in [-1.0, 1.0]:
		k.walls("wall-timber", Vector2(0, s * 12), 44, 9, 0, 6, 3, 3, Color(0.7, 0.62, 0.58))
		k.gable("roof-tiles", "wall-timber", Vector2(0, s * 12), 44, 9, 6, 3.5, 0.6, ROOF_T, 3, 3, Color(0.6, 0.45, 0.4))
		for j in 6:
			k.pane("glow:slaughter", Vector3(-18 + j * 7, 2.5, s * 12 + s * 4.55), Vector3(0, 0, s), 1.4, 1.2)
	for j in 6:
		k.box("wood", Vector2(-15 + j * 6, 0), 5, 0.2, 0, 1.2, 2, 2)
	k.cylinder("wall-stone", Vector2(20, 0), 1.6, 0, 22, 10, 2, 3, Color(0.6, 0.45, 0.4))
	mark(c, -0.5, 23, 17, 2)
	_label("slaughter", 26)
	# Docks: a stone quay, warehouses, a crane, moored barges.
	c = _at(k, "docks", -0.15)
	k.box("wall-stone", Vector2.ZERO, 70, 12, 0, 1.0, 4, 4, Color(0.7, 0.68, 0.64), "cobbles")
	for j in 2:
		var wc := Vector2(-22 + j * 30, -14)
		k.walls("wall-timber", wc, 18, 12, 0, 9, 3, 3, Color(0.75, 0.7, 0.62))
		k.gable("roof-tiles", "wall-timber", wc, 18, 12, 9, 4.5, 0.6, ROOF_T, 3, 3)
		k.pane("glow:docks", Vector3(wc.x, 3, wc.y + 6.05), Vector3.BACK, 3.5, 4.0)
	k.box("wood", Vector2(20, 2), 1.0, 1.0, 1, 14, 2, 2)
	k.box("wood", Vector2(24, 2), 9, 0.7, 13, 13.8, 2, 2)
	k.box("wood", Vector2(28, 2), 0.1, 0.1, 6, 13, 1, 1)
	for j in 8:
		k.box("wood", Vector2(-30 + j * 3.2, 3 + (j % 2) * 1.6), 1.4, 1.4, 1, 2.4, 1, 1)
	for j in 2:
		var bc := Vector2(-18 + j * 26, 12)
		k.box("wood", bc, 16, 4.5, -0.3, 1.2, 2, 2)
		k.box("wood", bc + Vector2(-4, 0), 4, 3, 1.2, 2.6, 2, 2)
	mark(c, -0.15, 37, 22, 2)
	_label("docks", 20)
	# Morgue: a low stone house with a small lantern turret.
	c = _at(k, "morgue", 0.1)
	k.walls("wall-stone", Vector2.ZERO, 18, 12, 0, 8, 3, 3, Color(0.72, 0.76, 0.76))
	k.hip("roof-tiles", Vector2.ZERO, 18, 12, 8, 4, 0.6, ROOF_T, slate)
	k.cylinder("wall-stone", Vector2.ZERO, 1.6, 10, 13, 8, 2, 2)
	k.cone("roof-tiles", Vector2.ZERO, 2.0, 13, 2.5, 8, ROOF_T, slate)
	k.pane("glow:morgue", Vector3(0, 2.5, 6.05), Vector3.BACK, 2.0, 3.5)
	k.pane("glow:morgue", Vector3(-5, 4.5, 6.05), Vector3.BACK, 1.0, 1.6)
	k.pane("glow:morgue", Vector3(5, 4.5, 6.05), Vector3.BACK, 1.0, 1.6)
	mark(c, 0.1, 10, 7, 2)
	_label("morgue", 18)
	k.xf = Transform3D.IDENTITY
	# Keep the landmarks' surroundings open before the houses go in.
	for id in ["academy", "hospital", "odeon", "morgue", "slaughter"]:
		var p: Vector2 = PLACES[id].pos
		mark(p + Vector2(0, 26), 0.0, 14, 5, 4)


# ---------------------------------------------------------------- the country

func _leaf() -> Color:
	var t := rng.randf_range(0.55, 1.0)
	return Color(0.32 * t, 0.42 * t, 0.24 * t)

func _build_country(k: Kit) -> void:
	# Fields: a patchwork of tilted plots on a coarse grid, with hedges of trees along some edges.
	var step := 70.0
	var x := -HALF
	while x < HALF:
		var z := -HALF
		while z < HALF:
			var c := Vector2(x + step / 2 + rng.randf_range(-10, 10), z + step / 2 + rng.randf_range(-10, 10))
			var w := step * rng.randf_range(0.75, 0.95)
			var d := step * rng.randf_range(0.6, 0.95)
			var ang := rng.randf_range(-0.25, 0.25)
			if pow(c.x / (WALL_A + 150), 2) + pow(c.y / (WALL_B + 130), 2) > 1.0 and is_free(c, ang, w / 2, d / 2):
				var t := rng.randf_range(0.38, 0.6)
				var tint: Color = [Color(t, t, t * 0.85), Color(t * 0.8, t, t * 0.7), Color(t, t * 0.9, t * 0.7)][rng.randi_range(0, 2)]
				var saved := k.xf
				k.xf = Transform3D(Basis(Vector3.UP, -ang), Vector3(c.x, 0, c.y))
				if rng.randf() < 0.75:
					k.flat("field", Vector2.ZERO, w, d, 0.05, rng.randf_range(10, 16), tint)
				k.xf = saved
				mark(c, ang, w / 2, d / 2, 4)
				# Hedgerow along one or two edges.
				var dir := Vector2(cos(ang), sin(ang))
				var nrm := dir.orthogonal()
				for e in rng.randi_range(0, 2):
					var off := nrm * (d / 2 + 3) * (1.0 if e == 0 else -1.0)
					var n := int(w / 6)
					for j in n:
						if rng.randf() < 0.75:
							var p := c + off + dir * (-w / 2 + j * w / n)
							trees.append([Vector3(p.x, 0, p.y), rng.randf_range(3.0, 5.0), _leaf()])
				# A farm now and then.
				if rng.randf() < 0.1:
					var fc := c + nrm * (d / 2 + 12)
					if is_free(fc, ang, 10, 8):
						house(k, fc, ang, 12, 9, 1)
						mark(fc, ang, 8, 6, 2)
			z += step
		x += step
	# Woods and lone trees on what is left.
	for i in 5000:
		var p := Vector2(rng.randf_range(-HALF, HALF), rng.randf_range(-HALF, HALF))
		if inside_wall(p, -20.0):
			continue
		if cell(p) == 0 and (rng.randf() < 0.5 or p.length() > 380):
			trees.append([Vector3(p.x, 0, p.y), rng.randf_range(3.0, 6.0), _leaf()])
			mark(p, 0.0, 2, 2, 4)
	# A windmill on a rise to the north-west.
	var wm := Vector2(-330, -260)
	k.xf = Transform3D.IDENTITY
	k.cylinder("wall-stone", wm, 5, 0, 13, 12, 3, 3, Color(0.8, 0.78, 0.72))
	k.cone("roof-tiles", wm, 5.6, 13, 5, 12, ROOF_T)
	k.xf = Transform3D(Basis(Vector3.UP, 0.4), Vector3(wm.x, 0, wm.y))
	for a in 4:
		var s2 := k.xf
		k.xf = k.xf * Transform3D(Basis(Vector3.BACK, a * PI / 2 + 0.3), Vector3(0, 12, 5.8))
		k.box("wood", Vector2(0, 0), 1.2, 0.3, 0, 11, 2, 2)
		k.xf = s2
	k.xf = Transform3D.IDENTITY


func _build_trees(root: Node3D) -> void:
	var crown := SphereMesh.new()
	crown.radius = 1.0
	crown.height = 1.7
	crown.radial_segments = 8
	crown.rings = 4
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.12
	trunk.bottom_radius = 0.2
	trunk.height = 1.0
	trunk.radial_segments = 5
	var lm := StandardMaterial3D.new()
	lm.vertex_color_use_as_albedo = true
	lm.roughness = 1.0
	lm.albedo_texture = mats["grass"].albedo_texture
	lm.uv1_scale = Vector3(0.5, 0.5, 0.5)
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
		var b := Basis.from_scale(Vector3(s, s * rng.randf_range(0.9, 1.25), s)).rotated(Vector3.UP, rng.randf() * TAU)
		mc.set_instance_transform(i, Transform3D(b, p + Vector3(0, s * 1.55, 0)))
		mc.set_instance_color(i, trees[i][2])
		mt.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(s * 0.6, s * 1.2, s * 0.6)), p + Vector3(0, s * 0.6, 0)))
	var a := MultiMeshInstance3D.new()
	a.multimesh = mc
	root.add_child(a)
	var b2 := MultiMeshInstance3D.new()
	b2.multimesh = mt
	root.add_child(b2)


# ---------------------------------------------------------------- build

func build(root: Node3D) -> void:
	rng.seed = 1819
	occ.resize(int(2 * HALF / GRID) * int(2 * HALF / GRID))
	occ.fill(0)
	_make_mats()
	var k := Kit.new(mats)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(6000, 6000)
	ground.mesh = pm
	var gm: StandardMaterial3D = mats["grass"].duplicate()
	gm.uv1_scale = Vector3(6000.0 / 30, 6000.0 / 30, 1)
	gm.albedo_color = Color(0.55, 0.62, 0.45)
	ground.material_override = gm
	root.add_child(ground)
	_build_river(k)
	var segs := 64
	for i in segs:
		var a0 := TAU * i / segs
		var a1 := TAU * (i + 1) / segs
		var p0 := Vector2(cos(a0) * WALL_A, sin(a0) * WALL_B)
		var p1 := Vector2(cos(a1) * WALL_A, sin(a1) * WALL_B)
		k.tri("cobbles", Vector3(0, 0.04, 0), Vector3(p1.x, 0.04, p1.y), Vector3(p0.x, 0.04, p0.y), Vector2.ZERO, p1 / 9.0, p0 / 9.0, Color(0.5, 0.47, 0.42))
	_build_landmarks(k)
	_build_streets(k)
	_build_wall(k)
	_build_houses(k)
	_build_country(k)
	k.finish(root)
	_build_trees(root)
