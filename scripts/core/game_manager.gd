extends Node
## GameManager (автозагрузка): состояние партии, скорость как в TPR (F8), пауза, победа/поражение.
## Сигналы смотрят HUD и мир.

signal resources_changed
signal speed_changed(value: float)
signal message_added(text: String, kind: String)
signal mission_finished(won: bool)
signal selection_changed

const SPEEDS := [0.0, 1.0, 2.0, 4.0]
const SPEED_NAMES := ["⏸", "x1", "x2", "x4"]

var campaign := "tsk"
var mission_n := 1
var mission: Dictionary = {}
var game_time := 0.0
var paused := false
var speed_idx := 1
var store: Dictionary = {}        # склад игрока: res_id -> кол-во
var selected: Dictionary = {}     # {kind: building/unit/squad, ref...}
var build_ghost := ""             # id здания-призрака
var objectives: Array = []
var enemy_left := 0
var fog_enabled := true
var fast_tooltip := ""

func speed() -> float:
	if paused:
		return 0.0
	return SPEEDS[speed_idx]

func start_mission(p_campaign: String, p_n: int) -> void:
	campaign = p_campaign
	mission_n = p_n
	mission = Campaigns.get_mission(campaign, mission_n)
	game_time = 0.0
	paused = false
	speed_idx = 1
	store = {"planks": 0, "stone": 0, "bread": 0, "sausage": 0, "wine": 0, "fish": 0,
		"timber": 0, "corn": 0, "gold": 0, "axe": 0, "bow": 0, "spear": 0, "sword": 0,
		"pike": 0, "crossbow": 0, "wood_shield": 0, "iron_shield": 0,
		"leather_armor": 0, "iron_armor": 0, "horse": 0, "coal": 0, "iron": 0}
	for k in (mission.get("start", {}) as Dictionary):
		store[k] = int(mission["start"][k])
	objectives = _make_objectives()
	enemy_left = int((mission.get("enemy", {}) as Dictionary).get("squads", 0)) * 6
	selected = {}
	build_ghost = ""
	add_message("Миссия %d: %s" % [mission_n, mission.get("name", "?")], "info")
	add_message(str(mission.get("brief", "")), "brief")
	resources_changed.emit()

func _make_objectives() -> Array:
	if mission.get("type", "peaceful") == "battle":
		return ["Уничтожьте всех солдат противника (%d осталось)" % enemy_left]
	return [
		"Развивайте город: дороги от склада, еда, школа",
		"Уничтожьте казармы, склады и школы врага",
		"Перебейте всех солдат врага",
		"Не потеряйте все свои склады!",
	]

func _process(delta: float) -> void:
	var s := speed()
	if s <= 0.0 or mission.is_empty():
		return
	game_time += delta * s
	if Input.is_action_just_pressed("toggle_speed"):
		cycle_speed()
	if Input.is_action_just_pressed("toggle_pause"):
		toggle_pause()

func add_res(id: String, n: int) -> void:
	store[id] = int(store.get(id, 0)) + n
	resources_changed.emit()

func take_res(id: String, n: int) -> bool:
	if int(store.get(id, 0)) < n:
		return false
	store[id] = int(store[id]) - n
	resources_changed.emit()
	return true

func can_afford(timber: int, stone: int) -> bool:
	# стройматериал: доски, но на старте засчитываем и брёвна (лесопилка перемелет)
	var wood: int = int(store.get("planks", 0)) + int(store.get("timber", 0))
	return wood >= timber and int(store.get("stone", 0)) >= stone

func pay_building(id: String) -> bool:
	var b := GameData.building(id)
	if b.is_empty():
		return false
	if not can_afford(int(b["timber"]), int(b["stone"])):
		add_message("Не хватает стройматериалов для: " + str(b["name"]), "warn")
		return false
	take_res("stone", int(b["stone"]))
	var rest: int = int(b["timber"])
	var from_planks: int = mini(rest, int(store.get("planks", 0)))
	take_res("planks", from_planks)
	rest -= from_planks
	if rest > 0:
		take_res("timber", rest)
	return true

func cycle_speed() -> void:
	# как F8 в TPR: x1 -> x2 -> x4 -> x1
	speed_idx = 1 + ((speed_idx) % 3)
	paused = false
	speed_changed.emit(speed())
	add_message("Скорость: " + SPEED_NAMES[speed_idx], "info")

func set_paused(v: bool) -> void:
	paused = v
	if v:
		speed_changed.emit(0.0)
	else:
		speed_changed.emit(speed())

func toggle_pause() -> void:
	set_paused(not paused)

func add_message(text: String, kind := "info") -> void:
	message_added.emit(text, kind)

func set_ghost(id: String) -> void:
	build_ghost = id
	selection_changed.emit()

func select(d: Dictionary) -> void:
	selected = d
	selection_changed.emit()

func on_enemy_killed(n := 1) -> void:
	enemy_left = maxi(0, enemy_left - n)
	if enemy_left <= 0:
		finish(true)

func on_all_storehouses_lost() -> void:
	finish(false)

func finish(won: bool) -> void:
	mission_finished.emit(won)
	if won:
		add_message("Победа! Миссия %d пройдена." % mission_n, "win")
		SaveManager.mark_mission_done(campaign, mission_n)
	else:
		add_message("Поражение... Склады потеряны или армия разбита.", "lose")
