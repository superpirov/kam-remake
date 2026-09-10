extends CanvasLayer
## HUD 1:1 по компоновке оригинала: верхняя полоса ресурсов + нижняя панель
## (миникарта | вкладки стройки | инфо) + журнал сообщений.

var world: Node = null
var top_labels := {}
var msg_box: RichTextLabel
var info_panel: VBoxContainer
var build_grid: GridContainer
var tab := "base"
var minimap: Control
var selected_label: Label

const TABS := {
	"base": "🏠 База", "mine": "⛏ Добыча", "food": "🌾 Еда", "war": "⚔ Война",
}
const CATS := {
	"base": ["storehouse", "school", "inn", "road"],
	"mine": ["quarry", "woodcutter", "sawmill", "coal_mine", "iron_mine", "gold_mine", "metallurgist", "iron_smithy"],
	"food": ["farm", "vineyard", "mill", "bakery", "swine", "stables", "butcher", "tannery", "fisherman"],
	"war": ["weapon_workshop", "armor_workshop", "weapon_smithy", "armor_smithy", "barracks", "tower", "town_hall", "siege_workshop", "stables"],
}
const ROAD_DEF := {"name": "Дорога", "timber": 0, "stone": 0, "desc": "R: соединяет здания со складом. Без дороги здание молчит."}

func attach(w: Node) -> void:
	world = w
	_build()
	GameManager.resources_changed.connect(refresh_top)
	GameManager.message_added.connect(add_msg)
	GameManager.selection_changed.connect(refresh_info)
	GameManager.speed_changed.connect(func(_v: float) -> void: refresh_top())
	refresh_top()
	refresh_build()
	refresh_info()

func _stone_panel(c: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = c
	s.border_color = Color(0.1, 0.08, 0.06)
	s.set_border_width_all(2)
	s.content_margin_left = 8
	s.content_margin_right = 8
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s

func _build() -> void:
	# --- верхняя полоса ---
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", _stone_panel(Color(0.23, 0.18, 0.13)))
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_bottom = 44
	add_child(top)
	var th := HBoxContainer.new()
	th.add_theme_constant_override("separation", 10)
	top.add_child(th)
	var menu_btn := Button.new()
	menu_btn.text = "≡"
	menu_btn.pressed.connect(_show_menu)
	th.add_child(menu_btn)
	for key in ["planks", "stone", "bread", "sausage", "wine", "fish", "gold", "horse"]:
		var l := Label.new()
		l.add_theme_font_size_override("font_size", 15)
		l.add_theme_color_override("font_color", Color(0.95, 0.88, 0.7))
		th.add_child(l)
		top_labels[key] = l
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	th.add_child(spacer)
	for i in [1, 2, 3]:
		var b := Button.new()
		b.text = GameManager.SPEED_NAMES[i]
		var ii := i
		b.pressed.connect(func() -> void:
			GameManager.speed_idx = ii
			GameManager.paused = false
			GameManager.speed_changed.emit(GameManager.speed()))
		th.add_child(b)
	var pause_b := Button.new()
	pause_b.text = "⏸"
	pause_b.pressed.connect(func() -> void: GameManager.toggle_pause())
	th.add_child(pause_b)
	# --- журнал ---
	msg_box = RichTextLabel.new()
	msg_box.bbcode_enabled = true
	msg_box.scroll_following = true
	msg_box.custom_minimum_size = Vector2(360, 120)
	msg_box.set_anchors_preset(Control.PRESET_TOP_LEFT)
	msg_box.position = Vector2(8, 50)
	msg_box.add_theme_constant_override("line_separation", 2)
	add_child(msg_box)
	# --- нижняя панель ---
	var bottom := PanelContainer.new()
	bottom.add_theme_stylebox_override("panel", _stone_panel(Color(0.28, 0.21, 0.14)))
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_top = -176
	add_child(bottom)
	var hb := HBoxContainer.new()
	hb.add_theme_constant_override("separation", 10)
	bottom.add_child(hb)
	# миникарта
	var left := VBoxContainer.new()
	hb.add_child(left)
	minimap = MiniMap.new()
	minimap.custom_minimum_size = Vector2(168, 140)
	left.add_child(minimap)
	(minimap as MiniMap).hud = self
	# стройка
	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hb.add_child(mid)
	var tabs := HBoxContainer.new()
	mid.add_child(tabs)
	for k in TABS:
		var tb := Button.new()
		tb.text = TABS[k]
		tb.toggle_mode = true
		tb.button_pressed = (k == tab)
		var kk := k
		tb.pressed.connect(func() -> void:
			tab = kk
			refresh_build())
		tabs.add_child(tb)
	build_grid = GridContainer.new()
	build_grid.columns = 5
	build_grid.add_theme_constant_override("h_separation", 6)
	build_grid.add_theme_constant_override("v_separation", 6)
	mid.add_child(build_grid)
	# инфо
	var right := VBoxContainer.new()
	right.custom_minimum_size = Vector2(300, 0)
	hb.add_child(right)
	selected_label = Label.new()
	selected_label.text = "Выбор: —"
	selected_label.add_theme_color_override("font_color", Color(1, 0.93, 0.75))
	selected_label.add_theme_font_size_override("font_size", 15)
	right.add_child(selected_label)
	info_panel = VBoxContainer.new()
	right.add_child(info_panel)

func refresh_top() -> void:
	var icons := {"planks": "🪚", "stone": "🪨", "bread": "🍞", "sausage": "🌭", "wine": "🍷", "fish": "🐟", "gold": "💰", "horse": "🐎"}
	for k in top_labels:
		(top_labels[k] as Label).text = "%s %d" % [icons.get(k, "?"), int(GameManager.store.get(k, 0))]
	if minimap != null:
		minimap.queue_redraw()

func refresh_build() -> void:
	for c in build_grid.get_children():
		c.queue_free()
	for id in CATS.get(tab, []):
		var b := Button.new()
		var d: Dictionary = ROAD_DEF if id == "road" else GameData.building(id)
		b.text = "%s\n%s🪚%d 🪨%d" % [str(d.get("name", id)), "TPR·" if (d.get("tpr", false)) else "", int(d.get("timber", 0)), int(d.get("stone", 0))]
		b.custom_minimum_size = Vector2(128, 52)
		b.tooltip_text = str(d.get("desc", ""))
		var iid := id
		b.pressed.connect(func() -> void:
			GameManager.set_ghost(iid)
			add_msg("Призрак: %s — ЛКМ поставить, ПКМ отмена." % str((ROAD_DEF if iid == "road" else GameData.building(iid)).get("name", iid)), "info")
			AudioManager.play("click"))
		build_grid.add_child(b)

func refresh_info() -> void:
	for c in info_panel.get_children():
		c.queue_free()
	var s: Dictionary = GameManager.selected
	if s.is_empty():
		selected_label.text = "Выбор: — (ЛКМ — выбрать, ПКМ — приказ)"
		return
	if s.get("kind") == "building" and is_instance_valid(s.get("node")):
		var b = s["node"]
		var d := GameData.building(b.building_id)
		selected_label.text = "Здание: %s  HP %d/%d" % [str(d.get("name", "?")), int(b.hp), int(b.max_hp)]
		var hint := Label.new()
		hint.text = str(d.get("desc", ""))
		hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_panel.add_child(hint)
		if b.building_id == "barracks" or b.building_id == "town_hall":
			_add_train_buttons(b.building_id)
		if b.building_id == "school":
			var sb := Button.new()
			sb.text = "Обучить: рекрут (2💰) / житель (1💰)"
			sb.pressed.connect(func() -> void: _train_school())
			info_panel.add_child(sb)
	elif s.get("kind") == "squad":
		var g := int(s.get("group", -1))
		var n := 0
		var hungry := 0
		if world != null:
			for u in (world as World).units:
				if is_instance_valid(u) and (u as Unit).team == 0 and (u as Unit).group_id == g:
					n += 1
					if (u as Unit).hunger < 35.0:
						hungry += 1
		selected_label.text = "⚔ Отряд #%d · бойцов: %d · голодных: %d" % [g, n, hungry]
		var feed := Button.new()
		feed.text = "🍞 Обеспечить продовольствием"
		feed.tooltip_text = "Слуги принесут еду к отряду. Голодные умирают!"
		feed.pressed.connect(func() -> void:
			if world != null:
				var w2 := world as World
				var need := 0
				for u in w2.units:
					if is_instance_valid(u) and (u as Unit).team == 0 and (u as Unit).group_id == g:
						need += 1
				var given := 0
				for food in ["bread", "sausage", "fish", "wine"]:
					while given < need and int(GameManager.store.get(food, 0)) > 0:
						GameManager.take_res(food, 1)
						given += 1
				for u in w2.units:
					if is_instance_valid(u) and (u as Unit).team == 0 and (u as Unit).group_id == g:
						(u as Unit).hunger = clampf((u as Unit).hunger + 60.0, 0.0, 100.0)
				if given < need:
					add_msg("Не хватило еды для солдат! (%d/%d)" % [given, need], "warn")
				else:
					add_msg("Отряд накормлен.", "info")
			AudioManager.play("eat"))
		info_panel.add_child(feed)
		var h2 := Label.new()
		h2.text = "ПКМ — движение/атака · Shift+ПКМ — штурм (пехота, с потерей управления)"
		h2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_panel.add_child(h2)

func _add_train_buttons(place: String) -> void:
	var ids: Array = []
	if place == "barracks":
		ids = ["militia", "footman", "swordsman", "scout", "knight", "bowman", "crossbowman", "spearman", "pikeman"]
	else:
		ids = ["bandit", "rebel", "squire", "warrior", "barbarian"]
	for sid in ids:
		var d := GameData.soldier(sid)
		var cost := "💰%d" % int(d.get("gold", 0)) if d.get("merc", false) else _equip_text(d)
		var b := Button.new()
		b.text = "%s (%s)" % [str(d.get("name", sid)), cost]
		b.tooltip_text = str(d.get("desc", ""))
		var ss := sid
		b.pressed.connect(func() -> void: _train(ss))
		info_panel.add_child(b)

func _equip_text(d: Dictionary) -> String:
	var parts: Array = []
	for k in (d.get("equip", {}) as Dictionary):
		parts.append("%s×%d" % [GameData.res_name(k), int(d["equip"][k])])
	return "+".join(parts)

func _train(sid: String) -> void:
	if not Military.train_soldier(sid):
		return
	AudioManager.play("gold")
	if world != null:
		var w := world as World
		var pos: Vector2 = w._tile_to_world(Vector2i(w.map_size / 2, w.map_size / 2 + 6))
		var u := w.spawn_unit(sid, pos + Vector2(randf_range(-50, 50), 30), 0, w.next_group)
		add_msg("Обучен: %s (отряд #%d)" % [str(GameData.soldier(sid).get("name", sid)), u.group_id], "info")

func _train_school() -> void:
	# упрощённо: золото → еда/слуги уже симулируются складом; даём рекрута-рекрута в казарму-очередь
	if GameManager.take_res("gold", 2):
		GameManager.add_res("bread", 0)
		AudioManager.play("gold")
		add_msg("Школа: новый рекрут готов (иди в казарму).", "info")
		if world != null:
			var w := world as World
			w.spawn_unit("militia", w._tile_to_world(Vector2i(w.map_size / 2, w.map_size / 2 + 6)), 0, w.next_group)
	else:
		add_msg("Нужно 2 золота для рекрута.", "warn")

func add_msg(text: String, kind := "info") -> void:
	if msg_box == null:
		return
	var col := {"info": "#e8d9a8", "warn": "#ffcf6e", "alarm": "#ff7b6e", "win": "#9fe8a8", "lose": "#ff7b6e", "brief": "#d7e8ff"}.get(kind, "#e8d9a8")
	msg_box.append_text("[color=%s]%s[/color]\n" % [col, text])

func _show_menu() -> void:
	var d := AcceptDialog.new()
	d.title = "Меню"
	d.dialog_text = "Миссия: %s-%d · Время %02d:%02d\nСлоты: 1–3 (сейвы в user://saves/)" % [GameManager.campaign.to_upper(), GameManager.mission_n, int(GameManager.game_time) / 60, int(GameManager.game_time) % 60]
	add_child(d)
	d.popup_centered(Vector2(420, 200))
	var w := world as World
	SaveManager.save_game(1, w)


class MiniMap extends Control:
	var hud = null
	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.04, 0.03))
		if hud == null or hud.world == null:
			return
		var w = hud.world
		if (w as World).map.is_empty():
			return
		var tiles: Array = (w as World).map["tiles"]
		var n: int = (w as World).map_size
		var cw := size.x / n
		var ch := size.y / n
		for y in n:
			for x in n:
				var v: int = (tiles[y] as Array)[x]
				draw_rect(Rect2(x * cw, y * ch, cw + 0.5, ch + 0.5), (w as World)._tile_color(v))
		for b in (w as World).buildings:
			if is_instance_valid(b):
				var bb = b
				var col := Color(0.3, 0.5, 1.0) if bb.team == 0 else Color(1.0, 0.3, 0.25)
				draw_rect(Rect2(bb.tile.x * cw - 1, bb.tile.y * ch - 1, 3, 3), col)
		for u in (w as World).units:
			if is_instance_valid(u):
				var uu = u
				if uu.kind == "soldier":
					var t := (w as World)._world_to_tile(uu.global_position)
					var col2 := Color(0.5, 0.8, 1.0) if uu.team == 0 else Color(1.0, 0.4, 0.3)
					draw_rect(Rect2(t.x * cw, t.y * ch, 2, 2), col2)
