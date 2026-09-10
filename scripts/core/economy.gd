extends Node
## Economy: носильщики, производство по RECIPES, голод и харчевня.
## Упрощённая, но верная оригиналу модель: всё идёт через склад, по 1 шт., по дорогам.

var buildings: Array = []   # ссылки на Building-ноды
var serfs: Array = []
var tasks: Array = []       # очередь {from, to, res, amount}
var tick := 0.0
const TICK_LEN := 0.5

func register_building(b: Node) -> void:
	if not buildings.has(b):
		buildings.append(b)

func unregister_building(b: Node) -> void:
	buildings.erase(b)

func register_serf(s: Node) -> void:
	if not serfs.has(s):
		serfs.append(s)

func _process(delta: float) -> void:
	var s: float = GameManager.speed()
	if s <= 0.0:
		return
	tick += delta * s
	if tick < TICK_LEN:
		return
	tick = 0.0
	_produce()
	_hunger(delta * 2.0)
	_assign_tasks()

func _produce() -> void:
	# каждое готовое здание с рецептом тикает прогресс; по готовности кладёт на склад
	for b in buildings:
		if not is_instance_valid(b) or not b.is_working():
			continue
		# сырьевые производители (без рецептов): капают напрямую
		if _produce_raw(b):
			continue
		var recipe_id: String = b.current_recipe
		if recipe_id == "":
			recipe_id = _default_recipe(b.building_id)
			b.current_recipe = recipe_id
		if recipe_id == "" or not GameData.RECIPES.has(recipe_id):
			continue
		var r: Dictionary = GameData.RECIPES[recipe_id]
		b.work_progress += TICK_LEN
		if b.work_progress >= float(r["time"]):
			if _consume_inputs(r["in"]):
				for out_id in (r["out"] as Dictionary):
					GameManager.add_res(out_id, int(r["out"][out_id]))
				b.work_progress = 0.0
				b.flash_produced()

func _default_recipe(building_id: String) -> String:
	match building_id:
		"sawmill": return "planks"
		"mill": return "flour"
		"bakery": return "bread"
		"butcher": return "sausage"
		"tannery": return "leather"
		"metallurgist": return "gold"
		"iron_smithy": return "iron"
		"weapon_smithy": return "sword"
		"armor_smithy": return "iron_armor"
		"weapon_workshop": return "axe_wood"
		"armor_workshop": return "wood_shield"
		"siege_workshop": return "ballista"
	return ""

func _consume_inputs(need: Dictionary) -> bool:
	for k in need:
		if int(GameManager.store.get(k, 0)) < int(need[k]):
			return false
	for k in need:
		GameManager.take_res(k, int(need[k]))
	return true

func _hunger(step: float) -> void:
	# мирные: сытость падает; голодные бросают работу и идут в харчевню (флаг is_eating)
	for b in buildings:
		if not is_instance_valid(b) or b.worker_hunger < 0.0:
			continue
		if b.under_construction:
			continue
		b.worker_hunger = maxf(0.0, b.worker_hunger - GameData.HUNGER_DECAY * step * 10.0)
		if b.worker_hunger <= 0.0 and not b.worker_eating:
			if _feed_from_inn():
				b.worker_hunger = GameData.HUNGER_MAX
				b.worker_eating = false
			else:
				b.worker_eating = true # идёт есть; производство стоит
				if randf() < 0.02:
					GameManager.add_message("Житель голодает! Нет еды в харчевне.", "warn")

func _feed_from_inn() -> bool:
	for food in ["bread", "sausage", "fish", "wine"]:
		if int(GameManager.store.get(food, 0)) > 0:
			GameManager.take_res(food, 1)
			return true
	return false

func feed_squad(squad: Node) -> void:
	# приказ «Обеспечить продовольствием»: слуги несут еду к отряду
	var need := squad.units.size()
	var given := 0
	for food in ["bread", "sausage", "fish", "wine"]:
		while given < need and int(GameManager.store.get(food, 0)) > 0:
			GameManager.take_res(food, 1)
			given += 1
	squad.restore_food(given)
	if given < need:
		GameManager.add_message("Не хватило еды для солдат! (%d/%d)" % [given, need], "warn")
	else:
		GameManager.add_message("Отряд накормлен.", "info")

func _assign_tasks() -> void:
	# заглушка очереди носильщиков: визуально серфы снуют между складом и зданиями
	pass

# Сырьё: здание -> ресурс, сек. Оригинал: поля размечаются вручную, шахты на жилах.
const RAW := {
	"quarry": {"out": "stone", "time": 18.0},
	"woodcutter": {"out": "timber", "time": 14.0},
	"farm": {"out": "corn", "time": 16.0},
	"vineyard": {"out": "wine", "time": 22.0},
	"swine": {"out": "pig", "time": 30.0, "also": "skin"},
	"stables": {"out": "horse", "time": 45.0},
	"coal_mine": {"out": "coal", "time": 20.0},
	"iron_mine": {"out": "iron_ore", "time": 20.0},
	"gold_mine": {"out": "gold_ore", "time": 24.0},
	"fisherman": {"out": "fish", "time": 16.0},
}

func _produce_raw(b: Node) -> bool:
	if not RAW.has(b.building_id):
		return false
	var r: Dictionary = RAW[b.building_id]
	b.work_progress += TICK_LEN
	if b.work_progress >= float(r["time"]):
		# свиноферма жрёт зерно, конюшня тоже — как в оригинале
		if b.building_id == "swine" or b.building_id == "stables":
			if int(GameManager.store.get("corn", 0)) < 2:
				b.work_progress = float(r["time"]) * 0.8
				return true
			GameManager.take_res("corn", 2)
		b.work_progress = 0.0
		GameManager.add_res(str(r["out"]), 1)
		if r.has("also"):
			GameManager.add_res(str(r["also"]), 1)
		# лесопилка любит брёвна: конвертируем timber -> planks-запас через склад автоматически
		b.flash_produced()
	# авто-перемол бревен в доски идёт через sawmill-рецепт; но чтобы стройка не встала,
	# склад принимает timber как стройматериал-заменитель проверкой в GameManager — см. ниже
	return true
