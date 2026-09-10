extends Node
## AIDirector: как в кампании оригинала — база-декорация + выданные ресурсы + волны.
## Не строится с нуля: поддерживает армию и шлёт отряды по таймеру.

var wave_timer := 0.0
var wave_period := 150.0
var wave_size := 6
var max_waves := 6
var waves_sent := 0
var active := false
var enemy_comp: Array = ["militia", "footman", "bowman"]

func setup_for_mission(m: Dictionary) -> void:
	var e: Dictionary = m.get("enemy", {})
	var squads: int = int(e.get("squads", 2))
	max_waves = maxi(1, squads / 2)
	wave_size = 4 + mini(5, m.get("n", 1) / 2)
	wave_period = maxf(70.0, 170.0 - float(m.get("n", 1)) * 6.0)
	waves_sent = 0
	wave_timer = wave_period * 0.6
	active = true
	if int(m.get("n", 1)) >= 10:
		enemy_comp = ["footman", "swordsman", "spearman", "bowman", "crossbowman"]
	if int(m.get("n", 1)) >= 15:
		enemy_comp = ["swordsman", "knight", "pikeman", "crossbowman", "scout"]
	if str(m.get("campaign", "tsk")) == "tpr" and int(m.get("n", 1)) >= 7:
		enemy_comp = ["warrior", "barbarian", "squire", "pikeman", "crossbowman"]

func _process(delta: float) -> void:
	if not active:
		return
	var s: float = GameManager.speed()
	if s <= 0.0:
		return
	wave_timer -= delta * s
	if wave_timer <= 0.0 and waves_sent < max_waves:
		waves_sent += 1
		wave_timer = wave_period
		_emit_wave()

func _emit_wave() -> void:
	var world := get_tree().current_scene.get_node_or_null("World")
	if world == null or not world.has_method("spawn_enemy_wave"):
		return
	var comp: Array = []
	for i in wave_size:
		comp.append(enemy_comp[randi() % enemy_comp.size()])
	world.call("spawn_enemy_wave", comp)
	GameManager.add_message("Вражеский отряд наступает! (волна %d/%d)" % [waves_sent, max_waves], "alarm")
