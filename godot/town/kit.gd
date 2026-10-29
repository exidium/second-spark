class_name Kit
extends RefCounted
## A small mesh kit for the town: walls, roofs, towers and glowing panes, all written into one SurfaceTool per material.
## Units are metres. `xf` places whatever is drawn next (a house is drawn in its own frame, +z facing its street).

var st := {}
var mats := {}
var xf := Transform3D.IDENTITY
var uv_off := Vector2.ZERO           # shifts every texture, so neighbouring houses never line up
var soot := 0.0                       # how much darker walls get at the ground


func _init(m: Dictionary) -> void:
	mats = m


func _s(k: String) -> SurfaceTool:
	if not st.has(k):
		var s := SurfaceTool.new()
		s.begin(Mesh.PRIMITIVE_TRIANGLES)
		st[k] = s
	return st[k]


func tri(k: String, a: Vector3, b: Vector3, c: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, col := Color.WHITE) -> void:
	tri_c(k, a, b, c, ua, ub, uc, col, col, col)


## A triangle with a colour per corner.
func tri_c(k: String, a: Vector3, b: Vector3, c: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, ca: Color, cb: Color, cc: Color) -> void:
	var n := (b - a).cross(c - a)
	if n.length_squared() < 1e-12:
		return
	n = (xf.basis * n).normalized()
	# Nothing in the town faces the ground: a level face always looks up.
	if n.y < -0.7:
		n = -n
		var t := b
		b = c
		c = t
		var tu := ub
		ub = uc
		uc = tu
		var tc := cb
		cb = cc
		cc = tc
	var s := _s(k)
	# Godot's front faces wind clockwise seen from their normal side.
	for p in [[a, ua, ca], [c, uc, cc], [b, ub, cb]]:
		s.set_color(p[2])
		s.set_normal(n)
		s.set_uv((p[1] as Vector2) + uv_off)
		s.add_vertex(xf * (p[0] as Vector3))


func quad(k: String, a: Vector3, b: Vector3, c: Vector3, d: Vector3, ua: Vector2, ub: Vector2, uc: Vector2, ud: Vector2, col := Color.WHITE) -> void:
	tri(k, a, b, c, ua, ub, uc, col)
	tri(k, a, c, d, ua, uc, ud, col)


## A vertical wall from p0 to p1 (x, z), tiled tw x th metres per texture tile, tiles hung from the top.
func wall(k: String, p0: Vector2, p1: Vector2, y0: float, y1: float, tw: float, th: float, col := Color.WHITE) -> void:
	var u1 := p0.distance_to(p1) / tw
	var v1 := (y1 - y0) / th
	var low := col * (1.0 - soot * clampf(1.0 - y0 / 4.0, 0.0, 1.0))
	low.a = 1.0
	tri_c(k, Vector3(p0.x, y0, p0.y), Vector3(p1.x, y0, p1.y), Vector3(p1.x, y1, p1.y), Vector2(0, v1), Vector2(u1, v1), Vector2(u1, 0), low, low, col)
	tri_c(k, Vector3(p0.x, y0, p0.y), Vector3(p1.x, y1, p1.y), Vector3(p0.x, y1, p0.y), Vector2(0, v1), Vector2(u1, 0), Vector2(0, 0), low, col, col)


func walls(k: String, c: Vector2, w: float, d: float, y0: float, y1: float, tw: float, th: float, col := Color.WHITE) -> void:
	var a := Vector2(c.x - w / 2, c.y + d / 2)
	var b := Vector2(c.x + w / 2, c.y + d / 2)
	var e := Vector2(c.x + w / 2, c.y - d / 2)
	var f := Vector2(c.x - w / 2, c.y - d / 2)
	wall(k, a, b, y0, y1, tw, th, col)
	wall(k, b, e, y0, y1, tw, th, col)
	wall(k, e, f, y0, y1, tw, th, col)
	wall(k, f, a, y0, y1, tw, th, col)


func flat(k: String, c: Vector2, w: float, d: float, y: float, ts: float, col := Color.WHITE) -> void:
	var x0 := c.x - w / 2
	var x1 := c.x + w / 2
	var z0 := c.y - d / 2
	var z1 := c.y + d / 2
	quad(k, Vector3(x0, y, z1), Vector3(x1, y, z1), Vector3(x1, y, z0), Vector3(x0, y, z0), Vector2(x0, z1) / ts, Vector2(x1, z1) / ts, Vector2(x1, z0) / ts, Vector2(x0, z0) / ts, col)


func box(k: String, c: Vector2, w: float, d: float, y0: float, y1: float, tw: float, th: float, col := Color.WHITE, ktop := "") -> void:
	walls(k, c, w, d, y0, y1, tw, th, col)
	flat(k if ktop == "" else ktop, c, w, d, y1, tw, col)


## A pitched roof, ridge along x, eaves overhanging by oh; the gable ends take the wall material kw.
func gable(kr: String, kw: String, c: Vector2, w: float, d: float, y: float, h: float, oh: float, rt: float, tw: float, th: float, col_r := Color.WHITE, col_w := Color.WHITE) -> void:
	var slope := h / (d / 2)
	var ye := y - oh * slope
	var x0 := c.x - w / 2 - oh * 0.6
	var x1 := c.x + w / 2 + oh * 0.6
	var sl := Vector2(d / 2 + oh, h + oh * slope).length() / rt
	var u := (x1 - x0) / rt
	var top := Vector3(0, y + h, c.y)
	quad(kr, Vector3(x0, ye, c.y + d / 2 + oh), Vector3(x1, ye, c.y + d / 2 + oh), Vector3(x1, y + h, c.y), Vector3(x0, y + h, c.y), Vector2(0, sl), Vector2(u, sl), Vector2(u, 0), Vector2(0, 0), col_r)
	quad(kr, Vector3(x1, ye, c.y - d / 2 - oh), Vector3(x0, ye, c.y - d / 2 - oh), Vector3(x0, y + h, c.y), Vector3(x1, y + h, c.y), Vector2(0, sl), Vector2(u, sl), Vector2(u, 0), Vector2(0, 0), col_r)
	var hv := h / th
	for s: float in [-1.0, 1.0]:
		var x := c.x + s * w / 2
		if s < 0:
			tri(kw, Vector3(x, y, c.y - d / 2), Vector3(x, y, c.y + d / 2), Vector3(x, top.y, c.y), Vector2(0, hv), Vector2(d / tw, hv), Vector2(d / tw / 2, 0), col_w)
		else:
			tri(kw, Vector3(x, y, c.y + d / 2), Vector3(x, y, c.y - d / 2), Vector3(x, top.y, c.y), Vector2(0, hv), Vector2(d / tw, hv), Vector2(d / tw / 2, 0), col_w)


## A hipped roof over w x d (ridge along the longer side), eaves overhanging by oh.
func hip(kr: String, c: Vector2, w: float, d: float, y: float, h: float, oh: float, rt: float, col := Color.WHITE) -> void:
	var W := w + 2 * oh
	var D := d + 2 * oh
	var ye := y - oh * h / (minf(w, d) / 2)
	var hh := h + (y - ye)
	var r := absf(W - D) / 2
	var a := [Vector3(c.x - W / 2, ye, c.y + D / 2), Vector3(c.x + W / 2, ye, c.y + D / 2), Vector3(c.x + W / 2, ye, c.y - D / 2), Vector3(c.x - W / 2, ye, c.y - D / 2)]
	var r0: Vector3
	var r1: Vector3
	if W >= D:
		r0 = Vector3(c.x - r, ye + hh, c.y)
		r1 = Vector3(c.x + r, ye + hh, c.y)
		quad(kr, a[0], a[1], r1, r0, Vector2(0, 1) * D / 2 / rt, Vector2(W / rt, D / 2 / rt), Vector2((W / 2 + r) / rt, 0), Vector2((W / 2 - r) / rt, 0), col)
		quad(kr, a[2], a[3], r0, r1, Vector2(0, D / 2 / rt), Vector2(W / rt, D / 2 / rt), Vector2((W / 2 + r) / rt, 0), Vector2((W / 2 - r) / rt, 0), col)
		tri(kr, a[1], a[2], r1, Vector2(0, D / 2 / rt), Vector2(D / rt, D / 2 / rt), Vector2(D / 2 / rt, 0), col)
		tri(kr, a[3], a[0], r0, Vector2(0, D / 2 / rt), Vector2(D / rt, D / 2 / rt), Vector2(D / 2 / rt, 0), col)
	else:
		r0 = Vector3(c.x, ye + hh, c.y + r)
		r1 = Vector3(c.x, ye + hh, c.y - r)
		quad(kr, a[1], a[2], r1, r0, Vector2(0, W / 2 / rt), Vector2(D / rt, W / 2 / rt), Vector2((D / 2 + r) / rt, 0), Vector2((D / 2 - r) / rt, 0), col)
		quad(kr, a[3], a[0], r0, r1, Vector2(0, W / 2 / rt), Vector2(D / rt, W / 2 / rt), Vector2((D / 2 + r) / rt, 0), Vector2((D / 2 - r) / rt, 0), col)
		tri(kr, a[0], a[1], r0, Vector2(0, W / 2 / rt), Vector2(W / rt, W / 2 / rt), Vector2(W / 2 / rt, 0), col)
		tri(kr, a[2], a[3], r1, Vector2(0, W / 2 / rt), Vector2(W / rt, W / 2 / rt), Vector2(W / 2 / rt, 0), col)


## A spire or a tent roof: four faces to an apex.
func pyramid(kr: String, c: Vector2, w: float, d: float, y: float, h: float, rt: float, col := Color.WHITE) -> void:
	var a := [Vector3(c.x - w / 2, y, c.y + d / 2), Vector3(c.x + w / 2, y, c.y + d / 2), Vector3(c.x + w / 2, y, c.y - d / 2), Vector3(c.x - w / 2, y, c.y - d / 2)]
	var t := Vector3(c.x, y + h, c.y)
	for i in 4:
		var e: float = (a[(i + 1) % 4] - a[i]).length() / rt
		var sl := Vector2(e * rt / 2, h).length() / rt
		tri(kr, a[i], a[(i + 1) % 4], t, Vector2(0, sl), Vector2(e, sl), Vector2(e / 2, 0), col)


func cylinder(k: String, c: Vector2, r: float, y0: float, y1: float, segs: int, tw: float, th: float, col := Color.WHITE) -> void:
	var circ := TAU * r
	for i in segs:
		var a0 := TAU * i / segs
		var a1 := TAU * (i + 1) / segs
		var p0 := c + Vector2(cos(a0), sin(a0)) * r
		var p1 := c + Vector2(cos(a1), sin(a1)) * r
		var u0 := circ * i / segs / tw
		var u1 := circ * (i + 1) / segs / tw
		quad(k, Vector3(p1.x, y0, p1.y), Vector3(p0.x, y0, p0.y), Vector3(p0.x, y1, p0.y), Vector3(p1.x, y1, p1.y), Vector2(u1, (y1 - y0) / th), Vector2(u0, (y1 - y0) / th), Vector2(u0, 0), Vector2(u1, 0), col)


func cone(k: String, c: Vector2, r: float, y: float, h: float, segs: int, rt: float, col := Color.WHITE) -> void:
	var sl := Vector2(r, h).length() / rt
	var t := Vector3(c.x, y + h, c.y)
	for i in segs:
		var a0 := TAU * i / segs
		var a1 := TAU * (i + 1) / segs
		var p0 := c + Vector2(cos(a0), sin(a0)) * r
		var p1 := c + Vector2(cos(a1), sin(a1)) * r
		tri(k, Vector3(p1.x, y, p1.y), Vector3(p0.x, y, p0.y), t, Vector2(0, sl), Vector2(TAU * r / segs / rt, sl), Vector2(TAU * r / segs / rt / 2, 0), col)


## A disc of segs sides (a fountain basin, a well).
func disc(k: String, c: Vector2, r: float, y: float, segs: int, ts: float, col := Color.WHITE) -> void:
	for i in segs:
		var a0 := TAU * i / segs
		var a1 := TAU * (i + 1) / segs
		var p0 := c + Vector2(cos(a0), sin(a0)) * r
		var p1 := c + Vector2(cos(a1), sin(a1)) * r
		tri(k, Vector3(c.x, y, c.y), Vector3(p1.x, y, p1.y), Vector3(p0.x, y, p0.y), c / ts, p1 / ts, p0 / ts, col)


## A slim pinnacle or finial: a small square shaft and a tall point.
func pinnacle(k: String, c: Vector2, w: float, y: float, h: float, col := Color.WHITE) -> void:
	box(k, c, w, w, y, y + h * 0.35, 1.0, 1.0, col)
	pyramid(k, c, w * 1.15, w * 1.15, y + h * 0.35, h * 0.65, 1.0, col)


## A round turret with a conical spire.
func turret(kw: String, kr: String, c: Vector2, r: float, y0: float, y1: float, spire: float, tw: float, th: float, col_w := Color.WHITE, col_r := Color.WHITE) -> void:
	cylinder(kw, c, r, y0, y1, 10, tw, th, col_w)
	cone(kr, c, r * 1.12, y1, spire, 10, 2.0, col_r)


## A glowing pane facing n (a lit window, a clock face).
func pane(k: String, p: Vector3, n: Vector3, sw: float, sh: float) -> void:
	var side := Vector3(n.z, 0, -n.x).normalized() * sw / 2
	var up := Vector3(0, sh / 2, 0)
	var q := p + n * 0.05
	quad(k, q - side - up, q + side - up, q + side + up, q - side + up, Vector2(0, 1), Vector2(1, 1), Vector2(1, 0), Vector2(0, 0))


func finish(parent: Node3D) -> void:
	for k in st:
		var mi := MeshInstance3D.new()
		mi.mesh = (st[k] as SurfaceTool).commit()
		mi.material_override = mats[k]
		if String(k).begins_with("glow") or k == "win":
			mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		parent.add_child(mi)
	st.clear()
