class_name Landmarks
extends RefCounted
## The twelve landmarks as dead simple white models, like the map's houses but with a little more to them (D181).
## Built from boxes, gable roofs, cylinders, cones and domes, in centimetres; the cabin scales them by 0.01.
## Front faces +z. Everything fits inside a 3.4 cm radius, the wooden base under it.

var white: StandardMaterial3D
var roof: StandardMaterial3D
var dark: StandardMaterial3D
var wood: StandardMaterial3D
var metal: StandardMaterial3D
var node: Node3D


func _init() -> void:
	white = _mat(Color("#e4dccb"), 0.85)
	roof = _mat(Color("#5b4a3e"), 0.8)
	dark = _mat(Color("#2a211b"), 0.9)
	wood = _mat(Color("#6b5440"), 0.85)
	metal = _mat(Color("#8c8c88"), 0.35, 0.7)


func _mat(c: Color, rough: float, metallic := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metallic
	return m


func build(id: String) -> Node3D:
	node = Node3D.new()
	match id:
		"square": _square()
		"cemetery": _cemetery()
		"church": _church()
		"odeon": _odeon()
		"market": _market()
		"docks": _docks()
		"hospital": _hospital()
		"slaughter": _slaughter()
		"first": _cathedral()
		"academy": _academy()
		"morgue": _morgue()
		"alley": _alley()
	return node


# ---------------------------------------------------------------- parts

func part(mesh: Mesh, mat: Material, pos: Vector3, rot := Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	mi.rotation_degrees = rot
	node.add_child(mi)
	return mi

## A box standing on y = base.
func block(size: Vector3, at: Vector3, mat: Material = null, rot_y := 0.0) -> MeshInstance3D:
	var b := BoxMesh.new()
	b.size = size
	return part(b, mat if mat != null else white, at + Vector3(0, size.y / 2, 0), Vector3(0, rot_y, 0))

## A pitched roof on y = base, ridge along z (or along x).
func gable(w: float, d: float, h: float, at: Vector3, along_x := false, mat: Material = null) -> MeshInstance3D:
	var p := PrismMesh.new()
	p.size = Vector3(w, h, d)
	return part(p, mat if mat != null else roof, at + Vector3(0, h / 2, 0), Vector3(0, 90 if along_x else 0, 0))

## A house: walls and a roof with a little overhang. w across x, d along z.
func house(w: float, d: float, walls: float, roof_h: float, at: Vector3, along_x := false) -> void:
	block(Vector3(w, walls, d), at)
	if along_x:
		gable(d * 1.15, w * 1.08, roof_h, at + Vector3(0, walls, 0), true)
	else:
		gable(w * 1.15, d * 1.08, roof_h, at + Vector3(0, walls, 0))

func cyl(r_top: float, r_bot: float, h: float, at: Vector3, mat: Material = null, seg := 16) -> MeshInstance3D:
	var c := CylinderMesh.new()
	c.top_radius = r_top
	c.bottom_radius = r_bot
	c.height = h
	c.radial_segments = seg
	c.rings = 1
	return part(c, mat if mat != null else white, at + Vector3(0, h / 2, 0))

func cone(r: float, h: float, at: Vector3, mat: Material = null, seg := 12) -> MeshInstance3D:
	return cyl(0.0, r, h, at, mat if mat != null else roof, seg)

## A square pyramid roof.
func pyramid(w: float, h: float, at: Vector3, mat: Material = null) -> MeshInstance3D:
	var p := cyl(0.0, w * 0.7071, h, at, mat if mat != null else roof, 4)
	p.rotation_degrees.y = 45
	return p

func dome(r: float, at: Vector3, mat: Material = null) -> MeshInstance3D:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r
	s.is_hemisphere = true
	s.radial_segments = 20
	s.rings = 8
	return part(s, mat if mat != null else white, at)

## A door on the face at z = face, centred on x.
func door(x: float, face: float, w := 0.5, h := 0.9, base := 0.0) -> void:
	block(Vector3(w, h, 0.08), Vector3(x, base, face + 0.02), dark)

## A row of windows on the face at z = face.
func windows(xs: Array, face: float, y: float, w := 0.3, h := 0.45) -> void:
	for x: float in xs:
		block(Vector3(w, h, 0.06), Vector3(x, y, face + 0.02), dark)

## Windows on a side face at x = face, facing out along x.
func side_windows(zs: Array, face: float, y: float, w := 0.3, h := 0.45) -> void:
	for z: float in zs:
		block(Vector3(0.06, h, w), Vector3(face + signf(face) * 0.02, y, z), dark)


# ---------------------------------------------------------------- the landmarks

## The square: a paved square with the scaffold and its blade in the middle.
func _square() -> void:
	block(Vector3(5.2, 0.15, 5.2), Vector3.ZERO)
	block(Vector3(2.6, 0.7, 2.6), Vector3(0, 0.15, 0))                  # the platform
	block(Vector3(1.0, 0.35, 0.6), Vector3(0, 0.15, 1.6))                # a step up to it
	for x: float in [-0.55, 0.55]:
		block(Vector3(0.22, 3.2, 0.22), Vector3(x, 0.85, -0.2), wood)    # the uprights
	block(Vector3(1.4, 0.25, 0.3), Vector3(0, 4.05, -0.2), wood)         # the crossbar
	part(_box(Vector3(0.88, 0.5, 0.06)), metal, Vector3(0, 3.35, -0.2), Vector3(0, 0, 12))   # the blade, slanted
	block(Vector3(1.0, 0.3, 0.3), Vector3(0, 1.3, -0.2), wood)           # the lunette
	# Lamp posts at two corners.
	for p: Vector2 in [Vector2(-2.1, 2.1), Vector2(2.1, -2.1)]:
		cyl(0.07, 0.09, 2.2, Vector3(p.x, 0.15, p.y), dark, 8)
		cyl(0.2, 0.14, 0.35, Vector3(p.x, 2.35, p.y), dark, 6)

## The graveyard: a low wall with a gate, a small chapel at the back, rows of headstones.
func _cemetery() -> void:
	var r := 2.6
	var t := 0.22
	block(Vector3(2 * r, 0.6, t), Vector3(0, 0, -r))
	block(Vector3(t, 0.6, 2 * r), Vector3(-r, 0, 0))
	block(Vector3(t, 0.6, 2 * r), Vector3(r, 0, 0))
	for x: float in [-1.75, 1.75]:
		block(Vector3(r - 0.7, 0.6, t), Vector3(signf(x) * (r + 0.7) / 2, 0, r))         # the front wall, a gap for the gate
	for x: float in [-0.7, 0.7]:
		block(Vector3(0.35, 1.0, 0.35), Vector3(x, 0, r))                 # gate posts
	house(1.6, 2.0, 1.6, 1.1, Vector3(0, 0, -1.5))                        # the chapel
	door(0, -0.5, 0.45, 0.8)
	block(Vector3(0.1, 0.6, 0.1), Vector3(0, 2.7, -0.7))                  # its cross
	block(Vector3(0.38, 0.1, 0.1), Vector3(0, 3.05, -0.7))
	for row: float in [0.6, 1.6]:
		for x: float in [-1.9, -1.1, 1.1, 1.9]:
			block(Vector3(0.38, 0.5, 0.12), Vector3(x, 0, row), white, (x * 7.0))
	for x: float in [-1.5, 1.5]:
		block(Vector3(0.1, 0.8, 0.1), Vector3(x, 0, -0.3))                # two crosses
		block(Vector3(0.4, 0.1, 0.1), Vector3(x, 0.55, -0.3))

## The church: a nave under a long roof and a bell tower with a spire at the front.
func _church() -> void:
	house(2.6, 4.4, 2.2, 1.5, Vector3(0, 0, -0.8))
	side_windows([-2.2, -1.0, 0.2], 1.3, 0.9, 0.3, 0.8)
	side_windows([-2.2, -1.0, 0.2], -1.3, 0.9, 0.3, 0.8)
	block(Vector3(1.5, 4.0, 1.5), Vector3(0, 0, 1.9))                     # the tower
	pyramid(1.6, 0.3, Vector3(0, 4.0, 1.9), roof)
	cone(0.75, 2.6, Vector3(0, 4.2, 1.9), roof, 8)                        # the spire
	door(0, 2.65, 0.6, 1.1)
	windows([0.0], 2.65, 2.6, 0.35, 0.6)

## The theatre: a hall behind a portico of columns under a pediment, with steps.
func _odeon() -> void:
	block(Vector3(4.6, 2.6, 3.4), Vector3(0, 0, -1.0))
	gable(4.8, 3.6, 0.8, Vector3(0, 2.6, -1.0), true)
	block(Vector3(4.6, 0.35, 1.6), Vector3(0, 0, 1.4))                    # the steps
	for x: float in [-1.8, -1.08, -0.36, 0.36, 1.08, 1.8]:
		cyl(0.17, 0.19, 2.25, Vector3(x, 0.35, 1.7))
	block(Vector3(4.4, 0.3, 1.2), Vector3(0, 2.6, 1.3))                   # the beam over the columns
	gable(4.6, 1.3, 0.75, Vector3(0, 2.9, 1.3), true, white)              # the pediment
	for x: float in [-1.1, 0.0, 1.1]:
		door(x, 0.7, 0.45, 1.2)

## The market: one long low roof held on columns, open at the sides, a few stalls under it.
func _market() -> void:
	block(Vector3(5.4, 0.12, 3.2), Vector3.ZERO)
	for x: float in [-2.4, -1.2, 0.0, 1.2, 2.4]:
		for z: float in [-1.35, 1.35]:
			cyl(0.13, 0.15, 1.6, Vector3(x, 0.12, z), white, 8)
	block(Vector3(5.4, 0.18, 3.2), Vector3(0, 1.72, 0))
	gable(3.6, 5.8, 1.3, Vector3(0, 1.9, 0), true)
	for x: float in [-1.8, -0.6, 0.6, 1.8]:
		block(Vector3(0.7, 0.45, 0.5), Vector3(x, 0.12, 0), wood)          # stalls

## The docks: a plank pier on posts, a warehouse, a crane and crates.
func _docks() -> void:
	block(Vector3(2.0, 0.22, 5.0), Vector3(1.4, 0.3, 0), wood)            # the pier
	for z: float in [-2.2, -0.8, 0.6, 2.0]:
		for x: float in [0.5, 2.3]:
			cyl(0.1, 0.1, 0.55, Vector3(x, 0.0, z), wood, 6)
	house(2.2, 2.8, 1.8, 1.1, Vector3(-1.3, 0, -0.6))                     # the warehouse
	door(-1.3, 0.8, 0.9, 1.1)
	block(Vector3(0.3, 3.6, 0.3), Vector3(1.6, 0.52, -1.5), wood)         # the crane's mast
	part(_box(Vector3(0.18, 0.18, 3.0)), wood, Vector3(1.6, 3.8, -0.5), Vector3(-25, 0, 0))   # its arm
	cyl(0.02, 0.02, 1.5, Vector3(1.6, 2.6, 0.75), dark, 4)                # the rope
	block(Vector3(0.5, 0.4, 0.5), Vector3(1.6, 2.2, 0.75), wood)          # a crate on the hook
	for p: Vector3 in [Vector3(1.0, 0.52, 1.6), Vector3(1.6, 0.52, 1.9), Vector3(1.25, 0.92, 1.75)]:
		block(Vector3(0.45, 0.4, 0.45), p, wood)

## The hospital: four wings round a courtyard, an entrance with a small pediment, a bell turret.
func _hospital() -> void:
	var o := 2.45
	var d := 1.15
	house(2 * o, d, 1.8, 0.9, Vector3(0, 0, o - d / 2), true)            # front
	house(2 * o, d, 1.8, 0.9, Vector3(0, 0, -o + d / 2), true)           # back
	house(d, 2 * o - 2 * d, 1.8, 0.9, Vector3(-o + d / 2, 0, 0))         # sides
	house(d, 2 * o - 2 * d, 1.8, 0.9, Vector3(o - d / 2, 0, 0))
	windows([-1.9, -1.25, 1.25, 1.9], o, 0.8)
	block(Vector3(1.6, 2.3, 0.5), Vector3(0, 0, o + 0.1))                 # the entrance
	gable(1.8, 0.6, 0.55, Vector3(0, 2.3, o + 0.1), true, white)
	door(0, o + 0.35, 0.55, 1.0)
	block(Vector3(0.6, 0.7, 0.6), Vector3(0, 2.6, o - d / 2))              # the bell turret
	pyramid(0.7, 0.6, Vector3(0, 3.3, o - d / 2))

## The slaughterhouse: two long low sheds, a pen in front, a tall chimney.
func _slaughter() -> void:
	house(1.9, 4.6, 1.4, 1.0, Vector3(-1.1, 0, -0.4))
	house(1.9, 4.6, 1.4, 1.0, Vector3(1.1, 0, -0.4))
	door(-1.1, 1.9, 0.8, 1.0)
	door(1.1, 1.9, 0.8, 1.0)
	cyl(0.22, 0.32, 4.6, Vector3(0, 0, -2.4), white, 10)                   # the chimney
	cyl(0.26, 0.26, 0.2, Vector3(0, 4.6, -2.4), dark, 10)
	for x: float in [-1.9, -0.6, 0.6, 1.9]:
		block(Vector3(0.1, 0.5, 0.1), Vector3(x, 0, 2.6), wood)            # the pen
	block(Vector3(3.9, 0.08, 0.06), Vector3(0, 0.38, 2.6), wood)
	block(Vector3(0.06, 0.08, 0.7), Vector3(-1.9, 0.38, 2.25), wood)
	block(Vector3(0.06, 0.08, 0.7), Vector3(1.9, 0.38, 2.25), wood)

## The cathedral: a tall nave and transept, two square towers at the front, a rose window, a spire at the crossing.
func _cathedral() -> void:
	house(2.8, 5.0, 2.8, 1.7, Vector3(0, 0, -0.6))
	house(5.6, 1.6, 2.6, 1.5, Vector3(0, 0, -1.2), true)                  # the transept
	for x: float in [-1.15, 1.15]:
		block(Vector3(1.3, 5.0, 1.3), Vector3(x, 0, 2.3))                  # the towers
		block(Vector3(1.45, 0.25, 1.45), Vector3(x, 5.0, 2.3))
		windows([x], 2.97, 3.4, 0.3, 0.8)
	block(Vector3(1.0, 3.6, 0.9), Vector3(0, 0, 2.3))                      # between the towers
	part(_disc(0.45), dark, Vector3(0, 2.6, 2.77), Vector3(90, 0, 0))     # the rose window
	door(0, 2.75, 0.6, 1.2)
	door(-1.15, 2.95, 0.45, 0.9)
	door(1.15, 2.95, 0.45, 0.9)
	cone(0.35, 2.4, Vector3(0, 4.0, -1.2), roof, 8)                        # the spire at the crossing
	side_windows([-2.4, -0.2, 0.8], 1.4, 1.1, 0.3, 0.9)
	side_windows([-2.4, -0.2, 0.8], -1.4, 1.1, 0.3, 0.9)

## The academy: a long block with a flat roof, a portico, and a dome on a drum with a lantern.
func _academy() -> void:
	block(Vector3(5.2, 2.2, 3.0), Vector3(0, 0, -0.5))
	block(Vector3(5.4, 0.2, 3.2), Vector3(0, 2.2, -0.5))
	windows([-2.0, -1.3, 1.3, 2.0], 1.0, 1.0, 0.35, 0.6)
	cyl(1.15, 1.15, 0.8, Vector3(0, 2.4, -0.5))                           # the drum
	dome(1.2, Vector3(0, 3.2, -0.5))
	cyl(0.22, 0.22, 0.5, Vector3(0, 4.3, -0.5))                           # the lantern
	cone(0.28, 0.4, Vector3(0, 4.8, -0.5), roof, 8)
	block(Vector3(2.2, 0.25, 1.3), Vector3(0, 0, 1.6))                    # portico steps
	for x: float in [-0.8, -0.27, 0.27, 0.8]:
		cyl(0.12, 0.14, 1.75, Vector3(x, 0.25, 1.9))
	gable(2.3, 1.3, 0.55, Vector3(0, 2.0, 1.6), true, white)
	door(0, 1.0, 0.55, 1.0)

## The morgue: a low, plain, heavy block with a hipped roof, a wide door and two small barred windows.
func _morgue() -> void:
	block(Vector3(4.2, 1.5, 2.8), Vector3(0, 0, -0.2))
	block(Vector3(4.4, 0.18, 3.0), Vector3(0, 1.5, -0.2))
	gable(3.1, 4.5, 0.75, Vector3(0, 1.68, -0.2), true)
	door(0, 1.2, 0.9, 1.0)
	windows([-1.3, 1.3], 1.2, 0.75, 0.4, 0.25)
	block(Vector3(1.4, 0.15, 0.7), Vector3(0, 0, 1.5))                   # the step
	block(Vector3(0.3, 0.8, 0.3), Vector3(1.4, 1.5, -1.0))                # a chimney
	# A handcart by the door.
	block(Vector3(0.9, 0.12, 0.6), Vector3(-1.6, 0.35, 1.9), wood)
	part(_disc(0.3), dark, Vector3(-1.6, 0.3, 2.25), Vector3(90, 0, 0))

## The crooked house: three narrow tall houses in a tangle, leaning on each other, upper floors jutting out.
func _alley() -> void:
	var spots := [Vector3(-1.3, 0, 0.4), Vector3(0.2, 0, -0.5), Vector3(1.5, 0, 0.6)]
	var tall := [3.2, 4.0, 2.8]
	var lean := [-6.0, 4.0, 8.0]
	for i in 3:
		var at: Vector3 = spots[i]
		var h: float = tall[i]
		var piece := Node3D.new()
		piece.position = at
		piece.rotation_degrees = Vector3(0, i * 17.0 - 15.0, lean[i])
		node.add_child(piece)
		var keep := node
		node = piece
		block(Vector3(1.2, h * 0.55, 1.4), Vector3.ZERO)
		block(Vector3(1.4, h * 0.45, 1.6), Vector3(0, h * 0.55, 0.1))       # the jutting upper floor
		gable(1.6, 1.8, 1.1, Vector3(0, h, 0.1), false)
		door(0, 0.7, 0.4, 0.8)
		windows([0.0], 0.9, h * 0.65, 0.3, 0.4)
		node = keep
	cyl(0.06, 0.08, 2.0, Vector3(-0.3, 0, 2.2), dark, 6)                  # a lamp post
	cyl(0.18, 0.12, 0.3, Vector3(-0.3, 2.0, 2.2), dark, 6)


func _box(size: Vector3) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = size
	return b

func _disc(r: float) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = r
	c.bottom_radius = r
	c.height = 0.06
	c.radial_segments = 16
	return c
