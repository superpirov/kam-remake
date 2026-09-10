extends Control
## Главное меню в стиле оригинала: пергамент, герб, пункты. Выбор кампании TSK/TPR.

signal play_requested(campaign: String, n: int)

var tsk_buttons := {}
var tpr_buttons := {}

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build()

func _parchment() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.85, 0.74, 0.52)
	s.border_color = Color(0.45, 0.3, 0.15)
	s.set_border_width_all(4)
	s.set_corner_radius_all(6)
	s.shadow_color = Color(0, 0, 0, 0.5)
	s.shadow_size = 8
	return s

func _btn(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(300, 44)
	b.add_theme_font_size_override("font_size", 20)
	var n := StyleBoxFlat.new()
	n.bg_color = Color(0.55, 0.38, 0.2)
	n.border_color = Color(0.85, 0.68, 0.3)
	n.set_border_width_all(2)
	n.set_corner_radius_all(4)
	b.add_theme_stylebox_override("normal", n)
	var h := n.duplicate() as StyleBoxFlat
	h.bg_color = Color(0.68, 0.48, 0.25)
	b.add_theme_stylebox_override("hover", h)
	var pr := n.duplicate() as StyleBoxFlat
	pr.bg_color = Color(0.42, 0.28, 0.14)
	b.add_theme_stylebox_override("pressed", pr)
	b.add_theme_color_override("font_color", Color(0.98, 0.92, 0.75))
	return b

func _build() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.06, 0.04)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _parchment())
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	panel.add_child(v)
	var title := Label.new()
	title.text = "⚔  ВОЙНА и МИР  ⚔"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 44)
	title.add_theme_color_override("font_color", Color(0.35, 0.12, 0.08))
	v.add_child(title)
	var sub := Label.new()
	sub.text = "KaM Remake · TSK «Разрушенное королевство» + TPR «Вторая корона»"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 16)
	sub.add_theme_color_override("font_color", Color(0.4, 0.25, 0.12))
	v.add_child(sub)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	v.add_child(row)
	row.add_child(_campaign_box("ТАК: Разрушенное королевство (20)", "tsk", 20))
	row.add_child(_campaign_box("ТPR: Вторая корона (14)", "tpr", 14))
	var bottom := HBoxContainer.new()
	bottom.alignment = BoxContainer.ALIGNMENT_CENTER
	bottom.add_theme_constant_override("separation", 12)
	v.add_child(bottom)
	var help := _btn("Помощь")
	help.custom_minimum_size = Vector2(180, 40)
	help.pressed.connect(_show_help)
	bottom.add_child(help)
	var quit := _btn("Выход")
	quit.custom_minimum_size = Vector2(180, 40)
	quit.pressed.connect(func() -> void: get_tree().quit())
	bottom.add_child(quit)
	var ver := Label.new()
	ver.text = "Фанатский ремейк по механикам оригинала 1998/2002 · Godot 4 · v0.1"
	ver.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ver.add_theme_font_size_override("font_size", 13)
	v.add_child(ver)

func _campaign_box(title: String, campaign: String, count: int) -> VBoxContainer:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	var l := Label.new()
	l.text = title
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", 18)
	box.add_child(l)
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	box.add_child(grid)
	var unlocked: int = int(SaveManager.progress.get(campaign, 1))
	for i in range(1, count + 1):
		var b := Button.new()
		b.text = str(i)
		b.custom_minimum_size = Vector2(44, 36)
		b.disabled = i > unlocked
		b.tooltip_text = "Миссия %d" % i
		var ii := i
		b.pressed.connect(func() -> void: play_requested.emit(campaign, ii))
		grid.add_child(b)
	return box

func _show_help() -> void:
	GameManager.add_message("Помощь открыта в брифинге миссии.", "info")
	var d := AcceptDialog.new()
	d.title = "Как играть (как в оригинале)"
	d.dialog_text = "ЛКМ — выбор/стройка · ПКМ — приказ/отмена\nB — стройка · R — дороги · Space — пауза · F8 — ускорение x1→x2→x4\nСтрой только по дорогам от склада. Корми жителей (харчевня) и солдат (приказ «Накормить»).\nВ ближнем бою отряд теряет управление. Пехота: Shift+ПКМ — штурм.\nПобеда: снести казармы+склады+школы и армию врага."
	add_child(d)
	d.popup_centered(Vector2(560, 320))
