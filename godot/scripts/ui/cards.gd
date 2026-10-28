class_name Cards
extends RefCounted
## Card faces as Controls, matching cardHTML in src/ui.js: parchment frames for research and humanity,
## full art for scoundrels and cadavers, landscape scenes for events and encounters.

const W := 196.0
const H := 262.0


## A row of material cubes: coloured square, count, stage.
static func mats_row(list: Array, size := 15, ink := Style.PAPER_INK) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.add_theme_constant_override("h_separation", 8)
	f.add_theme_constant_override("v_separation", 2)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for m in list:
		if m[2] <= 0:
			continue
		f.add_child(mat_chip(m[0], m[2], 0 if m[0] == "bone" else m[1], size, ink))
	return f

static func mat_chip(t: String, n: int, stage: int, size := 15, ink := Style.PAPER_INK) -> HBoxContainer:
	var h := Style.hbox(3)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sq := ColorRect.new()
	sq.color = Style.MAT_COL.get(t, Color.GRAY)
	sq.custom_minimum_size = Vector2(size - 3, size - 3)
	sq.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	sq.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(sq)
	h.add_child(Style.title(str(n), size, ink))
	h.add_child(Style.label(t + ((" " + Style.roman(stage)) if stage > 0 else ""), size - 1, ink))
	h.tooltip_text = ""
	return h

static func gains_row(g: Dictionary, size := 16, ink := Style.PAPER_INK) -> HBoxContainer:
	var h := Style.hbox(10)
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for k in [["exp", "expertise"], ["rep", "reputation"], ["coin", "coin"], ["hum", "heart"]]:
		var v: int = g.get(k[0], 0)
		if v:
			var c := Style.hbox(2)
			c.add_child(Style.title("%+d" % v, size, Style.CRIM if v < 0 else ink))
			c.add_child(Style.icon("heart-broken" if k[0] == "hum" and v < 0 else k[1], size + 4))
			h.add_child(c)
	return h


static func _frame(bg: Texture2D, w: float, h: float) -> Control:
	var root := Control.new()
	root.custom_minimum_size = Vector2(w, h)
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	var t := Style.picture(bg, Vector2(w, h), false)
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(t)
	return root

static func _content(root: Control, pad := 16.0) -> VBoxContainer:
	var m := MarginContainer.new()
	m.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for s in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + s, int(pad))
	m.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(m)
	var v := Style.vbox(4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	m.add_child(v)
	return v

static func _centered(text: String, size: int, color: Color, font: Font) -> Label:
	var l := Style.label(text, size, color, font)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


## Research and humanity cards: parchment frame, emblem, name, kind, text, gains (and the dice a research card changes).
static func paper_card(g: Game, c: Dictionary, scale := 1.0) -> Control:
	Style.init()
	var research: bool = c.kind == "research"
	var root := _frame(Style.art("frames/card-%s-bg.png" % ("research" if research else "humanity")), W * scale, H * scale)
	var v := _content(root, 14 * scale)
	var em := Style.icon("book" if research else "cross", int(30 * scale))
	em.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(em)
	v.add_child(_centered(c.name, int(19 * scale), Style.PAPER_INK, Style.display))
	v.add_child(_centered("RESEARCH" if research else "HUMANITY", int(12 * scale), Color(Style.PAPER_INK, 0.6), Style.display))
	var tx := _centered(c.text, int(14 * scale), Style.PAPER_INK, Style.body)
	tx.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(tx)
	var gr := gains_row(c.get("gain", {}), int(15 * scale))
	gr.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_child(gr)
	if research:
		v.add_child(_centered("After a throw: " + g.D.MIT_N[c.mit], int(12 * scale), Color(Style.PAPER_INK, 0.75), Style.body))
	return root


static func _art_card(texture: Texture2D, kind: String, name: String, scale: float) -> Array:
	var root := Control.new()
	root.custom_minimum_size = Vector2(W, H) * scale
	root.mouse_filter = Control.MOUSE_FILTER_PASS
	var bg := ColorRect.new()
	bg.color = Style.PAPER
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(bg)
	var v := Style.vbox(0)
	v.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(v)
	var pic := Style.picture(texture, Vector2(W * scale, H * scale * 0.56))
	v.add_child(pic)
	var info := MarginContainer.new()
	for s in ["left", "right"]:
		info.add_theme_constant_override("margin_" + s, int(9 * scale))
	info.add_theme_constant_override("margin_top", int(5 * scale))
	info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(info)
	var iv := Style.vbox(2)
	iv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(iv)
	iv.add_child(Style.label(kind.to_upper(), int(11 * scale), Color(Style.PAPER_INK, 0.65), Style.display))
	var nm := Style.label(name, int(17 * scale), Style.PAPER_INK, Style.display)
	nm.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	iv.add_child(nm)
	var border := Panel.new()
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var sb := Style.box(Color(0, 0, 0, 0), Color("#5a4630"), 2)
	border.add_theme_stylebox_override("panel", sb)
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(border)
	return [root, iv]


static func scoundrel_card(g: Game, c: Dictionary, scale := 1.0) -> Control:
	var cost: int = g.sc_cost(c) if not g.S.is_empty() else c.cost
	var hc: int = g.sc_hcost(c) if not g.S.is_empty() else c.hcost
	var parts := _art_card(Style.art("scoundrels/scoundrel-%02d.png" % (c.tpl + 1)), "Scoundrel · " + Style.fr(cost) + ((" · -%d humanity" % hc) if hc else ""), c.name, scale)
	var iv: VBoxContainer = parts[1]
	if c.sk == "thief":
		iv.add_child(Style.wrap("Draw %d cadaver%s from the Hospital." % [c.draw, "" if c.draw == 1 else "s"], int(14 * scale), Style.PAPER_INK))
	else:
		iv.add_child(mats_row(c.get("mats", []), int(14 * scale)))
		var alt := []
		if c.get("exp", 0):
			alt.append("+%d expertise%s" % [c.exp, " (-1 humanity)" if c.get("expH", 0) else ""])
		if c.get("hum", 0):
			alt.append("+%d humanity" % c.hum)
		if alt.size():
			iv.add_child(Style.wrap("or " + " or ".join(alt), int(13 * scale), Style.PAPER_INK))
	return parts[0]


static func cadaver_card(g: Game, c: Dictionary, scale := 1.0, no_cost := false, extra_h := 0) -> Control:
	var stage := ("stage " + Style.roman(c.stage)) if c.stage else "bones"
	var tex: Texture2D = Style.art("cadavers/%s.png" % c.art) if c.art != null else null
	var parts := _art_card(tex, "%s · %s" % [g.LOC[c.src].name, stage], c.name, scale)
	var iv: VBoxContainer = parts[1]
	iv.add_child(mats_row(c.mats, int(14 * scale)))
	iv.add_child(Style.wrap(("or +%d expertise" % c.exp) if c.exp else "Bones only, no expertise", int(13 * scale), Style.PAPER_INK))
	var hcost: int = 0 if no_cost else c.hcost + extra_h
	if hcost:
		iv.add_child(Style.label("-%d humanity to resolve" % hcost, int(13 * scale), Style.BLOOD))
	if c.cost:
		iv.add_child(Style.label("+%s to buy" % Style.fr(c.cost), int(13 * scale), Style.BLOOD))
	return parts[0]


static func face(g: Game, c: Dictionary, scale := 1.0, extra := {}) -> Control:
	match c.kind:
		"research", "humanity":
			return paper_card(g, c, scale)
		"scoundrel":
			return scoundrel_card(g, c, scale)
		"cadaver":
			return cadaver_card(g, c, scale, extra.get("noCost", false), extra.get("extraH", 0))
	return Control.new()


static func back(name: String, scale := 0.6) -> Control:
	var root := _frame(Style.art("frames/card-tall-back.png"), W * scale, H * scale)
	var l := _centered(name, int(14 * scale / 0.6), Style.PAPER_INK, Style.display)
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	root.add_child(l)
	return root


## Event and encounter cards: a landscape scene with the name over it and the text in a panel below.
static func scene_card(texture: Texture2D, kind: String, name: String, lines: Array, width := 460.0) -> Control:
	Style.init()
	var v := Style.vbox(0)
	v.custom_minimum_size.x = width
	var art := Control.new()
	art.custom_minimum_size = Vector2(width, width * 0.75)
	art.clip_contents = true
	var pic := Style.picture(texture, Vector2(width, width * 0.75))
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(pic)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.45)
	shade.anchor_top = 0.72
	shade.anchor_right = 1
	shade.anchor_bottom = 1
	art.add_child(shade)
	var nm := Style.title(name, 30, Color.WHITE)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.anchor_top = 0.72
	nm.anchor_right = 1
	nm.anchor_bottom = 1
	nm.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	nm.add_theme_color_override("font_outline_color", Color.BLACK)
	nm.add_theme_constant_override("outline_size", 6)
	art.add_child(nm)
	var k := Style.label(kind.to_upper(), 13, Color(1, 1, 1, 0.85), Style.display)
	k.position = Vector2(12, 10)
	k.add_theme_color_override("font_outline_color", Color.BLACK)
	k.add_theme_constant_override("outline_size", 5)
	art.add_child(k)
	v.add_child(art)
	var body := Style.panel(Style.PAPER, Color("#5a4630"), 12)
	var bv := Style.vbox(4)
	body.add_child(bv)
	for l in lines:
		var lab := Style.wrap(l, 17, Style.PAPER_INK)
		bv.add_child(lab)
	v.add_child(body)
	return v

static func event_card(g: Game, e: Dictionary, width := 460.0) -> Control:
	var k: int = g.D.EVENTS.find(e)
	var lines: Array = [e.text]
	if e.get("storm", 0):
		lines.append("Lightning: every Leyden jar is charged.")
	if e.get("exec", 0):
		lines.append("Execution: bodies go on display at the Public Square.")
	return scene_card(Style.art("events/event-%02d.png" % (k + 1)), "Event · days %d to %d" % [e.r[0], e.r[1]], e.name, lines, width)

const TARGET_TEXT := {"maxExp": "The scientist with the most expertise", "fewestComplete": "The scientist with the fewest complete parts",
	"maxHum": "The scientist with the most humanity", "fpOther": "Someone the first player chooses (not themselves)",
	"fp": "Someone the first player chooses", "fpWithPart": "Someone with a part on the table, chosen by the first player",
	"lastDark": "Whoever last killed or hired a Cutthroat", "mostHumCards": "Whoever holds the most humanity cards"}

static func encounter_card(g: Game, e: Dictionary, width := 460.0) -> Control:
	var k: int = g.D.ENCOUNTERS.find(e)
	var who: String = "Captain Walton" if e.who == "captain" else "A stranger" if e.who == "woman" else "The Creature"
	var lines: Array = [e.text]
	if e.has("loc"):
		var sp: Dictionary = g.SPACE[e.loc]
		lines.append("Hidden. Triggers on the first rival to use %s: %s." % [g.LOC[sp.loc].name, sp.n])
	else:
		lines.append("Now. %s." % TARGET_TEXT.get(e.get("target", ""), ""))
	if e.has("testText"):
		lines.append("Test: %s." % e.testText)
	if e.has("choice"):
		lines.append("Choice: %s or %s." % [e.choice[0], e.choice[1]])
	return scene_card(Style.art("encounters/encounter-%02d.png" % (k + 1)), "Encounter · days %d to %d" % [e.r[0], e.r[1]], who, lines, width)
