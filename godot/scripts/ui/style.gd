class_name Style
extends RefCounted
## Colours, fonts and small widget builders shared by every screen. Mirrors the tokens at the top of src/head.html.

const INK := Color("#121016")
const PANEL := Color("#1b171f")
const PANEL2 := Color("#241f29")
const LINE := Color("#3a3240")
const LINE2 := Color("#4b4152")
const PARCH := Color("#ece0c6")
const PARCH_DIM := Color("#b9ac93")
const MUTED := Color("#8e8393")
const SPARK := Color("#9fd0ff")
const BLOOD := Color("#b4423c")
const BRASS := Color("#cda65c")
const VERD := Color("#74b393")
const CRIM := Color("#d6675f")
const PAPER := Color("#d9c8a3")
const PAPER_INK := Color("#3b2d22")
const MUSCLE := Color("#c0443a")
const SKIN := Color("#e2c26a")
const ALIVE := Color("#7cc4ff")
const DMG := Color("#f2d24b")
const MAT_COL := {"muscle": Color("#c0443a"), "organ": Color("#9b5aa8"), "blood": Color("#8c1c22"), "bone": Color("#e7dcc4"), "animal": Color("#a7744a")}

static var display: Font
static var body: Font
static var _tex := {}


static func init() -> void:
	if display != null:
		return
	display = load("res://assets/fonts/Amarante-Regular.ttf")
	body = load("res://assets/fonts/EBGaramond.ttf")


static func make_theme() -> Theme:
	init()
	var t := Theme.new()
	t.default_font = body
	t.default_font_size = 17
	t.set_color("font_color", "Label", PARCH)
	t.set_color("default_color", "RichTextLabel", PARCH)
	t.set_font("bold_font", "RichTextLabel", display)
	t.set_font_size("bold_font_size", "RichTextLabel", 17)
	t.set_font("font", "Button", display)
	t.set_font_size("font_size", "Button", 16)
	t.set_color("font_color", "Button", PARCH)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color(MUTED, 0.7))
	t.set_color("font_pressed_color", "Button", SPARK)
	t.set_stylebox("normal", "Button", box(PANEL2, LINE2, 1))
	t.set_stylebox("hover", "Button", box(Color("#2e2735"), PARCH_DIM, 1))
	t.set_stylebox("pressed", "Button", box(Color("#1d2a36"), SPARK, 1))
	t.set_stylebox("disabled", "Button", box(Color(PANEL2, 0.5), LINE, 1))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_stylebox("panel", "PanelContainer", box(PANEL, LINE, 1))
	t.set_stylebox("normal", "LineEdit", box(PANEL2, LINE2, 1))
	t.set_stylebox("focus", "LineEdit", box(PANEL2, SPARK, 1))
	t.set_color("font_color", "LineEdit", PARCH)
	t.set_font("font", "LineEdit", display)
	t.set_font_size("font_size", "LineEdit", 18)
	t.set_stylebox("panel", "TooltipPanel", box(Color("#0e0b10"), LINE2, 1))
	t.set_color("font_color", "TooltipLabel", PARCH)
	t.set_font_size("font_size", "TooltipLabel", 15)
	t.set_stylebox("scroll", "VScrollBar", box(Color(0, 0, 0, 0.2), Color(0, 0, 0, 0), 0))
	t.set_stylebox("grabber", "VScrollBar", box(LINE2, LINE2, 0))
	t.set_stylebox("grabber_highlight", "VScrollBar", box(PARCH_DIM, PARCH_DIM, 0))
	return t


## A square-cornered pixel panel: flat fill, hard border.
static func box(bg: Color, border: Color, w := 1, pad := 8) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(w)
	s.content_margin_left = pad + 2
	s.content_margin_right = pad + 2
	s.content_margin_top = pad
	s.content_margin_bottom = pad
	return s


static func tex(path: String) -> Texture2D:
	if not _tex.has(path):
		_tex[path] = load(path) if ResourceLoader.exists(path) else null
	return _tex[path]

static func art(rel: String) -> Texture2D:
	return tex("res://assets/art/" + rel)

static func icon_tex(name: String) -> Texture2D:
	return art("icons/icon-%s.png" % name)


static func label(text: String, size := 17, color := PARCH, font: Font = null) -> Label:
	init()
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if font != null:
		l.add_theme_font_override("font", font)
	return l

static func title(text: String, size := 22, color := PARCH) -> Label:
	init()
	return label(text, size, color, display)

static func wrap(text: String, size := 16, color := PARCH_DIM, width := 0.0) -> Label:
	var l := label(text, size, color)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if width > 0:
		l.custom_minimum_size.x = width
	return l

static func rich(bb: String, size := 16, width := 0.0) -> RichTextLabel:
	init()
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.text = bb
	r.add_theme_font_size_override("normal_font_size", size)
	r.add_theme_font_size_override("bold_font_size", size)
	r.add_theme_font_override("bold_font", display)
	r.add_theme_color_override("default_color", PARCH)
	if width > 0:
		r.custom_minimum_size.x = width
	return r

static func icon(name: String, size := 20) -> TextureRect:
	var t := TextureRect.new()
	t.texture = icon_tex(name)
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.custom_minimum_size = Vector2(size, size)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

static func picture(texture: Texture2D, size: Vector2, cover := true) -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if cover else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	t.custom_minimum_size = size
	t.clip_contents = true
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return t

## "3 [coin]" style gain: a number then an icon.
static func gain_chip(n: int, icon_name: String, neg := false, size := 18) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 3)
	h.add_child(title(("%+d" % n) if not neg else str(-absi(n)), size, CRIM if neg else PARCH))
	h.add_child(icon(icon_name, size + 2))
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return h

static func button(text: String, primary := false, size := 16) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", size)
	if primary:
		b.add_theme_stylebox_override("normal", box(Color("#1d2a36"), SPARK, 1))
		b.add_theme_stylebox_override("hover", box(Color("#24384a"), Color.WHITE, 1))
		b.add_theme_color_override("font_color", SPARK)
	b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return b

static func hbox(sep := 8) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", sep)
	return h

static func vbox(sep := 8) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", sep)
	return v

static func panel(bg := PANEL, border := LINE, pad := 10) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", box(bg, border, 1, pad))
	return p

static func spacer(h := 6) -> Control:
	var c := Control.new()
	c.custom_minimum_size.y = h
	return c

static func roman(n: int) -> String:
	return ["I", "II", "III", "IV"][clampi(n, 1, 4) - 1]

static func fr(n: int) -> String:
	return "%d franc%s" % [n, "" if n == 1 else "s"]
