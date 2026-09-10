class_name World
extends Node2D
## Мир: изометрия ромбами, камера, дороги, призрак стройки, выбор, волны ИИ.

const UnitScene := preload("res://scripts/world/unit.gd")
const BuildingScene := preload("res://scripts/world/building.gd")

var map: Dictionary = {}
var map_size := 72
var cam := Vector2.ZERO
var zoom := 1.0
var buildings: Array = []
var units: Array = []
var roads: Dictionary = {}  # Vector2i -> true
var hover_tile := Vector2i(-1, -1)
var selected_squad := -1
var next_group := 1
var dragging := false
var drag_button := MOUSE_BUTTON_MIDDLE

func _ready() -> void:
	var m: Dictionary = GameManager.mission
	map_size = int(m.get("map", 72))
	var seed_v := int(m.get("n", 1)) * 1000 + (7 if str(m.get("campaign", "tsk")) == "tpr" else 3)
	map = MapGenerator.generate(map_size, seed_v)
	cam = Vector2(map_size * 32.0, map_size * 16.0) / 2.0
	_setup_starting_base()
	AIDirector.setup_for_mission(m)
	set_process_input(true)

func _setup_starting_base() -> void:
	# штаб игрока: склад + пара зданий + стартовые отряды для боевых миссий
	var cx := map_size / 2
	var cy := map_size / 2 + 6
	_place_free("storehouse", Vector2i(cx, cy), 0, true)
	if GameManager.mission.get("type", "peaceful") == "peaceful":
		_place_free("school", Vector2i(cx - 4, cy + 2), 0, true)
		_place_free("inn", Vector2i(cx + 4, cy + 2), 0, true)
		_place_free("woodcutter", Vector2i(cx - 6, cy - 4), 0, true)
		_place_free("quarry", Vector2i(cx + 6, cy - 4), 0, true)
		_spawn_civilians()
	else:
		for sid in (GameManager.mission.get("army", []) as Array):
			spawn_unit(str(sid), _iso_to_world(Vector2(cx * 32, cy * 32)) + Vector2(randf_range(-60, 60), randf_range(-40, 40)), 0, 1)
	# вражеская декоративная база в углу
	var ex := map_size - 14
	var ey := 12
	_place_free("storehouse", Vector2i(ex, ey), 1, true)
	_place_free("barracks", Vector2i(ex - 5, ey + 2), 1, true)
	_place_free("school", Vector2i(ex + 3, ey + 4), 1, true)
	var towers: int = int((GameManager.mission.get("enemy", {}) as Dictionary).get("towers", 0))
	for i in towers:
		_place_free("tower", Vector2i(ex - 8 + i * 3, ey + 7), 1, true)

func _spawn_civilians() -> void:
	for i in 6:
		var u := Unit.new()
		u.setup("serf", 0, -1)
		u.kind = "serf"
		u.global_position = _iso_to_world(Vector2(map_size * 16, map_size * 8)) + Vector2(randf_range(-80, 80), randf_range(-40, 40))
		add_child(u)
		units.append(u)

func spawn_unit(sid: String, pos: Vector2, team: int, group := -1) -> Unit:
	var u := Unit.new()
	var g := group if group > 0 else (next_group if team == 0 else -2)
	if team == 0 and group < 0:
		g = next_group
	u.setup(sid, team, g)
	u.global_position = pos
	add_child(u)
	units.append(u)
	return u

func spawn_enemy_wave(comp: Array) -> void:
	var ex := (map_size - 14) * 32.0
	var ey := 12 * 16.0
	var p := _iso_to_world(Vector2(ex, ey))
	for sid in comp:
		spawn_unit(str(sid), p + Vector2(randf_range(-80, 80), randf_range(-60, 60)), 1, -2)
	# волна идёт к игроку
	for u in units:
		if u is Unit and (u as Unit).team == 1 and (u as Unit).move_target == Vector2.INF:
			(u as Unit).order_move(_iso_to_world(Vector2(map_size * 16, map_size * 8)))

# ---------- координаты ----------
func _iso_to_world(t: Vector2) -> Vector2:
	# t = тайл-пиксели (x*32, y*16) условно; ромб 64x32
	return Vector2((t.x - t.y), (t.x + t.y) * 0.5)

func _world_to_tile(w: Vector2) -> Vector2i:
	var p := (w - global_position)
	var fx := (p.x / 64.0 + p.y / 32.0)
	var fy := (p.y / 32.0 - p.x / 64.0)
	return Vector2i(int(round(fx)), int(round(fy)))

func _tile_to_world(t: Vector2i) -> Vector2:
	return _iso_to_world(Vector2(t.x * 32.0, t.y * 16.0))

# ---------- стройка ----------
func try_build(tile: Vector2i) -> void:
	var id := GameManager.build_ghost
	if id == "":
		return
	if not _tile_free(tile):
		GameManager.add_message("Здесь строить нельзя.", "warn")
		return
	if id == "road":
		if GameManager.take_res("stone", 0):
			roads[tile] = true
			AudioManager.play("build")
			queue_redraw()
		return
	if not GameManager.pay_building(id):
		return
	_place_free(id, tile, 0, false)
	AudioManager.play("build")
	if not Input.is_key_pressed(KEY_SHIFT):
		GameManager.set_ghost("")

func _tile_free(t: Vector2i) -> bool:
	if t.x < 2 or t.y < 2 or t.x >= map_size - 2 or t.y >= map_size - 2:
		return false
	var tiles: Array = map["tiles"]
	var v: int = (tiles[t.y] as Array)[t.x]
	if v == MapGenerator.T_WATER:
		return GameManager.build_ghost == "fisherman"
	for b in buildings:
		if is_instance_valid(b) and (b as Building).tile == t:
			return false
	return true

func _place_free(id: String, tile: Vector2i, team: int, instant: bool) -> Building:
	var b := Building.new()
	b.setup(id, tile, team)
	if instant:
		b.under_construction = false
		b.hp = b.max_hp
	b.global_position = _tile_to_world(tile)
	add_child(b)
	buildings.append(b)
	Economy.register_building(b)
	return b

func building_destroyed(b: Building) -> void:
	buildings.erase(b)
	Economy.unregister_building(b)
	var nid := b.building_id
	var was_player_store := b.team == 0 and nid == "storehouse"
	b.queue_free()
	GameManager.add_message("Здание уничтожено: " + str(GameData.building(nid).get("name", nid)), "alarm")
	if was_player_store and not _player_has("storehouse"):
		GameManager.on_all_storehouses_lost()
	_check_win()

func _player_has(id: String) -> bool:
	for b in buildings:
		if is_instance_valid(b) and (b as Building).team == 0 and (b as Building).building_id == id:
			return true
	return false

func unit_died(u: Unit, _from: Node = null) -> void:
	units.erase(u)
	var was_enemy := u.team == 1
	u.queue_free()
	if was_enemy:
		GameManager.on_enemy_killed(1)
	_check_win()

func _check_win() -> void:
	# победа мирной: у врага нет казарм+складов+школ и солдат почти нет
	var enemy_soldiers := 0
	var enemy_key := 0
	for u in units:
		if is_instance_valid(u) and (u as Unit).team == 1 and (u as Unit).kind == "soldier":
			enemy_soldiers += 1
	for b in buildings:
		if is_instance_valid(b) and (b as Building).team == 1:
			var bid := (b as Building).building_id
			if bid == "barracks" or bid == "storehouse" or bid == "school":
				enemy_key += 1
	if GameManager.mission.get("type", "peaceful") == "battle":
		if enemy_soldiers == 0:
			GameManager.finish(true)
	else:
		if enemy_soldiers <= 2 and enemy_key == 0:
			GameManager.finish(true)

# ---------- ввод ----------
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			zoom = clampf(zoom + 0.1, 0.5, 2.0)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			zoom = clampf(zoom - 0.1, 0.5, 2.0)
		elif mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_left_click(get_global_mouse_position())
		elif mb.button_index == MOUSE_BUTTON_RIGHT and mb.pressed:
			_right_click(get_global_mouse_position())
		elif mb.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = mb.pressed
	elif event is InputEventMouseMotion:
		hover_tile = _world_to_tile(get_global_mouse_position())
		if dragging:
			var mm := event as InputEventMouseMotion
			cam -= mm.relative / zoom
			queue_redraw()
		else:
			queue_redraw()

func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1
	if dir != Vector2.ZERO:
		cam += dir.normalized() * 600.0 * delta / zoom
		queue_redraw()
	_update_camera()

func _update_camera() -> void:
	var vp := get_viewport_rect().size
	var cams := get_tree().get_nodes_in_group("game_camera")
	if not cams.is_empty():
		var c: Camera2D = cams[0]
		c.position = cam
		c.zoom = Vector2(zoom, zoom)

func _left_click(w: Vector2) -> void:
	AudioManager.play("click")
	if GameManager.build_ghost != "":
		try_build(_world_to_tile(w))
		return
	# выбор: сначала юнит игрока, потом здание
	var best: Unit = null
	var bd := 34.0
	for u in units:
		if not is_instance_valid(u):
			continue
		var uu := u as Unit
		if uu.team != 0:
			continue
		var d := uu.global_position.distance_to(w)
		if d < bd:
			bd = d
			best = uu
	if best != null:
		selected_squad = best.group_id
		GameManager.select({"kind": "squad", "group": selected_squad})
		return
	var bb: Building = null
	var bd2 := 44.0
	for b in buildings:
		if not is_instance_valid(b):
			continue
		var d2 := (b as Building).global_position.distance_to(w)
		if d2 < bd2:
			bd2 = d2
			bb = b
	if bb != null:
		GameManager.select({"kind": "building", "node": bb})
	else:
		GameManager.select({})

func _right_click(w: Vector2) -> void:
	if GameManager.build_ghost != "":
		GameManager.set_ghost("")
		return
	if selected_squad < 0:
		return
	# приказ: атака по врагу или движение; Shift — штурм пехоты
	var target: Node2D = null
	var bd := 34.0
	for u in units:
		if not is_instance_valid(u):
			continue
		var uu := u as Unit
		if uu.team != 1:
			continue
		var d := uu.global_position.distance_to(w)
		if d < bd:
			bd = d
			target = uu
	for b in buildings:
		if not is_instance_valid(b):
			continue
		if (b as Building).team != 1:
			continue
		if (b as Building).global_position.distance_to(w) < 50.0:
			target = b
	var charging := Input.is_key_pressed(KEY_SHIFT)
	for u in units:
		if not is_instance_valid(u):
			continue
		var uu2 := u as Unit
		if uu2.team == 0 and uu2.group_id == selected_squad and uu2.kind == "soldier":
			if target != null:
				uu2.order_attack(target)
			elif charging:
				uu2.order_charge(w)
			else:
				uu2.order_move(w)

# ---------- отрисовка карты ----------
func _draw() -> void:
	if map.is_empty():
		return
	var tiles: Array = map["tiles"]
	var x0 := maxi(0, int(cam.x / 64.0) - 14)
	var y0 := maxi(0, int(cam.y / 32.0) - 16)
	var x1 := mini(map_size, x0 + 30)
	var y1 := mini(map_size, y0 + 34)
	for y in range(y0, y1):
		for x in range(x0, x1):
			var v: int = (tiles[y] as Array)[x]
			var p := _tile_to_world(Vector2i(x, y)) - global_position
			_draw_tile(p, v)
	# дороги
	for t in roads:
		var p2 := _tile_to_world(t) - global_position
		_draw_road(p2)
	# призрак
	if GameManager.build_ghost != "" and hover_tile.x >= 0:
		var gp := _tile_to_world(hover_tile) - global_position
		var ok := _tile_free(hover_tile)
		draw_colored_polygon(PackedVector2Array([gp + Vector2(0, -16), gp + Vector2(32, 0), gp + Vector2(0, 16), gp + Vector2(-32, 0)]),
			Color(0.2, 0.9, 0.2, 0.35) if ok else Color(0.9, 0.2, 0.2, 0.35))

func _tile_color(v: int) -> Color:
	match v:
		MapGenerator.T_FOREST: return Color(0.16, 0.35, 0.14)
		MapGenerator.T_STONE: return Color(0.5, 0.5, 0.52)
		MapGenerator.T_COAL: return Color(0.2, 0.2, 0.22)
		MapGenerator.T_IRON: return Color(0.5, 0.32, 0.2)
		MapGenerator.T_GOLD: return Color(0.6, 0.52, 0.2)
		MapGenerator.T_WATER: return Color(0.15, 0.3, 0.55)
		MapGenerator.T_FERTILE: return Color(0.35, 0.5, 0.2)
		MapGenerator.T_ROAD: return Color(0.45, 0.36, 0.24)
	return Color(0.3, 0.42, 0.2)

func _draw_tile(p: Vector2, v: int) -> void:
	var pts := PackedVector2Array([p + Vector2(0, -16), p + Vector2(32, 0), p + Vector2(0, 16), p + Vector2(-32, 0)])
	draw_colored_polygon(pts, _tile_color(v))
	draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[3], pts[0]]), Color(0, 0, 0, 0.18), 1.0)
	if v == MapGenerator.T_FOREST:
		draw_circle(p + Vector2(-8, -4), 7.0, Color(0.1, 0.28, 0.1))
		draw_circle(p + Vector2(8, -6), 8.0, Color(0.12, 0.32, 0.12))
	elif v == MapGenerator.T_WATER:
		draw_line(p + Vector2(-14, 0), p + Vector2(14, 0), Color(1, 1, 1, 0.25), 1.0)

func _draw_road(p: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([p + Vector2(0, -10), p + Vector2(20, 0), p + Vector2(0, 10), p + Vector2(-20, 0)]), Color(0.5, 0.4, 0.26))

func get_snapshot() -> Dictionary:
	var bs: Array = []
	for b in buildings:
		if is_instance_valid(b):
			var bb := b as Building
			bs.append({"id": bb.building_id, "t": [bb.tile.x, bb.tile.y], "team": bb.team, "hp": bb.hp, "done": not bb.under_construction})
	return {"buildings": bs, "store": GameManager.store, "time": GameManager.game_time, "roads": roads.keys()}
