class_name City
extends RefCounted
## The city the game is played in (D168): no painted map, the ground is the board. Inside the railing lies the play
## area: cobbled streets, the Seine with its two islands, and one landmark per place in that place's own colour.
## Outside it the city runs on in every direction, rising as it goes, until the fog takes it.
## Geometry only: built once from a fixed seed, merged into one mesh per material.

const ST := 0.34                    # one storey: wall tiles are ST x ST, so windows line up
const PLAY := Rect2(-8.4, -5.6, 16.8, 10.9)   # inside the railing: the map, both home rows and the rival lab mats
const BOARD_ZONE := Rect2(-9.4, 5.0, 19.6, 5.4) # your board and its dials, on the street in front of the railing
const FAR := 34.0
const FLOOR_Y := -0.03
const WATER_Y := -0.02
const ISLAND_Y := -0.008
# The Seine, west to east (world x, z), and the islands that carry First Player and the Morgue.
const RIVER := [Vector2(-40, 1.6), Vector2(-12, 0.6), Vector2(-8.5, 0.2), Vector2(-6, -0.25), Vector2(-3.5, -0.45), Vector2(-1.5, -0.4), Vector2(0.5, -0.2), Vector2(2.5, 0.35), Vector2(4.5, 0.75), Vector2(6.5, 1.0), Vector2(8.5, 1.4), Vector2(12, 2.0), Vector2(40, 4.0)]
const ISLANDS := [[Vector2(-0.4, -0.5), Vector2(1.4, 0.82)], [Vector2(3.25, 0.42), Vector2(2.35, 0.6)]]
const BRIDGES := [-7.0, -2.6, 6.3]
const STREETS_X := [-7.0, -2.6, 6.3]   # the streets that lead to the bridges
const LM_SCALE := 1.35
# Landmark footprints (w, d), built facing +z, towards you.
const LM_SIZE := {"cemetery": Vector2(1.5, 0.9), "square": Vector2(1.0, 0.75), "slaughter": Vector2(1.6, 0.8), "church": Vector2(0.9, 1.25),
	"market": Vector2(1.3, 0.85), "first": Vector2(0.45, 0.45), "morgue": Vector2(0.75, 0.55), "hospital": Vector2(1.7, 0.75),
	"academy": Vector2(1.4, 0.95), "docks": Vector2(1.3, 0.75), "alley": Vector2(0.9, 0.7), "odeon": Vector2(1.36, 0.8)}

var rng := RandomNumberGenerator.new()
var mats := {}
var keep_out: Array[Rect2] = []     # discs, card rows, home rows, landmarks: no house here
var clear_circles := []             # [Vector2 centre, radius]
var win_night: StandardMaterial3D
var gas_lamps: Array[OmniLight3D] = []


# ---------------------------------------------------------------- mesh builder

class Builder:
	var st := {}
	var mats := {}
	func _init(m: Dictionary) -> void:
		mats = m
	func _s(k: String) -> SurfaceTool:
		if not st.has(k):
			var s := SurfaceTool.new()
			s.begin(Mesh.PRIMITIVE_TRIANGLES)
			st[k] = s
		return st[k]
	func tri(k: String, a: Vector3, b: Vector3, c: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, n: Vector3, col := Color.WHITE) -> void:
		var s := _s(k)
		for p in [[a, ua], [b, ub], [c, uc]]:
			s.set_color(col)
			s.set_normal(n)
			s.set_uv(p[1])
			s.add_vertex(p[0])
	func quad(k: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, ud: Vector2, n: Vector3, col := Color.WHITE) -> void:
		tri(k, a, b, c, ua, ub, uc, n, col)
		tri(k, a, c, d, ua, uc, ud, n, col)
	## A vertical wall from (x0, z0) to (x1, z1), tiled one texture per storey.
	func wall(k: String, x0: float, z0: float, x1: float, z1: float, y0: float, y1: float, n: Vector3, col := Color.WHITE) -> void:
		var u1 := Vector2(x1 - x0, z1 - z0).length() / ST
		var v1 := (y1 - y0) / ST
		quad(k, Vector3(x0, y1, z0), Vector3(x1, y1, z1), Vector3(x1, y0, z1), Vector3(x0, y0, z0), Vector2(0, 0), Vector2(u1, 0), Vector2(u1, v1), Vector2(0, v1), n, col)
	func walls(k: String, c: Vector2, w: float, d: float, y0: float, y1: float, col := Color.WHITE) -> void:
		var x0 := c.x - w / 2
		var x1 := c.x + w / 2
		var z0 := c.y - d / 2
		var z1 := c.y + d / 2
		wall(k, x0, z1, x1, z1, y0, y1, Vector3.BACK, col)
		wall(k, x1, z0, x0, z0, y0, y1, Vector3.FORWARD, col)
		wall(k, x1, z1, x1, z0, y0, y1, Vector3.RIGHT, col)
		wall(k, x0, z0, x0, z1, y0, y1, Vector3.LEFT, col)
	func top(k: String, c: Vector2, w: float, d: float, y: float, col := Color.WHITE, scale := ST) -> void:
		var x0 := c.x - w / 2
		var x1 := c.x + w / 2
		var z0 := c.y - d / 2
		var z1 := c.y + d / 2
		quad(k, Vector3(x0, y, z0), Vector3(x1, y, z0), Vector3(x1, y, z1), Vector3(x0, y, z1), Vector2(x0, z0) / scale, Vector2(x1, z0) / scale, Vector2(x1, z1) / scale, Vector2(x0, z1) / scale, Vector3.UP, col)
	func box(k: String, c: Vector2, w: float, d: float, y0: float, y1: float, col := Color.WHITE, kt := "") -> void:
		walls(k, c, w, d, y0, y1, col)
		top(k if kt == "" else kt, c, w, d, y1, col)
	## A sloped roof from the w x d base at y up to an inset ring at y + h (a mansard, or a hip roof when inset meets).
	func mansard(k: String, c: Vector2, w: float, d: float, y: float, h: float, ix: float, iz: float, col := Color.WHITE, flat := true) -> void:
		var a := [Vector3(c.x - w / 2, y, c.y + d / 2), Vector3(c.x + w / 2, y, c.y + d / 2), Vector3(c.x + w / 2, y, c.y - d / 2), Vector3(c.x - w / 2, y, c.y - d / 2)]
		var b := [Vector3(c.x - w / 2 + ix, y + h, c.y + d / 2 - iz), Vector3(c.x + w / 2 - ix, y + h, c.y + d / 2 - iz), Vector3(c.x + w / 2 - ix, y + h, c.y - d / 2 + iz), Vector3(c.x - w / 2 + ix, y + h, c.y - d / 2 + iz)]
		var ns := [Vector3(0, iz, h).normalized(), Vector3(h, ix, 0).normalized(), Vector3(0, iz, -h).normalized(), Vector3(-h, ix, 0).normalized()]
		var slope := Vector2(maxf(ix, iz), h).length() / ST
		for i in 4:
			var j := (i + 1) % 4
			var len_a: float = (a[j] - a[i]).length() / ST
			var len_b: float = (b[j] - b[i]).length() / ST
			var off := (len_a - len_b) / 2
			quad(k, b[i], b[j], a[j], a[i], Vector2(off, 0), Vector2(off + len_b, 0), Vector2(len_a, slope), Vector2(0, slope), ns[i], col)
		if flat and w - 2 * ix > 0.01 and d - 2 * iz > 0.01:
			top(k, c, w - 2 * ix, d - 2 * iz, y + h, col)
	## A pitched roof with its ridge along x; the gable ends take the wall material kw.
	func gable(k: String, kw: String, c: Vector2, w: float, d: float, y: float, h: float, col := Color.WHITE) -> void:
		var x0 := c.x - w / 2
		var x1 := c.x + w / 2
		var z0 := c.y - d / 2
		var z1 := c.y + d / 2
		var sl := Vector2(d / 2, h).length() / ST
		var u := w / ST
		quad(k, Vector3(x0, y + h, c.y), Vector3(x1, y + h, c.y), Vector3(x1, y, z1), Vector3(x0, y, z1), Vector2(0, 0), Vector2(u, 0), Vector2(u, sl), Vector2(0, sl), Vector3(0, d / 2, h).normalized(), col)
		quad(k, Vector3(x1, y + h, c.y), Vector3(x0, y + h, c.y), Vector3(x0, y, z0), Vector3(x1, y, z0), Vector2(0, 0), Vector2(u, 0), Vector2(u, sl), Vector2(0, sl), Vector3(0, d / 2, -h).normalized(), col)
		var hv := h / ST
		tri(kw, Vector3(x0, y, z0), Vector3(x0, y, z1), Vector3(x0, y + h, c.y), Vector2(0, hv), Vector2(d / ST, hv), Vector2(d / ST / 2, 0), Vector3.LEFT, col)
		tri(kw, Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x1, y + h, c.y), Vector2(0, hv), Vector2(d / ST, hv), Vector2(d / ST / 2, 0), Vector3.RIGHT, col)
	## A pitched roof with its ridge along z (gable end facing you).
	func gable_z(k: String, kw: String, c: Vector2, w: float, d: float, y: float, h: float, col := Color.WHITE) -> void:
		var x0 := c.x - w / 2
		var x1 := c.x + w / 2
		var z0 := c.y - d / 2
		var z1 := c.y + d / 2
		var sl := Vector2(w / 2, h).length() / ST
		var u := d / ST
		quad(k, Vector3(c.x, y + h, z1), Vector3(c.x, y + h, z0), Vector3(x1, y, z0), Vector3(x1, y, z1), Vector2(0, 0), Vector2(u, 0), Vector2(u, sl), Vector2(0, sl), Vector3(h, w / 2, 0).normalized(), col)
		quad(k, Vector3(c.x, y + h, z0), Vector3(c.x, y + h, z1), Vector3(x0, y, z1), Vector3(x0, y, z0), Vector2(0, 0), Vector2(u, 0), Vector2(u, sl), Vector2(0, sl), Vector3(-h, w / 2, 0).normalized(), col)
		var hv := h / ST
		tri(kw, Vector3(x0, y, z1), Vector3(x1, y, z1), Vector3(c.x, y + h, z1), Vector2(0, hv), Vector2(w / ST, hv), Vector2(w / ST / 2, 0), Vector3.BACK, col)
		tri(kw, Vector3(x1, y, z0), Vector3(x0, y, z0), Vector3(c.x, y + h, z0), Vector2(0, hv), Vector2(w / ST, hv), Vector2(w / ST / 2, 0), Vector3.FORWARD, col)
	func spire(k: String, c: Vector2, w: float, y: float, h: float, col := Color.WHITE) -> void:
		mansard(k, c, w, w, y, h, w / 2, w / 2, col, false)
	## A small glowing pane just in front of a wall facing n.
	func pane(k: String, p: Vector3, n: Vector3, sw: float, sh: float) -> void:
		var side := Vector3(-n.z, 0, n.x) * sw / 2
		var up := Vector3(0, sh / 2, 0)
		var q := p + n * 0.006
		quad(k, q - side + up, q + side + up, q + side - up, q - side - up, Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1), n)
	func finish(parent: Node3D, shadows := true) -> void:
		for k in st:
			var mi := MeshInstance3D.new()
			mi.mesh = st[k].commit()
			mi.material_override = mats[k]
			if not shadows:
				mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			parent.add_child(mi)


# ---------------------------------------------------------------- materials

func _tex_mat(file: String, rough := 0.95) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = Style.art(file)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	m.vertex_color_use_as_albedo = true
	m.roughness = rough
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	return m

func _flat(c: Color, e := 0.0, rough := 0.9) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.vertex_color_use_as_albedo = true
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	if e > 0.0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = e
	return m

func _make_mats() -> void:
	for k in ["facade-plaster", "facade-brick", "shopfront", "roof-slate", "stone-wall", "planks"]:
		mats[k] = _tex_mat("city/%s.png" % k)
	mats["water"] = _tex_mat("city/water.png", 0.2)
	mats["water"].metallic = 0.35
	mats["cobbles"] = _tex_mat("ui/floor-cobbles.png")
	mats["iron"] = _flat(Color("#17161a"), 0.0, 0.5)
	mats["wood"] = _flat(Color("#2b1e15"))
	mats["awning-a"] = _flat(Color("#6e2622"))
	mats["awning-b"] = _flat(Color("#9a8c70"))
	mats["win"] = _flat(Color("#ffb35a"), 1.6)
	win_night = _flat(Color("#ffb35a"), 0.0)
	mats["win_n"] = win_night
	mats["gas"] = _flat(Color("#ffd49a"), 2.2)
	for id in Style.PLACE_COL:
		mats["glow:" + id] = _flat(Style.PLACE_COL[id], 1.8)


# ---------------------------------------------------------------- the river

func river_z(x: float) -> float:
	for i in RIVER.size() - 1:
		var a: Vector2 = RIVER[i]
		var b: Vector2 = RIVER[i + 1]
		if x <= b.x:
			var t := clampf((x - a.x) / (b.x - a.x), 0.0, 1.0)
			return lerpf(a.y, b.y, smoothstep(0.0, 1.0, t))
	return RIVER[-1].y

func river_hw(x: float) -> float:
	# Wider where the islands sit.
	return 0.6 + 0.5 * _bump(x, -0.4, 1.9) + 0.4 * _bump(x, 3.25, 2.6)

func _bump(x: float, c: float, r: float) -> float:
	var t := absf(x - c) / r
	return 0.0 if t >= 1.0 else 0.5 + 0.5 * cos(t * PI)

func on_island(p: Vector2) -> bool:
	for il in ISLANDS:
		var q: Vector2 = (p - il[0]) / il[1]
		if q.length() <= 1.0:
			return true
	return false

func in_water(p: Vector2, margin := 0.0) -> bool:
	return absf(p.y - river_z(p.x)) < river_hw(p.x) + margin and not on_island(p)

func _build_river(b: Builder) -> void:
	var x := -FAR - 6.0
	var step := 0.25
	while x < FAR + 6.0:
		var za := river_z(x)
		var zb := river_z(x + step)
		var ha := river_hw(x)
		var hb := river_hw(x + step)
		var p := [Vector3(x, WATER_Y, za - ha), Vector3(x + step, WATER_Y, zb - hb), Vector3(x + step, WATER_Y, zb + hb), Vector3(x, WATER_Y, za + ha)]
		b.quad("water", p[0], p[1], p[2], p[3], Vector2(p[0].x, p[0].z) / 1.6, Vector2(p[1].x, p[1].z) / 1.6, Vector2(p[2].x, p[2].z) / 1.6, Vector2(p[3].x, p[3].z) / 1.6, Vector3.UP)
		# Stone quays along both banks: a low wall down to the water and a kerb on top.
		for s in [-1.0, 1.0]:
			var e0 := Vector3(x, 0.0, za + s * ha)
			var e1 := Vector3(x + step, 0.0, zb + s * hb)
			var n := Vector3(0, 0, -s)
			b.quad("stone-wall", e0 + Vector3(0, 0.05, 0), e1 + Vector3(0, 0.05, 0), e1 + Vector3(0, WATER_Y, 0), e0 + Vector3(0, WATER_Y, 0), Vector2(x / ST, 0), Vector2((x + step) / ST, 0), Vector2((x + step) / ST, 0.2), Vector2(x / ST, 0.2), n, Color(0.8, 0.8, 0.8))
			var k0 := e0 + Vector3(0, 0.05, s * 0.07)
			var k1 := e1 + Vector3(0, 0.05, s * 0.07)
			b.quad("stone-wall", e0 + Vector3(0, 0.05, 0), e1 + Vector3(0, 0.05, 0), k1, k0, Vector2(x / ST, 0), Vector2((x + step) / ST, 0), Vector2((x + step) / ST, 0.2), Vector2(x / ST, 0.2), Vector3.UP, Color(0.7, 0.7, 0.7))
		x += step
	# The islands: a cobbled top with a stone rim.
	for il in ISLANDS:
		var c: Vector2 = il[0]
		var r: Vector2 = il[1]
		var segs := 40
		for i in segs:
			var a0 := TAU * i / segs
			var a1 := TAU * (i + 1) / segs
			var p0 := c + Vector2(cos(a0), sin(a0)) * r
			var p1 := c + Vector2(cos(a1), sin(a1)) * r
			b.tri("cobbles", Vector3(c.x, ISLAND_Y, c.y), Vector3(p0.x, ISLAND_Y, p0.y), Vector3(p1.x, ISLAND_Y, p1.y), c / 4.5, p0 / 4.5, p1 / 4.5, Vector3.UP)
			var n := Vector3(cos((a0 + a1) / 2), 0, sin((a0 + a1) / 2))
			b.quad("stone-wall", Vector3(p0.x, 0.04, p0.y), Vector3(p1.x, 0.04, p1.y), Vector3(p1.x, WATER_Y, p1.y), Vector3(p0.x, WATER_Y, p0.y), Vector2(a0 * 3, 0), Vector2(a1 * 3, 0), Vector2(a1 * 3, 0.2), Vector2(a0 * 3, 0.2), n, Color(0.8, 0.8, 0.8))
			var q0 := p0 - (p0 - c).normalized() * 0.06
			var q1 := p1 - (p1 - c).normalized() * 0.06
			b.quad("stone-wall", Vector3(p0.x, 0.04, p0.y), Vector3(p1.x, 0.04, p1.y), Vector3(q1.x, 0.04, q1.y), Vector3(q0.x, 0.04, q0.y), Vector2(a0 * 3, 0), Vector2(a1 * 3, 0), Vector2(a1 * 3, 0.2), Vector2(a0 * 3, 0.2), Vector3.UP, Color(0.7, 0.7, 0.7))
	# Stone bridges with low parapets.
	for bx in BRIDGES:
		var cz := river_z(bx)
		var hw := river_hw(bx) + 0.2
		var c := Vector2(bx, cz)
		b.box("stone-wall", c, 0.46, hw * 2, WATER_Y, 0.06, Color(0.85, 0.85, 0.85))
		for s in [-1.0, 1.0]:
			b.box("stone-wall", c + Vector2(s * 0.21, 0), 0.04, hw * 2, 0.06, 0.12, Color(0.7, 0.7, 0.7))
		keep_out.append(Rect2(bx - 0.3, cz - hw, 0.6, hw * 2))


# ---------------------------------------------------------------- houses

## A Paris town house: a shop or plain ground floor, plaster or brick storeys, a cornice, a mansard, gable or flat roof,
## chimneys, and a few lit windows.
func house(b: Builder, c: Vector2, w: float, d: float, floors: int) -> void:
	var facade := "facade-plaster" if rng.randf() < 0.62 else "facade-brick"
	var t := rng.randf_range(0.62, 1.0)
	var col := Color(t, t * rng.randf_range(0.93, 1.0), t * rng.randf_range(0.88, 1.0))
	var shop := floors >= 2 and rng.randf() < 0.55
	var h := floors * ST
	if shop:
		b.walls("shopfront", c, w, d, 0.0, ST, col)
		b.walls(facade, c, w, d, ST, h, col)
	else:
		b.walls(facade, c, w, d, 0.0, h, col)
	b.box("stone-wall", c, w + 0.04, d + 0.04, h - 0.03, h, col * 0.8)
	var r := rng.randf()
	var roof_col := Color(rng.randf_range(0.6, 0.95), rng.randf_range(0.6, 0.9), rng.randf_range(0.65, 0.95))
	var rh := 0.0
	if r < 0.55:
		rh = rng.randf_range(0.2, 0.3)
		b.mansard("roof-slate", c, w, d, h, rh, 0.09, 0.09, roof_col)
		# Dormers on the street side.
		var n := int(round(w / ST))
		for k in n:
			if rng.randf() < 0.6:
				var x := c.x - w / 2 + (k + 0.5) * ST
				var dz := c.y + d / 2 - 0.07
				b.box(facade, Vector2(x, dz), 0.09, 0.06, h, h + 0.13, col * 0.9, "roof-slate")
				if rng.randf() < 0.3:
					b.pane("win_n", Vector3(x, h + 0.065, dz + 0.03), Vector3.BACK, 0.05, 0.07)
	elif r < 0.85:
		rh = rng.randf_range(0.2, 0.32)
		if w >= d:
			b.gable("roof-slate", facade, c, w, d, h, rh, roof_col)
		else:
			b.gable_z("roof-slate", facade, c, w, d, h, rh, roof_col)
	else:
		b.top("roof-slate", c, w, d, h, roof_col * 0.6)
		b.walls("stone-wall", c, w, d, h, h + 0.06, col * 0.8)
	for k in rng.randi_range(1, 3):
		var cx := c.x + rng.randf_range(-w / 2 + 0.06, w / 2 - 0.06)
		var cz := c.y + rng.randf_range(-d / 2 + 0.06, d / 2 - 0.06) * 0.6
		b.box("facade-brick", Vector2(cx, cz), 0.07, 0.07, h, h + rh + rng.randf_range(0.04, 0.16), col * 0.8)
	# Lit windows, centred on the window of each wall tile.
	var f0 := 1 if shop else 0
	for f in range(f0, floors):
		var y := f * ST + ST * 0.52
		for side in 4:
			var along := w if side < 2 else d
			var n := int(round(along / ST))
			for k in n:
				var roll := rng.randf()
				if roll > 0.3:
					continue
				var u := -along / 2 + (k + 0.5) * ST
				var p: Vector3
				var nv: Vector3
				match side:
					0: p = Vector3(c.x + u, y, c.y + d / 2); nv = Vector3.BACK
					1: p = Vector3(c.x + u, y, c.y - d / 2); nv = Vector3.FORWARD
					2: p = Vector3(c.x + w / 2, y, c.y + u); nv = Vector3.RIGHT
					_: p = Vector3(c.x - w / 2, y, c.y + u); nv = Vector3.LEFT
				b.pane("win" if roll < 0.1 else "win_n", p, nv, ST * 0.26, ST * 0.42)

func _lot_free(r: Rect2, water_margin: float) -> bool:
	for k in keep_out:
		if k.intersects(r):
			return false
	var c := r.get_center()
	for cc in clear_circles:
		var q := Vector2(clampf(cc[0].x, r.position.x, r.end.x), clampf(cc[0].y, r.position.y, r.end.y))
		if q.distance_to(cc[0]) < cc[1]:
			return false
	for p in [r.position, r.end, Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), c]:
		if absf(p.y - river_z(p.x)) < river_hw(p.x) + water_margin:
			return false
	for sx in STREETS_X:
		if absf(c.x - sx) < r.size.x / 2 + 0.22 and r.position.y < PLAY.end.y and r.end.y > PLAY.position.y:
			return false
	return true

func _fill_play_area(b: Builder) -> void:
	var z := PLAY.position.y + 0.9
	while z < PLAY.end.y - 0.5:
		var x := PLAY.position.x + 0.45
		while x < PLAY.end.x - 0.4:
			var w := ST * rng.randi_range(1, 3)
			var d := ST * 2
			var c := Vector2(x + w / 2, z)
			var r := Rect2(c - Vector2(w, d) / 2, Vector2(w, d)).grow(0.02)
			if PLAY.grow(-0.3).encloses(r) and _lot_free(r, 0.3):
				house(b, c, w, d, 1 if rng.randf() < 0.45 else 2)
				keep_out.append(r)
			x += w + (0.05 if rng.randf() < 0.8 else 0.3)
		z += ST * 2 + 0.16

func _build_outskirts(b: Builder) -> void:
	var inner := PLAY.grow(0.7)
	var z := -FAR
	while z < FAR:
		var x := -FAR
		var row_d := ST * rng.randi_range(2, 4)
		while x < FAR:
			var w := ST * rng.randi_range(2, 4)
			var c := Vector2(x + w / 2, z + row_d / 2)
			x += w + (0.42 if rng.randf() < 0.12 else 0.03)
			if c.length() > FAR:
				continue
			var r := Rect2(c - Vector2(w, row_d) / 2, Vector2(w, row_d))
			if r.intersects(inner) or r.intersects(BOARD_ZONE.grow(0.4)):
				continue
			if absf(c.y - river_z(c.x)) < river_hw(c.x) + 0.6 + row_d / 2:
				continue
			var dx := maxf(maxf(inner.position.x - c.x, c.x - inner.end.x), 0.0)
			var dz := maxf(maxf(inner.position.y - c.y, c.y - inner.end.y), 0.0)
			var dist := Vector2(dx, dz).length()
			var floors := clampi(2 + int(dist / 3.5) + rng.randi_range(-1, 1), 2, 7)
			if c.y > BOARD_ZONE.end.y and c.y < 17.0:
				floors = mini(floors, 2)   # in front of you: keep low so nothing hides the table
			house(b, c, w, row_d, floors)
		# Every few rows a wider street.
		z += row_d + (0.5 if rng.randf() < 0.3 else 0.12)
	# A few spires on the skyline.
	for k in 7:
		var a := rng.randf_range(PI * 1.1, PI * 1.9)
		var dd := rng.randf_range(16.0, 28.0)
		var c := Vector2(cos(a), sin(a)) * dd
		var hh := rng.randf_range(2.6, 4.2)
		b.box("stone-wall", c, 0.6, 0.6, 0.0, hh, Color(0.7, 0.7, 0.75))
		b.spire("roof-slate", c, 0.66, hh, rng.randf_range(1.2, 2.0))


# ---------------------------------------------------------------- the edge of play

func _build_railing(root: Node3D, b: Builder) -> void:
	var r := PLAY
	var corners := [r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]
	for i in 4:
		var a: Vector2 = corners[i]
		var e: Vector2 = corners[(i + 1) % 4]
		var len := a.distance_to(e)
		var n := int(len / 0.6)
		for k in n + 1:
			var p := a.lerp(e, float(k) / n)
			b.box("iron", p, 0.04, 0.04, 0.0, 0.2, Color.WHITE)
		var mid := (a + e) / 2
		var horiz := absf(a.y - e.y) < 0.01
		b.box("iron", mid, len if horiz else 0.025, 0.025 if horiz else len, 0.16, 0.18, Color.WHITE)
		b.box("iron", mid, len if horiz else 0.02, 0.02 if horiz else len, 0.07, 0.085, Color.WHITE)
		# A band of worn flagstones just inside.
		var inset := (r.get_center() - mid).normalized() * 0.0
		b.top("stone-wall", mid + inset + (Vector2(0, 0.17) if (horiz and a.y < 0) else Vector2(0, -0.17) if horiz else (Vector2(0.17, 0) if a.x < 0 else Vector2(-0.17, 0))), len if horiz else 0.3, 0.3 if horiz else len, FLOOR_Y + 0.004, Color(0.55, 0.55, 0.55), ST * 1.2)
	for p in corners + [Vector2(0, r.position.y), Vector2(0, r.end.y), Vector2(r.position.x, 0), Vector2(r.end.x, 0)]:
		gas_lamp(root, b, p)

func gas_lamp(root: Node3D, b: Builder, p: Vector2) -> void:
	b.box("iron", p, 0.05, 0.05, 0.0, 0.62, Color.WHITE)
	b.box("gas", p, 0.1, 0.1, 0.62, 0.74, Color.WHITE)
	b.spire("iron", p, 0.14, 0.74, 0.07, Color.WHITE)
	var l := OmniLight3D.new()
	l.light_color = Color("#ffc27a")
	l.light_energy = 0.35
	l.omni_range = 2.6
	l.position = Vector3(p.x, 0.7, p.y)
	root.add_child(l)
	gas_lamps.append(l)


# ---------------------------------------------------------------- landmarks

## Find a spot for a landmark next to its place: the nearest free one, behind the place by preference (it then never hides
## the rings), never on cards, water, a neighbour's clearing or another landmark.
func place_landmark(id: String, pos: Vector3, radius: float) -> Vector2:
	var s: Vector2 = LM_SIZE[id] * LM_SCALE
	var p := Vector2(pos.x, pos.z)
	var best := Vector2.INF
	var best_cost := INF
	for iz in range(-30, 21):
		for ix in range(-30, 31):
			var off := Vector2(ix, iz) * 0.1
			# Clear of the place's own disc, with a little gap.
			var near := Vector2(clampf(0.0, off.x - s.x / 2, off.x + s.x / 2), clampf(0.0, off.y - s.y / 2, off.y + s.y / 2))
			if near.length() < radius + 0.12:
				continue
			var cost := off.length() + maxf(off.y + s.y / 2, 0.0) * 1.2
			if _crosses_water(p, p + off):
				cost += 4.0   # stay on the place's own bank
			if cost >= best_cost:
				continue
			if _landmark_fits(id, Rect2(p + off - s / 2, s)):
				best = off
				best_cost = cost
	if best == Vector2.INF:
		push_warning("no room for landmark " + id)
		return Vector2(0, -(radius + s.y / 2 + 0.1))
	keep_out.append(Rect2(p + best - s / 2, s))
	return best

func _crosses_water(a: Vector2, b: Vector2) -> bool:
	for k in range(1, 10):
		if in_water(a.lerp(b, k / 10.0)):
			return true
	return false

func _landmark_fits(id: String, r: Rect2) -> bool:
	if not PLAY.grow(-0.25).encloses(r):
		return false
	for k in keep_out:
		if k.intersects(r):
			return false
	for cc in clear_circles:
		if cc[2] == id:
			continue
		var q := Vector2(clampf(cc[0].x, r.position.x, r.end.x), clampf(cc[0].y, r.position.y, r.end.y))
		if q.distance_to(cc[0]) < cc[1]:
			return false
	var c := r.get_center()
	for q in [r.position, r.end, Vector2(r.position.x, r.end.y), Vector2(r.end.x, r.position.y), c, Vector2(c.x, r.position.y), Vector2(c.x, r.end.y)]:
		if in_water(q, 0.06):
			return false
	return true

func landmark(id: String, root: Node3D) -> Node3D:
	var n := Node3D.new()
	root.add_child(n)
	var b := Builder.new(mats)
	var col: Color = Style.PLACE_COL.get(id, Color.WHITE)
	var gk := "glow:" + id
	var w: Vector2 = LM_SIZE[id]
	match id:
		"cemetery":
			for s in [-1.0, 1.0]:
				b.box("stone-wall", Vector2(s * w.x / 2, 0), 0.06, w.y, 0.0, 0.16)
			b.box("stone-wall", Vector2(0, -w.y / 2), w.x, 0.06, 0.0, 0.16)
			b.box("stone-wall", Vector2(-0.45, w.y / 2), 0.6, 0.06, 0.0, 0.16)
			b.box("stone-wall", Vector2(0.45, w.y / 2), 0.6, 0.06, 0.0, 0.16)
			b.box("iron", Vector2(0, w.y / 2), 0.3, 0.02, 0.0, 0.2)
			b.box("stone-wall", Vector2(0.38, -0.12), 0.4, 0.5, 0.0, 0.36, Color(0.85, 0.85, 0.85))
			b.gable_z("roof-slate", "stone-wall", Vector2(0.38, -0.12), 0.44, 0.54, 0.36, 0.2)
			b.box("stone-wall", Vector2(0.38, 0.12), 0.1, 0.1, 0.36, 0.62)
			b.spire("roof-slate", Vector2(0.38, 0.12), 0.12, 0.62, 0.14)
			b.pane(gk, Vector3(0.38, 0.2, 0.135), Vector3.BACK, 0.08, 0.12)
			for k in 7:
				var hp := Vector2(rng.randf_range(-0.65, 0.1), rng.randf_range(-0.3, 0.3))
				b.box("stone-wall", hp, 0.07, 0.03, 0.0, rng.randf_range(0.07, 0.13), Color(0.75, 0.75, 0.75))
			var tree := Vector2(-0.55, -0.25)
			b.box("wood", tree, 0.05, 0.05, 0.0, 0.45)
			for k in 4:
				var a := k * 1.7
				b.box("wood", tree + Vector2(cos(a), sin(a)) * 0.08, 0.14 if k % 2 == 0 else 0.03, 0.03 if k % 2 == 0 else 0.14, 0.3 + k * 0.04, 0.33 + k * 0.04)
		"square":
			b.top("stone-wall", Vector2.ZERO, w.x, w.y, ISLAND_Y + 0.012, Color(0.6, 0.6, 0.6), ST * 1.2)
			var f := MeshInstance3D.new()
			var cm := CylinderMesh.new()
			cm.top_radius = 0.26
			cm.bottom_radius = 0.28
			cm.height = 0.09
			f.mesh = cm
			f.material_override = mats["stone-wall"]
			f.position = Vector3(-0.2, 0.045, 0.05)
			n.add_child(f)
			var wd := MeshInstance3D.new()
			var wm := CylinderMesh.new()
			wm.top_radius = 0.22
			wm.bottom_radius = 0.22
			wm.height = 0.01
			wd.mesh = wm
			wd.material_override = mats["water"]
			wd.position = Vector3(-0.2, 0.085, 0.05)
			n.add_child(wd)
			b.box("stone-wall", Vector2(-0.2, 0.05), 0.06, 0.06, 0.09, 0.32)
			b.box(gk, Vector2(-0.2, 0.05), 0.09, 0.09, 0.32, 0.36)
			# The scaffold.
			b.box("planks", Vector2(0.3, -0.12), 0.36, 0.34, 0.0, 0.14)
			b.box("wood", Vector2(0.18, -0.2), 0.03, 0.03, 0.14, 0.5)
			b.box("wood", Vector2(0.26, -0.2), 0.2, 0.03, 0.48, 0.51)
			b.box("iron", Vector2(0.34, -0.2), 0.005, 0.005, 0.36, 0.48)
		"slaughter":
			b.walls("planks", Vector2.ZERO, w.x, w.y * 0.8, 0.0, 0.32, Color(0.85, 0.75, 0.7))
			b.gable("roof-slate", "planks", Vector2.ZERO, w.x + 0.06, w.y * 0.8 + 0.08, 0.32, 0.24, Color(0.75, 0.6, 0.55))
			b.box("facade-brick", Vector2(0.55, -0.15), 0.12, 0.12, 0.3, 0.85)
			for k in 3:
				b.pane(gk, Vector3(-0.5 + k * 0.5, 0.17, w.y * 0.4), Vector3.BACK, 0.16, 0.1)
			for k in 6:
				b.box("wood", Vector2(-w.x / 2 + k * w.x / 5, w.y / 2), 0.025, 0.025, 0.0, 0.14)
		"church":
			var nave := Vector2(0, -0.12)
			b.box("stone-wall", nave, 0.58, 1.0, 0.0, 0.5, Color(0.8, 0.78, 0.72))
			b.gable_z("roof-slate", "stone-wall", nave, 0.62, 1.04, 0.5, 0.3)
			var tw := Vector2(0, 0.46)
			b.box("stone-wall", tw, 0.34, 0.3, 0.0, 0.95, Color(0.85, 0.82, 0.75))
			b.box("stone-wall", tw, 0.38, 0.34, 0.95, 1.0)
			b.spire("roof-slate", tw, 0.34, 1.0, 0.55)
			b.pane(gk, Vector3(0, 0.62, 0.61), Vector3.BACK, 0.13, 0.13)
			b.pane(gk, Vector3(0, 0.15, 0.61), Vector3.BACK, 0.1, 0.2)
			for s in [-1.0, 1.0]:
				for k in 3:
					b.pane(gk, Vector3(s * 0.29, 0.28, -0.45 + k * 0.3), Vector3.RIGHT * s, 0.08, 0.18)
		"market":
			for px in [-0.6, 0.0, 0.6]:
				for pz in [-0.36, 0.36]:
					b.box("wood", Vector2(px, pz), 0.04, 0.04, 0.0, 0.32)
			b.mansard("roof-slate", Vector2.ZERO, w.x, w.y, 0.32, 0.26, 0.4, 0.3, Color(0.8, 0.75, 0.7))
			for k in 4:
				var sc := Vector2(-0.45 + k * 0.3, 0.05)
				b.box("planks", sc, 0.2, 0.14, 0.0, 0.1)
				b.box("awning-a" if k % 2 == 0 else "awning-b", sc + Vector2(0, 0.08), 0.22, 0.04, 0.2, 0.22)
			b.pane(gk, Vector3(0, 0.26, w.y / 2), Vector3.BACK, 0.5, 0.05)
		"first":
			b.box("stone-wall", Vector2.ZERO, 0.3, 0.3, 0.0, 0.12)
			var col_m := MeshInstance3D.new()
			var cy := CylinderMesh.new()
			cy.top_radius = 0.06
			cy.bottom_radius = 0.075
			cy.height = 0.7
			col_m.mesh = cy
			col_m.material_override = mats["stone-wall"]
			col_m.position = Vector3(0, 0.47, 0)
			n.add_child(col_m)
			b.box("iron", Vector2.ZERO, 0.2, 0.2, 0.82, 1.02)
			for nv in [Vector3.BACK, Vector3.FORWARD, Vector3.LEFT, Vector3.RIGHT]:
				b.pane(gk, Vector3(0, 0.92, 0) + nv * 0.1, nv, 0.14, 0.14)
			b.spire("roof-slate", Vector2.ZERO, 0.24, 1.02, 0.2)
		"morgue":
			b.box("stone-wall", Vector2.ZERO, w.x, w.y, 0.0, 0.38, Color(0.75, 0.8, 0.8))
			b.box("stone-wall", Vector2.ZERO, w.x + 0.04, w.y + 0.04, 0.36, 0.4, Color(0.6, 0.65, 0.65))
			var dome := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.2
			sm.height = 0.2
			sm.is_hemisphere = true
			dome.mesh = sm
			dome.material_override = mats["roof-slate"]
			dome.position = Vector3(0, 0.4, 0)
			n.add_child(dome)
			b.pane(gk, Vector3(0, 0.12, w.y / 2), Vector3.BACK, 0.12, 0.22)
			b.pane(gk, Vector3(-0.24, 0.22, w.y / 2), Vector3.BACK, 0.07, 0.1)
			b.pane(gk, Vector3(0.24, 0.22, w.y / 2), Vector3.BACK, 0.07, 0.1)
		"hospital":
			b.walls("facade-plaster", Vector2.ZERO, w.x, w.y, 0.0, ST * 2, Color(0.95, 0.95, 0.92))
			b.mansard("roof-slate", Vector2.ZERO, w.x, w.y, ST * 2, 0.24, 0.1, 0.1)
			var pav := Vector2(0, 0.06)
			b.walls("stone-wall", pav, 0.5, w.y + 0.12, 0.0, ST * 2 + 0.12)
			b.gable_z("roof-slate", "stone-wall", pav, 0.56, w.y + 0.16, ST * 2 + 0.12, 0.2)
			for f in 2:
				for k in 5:
					if k == 2:
						continue
					b.pane(gk, Vector3(-w.x / 2 + (k + 0.5) * ST, f * ST + ST * 0.52, w.y / 2), Vector3.BACK, ST * 0.26, ST * 0.42)
			b.pane(gk, Vector3(0, 0.14, w.y / 2 + 0.06), Vector3.BACK, 0.14, 0.24)
		"academy":
			var body := Vector2(0, -0.1)
			b.box("stone-wall", body, w.x, 0.7, 0.0, ST * 2, Color(0.82, 0.82, 0.8))
			b.box("stone-wall", body, w.x + 0.04, 0.74, ST * 2, ST * 2 + 0.05)
			for k in 6:
				var cm := MeshInstance3D.new()
				var cyl := CylinderMesh.new()
				cyl.top_radius = 0.03
				cyl.bottom_radius = 0.035
				cyl.height = ST * 2
				cm.mesh = cyl
				cm.material_override = mats["stone-wall"]
				cm.position = Vector3(-0.4 + k * 0.16, ST, 0.36)
				n.add_child(cm)
			b.box("stone-wall", Vector2(0, 0.33), 0.92, 0.12, ST * 2, ST * 2 + 0.05)
			b.gable("roof-slate", "stone-wall", Vector2(0, 0.33), 0.94, 0.14, ST * 2 + 0.05, 0.14)
			var drum := MeshInstance3D.new()
			var dc := CylinderMesh.new()
			dc.top_radius = 0.24
			dc.bottom_radius = 0.24
			dc.height = 0.16
			drum.mesh = dc
			drum.material_override = mats["stone-wall"]
			drum.position = Vector3(0, ST * 2 + 0.13, -0.1)
			n.add_child(drum)
			var dome := MeshInstance3D.new()
			var sm := SphereMesh.new()
			sm.radius = 0.25
			sm.height = 0.3
			sm.is_hemisphere = true
			dome.mesh = sm
			dome.material_override = mats["roof-slate"]
			dome.position = Vector3(0, ST * 2 + 0.21, -0.1)
			n.add_child(dome)
			b.box(gk, Vector2(0, -0.1), 0.05, 0.05, ST * 2 + 0.5, ST * 2 + 0.58)
			for k in 5:
				b.pane(gk, Vector3(-0.32 + k * 0.16, ST * 0.6, 0.251), Vector3.BACK, 0.06, 0.16)
		"docks":
			b.top("planks", Vector2.ZERO, w.x, w.y, ISLAND_Y + 0.015, Color(0.8, 0.8, 0.8), ST)
			b.box("planks", Vector2(-0.35, -0.12), 0.56, 0.4, 0.0, 0.3, Color(0.75, 0.7, 0.65))
			b.gable("roof-slate", "planks", Vector2(-0.35, -0.12), 0.6, 0.44, 0.3, 0.16)
			b.pane(gk, Vector3(-0.35, 0.12, 0.081), Vector3.BACK, 0.14, 0.16)
			# The crane: a mast, a jib, a hanging hook.
			b.box("wood", Vector2(0.35, -0.1), 0.06, 0.06, 0.0, 0.8)
			b.box("wood", Vector2(0.45, -0.1), 0.4, 0.04, 0.76, 0.8)
			b.box("iron", Vector2(0.62, -0.1), 0.006, 0.006, 0.45, 0.76)
			b.box("iron", Vector2(0.62, -0.1), 0.05, 0.05, 0.42, 0.46)
			for k in 4:
				var cp := Vector2(0.15 + (k % 2) * 0.13, 0.2 + (k / 2) * 0.12)
				b.box("planks", cp, 0.1, 0.1, 0.0, 0.1, Color(0.7, 0.6, 0.5))
		"alley":
			for s in [-1.0, 1.0]:
				var hc := Vector2(s * 0.27, 0)
				var hn := Node3D.new()
				hn.rotation_degrees.z = -s * 3.0
				n.add_child(hn)
				var hb := Builder.new(mats)
				hb.walls("facade-brick" if s < 0 else "facade-plaster", hc, ST, w.y, 0.0, ST * 3, Color(0.7, 0.68, 0.72))
				hb.gable_z("roof-slate", "facade-brick", hc, ST + 0.04, w.y + 0.04, ST * 3, 0.22)
				hb.pane(gk, Vector3(hc.x, ST * 1.52, w.y / 2), Vector3.BACK, ST * 0.26, ST * 0.42)
				hb.finish(hn)
			b.box("iron", Vector2(0, 0.15), 0.03, 0.03, 0.0, 0.5)
			b.box(gk, Vector2(0, 0.15), 0.07, 0.07, 0.5, 0.58)
		"odeon":
			b.box("facade-plaster", Vector2(0, -0.1), w.x, 0.6, 0.0, ST * 2, Color(0.9, 0.85, 0.8))
			b.mansard("roof-slate", Vector2(0, -0.1), w.x, 0.6, ST * 2, 0.2, 0.12, 0.12)
			for k in 8:
				var cm := MeshInstance3D.new()
				var cyl := CylinderMesh.new()
				cyl.top_radius = 0.03
				cyl.bottom_radius = 0.035
				cyl.height = ST * 2
				cm.mesh = cyl
				cm.material_override = mats["stone-wall"]
				cm.position = Vector3(-0.56 + k * 0.16, ST, 0.32)
				n.add_child(cm)
			b.box("stone-wall", Vector2(0, 0.3), 1.3, 0.14, ST * 2, ST * 2 + 0.06)
			for k in 4:
				b.pane(gk, Vector3(-0.42 + k * 0.28, 0.16, 0.201), Vector3.BACK, 0.12, 0.22)
	b.finish(n)
	return n


# ---------------------------------------------------------------- build

## Builds the whole city. `places` is board.gd's place table, `rows` its card rows, `homes` the meeple home rows.
func build(root: Node3D, places: Dictionary, rows: Dictionary) -> void:
	rng.seed = 1819
	_make_mats()
	# What must stay open: each place's plaza, the card rows, the home rows and the rival lab mats.
	for id in places:
		if id == "lab":
			continue
		var pl: Dictionary = places[id]
		var p: Vector3 = pl.root.position
		clear_circles.append([Vector2(p.x, p.z), pl.radius + 0.35, id])
		keep_out.append(Rect2(p.x - pl.radius - 0.1, p.z - pl.radius - 0.1, pl.radius * 2 + 0.2, pl.radius * 2 + 0.2))
	for row in rows.values():
		var r := Rect2(Vector2(row.slots[0].x, row.slots[0].z), Vector2.ZERO)
		for s in row.slots:
			r = r.expand(Vector2(s.x, s.z))
		keep_out.append(r.grow_individual(0.32, 0.42, 0.32, 0.42))
	keep_out.append(Rect2(PLAY.position.x, -5.6, PLAY.size.x, 1.05))  # rival home rows and lab mats
	keep_out.append(Rect2(PLAY.position.x, 4.6, PLAY.size.x, 0.7))    # your home row
	var b := Builder.new(mats)
	_build_river(b)
	# Landmarks first, so the houses fill around them.
	for id in LM_SIZE:
		if not places.has(id):
			continue
		var pl: Dictionary = places[id]
		var off := place_landmark(id, pl.root.position, pl.radius)
		var lm := landmark(id, pl.root)
		lm.position = Vector3(off.x, 0, off.y)
		lm.scale = Vector3.ONE * LM_SCALE
		if pl.has("lamp"):
			pl.lamp.position = Vector3(off.x, 0.8, off.y + LM_SIZE[id].y * LM_SCALE / 2 + 0.2)
	_fill_play_area(b)
	_build_railing(root, b)
	_build_outskirts(b)
	b.finish(root)
