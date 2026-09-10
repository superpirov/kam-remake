extends Node
## SaveManager: JSON-сейвы в user://saves/. Прогресс кампаний отдельно.

const SAVE_DIR := "user://saves"
const PROGRESS_FILE := "user://progress.json"
var progress := {"tsk": 1, "tpr": 1, "done": []}

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	load_progress()

func save_path(slot: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot]

func save_game(slot: int, world: Node) -> bool:
	var data := {
		"campaign": GameManager.campaign,
		"mission_n": GameManager.mission_n,
		"game_time": GameManager.game_time,
		"store": GameManager.store,
		"snapshot": world.call("get_snapshot") if world.has_method("get_snapshot") else {},
	}
	var f := FileAccess.open(save_path(slot), FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(JSON.stringify(data, "\t"))
	f.close()
	GameManager.add_message("Игра сохранена (слот %d)." % slot, "info")
	return true

func load_game(slot: int) -> Dictionary:
	if not FileAccess.file_exists(save_path(slot)):
		return {}
	var f := FileAccess.open(save_path(slot), FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	return data

func slot_info(slot: int) -> String:
	var d := load_game(slot)
	if d.is_empty():
		return "Пусто"
	return "%s-%d · %s" % [str(d.get("campaign", "?")).to_upper(), int(d.get("mission_n", 0)), _fmt_time(float(d.get("game_time", 0.0)))]

func _fmt_time(t: float) -> String:
	var m := int(t) / 60
	var s := int(t) % 60
	return "%02d:%02d" % [m, s]

func load_progress() -> void:
	if FileAccess.file_exists(PROGRESS_FILE):
		var f := FileAccess.open(PROGRESS_FILE, FileAccess.READ)
		progress = JSON.parse_string(f.get_as_text())
		f.close()

func mark_mission_done(campaign: String, n: int) -> void:
	var key := "%s%d" % [campaign, n]
	if not (progress["done"] as Array).has(key):
		(progress["done"] as Array).append(key)
	var cap := 20 if campaign == "tsk" else 14
	progress[campaign] = mini(cap, maxi(int(progress.get(campaign, 1)), n + 1))
	var f := FileAccess.open(PROGRESS_FILE, FileAccess.WRITE)
	f.store_string(JSON.stringify(progress, "\t"))
	f.close()
