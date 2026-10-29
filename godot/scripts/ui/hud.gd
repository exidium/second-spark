class_name Hud
extends PanelContainer
## The side column: the day, the Captain's track, today's card and the objectives; your stats and resources;
## your people; your laboratory at a glance; the rivals; the chronicle. Rebuilt on every sync.

signal kind_selected(kind: String)
signal action(name: String, arg)

const EXP_TIPS := {3: "Expertise 3: you can build arms.", 8: "Expertise 8: you can build the torso.", 10: "Expertise 10: one of your shock dice becomes a blue die (more eyes, fewer bolts).",
	14: "Expertise 14: you can build the head.", 20: "Expertise 20: two of your shock dice become blue.", 27: "Expertise 27: bonus objective, if it is in play this game. The first to reach it gains 10 VP."}
const REP_TIPS := {7: "Reputation 7: the Hospital lets you retrieve a cadaver for free. You hire a 3rd assistant.",
	15: "Reputation 15: an assistant is promoted to a 2nd scientist. At the Hospital you may take a 2nd cadaver for 1 franc.",
	23: "Reputation 23: bonus objective, if it is in play this game. The first to reach it gains 10 VP."}

var g: Game
var my_turn := false
var box: VBoxContainer
var log_box: RichTextLabel


func setup(game: Game) -> void:
	g = game
	add_theme_stylebox_override("panel", Style.box(Color(Style.PANEL, 0.97), Style.LINE, 1, 0))
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var m := MarginContainer.new()
	for s in ["left", "right", "top", "bottom"]:
		m.add_theme_constant_override("margin_" + s, 12)
	m.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(m)
	box = Style.vbox(10)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	m.add_child(box)


func refresh(turn_open: bool) -> void:
	my_turn = turn_open
	for c in box.get_children():
		c.queue_free()
	if g.S.is_empty():
		return
	var S: Dictionary = g.S
	var p: Dictionary = S.players[0]
	box.add_child(_top_buttons())
	box.add_child(_day_panel(S))
	box.add_child(_you_panel(p))
	box.add_child(_people_panel(p))
	box.add_child(_rivals_panel(S))
	box.add_child(_log_panel(S))


func _section(title_text: String) -> Array:
	var pnl := Style.panel(Style.PANEL2, Style.LINE, 10)
	var v := Style.vbox(6)
	pnl.add_child(v)
	if title_text != "":
		v.add_child(Style.label(title_text.to_upper(), 13, Style.MUTED, Style.display))
	return [pnl, v]


func _top_buttons() -> HBoxContainer:
	var h := Style.hbox(6)
	for b in [["Your character", "character"], ["Help", "help"], ["New game", "newgame"]]:
		var bt := Style.button(b[0], false, 14)
		bt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var a: String = b[1]
		bt.pressed.connect(func(): action.emit(a, null))
		h.add_child(bt)
	return h


func phase_name(S: Dictionary) -> String:
	match S.phase:
		"event": return "Morning"
		"day": return "City phase"
		"firstmove": return "The first player moves"
		"lab": return "Night %d" % S.round
		"dawn": return "Dawn"
		"end": return "The end"
	return ""


func _day_panel(S: Dictionary) -> PanelContainer:
	var sec := _section("")
	var v: VBoxContainer = sec[1]
	var h := Style.hbox(8)
	h.add_child(Style.title("Day %d" % S.round, 26))
	var ph := Style.label(phase_name(S), 16, Style.PARCH_DIM, Style.display)
	ph.size_flags_vertical = Control.SIZE_SHRINK_END
	h.add_child(ph)
	v.add_child(h)
	# Today's card.
	if S.card != null:
		var name: String
		if S.card.t == "ev":
			name = g.EVENT[S.card.id].name
		else:
			var e: Dictionary = g.ENC[S.card.id]
			name = "Encounter: " + ("Captain Walton" if e.who == "captain" else "a stranger" if e.who == "woman" else "the Creature")
		var tb := Style.button("", false)
		var th := Style.hbox(8)
		th.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		th.offset_left = 8
		th.mouse_filter = Control.MOUSE_FILTER_IGNORE
		th.add_child(Style.icon("note", 22))
		th.add_child(Style.label("Today's note:", 15, Style.PARCH_DIM, Style.display))
		var nl := Style.label(name, 16, Style.PARCH, Style.display)
		nl.clip_text = true
		nl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		th.add_child(nl)
		tb.add_child(th)
		tb.custom_minimum_size.y = 36
		tb.pressed.connect(func(): action.emit("today", null))
		v.add_child(tb)
	# Captain Walton's track.
	var ch := Style.hbox(3)
	ch.add_child(Style.label("Captain", 14, Style.MUTED, Style.display))
	for k in g.D.MAX_ROUNDS:
		var c := ColorRect.new()
		c.custom_minimum_size = Vector2(16, 12)
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		c.color = Style.CRIM if k < S.captain else (Style.PARCH if k == S.captain else Style.LINE2)
		ch.add_child(c)
	ch.add_child(Style.label("☠", 16, Style.PARCH_DIM))
	ch.tooltip_text = ""
	v.add_child(ch)
	# Bonus objectives: high contrast, claimed ones carry the claimer's colour.
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	for id in S.objectives:
		var claimed: bool = S.claimed.has(id)
		var pnl := Style.panel(Color("#2c2433") if not claimed else Color(Color(S.players[S.claimed[id]].color), 0.25), Style.BRASS if not claimed else Color(S.players[S.claimed[id]].color), 6)
		pnl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var l := Style.wrap(g.OBJ[id].name + (" · " + S.players[S.claimed[id]].name if claimed else ""), 14, Style.PARCH)
		l.add_theme_font_override("font", Style.display)
		pnl.add_child(l)
		grid.add_child(pnl)
	v.add_child(grid)
	return sec[0]


func _bar(filled: int, n: int, on_col: Color, marks: Dictionary) -> HBoxContainer:
	var h := Style.hbox(1)
	for k in n:
		var c := ColorRect.new()
		c.custom_minimum_size = Vector2(7, 12)
		var mk: bool = marks.has(k + 1)
		c.color = on_col if k < filled else (Color("#4a5a6e") if mk else Style.LINE)
		if mk:
			c.tooltip_text = marks[k + 1]
			c.mouse_filter = Control.MOUSE_FILTER_STOP
			if k >= filled:
				c.color = Color("#3d6e99")
		else:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(c)
	return h

func _hum_bar(hum: int) -> HBoxContainer:
	var h := Style.hbox(1)
	for k in 20:
		var v := k - 10
		var on: bool = (v >= hum and v < 0) if hum < 0 else (v >= 0 and v < hum)
		var c := ColorRect.new()
		c.custom_minimum_size = Vector2(10.5, 12)
		c.color = (Style.CRIM if hum < 0 else Style.VERD) if on else (Style.LINE2 if k == 10 else Style.LINE)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(c)
	return h

func stat_rows(p: Dictionary) -> VBoxContainer:
	var v := Style.vbox(4)
	var rows := [["heart-broken" if p.hum < 0 else "heart", "Humanity", _hum_bar(p.hum), ("%+d" % p.hum) if p.hum else "0"],
		["expertise", "Expertise", _bar(mini(p.exp, 30), 30, Style.SPARK, EXP_TIPS), str(p.exp)],
		["reputation", "Reputation", _bar(mini(p.rep, 30), 30, Style.BRASS, REP_TIPS), str(p.rep)]]
	for r in rows:
		var h := Style.hbox(6)
		h.add_child(Style.icon(r[0], 18))
		var l := Style.label(r[1], 14, Style.PARCH_DIM, Style.display)
		l.custom_minimum_size.x = 84
		h.add_child(l)
		h.add_child(r[2])
		var n := Style.title(r[3], 17)
		n.custom_minimum_size.x = 30
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		h.add_child(n)
		v.add_child(h)
	return v


func _you_panel(p: Dictionary) -> PanelContainer:
	var sec := _section("")
	var v: VBoxContainer = sec[1]
	var head := Style.hbox(8)
	var portrait := Style.picture(Style.art("characters/character-%s.png" % p.char), Vector2(40, 56))
	head.add_child(portrait)
	var nv := Style.vbox(0)
	nv.add_child(Style.title(p.name, 19, Color(p.color)))
	var C: Dictionary = g.D.CHARACTERS.filter(func(c): return c.id == p.char)[0]
	nv.add_child(Style.label("%s · %d VP built · %d of 6 alive" % [C.role, p.vp, g.alive_count(p)], 14, Style.PARCH_DIM))
	head.add_child(nv)
	v.add_child(head)
	v.add_child(stat_rows(p))
	var bh := Style.hbox(6)
	var night: bool = g.S.phase == "lab"
	var lb := Style.button("Laboratory", night, 15)
	lb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lb.pressed.connect(func(): action.emit("lab", null))
	bh.add_child(lb)
	if night:
		var eb := Style.button("End the night", false, 15)
		eb.pressed.connect(func(): action.emit("endlab", null))
		bh.add_child(eb)
	v.add_child(bh)
	return sec[0]


func _people_panel(p: Dictionary) -> PanelContainer:
	var S: Dictionary = g.S
	var sec := _section("Your people")
	var v: VBoxContainer = sec[1]
	var head := ""
	if my_turn:
		head = "Pick a meeple, then a location"
	elif S.phase == "day":
		head = "%s is choosing" % S.players[S.cur].name
	else:
		head = phase_name(S)
	v.add_child(Style.title(head, 18, Style.SPARK if my_turn else Style.PARCH))
	var row := HFlowContainer.new()
	row.add_theme_constant_override("h_separation", 6)
	var where := {"scientist": [], "assistant": []}
	for key in S.occ:
		if S.occ[key].p == 0:
			where[S.occ[key].kind].append(g.LOC[key.split(".")[0]].name)
	for s in p.labUsed:
		where[p.labUsed[s]].append(g.LABSPOT[s].name)
	for kind in ["scientist", "assistant"]:
		var totaln: int = g.sci_total(p) if kind == "scientist" else g.asst_total(p)
		var home: int = p.left[kind]
		totaln = maxi(totaln, home + where[kind].size())
		for k in totaln:
			var at_home := k < home
			var b := Button.new()
			b.custom_minimum_size = Vector2(72, 64)
			b.disabled = not (my_turn and at_home)
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var sel: bool = at_home and p.sel == kind
			b.add_theme_stylebox_override("normal", Style.box(Color("#1d2a36") if sel else Style.PANEL, Style.SPARK if sel else Style.LINE, 1, 2))
			b.add_theme_stylebox_override("disabled", Style.box(Style.PANEL if at_home else Color(0, 0, 0, 0), Style.LINE if at_home else Style.LINE2, 1, 2))
			var bv := Style.vbox(0)
			bv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bv.alignment = BoxContainer.ALIGNMENT_CENTER
			bv.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var fig := MeepleIcon.new()
			fig.kind = kind
			fig.color = Color(p.color) if at_home else Color(Style.PARCH, 0.25)
			fig.custom_minimum_size = Vector2(26, 30)
			fig.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			bv.add_child(fig)
			var txt: String = kind.capitalize() if at_home else (where[kind][k - home] if k - home < where[kind].size() else "Out")
			var l := Style.label(txt, 12, Style.PARCH if at_home else Style.MUTED, Style.display)
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.clip_text = true
			l.custom_minimum_size.x = 68
			bv.add_child(l)
			b.add_child(bv)
			var kk: String = kind
			b.pressed.connect(func(): kind_selected.emit(kk))
			row.add_child(b)
	v.add_child(row)
	return sec[0]


func _rivals_panel(S: Dictionary) -> PanelContainer:
	var sec := _section("Rivals")
	var v: VBoxContainer = sec[1]
	for i in range(1, S.players.size()):
		var p: Dictionary = S.players[i]
		var turn: bool = S.phase == "day" and S.cur == i
		var b := Button.new()
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_stylebox_override("normal", Style.box(Style.PANEL, Color(p.color) if turn else Style.LINE, 2 if turn else 1, 4))
		b.add_theme_stylebox_override("hover", Style.box(Color("#2e2735"), Color(p.color), 1, 4))
		var h := Style.hbox(8)
		h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		h.offset_left = 6
		h.offset_right = -6
		h.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var pic := Style.picture(Style.art("characters/character-%s.png" % p.char), Vector2(30, 42))
		h.add_child(pic)
		var nv := Style.vbox(0)
		nv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		nv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var nl := Style.title(p.name, 15, Color(p.color))
		nv.add_child(nl)
		var parts := "%d muscle · %d skin · %d alive · %d VP" % [g.on_table(p).size() - g.complete_count(p), g.complete_count(p) - g.alive_count(p), g.alive_count(p), p.vp]
		nv.add_child(Style.label(parts, 13, Style.PARCH_DIM))
		h.add_child(nv)
		var st := Style.vbox(0)
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for s in [["heart-broken" if p.hum < 0 else "heart", ("%+d" % p.hum) if p.hum else "0"], ["expertise", str(p.exp)], ["reputation", str(p.rep)]]:
			var sh := Style.hbox(2)
			sh.add_child(Style.icon(s[0], 14))
			sh.add_child(Style.label(s[1], 13, Style.PARCH))
			st.add_child(sh)
		h.add_child(st)
		b.add_child(h)
		b.custom_minimum_size.y = 56
		var ii := i
		b.pressed.connect(func(): action.emit("rival", ii))
		v.add_child(b)
	return sec[0]


func _log_panel(S: Dictionary) -> PanelContainer:
	var sec := _section("Chronicle")
	var v: VBoxContainer = sec[1]
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.add_theme_font_size_override("normal_font_size", 15)
	r.add_theme_font_size_override("bold_font_size", 15)
	r.add_theme_font_override("bold_font", Style.display)
	r.add_theme_color_override("default_color", Style.PARCH_DIM)
	var lines := []
	var logs: Array = S.log.duplicate()
	logs.reverse()
	for l in logs.slice(0, 60):
		if l.cls == "day":
			lines.append("[color=#8e8393][b]%s[/b][/color]" % l.t)
		else:
			lines.append(l.t)
	r.text = "\n".join(lines)
	v.add_child(r)
	return sec[0]
