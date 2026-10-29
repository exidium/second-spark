class_name Hud
extends Control
## Everything around the table, drawn over it instead of in a side column (D162):
## a thin top bar (day, today's note, the Captain's track, objectives, buttons), your people at the bottom left,
## a narrow rivals strip on the right (portrait with humanity, expertise and reputation on top),
## and the chronicle as a two-line bar along the bottom that opens upwards. Rebuilt on every sync.

signal kind_selected(kind: String)
signal action(name: String, arg)

const RIVAL_W := 96      # the rivals strip on the right; main.gd keeps the board left of it
const TOP_H := 46
const LOG_H := 52

const EXP_TIPS := {3: "Expertise 3: you can build arms.", 8: "Expertise 8: you can build the torso.", 10: "Expertise 10: one of your shock dice becomes a blue die (more eyes, fewer bolts).",
	14: "Expertise 14: you can build the head.", 20: "Expertise 20: two of your shock dice become blue.", 27: "Expertise 27: bonus objective, if it is in play this game. The first to reach it gains 10 VP."}
const REP_TIPS := {7: "Reputation 7: the Hospital lets you retrieve a cadaver for free. You hire a 3rd assistant.",
	15: "Reputation 15: an assistant is promoted to a 2nd scientist. At the Hospital you may take a 2nd cadaver for 1 franc.",
	23: "Reputation 23: bonus objective, if it is in play this game. The first to reach it gains 10 VP."}

var g: Game
var my_turn := false
var log_open := false
var top: PanelContainer
var rivals: PanelContainer
var log_bar: PanelContainer


func setup(game: Game) -> void:
	g = game
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	top = _strip()
	top.anchor_right = 1.0
	top.offset_bottom = TOP_H
	rivals = _strip()
	rivals.anchor_left = 1.0
	rivals.anchor_right = 1.0
	rivals.anchor_bottom = 1.0
	rivals.offset_left = -RIVAL_W
	rivals.offset_top = TOP_H
	log_bar = _strip()
	log_bar.anchor_top = 1.0
	log_bar.anchor_right = 1.0
	log_bar.anchor_bottom = 1.0
	log_bar.grow_vertical = Control.GROW_DIRECTION_BEGIN
	log_bar.offset_right = -RIVAL_W
	for c in [top, rivals, log_bar]:
		add_child(c)


func _strip(bg := Color(Style.PANEL, 0.94), pad := 6) -> PanelContainer:
	var pc := PanelContainer.new()
	pc.add_theme_stylebox_override("panel", Style.box(bg, Style.LINE, 1, pad))
	pc.mouse_filter = Control.MOUSE_FILTER_STOP
	return pc


func _clear(c: Control) -> void:
	for k in c.get_children():
		k.queue_free()


func refresh(turn_open: bool) -> void:
	my_turn = turn_open
	for c in [top, rivals, log_bar]:
		_clear(c)
	if g.S.is_empty():
		return
	var S: Dictionary = g.S
	var p: Dictionary = S.players[0]
	top.add_child(_top_bar(S, p))
	rivals.add_child(_rivals_strip(S))
	log_bar.add_child(_log(S))
	log_bar.offset_top = -(320 if log_open else LOG_H)


func _btn(text: String, act: String, primary := false) -> Button:
	var b := Style.button(text, primary, 14)
	b.pressed.connect(func(): action.emit(act, null))
	return b


func _top_bar(S: Dictionary, p: Dictionary) -> HBoxContainer:
	var h := Style.hbox(10)
	h.add_child(Style.title("Day %d" % S.round, 22))
	var ph := Style.label(phase_name(S), 15, Style.PARCH_DIM, Style.display)
	h.add_child(ph)
	# Today's card.
	if S.card != null:
		var name: String
		if S.card.t == "ev":
			name = g.EVENT[S.card.id].name
		else:
			var e: Dictionary = g.ENC[S.card.id]
			name = "Encounter: " + ("Captain Walton" if e.who == "captain" else "a stranger" if e.who == "woman" else "the Creature")
		var tb := Style.button(name, false, 14)
		tb.icon = Style.icon_tex("note")
		tb.expand_icon = true
		tb.add_theme_constant_override("icon_max_width", 18)
		tb.pressed.connect(func(): action.emit("today", null))
		h.add_child(tb)
	# Captain Walton's track.
	var ch := Style.hbox(2)
	ch.add_child(Style.label("Captain", 13, Style.MUTED, Style.display))
	for k in g.D.MAX_ROUNDS:
		var c := ColorRect.new()
		c.custom_minimum_size = Vector2(10, 12)
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		c.color = Style.CRIM if k < S.captain else (Style.PARCH if k == S.captain else Style.LINE2)
		c.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ch.add_child(c)
	ch.add_child(Style.label("☠", 14, Style.PARCH_DIM))
	h.add_child(ch)
	# Bonus objectives: small chips, claimed ones in the claimer's colour.
	for id in S.objectives:
		var claimed: bool = S.claimed.has(id)
		var col: Color = Color(S.players[S.claimed[id]].color) if claimed else Style.BRASS
		var pnl := Style.panel(Color(col, 0.22) if claimed else Color("#2c2433"), col, 4)
		var l := Style.label(g.OBJ[id].name, 13, Style.PARCH, Style.display)
		pnl.add_child(l)
		pnl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		h.add_child(pnl)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(sp)
	if S.phase == "lab":
		h.add_child(_btn("End the night", "endlab", true))
	h.add_child(_btn("Help", "help"))
	h.add_child(_btn("New game", "newgame"))
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


## Rivals: a narrow strip of portraits. The name sits on a dark fade at the top, humanity, expertise and
## reputation on a fade at the bottom; the rival whose turn it is gets a thick rim. Click for their laboratory.
func _fade(top_dark: bool) -> TextureRect:
	var gt := GradientTexture2D.new()
	var gr := Gradient.new()
	gr.set_color(0, Color(0, 0, 0, 0.5) if top_dark else Color(0, 0, 0, 0))
	gr.set_color(1, Color(0, 0, 0, 0) if top_dark else Color(0, 0, 0, 0.6))
	gt.gradient = gr
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(0, 1)
	gt.width = 4
	gt.height = 64
	var t := TextureRect.new()
	t.texture = gt
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_SCALE
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

func _rivals_strip(S: Dictionary) -> VBoxContainer:
	var v := Style.vbox(8)
	for i in S.players.size():
		var p: Dictionary = S.players[i]
		var turn: bool = (S.phase == "day" and S.cur == i) or (i == 0 and my_turn)
		var col := Color(p.color)
		var b := Button.new()
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.custom_minimum_size = Vector2(RIVAL_W - 14, 124)
		b.clip_contents = true
		b.add_theme_stylebox_override("normal", Style.box(Style.PANEL, col if turn else Color(col, 0.5), 3 if turn else 1, 0))
		b.add_theme_stylebox_override("hover", Style.box(Style.PANEL, col, 2, 0))
		b.add_theme_stylebox_override("pressed", Style.box(Style.PANEL, col, 2, 0))
		var pic := Style.picture(Style.art("characters/character-%s.png" % p.char), Vector2(10, 10))
		pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		b.add_child(pic)
		var top_fade := _fade(true)
		top_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		top_fade.anchor_bottom = 0.5
		b.add_child(top_fade)
		var bottom_fade := _fade(false)
		bottom_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bottom_fade.anchor_top = 0.55
		b.add_child(bottom_fade)
		var nl := Style.label(p.name.split(" ")[-1] if i > 0 else p.name, 14, Color.WHITE, Style.display)
		nl.clip_text = true
		nl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nl.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		nl.offset_top = 2
		nl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.6))
		nl.add_theme_constant_override("outline_size", 3)
		b.add_child(nl)
		var st := Style.hbox(2)
		st.alignment = BoxContainer.ALIGNMENT_CENTER
		st.mouse_filter = Control.MOUSE_FILTER_IGNORE
		st.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		st.offset_top = -36
		st.offset_bottom = -2
		for s in [["heart-broken" if p.hum < 0 else "heart", ("%+d" % p.hum) if p.hum else "0"], ["expertise", str(p.exp)], ["reputation", str(p.rep)]]:
			var sh := Style.vbox(0)
			sh.mouse_filter = Control.MOUSE_FILTER_IGNORE
			var ic := Style.icon(s[0], 15)
			ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			sh.add_child(ic)
			var n := Style.title(s[1], 13, Color.WHITE)
			n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			n.custom_minimum_size.x = 24
			n.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.7))
			n.add_theme_constant_override("outline_size", 3)
			sh.add_child(n)
			st.add_child(sh)
		b.add_child(st)
		var ii: int = i
		b.pressed.connect(func(): action.emit("rival" if ii > 0 else "character", ii))
		v.add_child(b)
		if i == 0:
			var sep := ColorRect.new()
			sep.color = Style.LINE2
			sep.custom_minimum_size = Vector2(0, 1)
			sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
			v.add_child(sep)
	return v


## The chronicle: the last two lines; the arrow opens the whole day's story upwards.
func _log(S: Dictionary) -> HBoxContainer:
	var h := Style.hbox(8)
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.scroll_active = log_open
	r.scroll_following = false
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.size_flags_vertical = Control.SIZE_EXPAND_FILL
	r.add_theme_font_size_override("normal_font_size", 15)
	r.add_theme_font_size_override("bold_font_size", 15)
	r.add_theme_font_override("bold_font", Style.display)
	r.add_theme_color_override("default_color", Style.PARCH_DIM)
	var lines := []
	var logs: Array = S.log.duplicate()
	logs.reverse()
	for l in logs.slice(0, 80 if log_open else 2):
		if l.cls == "day":
			lines.append("[color=#8e8393][b]%s[/b][/color]" % l.t)
		else:
			lines.append(l.t)
	r.text = "\n".join(lines)
	h.add_child(r)
	var t := Style.button("Less" if log_open else "Chronicle", false, 13)
	t.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	t.pressed.connect(func():
		log_open = not log_open
		refresh(my_turn))
	h.add_child(t)
	return h
