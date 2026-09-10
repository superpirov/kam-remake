extends Control
## Брифинг-свиток советника перед миссией + цели + старт.

signal start_pressed

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false

func show_mission(m: Dictionary) -> void:
	visible = true
	for c in get_children():
		c.queue_free()
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)
	var panel := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.88, 0.78, 0.58)
	sb.border_color = Color(0.5, 0.34, 0.16)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(8)
	sb.content_margin_left = 28
	sb.content_margin_right = 28
	sb.content_margin_top = 20
	sb.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", sb)
	panel.custom_minimum_size = Vector2(640, 0)
	center.add_child(panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	panel.add_child(v)
	var h := Label.new()
	var tag := "МИРНАЯ" if str(m.get("type", "peaceful")) == "peaceful" else "БОЕВАЯ"
	h.text = "Миссия %d · %s  [%s]" % [int(m.get("n", 1)), str(m.get("name", "?")), tag]
	h.add_theme_font_size_override("font_size", 26)
	h.add_theme_color_override("font_color", Color(0.4, 0.12, 0.08))
	v.add_child(h)
	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.custom_minimum_size = Vector2(600, 220)
	body.add_theme_font_size_override("normal_font_size", 17)
	body.add_theme_color_override("default_color", Color(0.25, 0.16, 0.08))
	body.text = "[i]Советник короля:[/i]\n" + str(m.get("brief", ""))
	v.add_child(body)
	var goals := Label.new()
	goals.text = "Цели:\n• " + "\n• ".join(GameManager.objectives)
	goals.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goals.add_theme_font_size_override("font_size", 16)
	v.add_child(goals)
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	v.add_child(row)
	var back := Button.new()
	back.text = "← Назад"
	back.pressed.connect(func() -> void: visible = false)
	row.add_child(back)
	var go := Button.new()
	go.text = "В бой! ⚔"
	go.custom_minimum_size = Vector2(220, 48)
	go.add_theme_font_size_override("font_size", 22)
	go.pressed.connect(func() -> void: start_pressed.emit())
	row.add_child(go)
