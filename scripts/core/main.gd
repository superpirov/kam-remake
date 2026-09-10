extends Node
## Main: меню -> брифинг -> мир + HUD + камера. Точка входа scenes/main.tscn.

const MainMenu := preload("res://scripts/ui/main_menu.gd")
const Briefing := preload("res://scripts/ui/briefing.gd")
const Hud := preload("res://scripts/ui/hud.gd")

var menu: Control = null
var briefing: Control = null
var hud: CanvasLayer = null
var world: Node2D = null
var camera: Camera2D = null

func _ready() -> void:
	_show_menu()
	GameManager.mission_finished.connect(_on_mission_finished)

func _clear() -> void:
	for c in [menu, briefing, hud, world, camera]:
		if c != null and is_instance_valid(c):
			c.queue_free()
	menu = null
	briefing = null
	hud = null
	world = null
	camera = null

func _show_menu() -> void:
	_clear()
	menu = MainMenu.new()
	add_child(menu)
	menu.play_requested.connect(_on_play_requested)

func _on_play_requested(campaign: String, n: int) -> void:
	GameManager.start_mission(campaign, n)
	if menu != null:
		menu.queue_free()
		menu = null
	briefing = Briefing.new()
	add_child(briefing)
	briefing.show_mission(GameManager.mission)
	briefing.start_pressed.connect(_start_world)

func _start_world() -> void:
	if briefing != null:
		briefing.queue_free()
		briefing = null
	camera = Camera2D.new()
	camera.name = "GameCamera"
	camera.add_to_group("game_camera")
	camera.position_smoothing_enabled = true
	add_child(camera)
	world = World.new()
	world.name = "World"
	add_child(world)
	hud = Hud.new()
	add_child(hud)
	hud.attach(world)
	GameManager.add_message("Управление: ЛКМ выбор · ПКМ приказ · B стройка · R дорога · F8 скорость.", "brief")

func _on_mission_finished(won: bool) -> void:
	AudioManager.play("win" if won else "alarm")
	var d := AcceptDialog.new()
	d.title = "Победа!" if won else "Поражение"
	var nxt := ""
	if won:
		var cap := 20 if GameManager.campaign == "tsk" else 14
		if GameManager.mission_n < cap:
			nxt = "\nОткрыта следующая миссия."
	d.dialog_text = ("Миссия %d пройдена.%s" % [GameManager.mission_n, nxt]) if won else "Миссия провалена. Попробуйте другую тактику: еда, башни, контр-юниты."
	add_child(d)
	d.popup_centered(Vector2(460, 220))
	d.confirmed.connect(_show_menu)
	d.cancelled.connect(_show_menu)

func _unhandled_input(event: InputEvent) -> void:
	if world == null:
		return
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo:
		match (event as InputEventKey).keycode:
			KEY_B:
				if hud != null and hud.has_method("refresh_build"):
					GameManager.add_message("Вкладки стройки — внизу по центру. Кликните здание.", "info")
			KEY_R:
				GameManager.set_ghost("road")
			KEY_F8:
				GameManager.cycle_speed()
			KEY_ESCAPE:
				GameManager.set_ghost("")
				GameManager.select({})
