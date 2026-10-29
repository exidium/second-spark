class_name LabView
extends RefCounted
## The laboratory, as in labBody() in src/ui.js: operating table, body parts with their build buttons,
## the switch, the decomposition track and the points table. Also used read-only for rivals.

const SLOT_ORDER := ["head", "torso", "armL", "armR", "legL", "legR"]


## The operating table with each part drawn in its state (muscle red, skin yellow, alive blue) and damage bolts.
static func figure(g: Game, p: Dictionary, size: Vector2) -> Control:
	var root := Control.new()
	root.custom_minimum_size = size
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var layers := ["body/table.png"]
	for s in g.D.SLOT6:
		var t = p.table[s]
		if t != null:
			layers.append("body/%s-%s.png" % ["alive" if t.alive else t.side, s])
	for l in layers:
		var tr := Style.picture(Style.art(l), size, false)
		tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		root.add_child(tr)
	for s in g.D.SLOT6:
		var t = p.table[s]
		if t != null and t.dmg:
			var c: Array = g.D.BODY_CENTRES[s]
			var bolt := Style.label("ϟ" if t.dmg == 1 else "ϟϟ", int(size.y / 9), Style.DMG)
			bolt.add_theme_color_override("font_outline_color", Color.BLACK)
			bolt.add_theme_constant_override("outline_size", 4)
			bolt.position = Vector2(size.x * c[0] / 100.0 - size.y / 30, size.y * c[1] / 100.0 - size.y / 16)
			root.add_child(bolt)
	return root


## Materials by stage. Red cells rot at the next dawn.
static func decay_grid(g: Game, p: Dictionary, compact := false) -> VBoxContainer:
	var v := Style.vbox(2)
	var fs := 13 if compact else 16
	var cw := 26 if compact else 44
	var head := Style.hbox(2)
	var hn := Style.label("", fs)
	hn.custom_minimum_size.x = 58 if compact else 90
	head.add_child(hn)
	for r in ["I", "II", "III", "IV"]:
		var l := Style.label(r, fs, Style.MUTED, Style.display)
		l.custom_minimum_size.x = cw
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		head.add_child(l)
	v.add_child(head)
	for t in g.D.MATS:
		var h := Style.hbox(2)
		var nh := Style.hbox(4)
		nh.custom_minimum_size.x = 58 if compact else 90
		var sq := ColorRect.new()
		sq.color = Style.MAT_COL[t]
		sq.custom_minimum_size = Vector2(fs - 4, fs - 4)
		sq.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		nh.add_child(sq)
		nh.add_child(Style.label(g.D.MAT_N[t], fs - 1, Style.PARCH_DIM))
		h.add_child(nh)
		for k in 4:
			var n: int = p.mats[t][k]
			var rot: bool = n > 0 and (k == 3 or (t == "blood" and k == 1))
			var cell := PanelContainer.new()
			cell.custom_minimum_size = Vector2(cw, fs + 6)
			var bg: Color = Color(Style.MAT_COL[t], 0.55) if n else Color(0, 0, 0, 0.25)
			cell.add_theme_stylebox_override("panel", Style.box(bg, Style.CRIM if rot else Style.LINE, 2 if rot else 1, 0))
			var l := Style.title(str(n) if n else "", fs, Style.PARCH)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			cell.add_child(l)
			h.add_child(cell)
		v.add_child(h)
	var foot := Style.label("Bone %d · Preserved %d/9%s" % [p.bone, p.preserved, (" · Ice: no decay for %d dawn%s" % [p.ice, "" if p.ice == 1 else "s"]) if p.ice else ""], fs - 1, Style.PARCH_DIM)
	foot.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(foot)
	return v


## "■ 4 muscle  ■ 5 organ" on one line, each square in its material's colour.
static func req_text(g: Game, req: Dictionary) -> String:
	var parts := []
	for k in req:
		if req[k] > 0:
			var t: String = g.D.KEY[k]
			parts.append("[color=#%s]■[/color] %d %s" % [Style.MAT_COL[t].to_html(false), req[k], t])
	return "  ".join(parts)


## One row per body part: its state, what the next step needs and scores, and the build buttons at night.
static func anatomy(g: Game, p: Dictionary, lab: bool, opts: Dictionary, on_build: Callable) -> GridContainer:
	var v := GridContainer.new()
	v.columns = 2
	v.add_theme_constant_override("h_separation", 8)
	v.add_theme_constant_override("v_separation", 8)
	for s in SLOT_ORDER:
		var t = p.table[s]
		var P: Dictionary = g.D.PARTS[g.D.SLOT_T[s]]
		var step = g.next_step(p, s)
		var row := Style.panel(Style.PANEL, Style.LINE, 8)
		row.custom_minimum_size.x = 318
		row.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var rv := Style.vbox(3)
		row.add_child(rv)
		var top := Style.hbox(8)
		var nm := Style.title(g.D.SLOT_N[s], 18)
		nm.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(nm)
		if t != null and t.dmg:
			top.add_child(Style.label("damaged", 14, Style.DMG, Style.display))
		var state: String = "Not started" if t == null else "Alive" if t.alive else "Complete" if t.side == "skin" else "Muscle"
		var scol: Color = Style.MUTED if t == null else Style.ALIVE if t.alive else Style.SKIN if t.side == "skin" else Style.MUSCLE
		top.add_child(Style.label(state, 15, scol, Style.display))
		rv.add_child(top)
		if step != null:
			var f = g.plan_build(p, s, "fresh", opts)
			var o = g.plan_build(p, s, "old", opts)
			rv.add_child(Style.rich("[color=#b9ac93]%s%s[/color]\n%s" % ["Start (muscle)" if step == "start" else "Add skin", (" · expertise %d" % P.exp) if P.exp else "", req_text(g, f.req)], 15, 300))
			var tbl: Array = P.vpS if step == "start" else P.vpC
			rv.add_child(Style.label("VP by stage: I %d · II %d · III %d · IV %d · alive %d" % [tbl[0], tbl[1], tbl[2], tbl[3], P.alive], 13, Style.MUTED))
			var lack: String = ("Needs expertise %d" % P.exp) if not f.expOK else ("Not enough materials" if not f.matsOK else "")
			if lab:
				if f.ok:
					var bh := VBoxContainer.new()
					var b1 := Style.button("%s · +%d VP" % ["Start" if step == "start" else "Add skin", f.vp], true, 15)
					var ss: String = s
					b1.pressed.connect(func(): on_build.call(ss, "fresh"))
					bh.add_child(b1)
					if o.ok and o.vp != f.vp:
						var b2 := Style.button("Use oldest first · +%d VP" % o.vp, false, 14)
						b2.pressed.connect(func(): on_build.call(ss, "old"))
						bh.add_child(b2)
					rv.add_child(bh)
				else:
					rv.add_child(Style.label(lack, 14, Style.MUTED))
			else:
				rv.add_child(Style.label("Ready to build tonight" if f.ok else lack, 14, Style.VERD if f.ok else Style.MUTED))
		elif not t.alive:
			rv.add_child(Style.wrap("Complete. Throw the switch to bring it to life: +%d points at the end." % P.alive, 14, Style.PARCH_DIM, 300))
		else:
			rv.add_child(Style.wrap("Alive: +%d points at the end, as long as it stays alive." % P.alive, 14, Style.ALIVE, 300))
		v.add_child(row)
	return v


static func switch_box(g: Game, p: Dictionary, on_throw: Callable) -> VBoxContainer:
	var v := Style.vbox(6)
	v.add_child(Style.title("Throw the switch", 18))
	var ch := g.charged(p)
	var note := "Each charged jar rolls 2 shock dice. "
	note += ("Your expertise makes %d of them blue." % g.blue_dice(p)) if g.blue_dice(p) else "Expertise 10 makes one of them blue."
	if p.sabotaged:
		note += " Your wires are cut: you lose a die."
	if g.has_char(p, "zoo") and not p.zooUsed:
		note += " Zoologist: +1 gray die."
	v.add_child(Style.wrap(note, 14, Style.PARCH_DIM, 180))
	if p.thrown:
		v.add_child(Style.label("Thrown for tonight.", 15, Style.MUTED))
		return v
	for n in [1, 2, 3]:
		var b := Style.button("", n == mini(3, ch), 16)
		var h := Style.hbox(6)
		h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		h.alignment = BoxContainer.ALIGNMENT_CENTER
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(Style.icon("jar", 20))
		h.add_child(Style.title("Use %d jar%s" % [n, "" if n == 1 else "s"], 16, Style.SPARK if n == mini(3, ch) else Style.PARCH))
		b.add_child(h)
		b.custom_minimum_size = Vector2(180, 36)
		b.disabled = not (g.can_throw(p) and n <= ch)
		var nn: int = n
		b.pressed.connect(func(): on_throw.call(nn))
		v.add_child(b)
	if not g.D.SLOT6.any(func(s): return p.table[s] != null and p.table[s].side == "skin"):
		v.add_child(Style.wrap("You need at least one complete (skinned) part.", 13, Style.MUTED, 180))
	elif not ch:
		v.add_child(Style.wrap("No charged jars. Charge them in your lab during the day.", 13, Style.MUTED, 180))
	return v


## VP for each part: muscle by stage, skin by stage, alive. Also printed on your board.
static func points_grid(g: Game, fs := 15) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 10
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 0)
	var hdr := ["Part", "I", "II", "III", "IV", "I", "II", "III", "IV", "Alive"]
	for k in hdr.size():
		var col: Color = Style.MUSCLE.lightened(0.2) if k in [1, 2, 3, 4] else Style.SKIN if k in [5, 6, 7, 8] else Style.MUTED
		var l := Style.label(hdr[k], fs - 1, col, Style.display)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(l)
	for part in [["Head", "head"], ["Torso", "torso"], ["Arm", "arm"], ["Leg", "leg"]]:
		var P: Dictionary = g.D.PARTS[part[1]]
		grid.add_child(Style.label(part[0], fs, Style.PARCH, Style.display))
		for x in P.vpS + P.vpC:
			var l := Style.label(str(x), fs, Style.PARCH)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			grid.add_child(l)
		var a := Style.label(str(P.alive), fs, Style.ALIVE)
		a.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(a)
	return grid


static func points_table(g: Game) -> VBoxContainer:
	var v := Style.vbox(2)
	v.add_child(Style.label("Muscle (start), then skin (complete), by the stage of the oldest material.", 13, Style.MUTED))
	v.add_child(points_grid(g))
	v.add_child(Style.wrap("Each step scores VP by the stage of the oldest material you use (I is freshest). Animal costs 1 VP (2 if 3 or more). Alive points count at the end of the game.", 13, Style.MUTED, 300))
	return v


## The whole laboratory: three columns. cb holds build(slot, policy), throw(n), preserve(t, n), toggle(name) for your own lab at night.
static func body(g: Game, p: Dictionary, own: bool, opts: Dictionary, cb: Dictionary) -> VBoxContainer:
	var lab: bool = own and g.S.phase == "lab"
	var root := Style.vbox(10)
	var intro := "Build parts (as many as you can), throw the switch once, and preserve spare flesh for the Market." if lab else ("By day you can only look. Building and the switch happen at night." if own else "")
	if intro != "":
		root.add_child(Style.wrap(intro, 16, Style.PARCH_DIM))
	var cols := Style.hbox(18)
	root.add_child(cols)
	var c1 := Style.vbox(8)
	c1.add_child(Style.label("OPERATING TABLE", 13, Style.MUTED, Style.display))
	c1.add_child(figure(g, p, Vector2(180, 270)))
	var legend := "muscle %d · skin %d · alive %d · damage %d" % [g.on_table(p).size() - g.complete_count(p), g.complete_count(p) - g.alive_count(p), g.alive_count(p), g.dmg_total(p)]
	c1.add_child(Style.label(legend, 14, Style.PARCH_DIM))
	c1.add_child(Style.label("%d VP built" % p.vp, 15, Style.PARCH, Style.display))
	if lab:
		c1.add_child(switch_box(g, p, cb.throw))
	cols.add_child(c1)
	var c2 := Style.vbox(8)
	c2.custom_minimum_size.x = 644
	c2.add_child(Style.label("BODY PARTS", 13, Style.MUTED, Style.display))
	if lab:
		var tg := Style.hbox(8)
		if g.has_card(p, "steady"):
			var b := CheckButton.new()
			b.text = "Steady Hands: 1 fewer of each material"
			b.button_pressed = opts.get("steady", false)
			b.toggled.connect(func(_on): cb.toggle.call("steady"))
			tg.add_child(b)
		if g.has_char(p, "surgeon") and not p.surgeonUsed:
			var b := CheckButton.new()
			b.text = "Surgeon: 1 less material"
			b.button_pressed = opts.get("surgeon", false)
			b.toggled.connect(func(_on): cb.toggle.call("surgeon"))
			tg.add_child(b)
		if tg.get_child_count():
			c2.add_child(tg)
	c2.add_child(anatomy(g, p, lab, opts, cb.get("build", func(_s, _p): pass)))
	cols.add_child(c2)
	var c3 := Style.vbox(8)
	c3.add_child(Style.label("DECOMPOSITION TRACK", 13, Style.MUTED, Style.display))
	c3.add_child(decay_grid(g, p))
	if lab:
		var ph := Style.hbox(6)
		for t in ["muscle", "organ"]:
			var n: int = mini(g.total(p.mats[t]), 9 - p.preserved)
			if n:
				var b := Style.button("Preserve %d %s" % [mini(3, n), t], false, 14)
				var tt: String = t
				var nn: int = mini(3, n)
				b.pressed.connect(func(): cb.preserve.call(tt, nn))
				ph.add_child(b)
		if ph.get_child_count():
			c3.add_child(ph)
	c3.add_child(Style.wrap("Each dawn materials age one stage. Red cells rot at the next dawn. Bone never rots (max 12). Preserved flesh sells at the Market.", 13, Style.MUTED, 300))
	c3.add_child(Style.spacer(4))
	c3.add_child(Style.label("POINTS PER PART AND QUALITY", 13, Style.MUTED, Style.display))
	c3.add_child(points_table(g))
	cols.add_child(c3)
	return root
