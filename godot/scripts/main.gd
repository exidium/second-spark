extends Node
## Second Spark in Godot. Boots the title screen, then runs a game: the rules (scripts/rules/game.gd) ask this
## node for every human decision and every animation; this node answers with the 3D board, the side panel and popups.

const SIDE_W := 452
const SHRINK := 2            # the 3D board renders at half resolution for the pixel look
const WHERE := {"preserve": "Use it: offered at the Market when you sell preserved flesh.", "steady": "Use it: at night, tick Steady Hands in your laboratory, then build.",
	"guest": "Use it: offered when you lecture at the Academy.", "daisy": "Use it: offered when you resolve a cadaver.", "dissect": "Use it: offered when you resolve a stage I or II cadaver.",
	"electro": "Use it: offered when you resolve a stage I to III cadaver (needs a charged jar).", "transfusion": "Use it: offered at Give Blood in your lab.",
	"unethical": "Use it: offered at the Dark Alley or when hiring a Cutthroat (needs a charged jar).", "counter": "Works by itself when a rival plays a humanity card on you.",
	"burial": "Use it: offered at the Public Square.", "animal": "Use it: offered when you lecture.", "human": "Use it: offered when you lecture.",
	"trap": "Use it: offered when the Creature visits you.", "mercy": "Use it: offered when an execution is announced.",
	"midnight": "Use it: press Play during your turn in the city phase.", "publish": "Use it: press Play during your turn, while your scientist is still at home."}

signal human_move(mv)
signal night_over

var data: Dictionary
var g: Game
var pace := 1.0
var ui: Control
var board_box: SubViewportContainer
var board_vp: SubViewport
var board: Board
var hud: Hud
var info: PanelContainer
var info_text: RichTextLabel
var toast_layer: Control
var title_screen: Control
var turn_open := false
var busy := false
var lab_modal: Modal = null
var lab_opts := {"steady": false, "surgeon": false}
var chosen_char := "random"
var move_toasts := {}
var shot_mode := false
var autoplay := false
var _auto_t := 0.0
var _auto_steps := 0


func _ready() -> void:
	randomize()
	Style.init()
	data = Game.load_data()
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.theme = Style.make_theme()
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(ui)
	var bg := TextureRect.new()
	bg.texture = Style.art("ui/bg-wall.png")
	bg.stretch_mode = TextureRect.STRETCH_TILE
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.modulate = Color(0.45, 0.42, 0.5)
	ui.add_child(bg)
	shot_mode = "--shot" in OS.get_cmdline_user_args()
	autoplay = "--autoplay" in OS.get_cmdline_user_args()
	if autoplay:
		Engine.time_scale = 12.0
		start_game("Auto", 3, "random", null)
		return
	if "--autostart" in OS.get_cmdline_user_args() or shot_mode:
		start_game("Dr Torres", 3, "surgeon", null)
	else:
		show_title()
		if "--shot-title" in OS.get_cmdline_user_args():
			await get_tree().create_timer(1.0).timeout
			await _save("res://../tests/godot-0-title.png")
			get_tree().quit()


# ================================================================ layout

func _build_game_layout() -> void:
	for c in ui.get_children():
		if c != ui.get_child(0):
			c.queue_free()
	board_box = SubViewportContainer.new()
	board_box.stretch = true
	board_box.stretch_shrink = SHRINK
	board_box.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	board_box.anchor_right = 1.0
	board_box.anchor_bottom = 1.0
	board_box.offset_right = -SIDE_W
	ui.add_child(board_box)
	board_vp = SubViewport.new()
	board_vp.physics_object_picking = true
	board_vp.msaa_3d = Viewport.MSAA_DISABLED
	board_vp.handle_input_locally = true
	board_box.add_child(board_vp)
	board = Board.new()
	board_vp.add_child(board)
	board.setup(g)
	board.place_clicked.connect(_on_place_clicked)
	board.slot_clicked.connect(_on_slot_clicked)
	board.meeple_clicked.connect(_on_kind_selected)
	board.hover_changed.connect(_on_hover)

	hud = Hud.new()
	hud.anchor_left = 1.0
	hud.anchor_right = 1.0
	hud.anchor_bottom = 1.0
	hud.offset_left = -SIDE_W
	ui.add_child(hud)
	hud.setup(g)
	hud.kind_selected.connect(_on_kind_selected)
	hud.action.connect(_on_hud_action)

	toast_layer = Control.new()
	toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_layer.anchor_right = 1.0
	toast_layer.anchor_bottom = 1.0
	toast_layer.offset_right = -SIDE_W
	ui.add_child(toast_layer)

	info = Style.panel(Color(Style.INK, 0.94), Style.LINE2, 10)
	info.position = Vector2(16, 16)
	info.custom_minimum_size.x = 360
	info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_text = Style.rich("", 16, 340)
	info_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info.add_child(info_text)
	info.visible = false
	toast_layer.add_child(info)
	var hint := Style.label("Right-drag turns the table. The wheel zooms.", 13, Color(Style.PARCH_DIM, 0.8))
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.position = Vector2(16, -26)
	toast_layer.add_child(hint)


func _on_hover(bb: String) -> void:
	info.visible = bb != ""
	info_text.text = bb
	info.reset_size()


# ================================================================ title screen

func show_title() -> void:
	g = null
	for c in ui.get_children():
		if c != ui.get_child(0):
			c.queue_free()
	title_screen = CenterContainer.new()
	title_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(title_screen)
	var v := Style.vbox(14)
	v.custom_minimum_size.x = 1100
	title_screen.add_child(v)
	var sub := Style.label("GALVANISM AND GRAVE-ROBBING IN 1819 PARIS, FOR ONE SCIENTIST AND UP TO THREE RIVALS", 14, Style.MUTED, Style.display)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(sub)
	var logo := Style.title("Second Spark", 88, Style.PARCH)
	logo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	logo.add_theme_color_override("font_outline_color", Color("#3a2618"))
	logo.add_theme_constant_override("outline_size", 10)
	v.add_child(logo)
	var setup := Style.hbox(10)
	setup.alignment = BoxContainer.ALIGNMENT_CENTER
	setup.add_child(Style.label("Your name", 16, Style.PARCH_DIM, Style.display))
	var nm := LineEdit.new()
	nm.text = "Dr Torres"
	nm.max_length = 28
	nm.custom_minimum_size.x = 220
	setup.add_child(nm)
	setup.add_child(Style.label("Rivals", 16, Style.PARCH_DIM, Style.display))
	var nr := OptionButton.new()
	for k in [1, 2, 3]:
		nr.add_item(["One rival", "Two rivals", "Three rivals"][k - 1], k)
	nr.select(2)
	setup.add_child(nr)
	var go := Style.button("Light the lamps", true, 18)
	go.custom_minimum_size = Vector2(200, 42)
	go.pressed.connect(func(): start_game(nm.text.strip_edges(), nr.get_selected_id(), chosen_char, null))
	setup.add_child(go)
	var saved = Game.load_saved()
	if saved != null:
		var cont := Style.button("Continue Day %d" % saved.round, false, 18)
		cont.custom_minimum_size.y = 42
		cont.pressed.connect(func(): start_game("", 0, "", saved))
		setup.add_child(cont)
	var help := Style.button("How to play", false, 16)
	help.pressed.connect(show_rules)
	setup.add_child(help)
	v.add_child(setup)
	var pick := Style.label("CHOOSE YOUR SCIENTIST", 14, Style.MUTED, Style.display)
	pick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(pick)
	var grid := HFlowContainer.new()
	grid.alignment = FlowContainer.ALIGNMENT_CENTER
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	v.add_child(grid)
	var cards := []
	for c in data.CHARACTERS + [{"id": "random", "name": "Random scientist", "role": "Fate decides", "text": "You are dealt one of the six at random. Your rivals always get random ones."}]:
		var b := Button.new()
		b.custom_minimum_size = Vector2(146, 330)
		b.toggle_mode = true
		b.button_pressed = c.id == chosen_char
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.add_theme_stylebox_override("normal", Style.box(Style.PAPER, Color("#5a4630"), 2, 0))
		b.add_theme_stylebox_override("hover", Style.box(Style.PAPER, Style.PARCH, 2, 0))
		b.add_theme_stylebox_override("pressed", Style.box(Style.PAPER, Style.SPARK, 4, 0))
		var bv := Style.vbox(4)
		bv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bv.offset_left = 6
		bv.offset_right = -6
		bv.offset_top = 6
		bv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tex: Texture2D = Style.art("characters/character-%s.png" % c.id) if c.id != "random" else Style.art("frames/card-tall-back.png")
		bv.add_child(Style.picture(tex, Vector2(134, 180)))
		var n := Style.label(c.name, 15, Style.PAPER_INK, Style.display)
		n.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		n.custom_minimum_size.x = 134
		bv.add_child(n)
		bv.add_child(Style.label(c.role.to_upper(), 11, Color(Style.PAPER_INK, 0.6), Style.display))
		var t := Style.wrap(c.text, 13, Style.PAPER_INK, 134)
		bv.add_child(t)
		b.add_child(bv)
		var id: String = c.id
		b.pressed.connect(func():
			chosen_char = id
			for o in cards:
				o.button_pressed = o == b)
		cards.append(b)
		grid.add_child(b)


func show_rules() -> void:
	var bb := """[b]The goal[/b]
Build all six parts of a companion (head, torso, two arms, two legs) and bring each to life. The game ends at the end of a night when someone’s companion is fully alive, or when Captain Walton reaches the end of his track (after Day 12, sooner if people help him). Most points wins.

[b]Each day[/b]
• Event phase: an event changes the rules for the day, or an encounter visits someone. Some encounters hide on a space and trigger on the first rival who goes there.
• City phase: take turns placing your scientist and assistants one at a time. Each space holds one meeple. To use a taken space, bump it: pay the next bump-track cost to its owner, and their meeple is out for the day. You can’t bump the First Player space.
• Lab phase: build parts, throw the switch once, and preserve flesh.
• Dawn: materials age, the Hospital, Docks, Academy and Saint-Roch get fresh cards, and the Captain moves 1 step.

[b]Scientists and assistants[/b]
• You start with 1 scientist and 2 assistants. Reputation 7 hires a 3rd assistant. Reputation 15 promotes one to a 2nd scientist.
• Scientist only: Hospital work and volunteering, advanced research, donating, the Dark Alley, Practice and Repair. A scientist also lectures for 1 more reputation, gains humanity at Saint-Roch, and charges 3 jars instead of 2.

[b]Cadavers and materials[/b]
• Cadaver cards give materials or expertise, your choice per card. Some cost humanity.
• Materials have a stage from I (fresh) to IV. Each dawn they age. Stage IV rots away, blood rots after stage II. Ice stops decay for 2 dawns. Bone never rots.
• Animal (Slaughterhouse, Dog Catchers) stands in for other materials but costs VP.

[b]Building and the switch[/b]
• Each part is built in two steps: start it as muscle, then add skin. Each step needs expertise and materials, gives VP (fresher is better) and +1 expertise.
• Throw the switch once a night with 1 to 3 charged jars, 2 dice each. Eye: a complete part comes alive. Bolt: damage (2 on one part downgrades it). Broken heart: -1 humanity.
• After rolling, research cards can be spent to ignore or re-roll dice.

[b]Police[/b]
Each murder in the Dark Alley gives a police marker. At 2, the Dark Alley is closed to you. Pay 3 francs any time to clear them.

[b]Final score[/b]
• VP from building, plus alive parts (head 6, torso 5, arms and legs 3 each).
• 10 VP per bonus objective claimed.
• Half your highest reputation, a third of your highest expertise, and your humanity (plus or minus).
• If the Captain ends the game, the kindest scientist (highest positive humanity) gains 5 VP."""
	var m := Modal.open(ui, {"title": "How to play", "text": bb, "width": 760, "buttons": [{"label": "Close", "primary": true, "value": 1}]})
	await m.done


# ================================================================ a game

func start_game(name: String, n: int, char_id: String, saved) -> void:
	g = Game.new(data, self)
	g.no_save = autoplay or shot_mode
	if saved != null:
		g.S = saved
	else:
		g.new_game(name, n, char_id, {})
	_build_game_layout()
	sync()
	if shot_mode:
		_screenshot_run()
	await g.run()
	if g != null and g.S.get("phase") == "end":
		show_end()


func _on_hud_action(a: String, arg) -> void:
	match a:
		"lab": open_lab()
		"endlab": _end_night_request()
		"hand": open_hand()
		"character": open_character()
		"rival": open_rival(arg)
		"today": open_today()
		"help": show_rules()
		"newgame":
			var m := Modal.open(ui, {"title": "Abandon this game?", "text": "Your laboratory and your creation will be lost.",
				"buttons": [{"label": "Keep playing", "value": false}, {"label": "Abandon", "primary": true, "value": true}]})
			if await m.done:
				g.token += 1
				if FileAccess.file_exists(Game.SAVE_PATH):
					DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.SAVE_PATH))
				show_title()


# ================================================================ presenter: drawing and pacing

var _last_phase := ""

func sync() -> void:
	if g == null or g.S.is_empty() or hud == null:
		return
	if autoplay and _last_phase != "%d %s" % [g.S.round, g.S.phase]:
		_last_phase = "%d %s" % [g.S.round, g.S.phase]
		print("AUTOPLAY ", _last_phase, " steps=", _auto_steps)
	hud.refresh(turn_open)
	board.sync()
	if g.S.phase != "day":
		clear_move_toasts()
	if lab_modal != null and is_instance_valid(lab_modal):
		_refresh_lab()

func sleep(ms: float) -> void:
	await get_tree().create_timer(ms / 1000.0 * pace).timeout

func toast(text: String) -> void:
	var t := _toast_panel("[center]%s[/center]" % text, Style.BRASS)
	toast_layer.add_child(t)
	await get_tree().process_frame
	t.position = Vector2((toast_layer.size.x - t.size.x) / 2, toast_layer.size.y - t.size.y - 70)
	var tw := t.create_tween()
	tw.tween_interval(3.5)
	tw.tween_property(t, "modulate:a", 0.0, 0.8)
	tw.tween_callback(t.queue_free)

func _toast_panel(bb: String, rim: Color) -> PanelContainer:
	var p := PanelContainer.new()
	var sb := Style.box(Color(0.055, 0.043, 0.063, 0.96), rim, 1, 10)
	sb.border_width_left = 5
	p.add_theme_stylebox_override("panel", sb)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var r := Style.rich(bb, 17)
	r.autowrap_mode = TextServer.AUTOWRAP_OFF
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(r)
	return p

## Your turn: rises from the bottom middle of the map, then fades out over about 3 seconds.
func your_turn_toast() -> void:
	var t := _toast_panel("[b][color=#9fd0ff]Your turn[/color][/b], pick a meeple, then a location.", Style.SPARK)
	toast_layer.add_child(t)
	await get_tree().process_frame
	var target := Vector2((toast_layer.size.x - t.size.x) / 2, toast_layer.size.y - t.size.y - 44)
	t.position = target + Vector2(0, 20)
	t.modulate.a = 0.0
	var tw := t.create_tween()
	tw.set_parallel(true)
	tw.tween_property(t, "modulate:a", 1.0, 0.25)
	tw.tween_property(t, "position", target, 0.25).set_ease(Tween.EASE_OUT)
	tw.chain().tween_interval(0.4)
	tw.chain().tween_property(t, "modulate:a", 0.0, 2.6)
	tw.chain().tween_callback(t.queue_free)

func _where(key: String) -> String:
	if key.begins_with("lab."):
		return "their laboratory"
	var n: String = g.LOC[g.SPACE[key].loc].name
	return n if n == "Saint-Roch" else "the " + n

const BODY_VERB := {"cemetery.dig": "dig up", "morgue.buy": "buy", "square.buy": "buy", "hospital.retrieve": "retrieve"}

## A rival's move: "Name sends an assistant to <action>, at <place>." just above the place, until you move.
func rival_moved(i: int, key: String, kind: String, lines: Array) -> void:
	var p: Dictionary = g.S.players[i]
	var who := "their scientist" if kind == "scientist" else "an assistant"
	var act := _move_action(key, lines)
	var bb := "[b][color=#%s]%s[/color][/b] sends %s to %s, at %s." % [Color(p.color).to_html(false), p.name, who, act, _where(key)]
	if move_toasts.has(i) and is_instance_valid(move_toasts[i]):
		move_toasts[i].queue_free()
	var t := _toast_panel(bb, Color(p.color))
	toast_layer.add_child(t)
	move_toasts[i] = t
	await get_tree().process_frame
	var at: Vector2 = board.key_screen_pos(i, key) * SHRINK
	var pos := at - Vector2(t.size.x / 2, t.size.y + 12)
	pos.x = clampf(pos.x, 8, toast_layer.size.x - t.size.x - 8)
	pos.y = clampf(pos.y, 8, toast_layer.size.y - t.size.y - 8)
	t.position = pos + Vector2(0, 10)
	t.modulate.a = 0
	var tw := t.create_tween().set_parallel(true)
	tw.tween_property(t, "modulate:a", 1.0, 0.2)
	tw.tween_property(t, "position", pos, 0.25)

func _move_action(key: String, lines: Array) -> String:
	# The action, in the infinitive, from the chronicle line of that move.
	var line := ""
	for l in lines:
		if not l.begins_with("Day "):
			line = l
	var plain := line
	var re := RegEx.new()
	re.compile("\\[/?[a-z]+(=[^\\]]*)?\\]")
	plain = re.sub(plain, "", true)
	match key:
		"academy.adv": return "do advanced research"
		"academy.research": return "research"
		"church.atone": return "atone"
		"docks.hire":
			var r2 := RegEx.new()
			r2.compile("hires an? ([A-Z][A-Za-z ]+?)(:|,| for| and|\\.)")
			var m := r2.search(plain)
			return ("hire a " + m.get_string(1)) if m else "hire a scoundrel"
	if BODY_VERB.has(key):
		var n := 0
		for l in lines:
			if " takes " in l or " dissects " in l or " studies " in l:
				n += 1
		return "%s %d cadaver%s" % [BODY_VERB[key], maxi(n, 1), "" if n == 1 else "s"]
	var sp_name: String = (g.LABSPOT[key.substr(4)].name if key.begins_with("lab.") else g.SPACE[key].n).split(" (")[0]
	return sp_name.substr(0, 1).to_lower() + sp_name.substr(1)

func clear_move_toasts() -> void:
	for i in move_toasts:
		if is_instance_valid(move_toasts[i]):
			move_toasts[i].queue_free()
	move_toasts.clear()

func placed(i: int, key: String, kind: String, _bumped) -> void:
	hud.refresh(turn_open)
	await board.animate_place(i, key, kind)


# ================================================================ presenter: simple questions

func ask(spec: Dictionary):
	var s := spec.duplicate()
	if spec.get("encounter") != null:
		s.content = Cards.encounter_card(g, spec.encounter, 480)
		s.width = 540
	var m := Modal.open(ui, s)
	return await m.done

func ask_yn(title: String, text: String, yes: String, no: String) -> bool:
	var m := Modal.open(ui, {"title": title, "text": text, "locked": true, "buttons": [{"label": no, "value": false}, {"label": yes, "primary": true, "value": true}]})
	return bool(await m.done)

func show_event(e: Dictionary) -> void:
	if shot_mode:
		return
	var m := Modal.open(ui, {"title": "Day %d" % g.S.round, "content": Cards.event_card(g, e, 480), "width": 540, "locked": true,
		"buttons": [{"label": "Begin the day", "primary": true, "value": 1}]})
	await m.done

func show_secret_encounter(e: Dictionary, mine: bool) -> void:
	var sp: Dictionary = g.SPACE[e.loc]
	if mine:
		var m := Modal.open(ui, {"title": "A secret encounter", "text": "You hold this card. The first rival to use [b]%s: %s[/b] today will trigger it." % [g.LOC[sp.loc].name, sp.n],
			"content": Cards.encounter_card(g, e, 480), "width": 540, "locked": true, "buttons": [{"label": "Keep it secret", "primary": true, "value": 1}]})
		await m.done
	else:
		var m := Modal.open(ui, {"title": "An encounter card", "text": "%s holds a secret encounter. Whoever (other than them) first visits a certain place today will meet it." % g.S.players[g.S.first].name,
			"locked": true, "buttons": [{"label": "Continue", "primary": true, "value": 1}]})
		await m.done

func dawn_report(round: int, lines: Array, footer: String) -> void:
	var bb := "\n".join(lines.map(func(l): return "• " + l)) + "\n\n[color=#b9ac93]%s[/color]" % footer
	var m := Modal.open(ui, {"title": "Dawn of Day %d" % round, "text": bb, "locked": true, "buttons": [{"label": "Begin Day %d" % round, "primary": true, "value": 1}]})
	await m.done


# ================================================================ your turn

func _legal(key: String, _kind: String) -> bool:
	if not turn_open or busy:
		return false
	if g.S.get("blocked") != null and g.SPACE.has(key) and g.SPACE[key].loc == g.S.blocked:
		return false
	return g.can_place(0, key)

func human_turn():
	var p: Dictionary = g.S.players[0]
	if not p.left[p.sel]:
		p.sel = "assistant" if p.left.assistant else "scientist"
	turn_open = true
	board.set_interactive(true, p.sel, _legal)
	hud.refresh(true)
	your_turn_toast()
	var mv = await human_move
	turn_open = false
	board.set_interactive(false, p.sel, _legal)
	clear_move_toasts()
	hud.refresh(false)
	return mv

func _on_kind_selected(kind: String) -> void:
	if g == null or not turn_open:
		return
	var p: Dictionary = g.S.players[0]
	if p.left[kind]:
		p.sel = kind
		board.set_interactive(true, kind, _legal)
		hud.refresh(true)

func _on_slot_clicked(key: String) -> void:
	if key.begins_with("lab.") or not turn_open:
		if not turn_open:
			_on_place_clicked(g.SPACE[key].loc if g.SPACE.has(key) else "lab")
			return
	await _choose_space(key, null)

## Sends your selected meeple (or the other kind, when only that one may go) to a space, after its choices.
func _choose_space(key: String, pre) -> void:
	if busy or not turn_open or not _legal(key, ""):
		return
	var p: Dictionary = g.S.players[0]
	var kind = g.kind_for(0, key)
	if kind == null:
		return
	busy = true
	if kind != p.sel:
		toast("Sending your %s: your %s can’t go there." % [kind, p.sel])
	if not key.begins_with("lab."):
		var b = g.bump_info(0, key)
		if b != null and b.bump:
			var o: Dictionary = g.S.occ[key]
			var cost_txt: String = " for free (they go home)" if b.get("free", false) else (" and pay them [b]%s[/b]" % Style.fr(b.cost) if b.cost else " (free, it’s your own)")
			var ok := await ask_yn("Bump?", "%s’s %s is already there. Bump them%s? Their meeple %s." % [g.S.players[o.p].name, o.kind, cost_txt, "returns to them" if b.get("free", false) else "goes to the bump track and is out for the day"], "Bump", "Cancel")
			if not ok:
				busy = false
				return
	if pre == null:
		pre = await human_pre(key, kind, false)
	busy = false
	if pre == null:
		return
	human_move.emit({"key": key, "kind": kind, "pre": pre})


# ---------------------------------------------------------------- gain lines for options

func _ic(name: String, n = null, neg := false) -> String:
	var s := "[img=20x20]res://assets/art/icons/icon-%s.png[/img]" % name
	if n == null:
		return s
	return "[b]%s%s[/b]%s" % ["-" if neg else "", str(n), s]

func _cube(t: String, n: int, stage := 0) -> String:
	return "[color=#%s]■[/color] [b]%d[/b] %s%s" % [Style.MAT_COL[t].to_html(false), n, t, (" " + Style.roman(stage)) if stage else ""]

func space_gain(key: String, kind: String) -> String:
	var p: Dictionary = g.S.players[0]
	var sci := kind == "scientist"
	var ev = g.S.ev
	match key:
		"square.buy": return _ic("coin", 1, true) + "  one body shown below"
		"slaughter.take": return _cube("animal", 4, 2) + "  or  " + _cube("animal", 3, 1) + (("  · plus " + _cube("animal", 2) + " " + _ic("coin", 1)) if ev == "meat" else "")
		"hospital.retrieve":
			var l := g.hosp_limits(p)
			if l.free:
				return "Free · take 1 body below" + (("  · up to %d more at " % l.paid + _ic("coin", 1) + " each") if l.paid else "")
			return (_ic("coin", 1, true) + " bribe · take 1 body below") if ev == "corrupt" else ("Needs " + _ic("reputation", 7))
		"hospital.work": return "Closed today" if ev == "hardtimes" else _ic("coin", (4 if p.exp >= 13 else 3 if p.exp >= 7 else 2) + (2 if ev == "cholera" else 0))
		"hospital.volunteer": return _ic("heart", 1) + "  " + _ic("reputation", 2)
		"academy.adv": return _ic("expertise", 1) + "  · 1 research card" + (("  " + _ic("coin", 2)) if ev == "grant" else "")
		"academy.research": return "1 research card" + (("  " + _ic("coin", 2)) if ev == "grant" else "")
		"academy.lecture": return ("" if ev == "hardtimes" else _ic("coin", 1) + "  ") + _ic("reputation", 2 if sci else 1) + ("" if sci else "  (scientist: +2)") + (("  " + _ic("coin", 2)) if ev == "grant" else "")
		"academy.donate": return "Pay 1 to 3 " + _ic("coin") + " · +1 " + _ic("reputation") + " per franc"
		"alley.murder": return _cube("muscle", 4, 1) + "  " + _cube("organ", 4, 1) + "  " + _cube("blood", 3, 1) + "  " + _cube("bone", 2) + "  " + _ic("heart-broken", 3, true) + "  " + _ic("police", 1)
		"church.atone": return "1 humanity card" + (("  " + _ic("heart", 1)) if sci else "  (scientist: +1 humanity)")
		"first.first": return "Can’t be bumped. At the end of the day you may move it to another space."
		"odeon.show": return _ic("reputation", 2)
		"lab.practice": return _ic("expertise", 1)
		"lab.blood": return _cube("blood", 3, 1)
		"lab.repair": return "Remove up to 3 damage"
		"lab.charge": return "Charge " + _ic("jar", 3 if sci else 2) + ("" if sci else "  (scientist: 3)")
		"cemetery.dig": return "Draw %d cadavers, resolve any" % (3 + (1 if ev == "cholera" else 0))
		"morgue.buy": return _ic("coin", 1, true) + "  draw %d cadavers, resolve any" % (2 + (1 if ev == "cholera" else 0))
		"market.trade": return "Sell bone and preserved flesh, buy jars and ice"
		"docks.hire": return "Hire one of the scoundrels"
	return ""

func _occupant(key: String) -> String:
	if not g.S.occ.has(key):
		return ""
	var o: Dictionary = g.S.occ[key]
	var b = g.bump_info(0, key) if turn_open else null
	var t := "%s’s %s" % [g.S.players[o.p].name, o.kind]
	if b != null and b.bump:
		t += " · bump free" if b.get("free", false) else (" · bump %s" % Style.fr(b.cost) if b.cost else " · bump")
	return t


# ---------------------------------------------------------------- place popups

func _on_place_clicked(id: String) -> void:
	if g == null or busy or Modal_open():
		return
	if id == "lab":
		await _lab_place_popup()
		return
	var L: Dictionary = g.LOC[id]
	var p: Dictionary = g.S.players[0]
	var closed: bool = g.S.closed.has(id)
	var notes := ""
	if closed:
		notes = "[color=#d6675f][b]Closed today.[/b][/color]"
	elif not turn_open:
		notes = "[color=#b9ac93]Not your move right now. You can look, not act.[/color]"
	var content := Style.vbox(10)
	var opts := []
	var picked := {"key": null, "pre": null}
	var m: Modal
	# Places whose cards are the choice: pick the card right here.
	var rows := {"academy": "researchRow", "church": "humanityRow", "docks": "docks", "hospital": "hosp", "square": "square"}
	if id in ["church", "docks"]:
		var key: String = id + "." + L.spaces[0].k
		var can := _legal(key, "")
		var items := []
		for c in g.S[rows[id]]:
			var acts := []
			if id == "church":
				var b := Style.button("Take this", true, 15)
				b.disabled = not can
				var cid = c.uid
				b.pressed.connect(func():
					picked.key = key
					picked.pre = {"card": cid}
					_close_from(b, 1))
				acts.append(b)
			else:
				for a in _scoundrel_actions(p, c, can):
					var b := Style.button(a.label, a.primary, 14)
					b.disabled = not a.ok
					var pv = a.value
					b.pressed.connect(func():
						picked.key = key
						picked.pre = pv
						_close_from(b, 1))
					acts.append(b)
			items.append(Modal.card_with_actions(Cards.face(g, c, 0.9), acts))
		var sub := "Take a humanity card" + ("  " + _ic("heart", 1) if g.kind_for(0, key) == "scientist" else "") if id == "church" else "Hire one of the scoundrels"
		content.add_child(Style.rich("[b]%s[/b]" % sub, 18))
		if _occupant(key) != "":
			content.add_child(Style.rich("[color=#b9ac93]%s[/color]" % _occupant(key), 15))
		if items.size():
			content.add_child(Modal.card_row(items))
		else:
			content.add_child(Style.label("None left today.", 16, Style.MUTED))
	elif id == "market":
		var key := "market.trade"
		var o := {"jars": 0, "ice": false, "sellBone": 0, "sellPres": 0, "pickle": false}
		content.add_child(Style.rich("[b]Do as many trades as you like[/b]", 18))
		var mb := _market_body(p, o)
		content.add_child(mb)
		var go := Style.button("Trade", true, 17)
		go.disabled = not _legal(key, "")
		go.pressed.connect(func():
			picked.key = key
			picked.pre = o
			_close_from(go, 1))
		content.add_child(go)
	else:
		for sp in L.spaces:
			var key: String = id + "." + sp.k
			var kind = g.kind_for(0, key)
			var who := _occupant(key)
			var gain := space_gain(key, kind if kind != null else p.sel)
			var lead = Color(g.S.players[g.S.occ[key].p].color) if g.S.occ.has(key) else null
			if id == "slaughter":
				for op in [["four", "Take 4 animal at stage II"], ["three", "Take 3 animal at stage I"]]:
					opts.append({"label": op[1], "sub": ("Glut of Meat: +2 animal and +1 franc. " if g.S.ev == "meat" else "") + who, "value": {"key": key, "pre": {"opt": op[0]}}, "disabled": not _legal(key, ""), "lead": lead})
			else:
				opts.append({"label": sp.n, "tag": "SCIENTIST" if sp.get("sci", 0) else "", "sub": gain + (("\n" + who) if who != "" else ""), "value": {"key": key, "pre": null}, "disabled": not _legal(key, ""), "lead": lead})
		if rows.has(id) and id not in ["church", "docks"]:
			var cards: Array = g.S[rows[id]]
			var label: String = {"hospital": "Bodies waiting today", "academy": "Research on offer", "square": "Bodies on display"}[id]
			content.add_child(Style.label(label.to_upper(), 13, Style.MUTED, Style.display))
			if cards.size():
				content.add_child(Modal.card_row(cards.map(func(c): return Cards.face(g, c, 0.85))))
			else:
				content.add_child(Style.label("None left today.", 16, Style.MUTED))
	m = Modal.open(ui, {"hero": Style.art("locations/location-%s.png" % id), "hero_title": L.name, "hero_text": L.text,
		"text": notes, "content": content, "options": opts, "width": 760 if id in ["church", "docks", "academy", "hospital", "square"] else 620,
		"buttons": [{"label": "Close", "value": null}]})
	var v = await m.done
	if v is Dictionary:
		await _choose_space(v.key, v.pre)
	elif picked.key != null:
		await _choose_space(picked.key, picked.pre)

## Closes the popup that holds this node (lambdas capture locals by value, so they can't hold the popup itself).
func _close_from(n: Node, v) -> void:
	while n != null and not (n is Modal):
		n = n.get_parent()
	if n != null:
		n.close(v)

func Modal_open() -> bool:
	for c in ui.get_children():
		if c is Modal:
			return true
	return false

func _lab_place_popup() -> void:
	var p: Dictionary = g.S.players[0]
	var opts := []
	for L in data.LABSPOTS:
		var key: String = "lab." + L.id
		var kind = g.kind_for(0, key)
		var used: bool = p.labUsed.has(L.id)
		opts.append({"label": L.name, "tag": "SCIENTIST" if L.get("sci", 0) else "", "sub": space_gain(key, kind if kind != null else p.sel) + ("  · Used today" if used else ""),
			"value": key, "disabled": not _legal(key, ""), "lead": Color(p.color) if used else null})
	var m := Modal.open(ui, {"hero": Style.art("locations/location-lab.png"), "hero_title": "Your laboratory", "hero_text": "Four spaces of your own. Each can be used once a day.",
		"text": "" if turn_open else "[color=#b9ac93]Not your move right now. You can look, not act.[/color]", "options": opts, "width": 620, "buttons": [{"label": "Close", "value": null}]})
	var k = await m.done
	if k != null:
		await _choose_space(k, null)


# ---------------------------------------------------------------- choices made on a space (humanPre)

func human_pre(key: String, kind: String, no_cancel: bool):
	var p: Dictionary = g.S.players[0]
	var cancel := [] if no_cancel else [{"label": "Cancel", "value": null}]
	match key:
		"square.buy":
			var bury := g.has_card(p, "burial")
			return await _card_choice("Public Square", "The crowd has gone home. 1 franc buys one body.", g.S.square, cancel, func(c):
				var a := [{"label": "Buy this one", "value": {"card": c.id}, "primary": true}]
				if bury:
					a.append({"label": "Bury it (A Decent Burial)", "value": {"card": c.id, "bury": true}})
				return a)
		"slaughter.take":
			return await ask({"title": "Slaughterhouse", "text": "Animal stands in for muscle, organ or (at stage I or II) blood. Each part built with it scores 1 VP less, 2 less if you use 3 or more.",
				"options": [{"label": "4 animal at stage II", "value": {"opt": "four"}}, {"label": "3 animal at stage I", "value": {"opt": "three"}}], "buttons": cancel})
		"hospital.retrieve":
			return await _hospital_choice(p, no_cancel)
		"academy.adv", "academy.research":
			if g.S.researchRow.is_empty():
				return {}
			return await _card_choice("Advanced research" if key == "academy.adv" else "Research", "+1 expertise and choose a research card." if key == "academy.adv" else "Choose a research card.",
				g.S.researchRow, cancel, func(c): return [{"label": "Take this", "value": {"card": c.uid}, "primary": true}])
		"academy.lecture":
			var alt: Array = p.hand.filter(func(h): return h.id in ["guest", "animal", "human"])
			if alt.is_empty():
				return {}
			var opts := [{"label": "Lecture as usual", "sub": "+%s and +%d reputation." % [Style.fr(0 if g.S.ev == "hardtimes" else 1), 2 if kind == "scientist" else 1], "value": {}}]
			for c in alt:
				opts.append({"label": "Use card “%s”" % c.name, "icon": "cards", "sub": c.text + " " + g.gain_text(c.gain), "value": {"card": c.id}})
			return await ask({"title": "Lecture", "options": opts, "buttons": cancel})
		"academy.donate":
			var opts := []
			for n in [1, 2, 3]:
				opts.append({"label": "Donate %s" % Style.fr(n), "sub": "+%d reputation" % n, "value": {"n": n}, "disabled": p.coin < n})
			return await ask({"title": "Donate", "text": "1 reputation per franc, up to 3.", "options": opts, "buttons": cancel})
		"market.trade":
			var o := {"jars": 0, "ice": false, "sellBone": 0, "sellPres": 0, "pickle": false}
			var m := Modal.open(ui, {"title": "Market", "text": "Les Halles. Do as many trades as you like.", "content": _market_body(p, o), "locked": no_cancel,
				"buttons": [{"label": "Skip" if no_cancel else "Cancel", "value": {} if no_cancel else null}, {"label": "Trade", "primary": true, "value": "go"}]})
			var v = await m.done
			return o if v is String else v
		"docks.hire":
			return await choose_scoundrel(p, g.S.docks, "Three scoundrels lean on the bollards.", not no_cancel)
		"alley.murder":
			var un: bool = g.has_card(p, "unethical") and g.charged(p) > 0
			var opts := [{"label": "Do it", "sub": _ic("heart-broken", 3, true) + "  " + _ic("police", 1), "value": {}}]
			if un:
				opts.append({"label": "Use card “Unethical Experiment”", "icon": "cards", "sub": "Spend " + _ic("jar", 1) + " · " + _ic("expertise", 5) + "  " + _ic("heart-broken", 1, true) + " · no materials", "value": {"unethical": true}})
			return await ask({"title": "Dark Alley", "text": "Murder someone for %s.\nCosts 3 humanity and earns a police marker. At 2 markers the Dark Alley is closed to you until you pay 3 francs." % g.mats_text([["muscle", 1, 4], ["organ", 1, 4], ["blood", 1, 3], ["bone", 0, 2]]),
				"options": opts, "buttons": cancel})
		"church.atone":
			if g.S.humanityRow.is_empty():
				return {}
			return await _card_choice("Saint-Roch", "Choose a humanity card." + (" Your scientist also gains 1 humanity." if kind == "scientist" else " (A scientist would also gain 1 humanity.)"),
				g.S.humanityRow, cancel, func(c): return [{"label": "Take this", "value": {"card": c.uid}, "primary": true}])
		"lab.blood":
			if not g.has_card(p, "transfusion"):
				return {}
			return await ask({"title": "Give Blood", "options": [{"label": "Give blood", "sub": _cube("blood", 3, 1), "value": {}},
				{"label": "Use card “Transfusion”", "icon": "cards", "sub": _ic("expertise", 3) + "  " + _ic("reputation", 1) + "  " + _ic("coin", 1), "value": {"transfusion": true}}], "buttons": cancel})
	return {}

## A row of cards, each with its own buttons; returns the value of the button pressed, or null.
func _card_choice(title: String, text: String, cards: Array, buttons: Array, acts_for: Callable):
	var m: Modal
	var items := []
	for c in cards:
		var acts := []
		for a in acts_for.call(c):
			var b := Style.button(a.label, a.get("primary", false), 15)
			b.disabled = not a.get("ok", true)
			var v = a.value
			b.pressed.connect(func(): _close_from(b, v))
			acts.append(b)
		items.append(Modal.card_with_actions(Cards.face(g, c, 0.9), acts))
	m = Modal.open(ui, {"title": title, "text": "[color=#b9ac93]%s[/color]" % text, "content": Modal.card_row(items), "width": 760, "buttons": buttons, "locked": buttons.is_empty()})
	return await m.done

func _scoundrel_actions(p: Dictionary, c: Dictionary, can: bool) -> Array:
	var ok: bool = can and g.sc_cost(c) <= p.coin and g.sc_allowed(c)
	if c.sk == "thief":
		return [{"label": "Draw %d from the Hospital" % c.draw, "value": {"card": c.id, "how": "mats"}, "primary": true, "ok": ok}]
	var a := [{"label": "Materials", "value": {"card": c.id, "how": "mats"}, "primary": true, "ok": ok}]
	if c.get("exp", 0):
		a.append({"label": "+%d expertise%s" % [c.exp, " (-1 humanity)" if c.get("expH", 0) else ""], "value": {"card": c.id, "how": "exp"}, "ok": ok})
	if c.get("hum", 0):
		a.append({"label": "+%d humanity" % c.hum, "value": {"card": c.id, "how": "hum"}, "ok": ok})
	if c.sk == "cut" and g.has_card(p, "unethical") and g.charged(p) > 0:
		a.append({"label": "Use card “Unethical Experiment”", "value": {"card": c.id, "how": "exp", "unethical": true}, "ok": ok})
	return a

func choose_scoundrel(p: Dictionary, row: Array, intro: String, can_cancel: bool):
	return await _card_choice("Docks", intro, row, [{"label": "Cancel", "value": null}] if can_cancel else [], func(c): return _scoundrel_actions(p, c, true))

func _hospital_choice(p: Dictionary, no_cancel: bool):
	var lim := g.hosp_limits(p)
	var mx: int = mini(g.S.hosp.size(), lim.free + lim.paid)
	var chosen := []
	var m: Modal
	var content := Style.vbox(10)
	var intro := "The porter lifts the sheets. " + ("Your reputation lets you take 1 for free." if lim.free else "Your reputation is below 7: bribing the porter costs 1 franc.")
	if lim.paid:
		intro += " You may take %d more for 1 franc each." % lim.paid
	content.add_child(Style.wrap(intro, 16, Style.PARCH_DIM, 700))
	var row := HFlowContainer.new()
	row.alignment = FlowContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("h_separation", 14)
	content.add_child(row)
	var cost_l := Style.label("", 17, Style.PARCH, Style.display)
	cost_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content.add_child(cost_l)
	var go := Style.button("Retrieve", true, 17)
	var toggles := []
	var refresh := func():
		var cost: int = maxi(0, chosen.size() - lim.free)
		cost_l.text = "Cost: " + Style.fr(cost)
		go.text = "Retrieve %d" % chosen.size()
		go.disabled = chosen.is_empty()
		for t in toggles:
			var on: bool = chosen.has(t.get_meta("id"))
			t.text = "Taking" if on else ("Take" + (" (1 franc)" if chosen.size() + 1 > lim.free else ""))
			t.disabled = not on and not (chosen.size() < mx and p.coin >= maxi(0, chosen.size() + 1 - lim.free))
	for c in g.S.hosp:
		var t := Style.button("Take", false, 15)
		t.set_meta("id", c.id)
		var cid = c.id
		t.pressed.connect(func():
			if chosen.has(cid):
				chosen.erase(cid)
			else:
				chosen.append(cid)
			refresh.call())
		toggles.append(t)
		row.add_child(Modal.card_with_actions(Cards.face(g, c, 0.9), [t]))
	var bh := Style.hbox(10)
	bh.alignment = BoxContainer.ALIGNMENT_END
	if not no_cancel:
		var cb := Style.button("Cancel", false, 17)
		cb.pressed.connect(func(): _close_from(cb, null))
		bh.add_child(cb)
	go.pressed.connect(func(): _close_from(go, {"cards": chosen.duplicate()}))
	bh.add_child(go)
	content.add_child(bh)
	refresh.call()
	m = Modal.open(ui, {"title": "Hospital", "content": content, "width": 760, "locked": true})
	return await m.done

## Market trades: steppers for each trade and a running "francs after" total.
func _market_body(p: Dictionary, o: Dictionary) -> VBoxContainer:
	var v := Style.vbox(6)
	var has_pickle := g.has_card(p, "preserve")
	var jar_cost := func(k): return int(ceil(k / 2.0)) * 2 if g.S.ev == "hardtimes" else 2 * k
	var cash := func(): return p.coin + o.sellBone + o.sellPres * (2 + (1 if o.pickle else 0)) - jar_cost.call(o.jars) - (1 if o.ice else 0)
	var total_l := Style.label("", 17, Style.PARCH, Style.display)
	var labels := {}
	var upd := func():
		total_l.text = "Francs after: " + Style.fr(cash.call())
		for k in labels:
			labels[k].text = str(o[k]) if not (o[k] is bool) else ("Buying" if o[k] else "Buy")
	var stepper := func(label: String, sub: String, k: String, mx: int):
		var row := Style.panel(Style.PANEL2, Style.LINE, 8)
		var h := Style.hbox(8)
		row.add_child(h)
		var tv := Style.vbox(0)
		tv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tv.add_child(Style.rich("[b]%s[/b]" % label, 17))
		tv.add_child(Style.wrap(sub, 14, Style.MUTED))
		h.add_child(tv)
		var minus := Style.button("-", false, 18)
		var n := Style.title("0", 18)
		n.custom_minimum_size.x = 24
		n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		labels[k] = n
		var plus := Style.button("+", false, 18)
		minus.pressed.connect(func():
			o[k] = maxi(0, o[k] - 1)
			upd.call())
		plus.pressed.connect(func():
			if o[k] < mx:
				o[k] += 1
				if cash.call() < 0:
					o[k] -= 1
			upd.call())
		h.add_child(minus)
		h.add_child(n)
		h.add_child(plus)
		v.add_child(row)
	stepper.call("Sell 2 bone for 1 franc", "You have %d bone." % p.bone, "sellBone", p.bone / 2)
	stepper.call("Sell 3 preserved flesh for 2 francs", "You have %d preserved. Preserve flesh in your lab at night." % p.preserved, "sellPres", p.preserved / 3)
	stepper.call("Buy a Leyden jar " + _ic("jar") + " (2 francs)", ("Hard Times: buy 1, get 1 free. " if g.S.ev == "hardtimes" else "") + "You have %d of 4. New jars are empty unless lightning is in the air." % p.jars.size(), "jars", 4 - p.jars.size())
	var ice := Style.panel(Style.PANEL2, Style.LINE, 8)
	var ih := Style.hbox(8)
	ice.add_child(ih)
	var itv := Style.vbox(0)
	itv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	itv.add_child(Style.rich("[b]Buy an ice block %s (1 franc)[/b]" % _ic("ice"), 17))
	itv.add_child(Style.wrap("Stops decay for the next 2 dawns." + (" You have %d left." % p.ice if p.ice else ""), 14, Style.MUTED))
	ih.add_child(itv)
	var ib := Style.button("Buy", false, 16)
	labels["ice"] = ib
	ib.pressed.connect(func():
		o.ice = not o.ice
		if cash.call() < 0:
			o.ice = false
		upd.call())
	ih.add_child(ib)
	v.add_child(ice)
	if has_pickle:
		var pk := CheckButton.new()
		pk.text = "Play Pickling Jars: +1 franc per preserved sale"
		pk.toggled.connect(func(on):
			o.pickle = on
			upd.call())
		v.add_child(pk)
	total_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	v.add_child(total_l)
	upd.call()
	return v


# ---------------------------------------------------------------- cadavers

func cadaver_picks(p: Dictionary, cards: Array, o: Dictionary) -> Dictionary:
	var picks := {}
	for c in cards:
		picks[c.id] = {"how": "mats"}
	var m: Modal
	var items := []
	var toggles := []
	var refresh := func():
		for t in toggles:
			var pk: Dictionary = picks[t.get_meta("cid")]
			var on: bool = (pk.how == t.get_meta("how")) if t.get_meta("how") != "card" else (pk.get("card") == t.get_meta("card"))
			t.add_theme_stylebox_override("normal", Style.box(Color("#1d2a36") if on else Style.PANEL2, Style.SPARK if on else Style.LINE2, 1))
			t.add_theme_color_override("font_color", Style.SPARK if on else Style.PARCH)
	for c in cards:
		var acts := []
		var opts := [["Materials", "mats"]]
		if c.exp:
			opts.append(["+%d expertise" % c.exp, "exp"])
		if not o.get("single", false):
			opts.append(["Leave", "leave"])
		var h := Style.hbox(4)
		for op in opts:
			var b := Style.button(op[0], false, 14)
			b.set_meta("cid", c.id)
			b.set_meta("how", op[1])
			var cid = c.id
			var how: String = op[1]
			b.pressed.connect(func():
				picks[cid].how = how
				refresh.call())
			toggles.append(b)
			h.add_child(b)
		acts.append(h)
		for h2 in p.hand:
			var fits: bool = h2.id == "daisy" or (h2.id == "dissect" and c.stage >= 1 and c.stage <= 2) or (h2.id == "electro" and c.stage >= 1 and c.stage <= 3 and g.charged(p) > 0)
			if not fits:
				continue
			var b := Style.button("Use card “%s”" % h2.name, false, 13)
			b.set_meta("cid", c.id)
			b.set_meta("how", "card")
			b.set_meta("card", h2.id)
			var cid = c.id
			var hid: String = h2.id
			b.pressed.connect(func():
				picks[cid].card = null if picks[cid].get("card") == hid else hid
				if picks[cid].how == "leave":
					picks[cid].how = "mats"
				refresh.call())
			toggles.append(b)
			acts.append(b)
		items.append(Modal.card_with_actions(Cards.cadaver_card(g, c, 0.9, o.get("noCardCost", false), o.get("extraH", 0)), acts))
	var content := Style.vbox(10)
	content.add_child(Style.wrap(o.get("intro", "") + " For each cadaver, take its materials or its expertise, or leave it.", 16, Style.PARCH_DIM, 760))
	content.add_child(Modal.card_row(items))
	var notes := ""
	if o.get("flatCost", 0):
		notes += "Resolving any card costs 1 humanity in total. "
	if o.get("extraH", 0):
		notes += "All Saints’ Day: every resolved card costs 1 extra humanity."
	if notes != "":
		content.add_child(Style.wrap(notes, 14, Style.MUTED, 760))
	refresh.call()
	m = Modal.open(ui, {"title": o.get("title", ""), "content": content, "width": 820, "locked": true, "buttons": [{"label": "Done", "primary": true, "value": 1}]})
	await m.done
	return picks


# ================================================================ night

func human_night() -> void:
	await sleep(1100)
	if shot_mode:
		return
	var m := Modal.open(ui, {"title": "Night %d" % g.S.round, "text": "Everyone is home. Build, throw the switch and preserve in your laboratory, or end the night now.",
		"buttons": [{"label": "End the night", "value": false}, {"label": "Go to the laboratory", "primary": true, "value": true}]})
	var go = await m.done
	if go:
		open_lab()
		await night_over
	elif not await _confirm_end_night():
		open_lab()
		await night_over

func _confirm_end_night() -> bool:
	var p: Dictionary = g.S.players[0]
	var can_build: bool = g.D.SLOT6.any(func(s):
		var a = g.plan_build(p, s, "fresh")
		return a != null and a.ok)
	if can_build or g.can_throw(p):
		var why := ("You can still build a part. " if can_build else "") + ("You have not thrown the switch yet." if g.can_throw(p) else "")
		return bool(await ask({"title": "Snuff the lamps?", "text": why, "buttons": [{"label": "Keep working", "value": false}, {"label": "End the night", "primary": true, "value": true}]}))
	return true

func _end_night_request() -> void:
	if g.S.phase != "lab":
		return
	if lab_modal != null and is_instance_valid(lab_modal):
		lab_modal.close(null)
	if await _confirm_end_night():
		night_over.emit()

func open_lab() -> void:
	if lab_modal != null and is_instance_valid(lab_modal):
		return
	var night: bool = g.S.phase == "lab"
	lab_modal = Modal.open(ui, {"title": "Your laboratory", "content": _lab_content(), "width": 1300,
		"buttons": [{"label": "Close", "value": null}, {"label": "End the night", "primary": true, "value": "end"}] if night else [{"label": "Close", "primary": true, "value": null}]})
	var v = await lab_modal.done
	lab_modal = null
	if v == "end":
		_end_night_request()

func _lab_content() -> Control:
	var p: Dictionary = g.S.players[0]
	return LabView.body(g, p, true, lab_opts, {
		"build": func(slot, pol):
			var r = g.build(0, slot, pol, lab_opts)
			if r != null:
				lab_opts = {"steady": false, "surgeon": false}
				_flash(Style.SPARK, 0.25)
				g.save()
				sync(),
		"throw": func(n): _throw(n),
		"preserve": func(t, n):
			g.preserve(p, t, n)
			g.save()
			sync(),
		"toggle": func(k):
			lab_opts[k] = not lab_opts.get(k, false)
			_refresh_lab()})

func _refresh_lab() -> void:
	if lab_modal == null or not is_instance_valid(lab_modal):
		return
	var old: Control = lab_modal.body.get_child(1)
	var idx := old.get_index()
	var fresh := _lab_content()
	lab_modal.body.add_child(fresh)
	lab_modal.body.move_child(fresh, idx)
	old.queue_free()

func _throw(n: int) -> void:
	if busy:
		return
	busy = true
	if lab_modal != null and is_instance_valid(lab_modal):
		lab_modal.close(null)
	await g.human_throw(n)
	busy = false
	sync()
	open_lab()

const FACE := {"alive": ["◉", Color("#7cc4ff")], "damage": ["ϟ", Color("#f2d24b")], "heart": ["♥", Color("#d6675f")], "blank": ["", Color.WHITE]}

func throw_dialog(dice: Array, st: Dictionary, rolled: Array, opts: Array):
	var row := Style.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	for k in dice.size():
		var d: Dictionary = dice[k]
		var die := PanelContainer.new()
		die.custom_minimum_size = Vector2(64, 64)
		die.add_theme_stylebox_override("panel", Style.box(Color("#2a5f8f") if d.c == "blue" else Color("#5d5862"), Color.BLACK, 2, 0))
		var f: Array = FACE[d.f]
		var l := Style.label(f[0], 38, f[1])
		if d.f == "heart":
			l.text = ""
			var hi := Style.icon("heart-broken", 40)
			hi.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			die.add_child(hi)
		else:
			l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			l.add_theme_color_override("font_outline_color", Color.BLACK)
			l.add_theme_constant_override("outline_size", 6)
			die.add_child(l)
		row.add_child(die)
		if rolled.has(k):
			die.pivot_offset = Vector2(32, 32)
			die.rotation = -1.2
			die.modulate.a = 0
			die.tree_entered.connect(func():
				var tw := die.create_tween().set_parallel(true)
				tw.tween_interval(0.12 * k)
				tw.chain().tween_property(die, "rotation", 0.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
				tw.parallel().tween_property(die, "modulate:a", 1.0, 0.2), CONNECT_ONE_SHOT)
	var content := Style.vbox(10)
	content.add_child(row)
	var sumtxt := "Eye: a finished part comes alive · Bolt: damage · Broken heart: -1 humanity"
	if st.get("ignoreDmg", false):
		sumtxt += " · bolts ignored"
	if st.get("ignoreHeart", false):
		sumtxt += " · hearts ignored"
	var s := Style.wrap(sumtxt, 15, Style.PARCH_DIM, 600)
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(s)
	if opts.size():
		content.add_child(Style.wrap("Before the result counts, you may spend research cards to change the dice.", 14, Style.MUTED, 600))
	var m := Modal.open(ui, {"title": "You throw the switch", "content": content, "options": opts, "width": 660, "locked": true,
		"buttons": [{"label": "Accept the result", "primary": true, "value": "ok"}]})
	return await m.done

func throw_result(notes: Array, alive: bool) -> void:
	if alive:
		_flash(Style.ALIVE, 0.8)
	var bb := "\n".join(notes.map(func(n): return "• " + n)) if notes.size() else "The current crackles through dead flesh. Nothing stirs."
	var m := Modal.open(ui, {"title": "The current fades", "text": bb, "buttons": [{"label": "Continue", "primary": true, "value": 1}]})
	await m.done

func _flash(c: Color, strength: float) -> void:
	var f := ColorRect.new()
	f.color = Color(c, strength)
	f.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	f.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.add_child(f)
	var tw := f.create_tween()
	tw.tween_property(f, "color:a", 0.0, 0.8)
	tw.tween_callback(f.queue_free)


# ================================================================ side panel popups

func open_today() -> void:
	var c = g.S.card
	if c == null:
		return
	var card: Control = Cards.event_card(g, g.EVENT[c.id], 480) if c.t == "ev" else Cards.encounter_card(g, g.ENC[c.id], 480)
	var m := Modal.open(ui, {"title": "Day %d" % g.S.round, "content": card, "width": 540, "buttons": [{"label": "Close", "primary": true, "value": 1}]})
	await m.done

func _hand_content() -> Control:
	var p: Dictionary = g.S.players[0]
	var v := Style.vbox(10)
	v.add_child(Style.wrap("Research cards come from the Academy, humanity cards from Saint-Roch. You may hold up to 3 of each kind; a 4th replaces the oldest.", 16, Style.PARCH_DIM, 760))
	if p.hand.is_empty():
		v.add_child(Style.label("No cards. Research comes from the Academy, humanity cards from Saint-Roch.", 15, Style.MUTED))
		return v
	var items := []
	for c in p.hand:
		var acts := []
		if g.card_playable(0, c, turn_open) and not busy:
			var b := Style.button("Play", true, 15)
			var cid: String = c.id
			b.pressed.connect(func(): _play(cid))
			acts.append(b)
		var how: String = WHERE.get(c.id, "Use it: press Play." if c.when in ["any", "aid", "target"] else "")
		if how != "":
			acts.append(Style.wrap(how, 13, Style.MUTED, 176))
		items.append(Modal.card_with_actions(Cards.face(g, c, 0.9), acts))
	v.add_child(Modal.card_row(items))
	return v

var hand_modal: Modal = null

func open_hand() -> void:
	hand_modal = Modal.open(ui, {"title": "Your cards", "content": _hand_content(), "width": 820, "buttons": [{"label": "Close", "primary": true, "value": 1}]})
	await hand_modal.done
	hand_modal = null

func _play(id: String) -> void:
	if busy:
		return
	var p: Dictionary = g.S.players[0]
	var c = g.find_card(p, id)
	if c == null:
		return
	if hand_modal != null and is_instance_valid(hand_modal):
		hand_modal.close(1)
	var target = null
	if c.when == "target":
		var opts := []
		for k in g.card_targets(0, c):
			opts.append({"label": g.S.players[k].name, "value": k, "lead": Color(g.S.players[k].color)})
		target = await ask({"title": c.name, "text": c.text, "options": opts, "buttons": [{"label": "Cancel", "value": null}]})
		if target == null:
			return
	busy = true
	var ok := g.play_card(0, id, target, turn_open)
	if ok and id == "midnight":
		await g.midnight_oil(0)
	busy = false
	g.save()
	sync()

func open_character() -> void:
	var p: Dictionary = g.S.players[0]
	var C: Dictionary = data.CHARACTERS.filter(func(c): return c.id == p.char)[0]
	var m: Modal
	var content := Style.hbox(16)
	content.add_child(Style.picture(Style.art("characters/character-%s.png" % p.char), Vector2(160, 240)))
	var v := Style.vbox(8)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(Style.title("%s, %s" % [C.name, C.role.to_lower()], 22))
	v.add_child(Style.wrap(C.text, 16, Style.PARCH_DIM, 420))
	if g.has_char(p, "zoo") and not p.zooUsed and p.jars.has(false) and g.S.phase != "end":
		var b := Style.button("Charge 1 jar with the eel", false, 15)
		b.pressed.connect(func():
			p.zooUsed = true
			p.jars[p.jars.find(false)] = true
			g.log_line("%s charges a jar with an eel." % g.B(p))
			g.save()
			sync()
			_close_from(b, 1))
		v.add_child(b)
	if p.police:
		v.add_child(Style.wrap("You have %d police marker%s from the Dark Alley.%s" % [p.police, "" if p.police == 1 else "s", " The Dark Alley is closed to you." if p.police >= 2 else ""], 15, Style.CRIM, 420))
		var b := Style.button("Pay 3 francs to clear them", false, 15)
		b.disabled = p.coin < 3
		b.pressed.connect(func():
			p.coin -= 3
			p.police = 0
			g.log_line("%s pays off the police." % g.B(p))
			g.save()
			sync()
			_close_from(b, 1))
		v.add_child(b)
	v.add_child(hud.stat_rows(p))
	v.add_child(Style.label("%d VP built · %d of 6 alive · %d scientist and %d assistant%s at home" % [p.vp, g.alive_count(p), p.left.scientist, p.left.assistant, "" if p.left.assistant == 1 else "s"], 15, Style.PARCH_DIM))
	content.add_child(v)
	m = Modal.open(ui, {"title": p.name, "content": content, "width": 680, "buttons": [{"label": "Your cards", "value": "hand"}, {"label": "Close", "primary": true, "value": null}]})
	if await m.done == "hand":
		open_hand()

func open_rival(i: int) -> void:
	var p: Dictionary = g.S.players[i]
	var C: Dictionary = data.CHARACTERS.filter(func(c): return c.id == p.char)[0]
	var v := Style.vbox(12)
	var head := Style.hbox(14)
	head.add_child(Style.picture(Style.art("characters/character-%s.png" % p.char), Vector2(80, 120)))
	var hv := Style.vbox(6)
	hv.add_child(Style.rich("[b]%s[/b], %s. [color=#b9ac93]%s[/color]" % [C.name, C.role.to_lower(), C.text], 16, 560))
	hv.add_child(Style.label("%d VP built · %s · %d/%d jars · %d police · ice %d · %d research and %d humanity cards" % [p.vp, Style.fr(p.coin), g.charged(p), p.jars.size(), p.police, p.ice,
		p.hand.filter(func(h): return h.kind == "research").size(), p.hand.filter(func(h): return h.kind == "humanity").size()], 15, Style.PARCH_DIM))
	hv.add_child(hud.stat_rows(p))
	head.add_child(hv)
	v.add_child(head)
	v.add_child(LabView.body(g, p, false, {}, {}))
	var m := Modal.open(ui, {"title": "%s’s Laboratory" % p.name, "content": v, "width": 1300, "buttons": [{"label": "Close", "primary": true, "value": 1}]})
	await m.done


# ================================================================ the end

func show_end() -> void:
	var F: Dictionary = g.S.final
	if autoplay:
		var you: Dictionary = F.rows.filter(func(r): return r.i == 0)[0]
		print("AUTOPLAY END day=%d reason=%s winner=%s you=%d steps=%d" % [F.round, F.reason, F.rows[0].name, you.total, _auto_steps])
	var top: Dictionary = F.rows[0]
	var you_won: bool = top.i == 0
	var why: String = "It’s alive." if F.reason == "alive" else "Captain Walton has found the Creature."
	var verdict: String
	if F.reason == "alive":
		verdict = "Lifeless flesh twitches and writhes against the straps. The Creature gently moves you aside to see her first face. “At last. You will know only compassion.” Then, to you: “Our work is not finished. It has only begun.”" if you_won else "%s receives the Creature’s thanks. Your laboratory goes quiet." % top.name
	else:
		verdict = "The Captain and the Creature struggle on the embankment and fall together into the dark Seine. Whatever you built stays on your table, unfinished."
	var v := Style.vbox(12)
	var e := Style.label("DAY %d · %s" % [F.round, why.to_upper()], 14, Style.MUTED, Style.display)
	e.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(e)
	var h := Style.title("You Win" if you_won else "%s Wins" % top.name, 54, Style.SPARK if you_won else Style.PARCH)
	h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(h)
	var letter := Style.panel(Style.PAPER, Color("#5a4630"), 16)
	letter.add_child(Style.wrap(verdict, 18, Style.PAPER_INK, 800))
	v.add_child(letter)
	var grid := GridContainer.new()
	grid.columns = 9
	grid.add_theme_constant_override("h_separation", 22)
	grid.add_theme_constant_override("v_separation", 8)
	for t in ["Scientist", "Build VP", "Alive", "Objectives", "Reputation", "Expertise", "Humanity", "Captain", "Total"]:
		grid.add_child(Style.label(t, 15, Style.MUTED, Style.display))
	for r in F.rows:
		grid.add_child(Style.title(r.name, 17, Color(r.color)))
		for x in [str(r.vp), "%d/6 · +%d" % [r.alive, r.alivePts], "+%d" % r.obj, "+%d" % r.repPts, "+%d" % r.expPts, ("%+d" % r.humPts) if r.humPts else "0", ("+%d" % r.capt) if r.capt else ""]:
			grid.add_child(Style.label(x, 17, Style.PARCH))
		grid.add_child(Style.title(str(r.total), 20, Style.PARCH))
	v.add_child(grid)
	var m := Modal.open(ui, {"content": v, "width": 980, "locked": true, "buttons": [{"label": "Play again", "primary": true, "value": 1}]})
	if autoplay:
		await get_tree().create_timer(2.0).timeout
		_save("res://../tests/godot-autoplay-end.png")
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()
		return
	await m.done
	show_title()


# ================================================================ autoplay (godot --path godot -- --autoplay)
# Plays as you through the real popups and buttons until the game ends, like tests/ui.js does for the web build.

const AUTO_AVOID := ["Cancel", "Close", "Keep working", "Never mind", "Refuse", "Stay put", "Leave", "Skip", "Abandon", "Keep playing"]

func _process(delta: float) -> void:
	if not autoplay or g == null or g.S.is_empty() or g.S.phase == "end":
		return
	_auto_t += delta
	if _auto_t < 0.06:
		return
	_auto_t = 0.0
	var modals := ui.get_children().filter(func(c): return c is Modal and not c.is_queued_for_deletion())
	if modals.size():
		_auto_modal(modals[-1])
		return
	if turn_open and not busy:
		var keys := g.all_keys().filter(func(k): return _legal(k, ""))
		if keys.size():
			_auto_steps += 1
			_choose_space(keys.pick_random(), null)

func _buttons_in(n: Node, out: Array) -> Array:
	for c in n.get_children():
		if c is Button and c.is_visible_in_tree() and not c.disabled:
			out.append(c)
		_buttons_in(c, out)
	return out

func _btn_text(b: Button) -> String:
	if b.text != "":
		return b.text
	for c in b.find_children("*", "Label", true, false):
		return c.text
	for c in b.find_children("*", "RichTextLabel", true, false):
		return c.get_parsed_text()
	return ""

func _auto_modal(m: Modal) -> void:
	_auto_steps += 1
	var bs := _buttons_in(m, [])
	var texts := bs.map(func(b): return _btn_text(b))
	if _auto_steps % 200 == 0:
		print("AUTOPLAY modal '%s' buttons %s" % [m.spec.get("title", ""), texts])
	if m == lab_modal:
		for k in bs.size():
			if texts[k].begins_with("Start ·") or texts[k].begins_with("Add skin ·") or texts[k].begins_with("Use ") and " jar" in texts[k]:
				bs[k].pressed.emit()
				return
		for k in bs.size():
			if texts[k] == "End the night" or (g.S.phase != "lab" and texts[k] == "Close"):
				bs[k].pressed.emit()
				return
	var prefer := ["Retrieve", "Go to the laboratory", "End the night", "Accept the result", "Bump", "Done", "Take this", "Buy this one", "Materials", "Draw ", "Take", "Trade"]
	for want in prefer:
		for k in bs.size():
			if texts[k].begins_with(want) and not (want == "Take" and texts[k] == "Taking"):
				bs[k].pressed.emit()
				return
	var ok := []
	for k in bs.size():
		if not (texts[k] in AUTO_AVOID):
			ok.append(bs[k])
	if ok.size():
		if randf() < 0.5:
			ok[-1].pressed.emit()
		else:
			ok.pick_random().pressed.emit()
	elif bs.size():
		bs[-1].pressed.emit()


# ================================================================ screenshots (godot --path godot -- --shot)

func _screenshot_run() -> void:
	pace = 0.3
	while not turn_open:
		await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(1.5).timeout
	await _save("res://../tests/godot-1-start.png")
	# Click the Academy and take a research card through the real popups.
	_on_place_clicked("academy")
	await get_tree().create_timer(1.0).timeout
	await _save("res://../tests/godot-2-place.png")
	for c in ui.get_children():
		if c is Modal:
			c.close({"key": "academy.research", "pre": null})
	await get_tree().create_timer(1.0).timeout
	await _save("res://../tests/godot-3-choice.png")
	for c in ui.get_children():
		if c is Modal:
			c.close({"card": g.S.researchRow[0].uid})
	await get_tree().create_timer(9.0).timeout
	await _save("res://../tests/godot-4-rivals.png")
	open_lab()
	await get_tree().create_timer(1.0).timeout
	await _save("res://../tests/godot-5-lab.png")
	get_tree().quit()

func _save(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(ProjectSettings.globalize_path(path))
