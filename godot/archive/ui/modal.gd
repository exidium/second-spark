class_name Modal
extends Control
## A popup over the game. Build it with Modal.open(parent, spec), then `var v = await m.done`.
## spec: title, hero (Texture2D) with hero_text, text, content (Control), options [{label, sub, value, disabled, lead (Color)}],
## buttons [{label, value, primary, disabled}], width, locked (no Escape or click-outside to cancel).

signal done(value)

var panel: PanelContainer
var body: VBoxContainer
var spec: Dictionary
var _closed := false


static func open(parent: Node, s: Dictionary) -> Modal:
	var m := Modal.new()
	m.spec = s
	parent.add_child(m)
	m._build()
	return m


func _build() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var scrim := ColorRect.new()
	scrim.color = Color(0.03, 0.02, 0.04, 0.72)
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.gui_input.connect(func(e):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT and not spec.get("locked", false):
			close(null))
	add_child(scrim)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	panel = Style.panel(Style.PANEL, Style.LINE2, 0)
	var w: float = spec.get("width", 560.0)
	panel.custom_minimum_size.x = w
	center.add_child(panel)

	var outer := Style.vbox(0)
	panel.add_child(outer)
	if spec.get("hero") != null:
		outer.add_child(_hero(spec.hero, spec.get("hero_title", ""), spec.get("hero_text", ""), w))

	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var pad := MarginContainer.new()
	for s in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + s, 20)
	pad.add_theme_constant_override("margin_top", 16)
	pad.add_theme_constant_override("margin_bottom", 18)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(pad)
	body = Style.vbox(10)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(body)

	if spec.get("title", "") != "":
		var t := Style.title(spec.title, 26)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		body.add_child(t)
	if spec.get("text", "") != "":
		var tx := Style.rich(spec.text, 18)
		tx.custom_minimum_size.x = w - 44
		body.add_child(tx)
	if spec.get("content") != null:
		body.add_child(spec.content)
	for o in spec.get("options", []):
		body.add_child(option_row(o))
	var btns: Array = spec.get("buttons", [])
	if btns.size():
		var row := Style.hbox(10)
		row.alignment = BoxContainer.ALIGNMENT_END
		for b in btns:
			var bt := Style.button(b.label, b.get("primary", false), 17)
			bt.custom_minimum_size.y = 40
			bt.disabled = b.get("disabled", false)
			var v = b.get("value")
			bt.pressed.connect(func(): close(v))
			row.add_child(bt)
		body.add_child(Style.spacer(2))
		body.add_child(row)
	# Fit tall popups to the window: the body scrolls.
	await get_tree().process_frame
	var vp := get_viewport_rect().size
	scroll.custom_minimum_size.y = mini(int(pad.get_combined_minimum_size().y), int(vp.y - 60 - (outer.get_child(0).size.y if spec.get("hero") != null else 0.0)))
	_appear()


func _hero(t: Texture2D, name: String, text: String, w: float) -> Control:
	var art := Control.new()
	art.custom_minimum_size = Vector2(w, w * 9.0 / 16.0 * 0.78)
	art.clip_contents = true
	var pic := Style.picture(t, art.custom_minimum_size)
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art.add_child(pic)
	var shade := ColorRect.new()
	shade.color = Color(0, 0, 0, 0.5)
	shade.anchor_top = 0.6
	shade.anchor_right = 1
	shade.anchor_bottom = 1
	art.add_child(shade)
	var v := Style.vbox(2)
	v.anchor_top = 0.6
	v.anchor_right = 1
	v.anchor_bottom = 1
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	art.add_child(v)
	var nm := Style.title(name, 32, Color.WHITE)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	nm.add_theme_color_override("font_outline_color", Color.BLACK)
	nm.add_theme_constant_override("outline_size", 6)
	v.add_child(nm)
	if text != "":
		var tx := Style.label(text, 17, Color.WHITE)
		tx.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tx.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		tx.add_theme_color_override("font_outline_color", Color.BLACK)
		tx.add_theme_constant_override("outline_size", 5)
		v.add_child(tx)
	return art


## A full-width option row: optional coloured lead square (who is there), label, sub line.
func option_row(o: Dictionary) -> Button:
	var b := Button.new()
	b.disabled = o.get("disabled", false)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	b.custom_minimum_size.y = 52 if o.get("sub", "") != "" else 42
	var h := Style.hbox(10)
	h.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	h.offset_left = 12
	h.offset_right = -12
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(h)
	if o.get("lead") != null:
		var lead := ColorRect.new()
		lead.color = o.lead
		lead.custom_minimum_size = Vector2(10, 22)
		lead.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		lead.mouse_filter = Control.MOUSE_FILTER_IGNORE
		h.add_child(lead)
	if o.get("icon", "") != "":
		h.add_child(Style.icon(o.icon, 24))
	var v := Style.vbox(0)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(v)
	var l := Style.title(o.label, 18, Style.MUTED if b.disabled else Style.PARCH)
	v.add_child(l)
	if o.get("sub", "") != "":
		var s := Style.rich(o.sub, 15)
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		s.add_theme_color_override("default_color", Style.MUTED if b.disabled else Style.PARCH_DIM)
		v.add_child(s)
	if o.get("tag", "") != "":
		h.add_child(Style.label(o.tag, 14, Style.BRASS, Style.display))
	b.custom_minimum_size.y = maxf(b.custom_minimum_size.y, h.get_combined_minimum_size().y + 12)
	var val = o.get("value")
	b.pressed.connect(func(): close(val))
	return b


## A card with its own buttons under it, for rows of cards in a popup.
static func card_with_actions(face: Control, actions: Array) -> VBoxContainer:
	var v := Style.vbox(6)
	v.add_child(face)
	for a in actions:
		v.add_child(a)
	return v

static func card_row(items: Array) -> HFlowContainer:
	var f := HFlowContainer.new()
	f.alignment = FlowContainer.ALIGNMENT_CENTER
	f.add_theme_constant_override("h_separation", 14)
	f.add_theme_constant_override("v_separation", 14)
	var k := 0
	for it in items:
		f.add_child(it)
		Modal.deal_in(it, k)
		k += 1
	return f

## Cards slide up and fade in, one after the other, on a popup's first draw.
static func deal_in(c: Control, k: int) -> void:
	c.modulate.a = 0.0
	c.tree_entered.connect(func():
		var tw := c.create_tween()
		tw.tween_interval(0.08 * k + 0.05)
		tw.tween_property(c, "modulate:a", 1.0, 0.25), CONNECT_ONE_SHOT)


func _appear() -> void:
	panel.pivot_offset = panel.size / 2
	panel.scale = Vector2(0.96, 0.96)
	modulate.a = 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, 0.15)
	tw.tween_property(panel, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _unhandled_input(e: InputEvent) -> void:
	if e.is_action_pressed("ui_cancel") and not spec.get("locked", false):
		get_viewport().set_input_as_handled()
		close(null)


func close(v) -> void:
	if _closed:
		return
	_closed = true
	done.emit(v)
	queue_free()
